/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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
 */

// Only compile this code on Mac. These files should not be included on your iOS project.
// But in case they are included, it won't be compiled.
#import "../../ccMacros.h"
#ifdef __CC_PLATFORM_MAC

#import <sys/time.h>

#import "CCDirectorMac.h"
#import "CCGLView.h"
#import "CCWindow.h"

#import "../../CCNode.h"
#import "../../CCScene.h"
#import "../../CCScheduler.h"
#import "../../ccMacros.h"
#import "../../CCGLProgram.h"
#import "../../ccGLStateCache.h"

// external
#import "kazmath/kazmath.h"
#import "kazmath/GL/matrix.h"

#import "CCDirector_Private.h"

#pragma mark -
#pragma mark Director Mac extensions


@interface CCDirector ()
-(void) setNextScene;
-(void) showStats;
-(void) calculateDeltaTime;
-(void) calculateMPF;
@end

@implementation CCDirector (MacExtension)
-(CGPoint) convertEventToGL:(NSEvent*)event
{
	NSPoint point = [[self view] convertPoint:[event locationInWindow] fromView:nil];
	CGPoint p = NSPointToCGPoint(point);

	return  [(CCDirectorMac*)self convertToGL:p];
}

@end

#pragma mark -
#pragma mark Director Mac

@implementation CCDirectorMac

@synthesize isFullScreen = _isFullScreen;
@synthesize originalWinSizeInPoints = _originalWinSizeInPoints;

-(id) init
{
	if( (self = [super init]) ) {
		_isFullScreen = NO;
		_resizeMode = kCCDirectorResize_AutoScale;

		_originalWinSizeInPoints = CGSizeZero;
		_fullScreenWindow = nil;
		_windowGLView = nil;
		_winOffset = CGPointZero;
	}

	return self;
}


//
// setFullScreen code taken from GLFullScreen example by Apple
//
- (void) setFullScreen:(BOOL)fullscreen
{
//	_isFullScreen = !_isFullScreen;
//		
//	if (_isFullScreen)
//	{
//		[self.view enterFullScreenMode:[[self.view window] screen] withOptions:nil];
//	}
//	else
//	{
//		[self.view exitFullScreenModeWithOptions:nil];
//		[[self.view window] makeFirstResponder: self.view];
//	}
//	
//	return;

	// Mac OS X 10.6 and later offer a simplified mechanism to create full-screen contexts
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5

    if (_isFullScreen == fullscreen)
		return;

	CCGLView *openGLview = (CCGLView*) self.view;
    BOOL viewAcceptsTouchEvents = openGLview.acceptsTouchEvents;

    if( fullscreen ) {
        _originalWinRect = [openGLview frame];

        // Cache normal window and superview of openGLView
        if(!_windowGLView)
            _windowGLView = [openGLview window];

        _superViewGLView = [openGLview superview];


        // Get screen size
        NSRect displayRect = [[NSScreen mainScreen] frame];

        // Create a screen-sized window on the display you want to take over
        _fullScreenWindow = [[CCWindow alloc] initWithFrame:displayRect fullscreen:YES];

        // Remove glView from window
        [openGLview removeFromSuperview];

        // Set new frame
        [openGLview setFrame:displayRect];

        // Attach glView to fullscreen window
        [_fullScreenWindow setContentView:openGLview];

        // Show the fullscreen window
        [_fullScreenWindow makeKeyAndOrderFront:self];
		[_fullScreenWindow makeMainWindow];

    } else {

        // Remove glView from fullscreen window
        [openGLview removeFromSuperview];

        // Release fullscreen window
        _fullScreenWindow = nil;

        // Attach glView to superview
        [_superViewGLView addSubview:openGLview];

        // Set new frame
        [openGLview setFrame:_originalWinRect];

        // Show the window
        [_windowGLView makeKeyAndOrderFront:self];
		[_windowGLView makeMainWindow];
    }
	
	// issue #1189
	[_windowGLView makeFirstResponder:openGLview];

    _isFullScreen = fullscreen;

     // Retain +1

    // re-configure glView
    [self setView:openGLview];
    
    [openGLview setAcceptsTouchEvents:viewAcceptsTouchEvents];
    
     // Retain -1

    [openGLview setNeedsDisplay:YES];
#else
#error Full screen is not supported for Mac OS 10.5 or older yet
#error If you don't want FullScreen support, you can safely remove these 2 lines
#endif
}

-(void) setView:(CCGLView *)view
{
	if( view != __view) {

		[super setView:view];

		// cache the NSWindow and NSOpenGLView created from the NIB
		if( !_isFullScreen && CGSizeEqualToSize(_originalWinSizeInPoints, CGSizeZero))
		{
			_originalWinSizeInPoints = _winSizeInPoints;
		}
	}
}

-(int) resizeMode
{
	return _resizeMode;
}

-(void) setResizeMode:(int)mode
{
	if( mode != _resizeMode ) {

		_resizeMode = mode;

        [self setProjection:_projection];
        [self.view setNeedsDisplay: YES];
	}
}

-(void) setViewport
{
	CGPoint offset = CGPointZero;
	float widthAspect = _winSizeInPixels.width;
	float heightAspect = _winSizeInPixels.height;


	if( _resizeMode == kCCDirectorResize_AutoScale && ! CGSizeEqualToSize(_originalWinSizeInPoints, CGSizeZero ) ) {
		
		float aspect = _originalWinSizeInPoints.width / _originalWinSizeInPoints.height;
		widthAspect = _winSizeInPixels.width;
		heightAspect = _winSizeInPixels.width / aspect;
		
		if( heightAspect > _winSizeInPixels.height ) {
			widthAspect = _winSizeInPixels.height * aspect;
			heightAspect = _winSizeInPixels.height;
		}
		
		_winOffset.x = (_winSizeInPixels.width - widthAspect) / 2;
		_winOffset.y =  (_winSizeInPixels.height - heightAspect) / 2;
		
		offset = _winOffset;
	}

	glViewport(offset.x, offset.y, widthAspect, heightAspect);
}

-(void) setProjection:(CCDirectorProjection)projection
{
	CGSize size = _winSizeInPoints;
	if( _resizeMode == kCCDirectorResize_AutoScale && ! CGSizeEqualToSize(_originalWinSizeInPoints, CGSizeZero ) ) {
		size = _originalWinSizeInPoints;
	}

	[self setViewport];

	switch (projection) {
		case CCDirectorProjection2D:

			kmGLMatrixMode(KM_GL_PROJECTION);
			kmGLLoadIdentity();

			kmMat4 orthoMatrix;
			kmMat4OrthographicProjection(&orthoMatrix, 0, size.width, 0, size.height, -1024, 1024);
			kmGLMultMatrix( &orthoMatrix );

			kmGLMatrixMode(KM_GL_MODELVIEW);
			kmGLLoadIdentity();
			break;


		case CCDirectorProjection3D:
		{

			float zeye = [self getZEye];

			kmGLMatrixMode(KM_GL_PROJECTION);
			kmGLLoadIdentity();

			kmMat4 matrixPerspective, matrixLookup;

			// issue #1334
			kmMat4PerspectiveProjection( &matrixPerspective, 60, (GLfloat)size.width/size.height, 0.1f, MAX(zeye*2,1500) );
//			kmMat4PerspectiveProjection( &matrixPerspective, 60, (GLfloat)size.width/size.height, 0.1f, 1500);


			kmGLMultMatrix(&matrixPerspective);


			kmGLMatrixMode(KM_GL_MODELVIEW);
			kmGLLoadIdentity();
			kmVec3 eye, center, up;

			float eyeZ = size.height * zeye / size.height;

			kmVec3Fill( &eye, size.width/2, size.height/2, eyeZ );
			kmVec3Fill( &center, size.width/2, size.height/2, 0 );
			kmVec3Fill( &up, 0, 1, 0);
			kmMat4LookAt(&matrixLookup, &eye, &center, &up);
			kmGLMultMatrix(&matrixLookup);
			break;
		}

		case CCDirectorProjectionCustom:
			if( [_delegate respondsToSelector:@selector(updateProjection)] )
				[_delegate updateProjection];
			break;

		default:
			CCLOG(@"cocos2d: Director: unrecognized projection");
			break;
	}

	_projection = projection;

	ccSetProjectionMatrixDirty();
	[self createStatsLabel];
}


// If scaling is supported, then it should always return the original size
// otherwise it should return the "real" size.
-(CGSize) winSize
{
	if( _resizeMode == kCCDirectorResize_AutoScale )
		return _originalWinSizeInPoints;

	return _winSizeInPoints;
}

-(CGSize) winSizeInPixels
{
	return _winSizeInPixels;
}

-(CGFloat)flipY
{
	return 1.0;
}

//- (CGPoint) convertToLogicalCoordinates:(CGPoint)coords
//{
//	CGPoint ret;
//
//	if( _resizeMode == kCCDirectorResize_NoScale )
//		ret = coords;
//
//	else {
//
//		float x_diff = _originalWinSizeInPoints.width / (_winSizeInPixels.width - _winOffset.x * 2);
//		float y_diff = _originalWinSizeInPoints.height / (_winSizeInPixels.height - _winOffset.y * 2);
//
//		float adjust_x = (_winSizeInPixels.width * x_diff - _originalWinSizeInPoints.width ) / 2;
//		float adjust_y = (_winSizeInPixels.height * y_diff - _originalWinSizeInPoints.height ) / 2;
//
//		ret = CGPointMake( (x_diff * coords.x) - adjust_x, ( y_diff * coords.y ) - adjust_y );
//	}
//
//	return ret;
//}
//
//-(CGPoint)convertToGL:(CGPoint)uiPoint
//{
//    NSPoint point = [[self view] convertPoint:uiPoint fromView:nil];
//	CGPoint p = NSPointToCGPoint(point);
//    
//	return  [(CCDirectorMac*)self convertToLogicalCoordinates:p];
//}
//
//- (CGPoint) unConvertFromLogicalCoordinates:(CGPoint)coords
//{
//	CGPoint ret;
//	
//	if( _resizeMode == kCCDirectorResize_NoScale )
//		ret = coords;
//	
//	else {
//		
//		float x_diff = _originalWinSizeInPoints.width / (_winSizeInPixels.width - _winOffset.x * 2);
//		float y_diff = _originalWinSizeInPoints.height / (_winSizeInPixels.height - _winOffset.y * 2);
//		
//		float adjust_x = (_winSizeInPixels.width * x_diff - _originalWinSizeInPoints.width ) / 2;
//		float adjust_y = (_winSizeInPixels.height * y_diff - _originalWinSizeInPoints.height ) / 2;
//		
//		ret = CGPointMake(  (coords.x+ adjust_x)/x_diff, (coords.y +adjust_y)/y_diff );
//	}
//	
//	return ret;
//}
//
//- (CGPoint) convertToUI:(CGPoint)glPoint
//{
//	return [self unConvertFromLogicalCoordinates:glPoint];
//}

@end


#pragma mark -
#pragma mark DirectorDisplayLink


@implementation CCDirectorDisplayLink

- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime
{
    @autoreleasepool
    {
#if (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_DISPLAY_LINK_THREAD)
        if( ! _runningThread )
            _runningThread = [NSThread currentThread];

		[self drawScene];

		// Process timers and other events
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:nil];

			
#else
		[self performSelector:@selector(drawScene) onThread:_runningThread withObject:nil waitUntilDone:YES];
#endif

        return kCVReturnSuccess;
    }
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    CVReturn result = [(__bridge CCDirectorDisplayLink*)displayLinkContext getFrameForTime:outputTime];
    return result;
}

- (void) startAnimation
{
	[super startAnimation];
	
    if(_animating)
        return;

	CCLOG(@"cocos2d: startAnimation");
#if (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_OWN_THREAD)
	_runningThread = [[NSThread alloc] initWithTarget:self selector:@selector(mainLoop) object:nil];
	[_runningThread start];
#elif (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_MAIN_THREAD)
    _runningThread = [NSThread mainThread];
#endif

	gettimeofday( &_lastUpdate, NULL);

	// Create a display link capable of being used with all active displays
	CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);

	// Set the renderer output callback function
	CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, (__bridge void *)(self));

	// Set the display link for the current renderer
	CCGLView *openGLview = (CCGLView*) self.view;
	CGLContextObj cglContext = [[openGLview openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = [[openGLview pixelFormat] CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);

	// Activate the display link
	CVDisplayLinkStart(displayLink);
    
    _animating = YES;
}

- (void) stopAnimation
{
    if(!_animating)
        return;

	CCLOG(@"cocos2d: stopAnimation");

	if( displayLink ) {
		CVDisplayLinkStop(displayLink);
		CVDisplayLinkRelease(displayLink);
		displayLink = NULL;

#if CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_OWN_THREAD
		[_runningThread cancel];
		[_runningThread release];
		_runningThread = nil;
#elif (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_MAIN_THREAD)
        _runningThread = nil;
#endif
	}
    
    _animating = NO;
}

-(void) dealloc
{
	if( displayLink ) {
		CVDisplayLinkStop(displayLink);
		CVDisplayLinkRelease(displayLink);
	}
}

//
// Mac Director has its own thread
//
-(void) mainLoop
{
	while( ![[NSThread currentThread] isCancelled] ) {
		// There is no autorelease pool when this method is called because it will be called from a background thread
		// It's important to create one or you will leak objects
		@autoreleasepool {

			[[NSRunLoop currentRunLoop] run];

		}
	}
}

//
// Draw the Scene
//
- (void) drawScene
{
	/* calculate "global" dt */
	[self calculateDeltaTime];

	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously	when resizing

	[self.view lockOpenGLContext];

	/* tick before glClear: issue #533 */
	if( ! _isPaused )
		[_scheduler update: _dt];

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	/* to avoid flickr, nextScene MUST be here: after tick and before draw.
	 XXX: Which bug is this one. It seems that it can't be reproduced with v0.9 */
	if( _nextScene )
		[self setNextScene];

	kmGLPushMatrix();


	/* draw the scene */
	[_runningScene visit];

	/* draw the notification node */
	[_notificationNode visit];

	if( _displayStats )
		[self showStats];

	kmGLPopMatrix();

	_totalFrames++;
	

	// flush buffer
	[self.view.openGLContext flushBuffer];	

	[self.view unlockOpenGLContext];

	if( _displayStats )
		[self calculateMPF];
}

// set the event dispatcher
-(void) setView:(CCGLView *)view
{
	[super setView:view];

	// Synchronize buffer swaps with vertical refresh rate
	[[view openGLContext] makeCurrentContext];
	GLint swapInt = 1;
	[[view openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
}

@end

#endif // __CC_PLATFORM_MAC
