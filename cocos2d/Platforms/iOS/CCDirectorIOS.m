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
#import "glu.h"
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
-(void) showFPS;
-(void) calculateDeltaTime;
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
				
		// portrait mode default
		deviceOrientation_ = CCDeviceOrientationPortrait;
		
		__ccContentScaleFactor = 1;
		isContentScaleSupported_ = NO;
		
		kmMat4Identity( &portraitProjectionMatrix_ );
		
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
	
	[self applyOrientation];

	// By default enable VertexArray, ColorArray, TextureCoordArray and Texture2D
	CC_ENABLE_DEFAULT_GL_STATES();

	[runningScene_ visit];

	[notificationNode_ visit];

	if( displayFPS_ )
		[self showFPS];

	CC_DISABLE_DEFAULT_GL_STATES();

#if CC_ENABLE_PROFILERS
	[self showProfilers];
#endif
	
	kmGLPopMatrix();

	[openGLView_ swapBuffers];
}

-(void) setProjection:(ccDirectorProjection)projection
{
	CGSize size = winSizeInPixels_;
    
    if( CC_CONTENT_SCALE_FACTOR() != 1)
        glViewport(0, -size.height * CC_CONTENT_SCALE_FACTOR() / 2.0f, size.width * CC_CONTENT_SCALE_FACTOR(), size.height * CC_CONTENT_SCALE_FACTOR());
    else
        glViewport(0, 0, size.width, size.height);

	switch (projection) {
		case kCCDirectorProjection2D:
			kmGLMatrixMode(KM_GL_PROJECTION);
			kmGLLoadIdentity();

			kmMat4 orthoMatrix;
			kmMat4OrthographicProjection(&orthoMatrix, 0, size.height, -1024 * CC_CONTENT_SCALE_FACTOR(), 1024 * CC_CONTENT_SCALE_FACTOR(), -1024, 1024);
			kmGLMultMatrix( &orthoMatrix );

			kmGLMatrixMode(KM_GL_MODELVIEW);
			kmGLLoadIdentity();
			break;

		case kCCDirectorProjection3D:
		{
			float zeye = [self getZEye];

			kmMat4 matrixPerspective, matrixLookup;

			kmGLMatrixMode(KM_GL_PROJECTION);
			kmGLLoadIdentity();
			
			kmMat4PerspectiveProjection( &matrixPerspective, 60, (GLfloat)size.width/size.height, 0.5f, 1500.0f);
			kmGLMultMatrix(&matrixPerspective);
			
			kmGLMatrixMode(KM_GL_MODELVIEW);	
			kmGLLoadIdentity();
			kmVec3 eye, center, up;
			kmVec3Fill( &eye, size.width/2, size.height/2, zeye );
			kmVec3Fill( &center, size.width/2, size.height/2, 0 );
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

//-(kmMat4) applyOrientationToMatrix:(kmMat4*)inMatrix
//{
//	CGSize s = winSizeInPixels_;
//	float w = s.width / 2;
//	float h = s.height / 2;
//	
//	kmMat4 matA, matB, matC;
//	kmMat4 ret;
//	
//	switch ( deviceOrientation_ ) {
//		case kCCDeviceOrientationPortrait:
//			ret = portraitProjectionMatrix_;
//			break;
//
//		case kCCDeviceOrientationPortraitUpsideDown:
//			// upside down
//			kmMat4Translation(&matA, w, h, 0);
//			kmMat4RotationZ(&matB, CC_DEGREES_TO_RADIANS(180) );
//			kmMat4Translation(&matC, -w, -h, 0);
//			
//			kmMat4Multiply(&ret, inMatrix, &matA);
//			kmMat4Multiply(&ret, &ret, &matB);
//			kmMat4Multiply(&ret, &ret, &matC);			
//			break;
//
//		case kCCDeviceOrientationLandscapeRight:
//			kmMat4Translation(&matA, w, h, 0);
//			kmMat4RotationZ(&matB, CC_DEGREES_TO_RADIANS(90) );
//			kmMat4Translation(&matC, -h, -w, 0);
//			
//			kmMat4Multiply(&ret, inMatrix, &matA);
//			kmMat4Multiply(&ret, &ret, &matB);
//			kmMat4Multiply(&ret, &ret, &matC);
//			break;
//
//		case kCCDeviceOrientationLandscapeLeft:
//			kmMat4Translation(&matA, w, h, 0);
//			kmMat4RotationZ(&matB, CC_DEGREES_TO_RADIANS(-90) );
//			kmMat4Translation(&matC, -h, -w, 0);
//			
//			kmMat4Multiply(&ret, inMatrix, &matA);
//			kmMat4Multiply(&ret, &ret, &matB);
//			kmMat4Multiply(&ret, &ret, &matC);
//			break;
//	}
//	
//	return ret;
//}

-(void) applyOrientation
{	
	CGSize s = winSizeInPixels_;
	float w = s.width / 2;
	float h = s.height / 2;
	
	// XXX it's using hardcoded values.
	// What if the the screen size changes in the future?
	switch ( deviceOrientation_ ) {
		case CCDeviceOrientationPortrait:
			// nothing
			break;
		case CCDeviceOrientationPortraitUpsideDown:
			// upside down
			kmGLTranslatef(w,h,0);
			kmGLRotatef(180,0,0,1);
			kmGLTranslatef(-w,-h,0);
			break;
		case CCDeviceOrientationLandscapeRight:
			kmGLTranslatef(w,h,0);
			kmGLRotatef(90,0,0,1);
			kmGLTranslatef(-h,-w,0);
			break;
		case CCDeviceOrientationLandscapeLeft:
			kmGLTranslatef(w,h,0);
			kmGLRotatef(-90,0,0,1);
			kmGLTranslatef(-h,-w,0);
			break;
	}	
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
		CCLOG(@"cocos2d: 'setContentScaleFactor:' is not supported on this device");
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
	float newX = s.width - uiPoint.x;
	
	CGPoint ret = CGPointZero;
	switch ( deviceOrientation_) {
		case CCDeviceOrientationPortrait:
			ret = ccp( uiPoint.x, newY );
			break;
		case CCDeviceOrientationPortraitUpsideDown:
			ret = ccp(newX, uiPoint.y);
			break;
		case CCDeviceOrientationLandscapeLeft:
			ret.x = uiPoint.y;
			ret.y = uiPoint.x;
			break;
		case CCDeviceOrientationLandscapeRight:
			ret.x = newY;
			ret.y = newX;
			break;
	}
	return ret;
}

-(CGPoint)convertToUI:(CGPoint)glPoint
{
	CGSize winSize = winSizeInPoints_;
	int oppositeX = winSize.width - glPoint.x;
	int oppositeY = winSize.height - glPoint.y;
	CGPoint uiPoint = CGPointZero;
	switch ( deviceOrientation_) {
		case CCDeviceOrientationPortrait:
			uiPoint = ccp(glPoint.x, oppositeY);
			break;
		case CCDeviceOrientationPortraitUpsideDown:
			uiPoint = ccp(oppositeX, glPoint.y);
			break;
		case CCDeviceOrientationLandscapeLeft:
			uiPoint = ccp(glPoint.y, glPoint.x);
			break;
		case CCDeviceOrientationLandscapeRight:
			// Can't use oppositeX/Y because x/y are flipped
			uiPoint = ccp(winSize.width-glPoint.y, winSize.height-glPoint.x);
			break;
	}
	return uiPoint;
}

// get the current size of the glview
-(CGSize) winSize
{
	CGSize s = winSizeInPoints_;
	
    // swap x,y in landscape mode
	if( deviceOrientation_ == CCDeviceOrientationLandscapeLeft || deviceOrientation_ == CCDeviceOrientationLandscapeRight )
        CC_SWAP(s.width, s.height);

	return s;
}

-(CGSize) winSizeInPixels
{
	CGSize s = [self winSize];

	s.width *= CC_CONTENT_SCALE_FACTOR();
	s.height *= CC_CONTENT_SCALE_FACTOR();

	return s;
}

-(ccDeviceOrientation) deviceOrientation
{
	return deviceOrientation_;
}

- (void) setDeviceOrientation:(ccDeviceOrientation) orientation
{
	if( deviceOrientation_ != orientation ) {
		deviceOrientation_ = orientation;
		switch( deviceOrientation_) {
			case CCDeviceOrientationPortrait:
				[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait animated:NO];
				break;
			case CCDeviceOrientationPortraitUpsideDown:
				[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortraitUpsideDown animated:NO];
				break;
			case CCDeviceOrientationLandscapeLeft:
				[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight animated:NO];
				break;
			case CCDeviceOrientationLandscapeRight:
				[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeLeft animated:NO];
				break;
			default:
				NSLog(@"Director: Unknown device orientation");
				break;
		}
	}
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
