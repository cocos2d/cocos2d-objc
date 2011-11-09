/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import <unistd.h>

// cocos2d imports
#import "CCDirectorIOS.h"
#import "CCTouchDelegateProtocol.h"
#import "CCTouchDispatcher.h"
#import "../../CCScheduler.h"
#import "../../CCActionManager.h"
#import "../../CCTextureCache.h"
#import "../../ccMacros.h"
#import "../../CCScene.h"
#import "../../GLProgram.h"
#import "../../ccGLState.h"
#import "../../CCLayer.h"

// support imports
#import "../../Support/OpenGL_Internal.h"
#import "../../Support/CGPointExtension.h"
#import "../../Support/TransformUtils.h"

#import "kazmath/kazmath.h"
#import "kazmath/GL/matrix.h"

#if CC_ENABLE_PROFILERS
#import "../../Support/CCProfiling.h"
#endif


#pragma mark -
#pragma mark Director - global variables (optimization)

CGFloat	__ccContentScaleFactor = 1;

#pragma mark -
#pragma mark Director

@interface CCDirector ()
-(void) setNextScene;
-(void) showStats;
-(void) calculateDeltaTime;
-(void) calculateMPF;
@end

@implementation CCDirector (iOSExtensionClassMethods)

+(Class) defaultDirector
{
	return [CCDirectorDisplayLink class];
}
@end



#pragma mark -
#pragma mark CCDirectorIOS

@interface CCDirectorIOS ()
-(void) updateContentScaleFactor;
@end

@implementation CCDirectorIOS
- (id) init
{  
	if( (self=[super init]) ) {
				
		__ccContentScaleFactor = 1;
		isContentScaleSupported_ = NO;
		
		// running thread is main thread on iOS
		runningThread_ = [NSThread currentThread];
	}
	
	return self;
}

- (void) dealloc
{	
	[super dealloc];
}

//
// Draw the Scene
//
- (void) drawScene
{    
	/* calculate "global" dt */
	[self calculateDeltaTime];
	
	/* tick before glClear: issue #533 */
	if( ! isPaused_ )
		[[CCScheduler sharedScheduler] tick: dt];	

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	/* to avoid flickr, nextScene MUST be here: after tick and before draw.
	 XXX: Which bug is this one. It seems that it can't be reproduced with v0.9 */
	if( nextScene_ )
		[self setNextScene];

	kmGLPushMatrix();

	[runningScene_ visit];

	[notificationNode_ visit];

	if( displayStats_ )
		[self showStats];

	kmGLPopMatrix();

	totalFrames_++;

	[openGLView_ swapBuffers];
	
	if( displayStats_ == kCCDirectorStatsMPF )
		[self calculateMPF];
}

-(void) setProjection:(ccDirectorProjection)projection
{
	CGSize size = winSizeInPixels_;
	CGSize sizePoint = winSizeInPoints_;

	glViewport(0, 0, size.width * CC_CONTENT_SCALE_FACTOR(), size.height * CC_CONTENT_SCALE_FACTOR() );

	switch (projection) {
		case kCCDirectorProjection2D:
			
			kmGLMatrixMode(KM_GL_PROJECTION);
			kmGLLoadIdentity();

			kmMat4 orthoMatrix;
			kmMat4OrthographicProjection(&orthoMatrix, 0, size.width, 0, size.height, -1024, 1024 );
			kmGLMultMatrix( &orthoMatrix );

			kmGLMatrixMode(KM_GL_MODELVIEW);
			kmGLLoadIdentity();
			break;

		case kCCDirectorProjection3D:
		{
			// reset the viewport if 3d proj & retina display
			if( CC_CONTENT_SCALE_FACTOR() != 1 )
				glViewport(-size.width/2, -size.height/2, size.width * CC_CONTENT_SCALE_FACTOR(), size.height * CC_CONTENT_SCALE_FACTOR() );
	
			float zeye = [self getZEye];

			kmMat4 matrixPerspective, matrixLookup;

			kmGLMatrixMode(KM_GL_PROJECTION);
			kmGLLoadIdentity();
			
			kmMat4PerspectiveProjection( &matrixPerspective, 60, (GLfloat)sizePoint.width/sizePoint.height, 0.5f, 1500.0f );
			kmGLMultMatrix(&matrixPerspective);
			
			kmGLMatrixMode(KM_GL_MODELVIEW);
			kmGLLoadIdentity();
			kmVec3 eye, center, up;
			kmVec3Fill( &eye, sizePoint.width/2, sizePoint.height/2, zeye );
			kmVec3Fill( &center, sizePoint.width/2, sizePoint.height/2, 0 );
			kmVec3Fill( &up, 0, 1, 0);
			kmMat4LookAt(&matrixLookup, &eye, &center, &up);
			kmGLMultMatrix(&matrixLookup);
			break;
		}
			
		case kCCDirectorProjectionCustom:
			if( projectionDelegate_ )
				[projectionDelegate_ updateProjection];
			break;

		default:
			CCLOG(@"cocos2d: Director: unrecognized projecgtion");
			break;
	}
	
	projection_ = projection;
	
	ccSetProjectionMatrixDirty();
}

#pragma mark Director Integration with a UIKit view

-(void) setOpenGLView:(EAGLView *)view
{
	if( view != openGLView_ ) {

		[super setOpenGLView:view];

		// set size
		winSizeInPixels_ = CGSizeMake(winSizeInPoints_.width * __ccContentScaleFactor, winSizeInPoints_.height *__ccContentScaleFactor);
		
		if( __ccContentScaleFactor != 1 )
			[self updateContentScaleFactor];
		
		CCTouchDispatcher *touchDispatcher = [CCTouchDispatcher sharedDispatcher];
		[openGLView_ setTouchDelegate: touchDispatcher];
		[touchDispatcher setDispatchEvents: YES];
	}
}

#pragma mark Director - Retina Display

-(CGFloat) contentScaleFactor
{
	return __ccContentScaleFactor;
}

-(void) setContentScaleFactor:(CGFloat)scaleFactor
{
	if( scaleFactor != __ccContentScaleFactor ) {
		
		__ccContentScaleFactor = scaleFactor;
		winSizeInPixels_ = CGSizeMake( winSizeInPoints_.width * scaleFactor, winSizeInPoints_.height * scaleFactor );
		
		if( openGLView_ )
			[self updateContentScaleFactor];
		
		// update projection
		[self setProjection:projection_];
	}
}

-(void) updateContentScaleFactor
{
	// Based on code snippet from: http://developer.apple.com/iphone/prerelease/library/snippets/sp2010/sp28.html
	if ([openGLView_ respondsToSelector:@selector(setContentScaleFactor:)])
	{			
		[openGLView_ setContentScaleFactor: __ccContentScaleFactor];
		
		isContentScaleSupported_ = YES;
	}
	else
	{
		CCLOG(@"cocos2d: WARNING: calling setContentScaleFactor on iOS < 4. Using fallback mechanism");		
		isContentScaleSupported_ = NO;
	}
}

-(BOOL) enableRetinaDisplay:(BOOL)enabled
{
	// Already enabled ?
	if( enabled && __ccContentScaleFactor == 2 )
		return YES;
	
	// Already disabled
	if( ! enabled && __ccContentScaleFactor == 1 )
		return YES;

	// setContentScaleFactor is not supported
	if (! [openGLView_ respondsToSelector:@selector(setContentScaleFactor:)])
		return NO;

	// SD device
	if ([[UIScreen mainScreen] scale] == 1.0)
		return NO;

	float newScale = enabled ? 2 : 1;
	[self setContentScaleFactor:newScale];
	
	// Load Hi-Res FPS label
	[self createFPSLabel];
	
	return YES;
}

// overriden, don't call super
-(void) reshapeProjection:(CGSize)size
{
	winSizeInPoints_ = [openGLView_ bounds].size;
	winSizeInPixels_ = CGSizeMake(winSizeInPoints_.width * __ccContentScaleFactor, winSizeInPoints_.height *__ccContentScaleFactor);
	
	[self setProjection:projection_];
}

#pragma mark Director Scene Landscape

-(CGPoint)convertToGL:(CGPoint)uiPoint
{
	CGSize s = winSizeInPoints_;
	float newY = s.height - uiPoint.y;
	
	return ccp( uiPoint.x, newY );
}

-(CGPoint)convertToUI:(CGPoint)glPoint
{
	CGSize winSize = winSizeInPoints_;
	int oppositeY = winSize.height - glPoint.y;
	
	return ccp(glPoint.x, oppositeY);
}


-(void) end
{
	// don't release the event handlers
	// They are needed in case the director is run again
	[[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
	
	[super end];
}

@end


#pragma mark -
#pragma mark DirectorDisplayLink

@implementation CCDirectorDisplayLink

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	animationInterval_ = interval;
	if(displayLink){
		[self stopAnimation];
		[self startAnimation];
	}
}

- (void) startAnimation
{
	NSAssert( displayLink == nil, @"displayLink must be nil. Calling startAnimation twice?");

	if ( gettimeofday( &lastUpdate_, NULL) != 0 ) {
		CCLOG(@"cocos2d: DisplayLinkDirector: Error on gettimeofday");
	}
	
	// approximate frame rate
	// assumes device refreshes at 60 fps
	int frameInterval = (int) floor(animationInterval_ * 60.0f);
	
	CCLOG(@"cocos2d: Frame interval: %d", frameInterval);

	displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(mainLoop:)];
	[displayLink setFrameInterval:frameInterval];
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];	
}

-(void) mainLoop:(id)sender
{
	[self drawScene];	
}

- (void) stopAnimation
{
	[displayLink invalidate];
	displayLink = nil;
}

-(void) dealloc
{
	[displayLink release];
	[super dealloc];
}
@end

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
