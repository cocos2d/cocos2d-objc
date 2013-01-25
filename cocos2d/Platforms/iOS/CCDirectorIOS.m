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
#import "../../ccMacros.h"
#ifdef __CC_PLATFORM_IOS

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
#import "../../CCGLProgram.h"
#import "../../ccGLStateCache.h"
#import "../../CCLayer.h"
#import "../../ccFPSImages.h"
#import "../../CCConfiguration.h"

// support imports
#import "../../Support/OpenGL_Internal.h"
#import "../../Support/CGPointExtension.h"
#import "../../Support/TransformUtils.h"
#import "../../Support/CCFileUtils.h"

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

-(void) setInterfaceOrientationDelegate:(id)delegate
{
	// override me
}

-(CCTouchDispatcher*) touchDispatcher
{
	return nil;
}

-(void) setTouchDispatcher:(CCTouchDispatcher*)touchDispatcher
{
	//
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
		_isContentScaleSupported = NO;

		_touchDispatcher = [[CCTouchDispatcher alloc] init];

		// running thread is main thread on iOS
		_runningThread = [NSThread currentThread];
		
		// Apparently it comes with a default view, and we don't want it
//		[self setView:nil];
	}

	return self;
}

- (void) dealloc
{
	[_touchDispatcher release];

	[super dealloc];
}

//
// Draw the Scene
//
- (void) drawScene
{
	/* calculate "global" dt */
	[self calculateDeltaTime];

	CCGLView *openGLview = (CCGLView*)[self view];

	[EAGLContext setCurrentContext: [openGLview context]];

	/* tick before glClear: issue #533 */
	if( ! _isPaused )
		[_scheduler update: _dt];

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	/* to avoid flickr, nextScene MUST be here: after tick and before draw.
	 XXX: Which bug is this one. It seems that it can't be reproduced with v0.9 */
	if( _nextScene )
		[self setNextScene];

	kmGLPushMatrix();

	[_runningScene visit];

	[_notificationNode visit];

	if( _displayStats )
		[self showStats];

	kmGLPopMatrix();

	_totalFrames++;

	[openGLview swapBuffers];

	if( _displayStats )
		[self calculateMPF];
}

-(void) setViewport
{
	CGSize size = _winSizeInPixels;
	glViewport(0, 0, size.width, size.height );
}

-(void) setProjection:(ccDirectorProjection)projection
{
	CGSize size = _winSizeInPixels;
	CGSize sizePoint = _winSizeInPoints;
    
	[self setViewport];

	switch (projection) {
		case kCCDirectorProjection2D:

			kmGLMatrixMode(KM_GL_PROJECTION);
			kmGLLoadIdentity();

			kmMat4 orthoMatrix;
			kmMat4OrthographicProjection(&orthoMatrix, 0, size.width / CC_CONTENT_SCALE_FACTOR(), 0, size.height / CC_CONTENT_SCALE_FACTOR(), -1024, 1024 );
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

			// issue #1334
			kmMat4PerspectiveProjection( &matrixPerspective, 60, (GLfloat)size.width/size.height, 0.1f, zeye*2);
//			kmMat4PerspectiveProjection( &matrixPerspective, 60, (GLfloat)size.width/size.height, 0.1f, 1500);

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
			if( [_delegate respondsToSelector:@selector(updateProjection)] )
				[_delegate updateProjection];
			break;

		default:
			CCLOG(@"cocos2d: Director: unrecognized projection");
			break;
	}

	_projection = projection;

	ccSetProjectionMatrixDirty();
}

// override default logic
- (void)runWithScene:(CCScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
	NSAssert(_runningScene == nil, @"This command can only be used to start the CCDirector. There is already a scene present.");
	
	[self pushScene:scene];

	NSThread *thread = [self runningThread];
	[self performSelector:@selector(drawScene) onThread:thread withObject:nil waitUntilDone:YES];
}

#pragma mark Director - TouchDispatcher

-(CCTouchDispatcher*) touchDispatcher
{
	return _touchDispatcher;
}

-(void) setTouchDispatcher:(CCTouchDispatcher*)touchDispatcher
{
	if( touchDispatcher != _touchDispatcher ) {
		[_touchDispatcher release];
		_touchDispatcher = [touchDispatcher retain];
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
		_winSizeInPixels = CGSizeMake( _winSizeInPoints.width * scaleFactor, _winSizeInPoints.height * scaleFactor );

		if( __view )
			[self updateContentScaleFactor];

		// update projection
		[self setProjection:_projection];
	}
}

-(void) updateContentScaleFactor
{
	NSAssert( [__view respondsToSelector:@selector(setContentScaleFactor:)], @"cocos2d v2.0+ runs on iOS 4 or later");

	[__view setContentScaleFactor: __ccContentScaleFactor];
	_isContentScaleSupported = YES;
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
	if (! [__view respondsToSelector:@selector(setContentScaleFactor:)])
		return NO;

	// SD device
	if ([[UIScreen mainScreen] scale] == 1.0)
		return NO;

	float newScale = enabled ? 2 : 1;
	[self setContentScaleFactor:newScale];

	// Load Hi-Res FPS label
	[[CCFileUtils sharedFileUtils] buildSearchResolutionsOrder];
	[self createStatsLabel];

	return YES;
}

// overriden, don't call super
-(void) reshapeProjection:(CGSize)size
{
	_winSizeInPoints = [__view bounds].size;
	_winSizeInPixels = CGSizeMake(_winSizeInPoints.width * __ccContentScaleFactor, _winSizeInPoints.height *__ccContentScaleFactor);

	[self setProjection:_projection];
  
	if( [_delegate respondsToSelector:@selector(directorDidReshapeProjection:)] )
		[_delegate directorDidReshapeProjection:self];
}

static void
GLToClipTransform(kmMat4 *transformOut)
{
	kmMat4 projection;
	kmGLGetMatrix(KM_GL_PROJECTION, &projection);
	
	kmMat4 modelview;
	kmGLGetMatrix(KM_GL_MODELVIEW, &modelview);
	
	kmMat4Multiply(transformOut, &projection, &modelview);
}

#pragma mark Director Point Convertion

-(CGPoint)convertToGL:(CGPoint)uiPoint
{
	kmMat4 transform;
	GLToClipTransform(&transform);
	
	kmMat4 transformInv;
	kmMat4Inverse(&transformInv, &transform);
	
	// Calculate z=0 using -> transform*[0, 0, 0, 1]/w
	kmScalar zClip = transform.mat[14]/transform.mat[15];
	
	CGSize glSize = __view.bounds.size;
	kmVec3 clipCoord = {2.0*uiPoint.x/glSize.width - 1.0, 1.0 - 2.0*uiPoint.y/glSize.height, zClip};
	
	kmVec3 glCoord;
	kmVec3TransformCoord(&glCoord, &clipCoord, &transformInv);
	
//	NSLog(@"uiPoint: %@, glPoint: %@", NSStringFromCGPoint(uiPoint), NSStringFromCGPoint(ccp(glCoord.x, glCoord.y)));
	return ccp(glCoord.x, glCoord.y);
}

-(CGPoint)convertTouchToGL:(UITouch*)touch
{
	CGPoint uiPoint = [touch locationInView: [touch view]];
	return [self convertToGL:uiPoint];
}


-(CGPoint)convertToUI:(CGPoint)glPoint
{
	kmMat4 transform;
	GLToClipTransform(&transform);
		
	kmVec3 clipCoord;
	// Need to calculate the zero depth from the transform.
	kmVec3 glCoord = {glPoint.x, glPoint.y, 0.0};
	kmVec3TransformCoord(&clipCoord, &glCoord, &transform);
	
	CGSize glSize = __view.bounds.size;
	return ccp(glSize.width*(clipCoord.x*0.5 + 0.5), glSize.height*(-clipCoord.y*0.5 + 0.5));
}

-(void) end
{
	// don't release the event handlers
	// They are needed in case the director is run again
	[_touchDispatcher removeAllDelegates];

	[super end];
}

#pragma mark Director - UIViewController delegate


-(void) setView:(CCGLView *)view
{
	if( view != __view) {
		[super setView:view];

		if( view ) {
			// set size
			_winSizeInPixels = CGSizeMake(_winSizeInPoints.width * __ccContentScaleFactor, _winSizeInPoints.height *__ccContentScaleFactor);

			if( __ccContentScaleFactor != 1 )
				[self updateContentScaleFactor];

			[view setTouchDelegate: _touchDispatcher];
			[_touchDispatcher setDispatchEvents: YES];
		}
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	BOOL ret =YES;
	if( [_delegate respondsToSelector:_cmd] )
		ret = (BOOL) [_delegate shouldAutorotateToInterfaceOrientation:interfaceOrientation];

	return ret;
}

// Commented. See issue #1453 for further info: http://code.google.com/p/cocos2d-iphone/issues/detail?id=1453
//-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//	if( [_delegate respondsToSelector:_cmd] )
//		[_delegate willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//}


-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self startAnimation];
}

-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
//	[self startAnimation];
}

-(void) viewWillDisappear:(BOOL)animated
{
//	[self stopAnimation];

	[super viewWillDisappear:animated];
}

-(void) viewDidDisappear:(BOOL)animated
{
	[self stopAnimation];

	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
	// Release any cached data, images, etc that aren't in use.
	[super purgeCachedData];

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

-(void) viewDidLoad
{
	CCLOG(@"cocos2d: viewDidLoad");

	[super viewDidLoad];
}


- (void)viewDidUnload
{
	CCLOG(@"cocos2d: viewDidUnload");

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark helper

-(void)getFPSImageData:(unsigned char**)datapointer length:(NSUInteger*)len
{
	int device = [[CCConfiguration sharedConfiguration] runningDevice];

	if( device == kCCDeviceiPadRetinaDisplay) {
		*datapointer = cc_fps_images_ipadhd_png;
		*len = cc_fps_images_ipadhd_len();
		
	} else if( device == kCCDeviceiPhoneRetinaDisplay || device == kCCDeviceiPhone5RetinaDisplay ) {
		*datapointer = cc_fps_images_hd_png;
		*len = cc_fps_images_hd_len();

	} else {
		*datapointer = cc_fps_images_png;
		*len = cc_fps_images_len();
	}
}

@end


#pragma mark -
#pragma mark DirectorDisplayLink

@implementation CCDirectorDisplayLink


-(void) mainLoop:(id)sender
{
	[self drawScene];
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	_animationInterval = interval;
	if(_displayLink){
		[self stopAnimation];
		[self startAnimation];
	}
}

- (void) startAnimation
{
	[super startAnimation];

    if(_isAnimating)
        return;

	gettimeofday( &_lastUpdate, NULL);

	// approximate frame rate
	// assumes device refreshes at 60 fps
	int frameInterval = (int) floor(_animationInterval * 60.0f);

	CCLOG(@"cocos2d: animation started with frame interval: %.2f", 60.0f/frameInterval);

	_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(mainLoop:)];
	[_displayLink setFrameInterval:frameInterval];

#if CC_DIRECTOR_IOS_USE_BACKGROUND_THREAD
	//
	_runningThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMainLoop) object:nil];
	[_runningThread start];

#else
	// setup DisplayLink in main thread
	[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
#endif

    _isAnimating = YES;
}

- (void) stopAnimation
{
    if(!_isAnimating)
        return;

	CCLOG(@"cocos2d: animation stopped");

#if CC_DIRECTOR_IOS_USE_BACKGROUND_THREAD
	[_runningThread cancel];
	[_runningThread release];
	_runningThread = nil;
#endif

	[_displayLink invalidate];
	_displayLink = nil;
    _isAnimating = NO;
}

// Overriden in order to use a more stable delta time
-(void) calculateDeltaTime
{
    // New delta time. Re-fixed issue #1277
    if( _nextDeltaTimeZero || _lastDisplayTime==0 ) {
        _dt = 0;
        _nextDeltaTimeZero = NO;
    } else {
        _dt = _displayLink.timestamp - _lastDisplayTime;
        _dt = MAX(0,_dt);
    }
    // Store this timestamp for next time
    _lastDisplayTime = _displayLink.timestamp;

	// needed for SPF
	if( _displayStats )
		gettimeofday( &_lastUpdate, NULL);

#ifdef DEBUG
	// If we are debugging our code, prevent big delta time
	if( _dt > 0.2f )
		_dt = 1/60.0f;
#endif
}


#pragma mark Director Thread

//
// Director has its own thread
//
-(void) threadMainLoop
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

	// start the run loop
	[[NSRunLoop currentRunLoop] run];

	[pool release];
}

-(void) dealloc
{
	[_displayLink release];
	[super dealloc];
}
@end

#endif // __CC_PLATFORM_IOS
