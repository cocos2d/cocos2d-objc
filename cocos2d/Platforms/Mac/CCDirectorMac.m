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
#if __CC_PLATFORM_MAC

#import <sys/time.h>

#import "CCDirectorMac.h"
#import "CCWindow.h"

#import "../../CCNode.h"
#import "../../CCScene.h"
#import "../../CCScheduler.h"
#import "../../ccMacros.h"
#import "../../CCShader.h"
#import "../../ccFPSImages.h"
 

#import "CCDirector_Private.h"
#import "CCRenderer_Private.h"
#import "CCRenderDispatch.h"

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

    CC_VIEW<CCDirectorView> *view = self.view;
    BOOL viewAcceptsTouchEvents = view.acceptsTouchEvents;

    if( fullscreen ) {
        _originalWinRect = [view frame];

        // Cache normal window and superview of openGLView
        if(!_windowGLView)
            _windowGLView = [view window];

        _superViewGLView = [view superview];


        // Get screen size
        NSRect displayRect = [[NSScreen mainScreen] frame];

        // Create a screen-sized window on the display you want to take over
        _fullScreenWindow = [[CCWindow alloc] initWithFrame:displayRect fullscreen:YES];

        // Remove glView from window
        [view removeFromSuperview];

        // Set new frame
        [view setFrame:displayRect];

        // Attach glView to fullscreen window
        [_fullScreenWindow setContentView:view];

        // Show the fullscreen window
        [_fullScreenWindow makeKeyAndOrderFront:self];
        [_fullScreenWindow makeMainWindow];
        // issue #632
        self.view.wantsBestResolutionOpenGLSurface = NO;


    } else {

        // Remove glView from fullscreen window
        [view removeFromSuperview];

        // Release fullscreen window
        _fullScreenWindow = nil;

        // Attach glView to superview
        [_superViewGLView addSubview:view];

        // Set new frame
        [view setFrame:_originalWinRect];

        // Show the window
        [_windowGLView makeKeyAndOrderFront:self];
        [_windowGLView makeMainWindow];
        // issue #632
        self.view.wantsBestResolutionOpenGLSurface = YES;

    }
	
	// issue #1189
	[_windowGLView makeFirstResponder:view];

    _isFullScreen = fullscreen;

     // Retain +1

    // re-configure glView
    [self setView:view];
    
    [view setAcceptsTouchEvents:viewAcceptsTouchEvents];
    
     // Retain -1

    [view setNeedsDisplay:YES];
#else
#error Full screen is not supported for Mac OS 10.5 or older yet
#error If you don't want FullScreen support, you can safely remove these 2 lines
#endif
}

-(void) setView:(CC_VIEW<CCDirectorView> *)view
{
		[super setView:view];

		// cache the NSWindow and NSOpenGLView created from the NIB
		if( !_isFullScreen && CGSizeEqualToSize(_originalWinSizeInPoints, CGSizeZero))
		{
			_originalWinSizeInPoints = _winSizeInPoints;
		}
}

- (CGFloat)deviceContentScaleFactor {
    if (self.view) {
        NSRect backingBounds = [self.view convertRectToBacking:[self.view bounds]];
        
        return backingBounds.size.width / self.view.bounds.size.width;
    }
    
    return 1.0;
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
	
	CCRenderDispatch(NO, ^{
		glViewport(offset.x, offset.y, widthAspect, heightAspect);
	});
}

-(void) setProjection:(CCDirectorProjection)projection
{
	CGSize sizePoint = _winSizeInPoints;
	if( _resizeMode == kCCDirectorResize_AutoScale && ! CGSizeEqualToSize(_originalWinSizeInPoints, CGSizeZero ) ) {
		sizePoint = _originalWinSizeInPoints;
	}

	[self setViewport];

	switch (projection) {
		case CCDirectorProjection2D:
			_projectionMatrix = GLKMatrix4MakeOrtho(0, sizePoint.width, 0, sizePoint.height, -1024, 1024 );
			break;


		case CCDirectorProjection3D: {
//			float zeye = [self getZEye];
//
//			kmGLMatrixMode(KM_GL_PROJECTION);
//			kmGLLoadIdentity();
//
//			kmMat4 matrixPerspective, matrixLookup;
//
//			// issue #1334
//			kmMat4PerspectiveProjection( &matrixPerspective, 60, (GLfloat)size.width/size.height, 0.1f, MAX(zeye*2,1500) );
////			kmMat4PerspectiveProjection( &matrixPerspective, 60, (GLfloat)size.width/size.height, 0.1f, 1500);
//
//
//			kmGLMultMatrix(&matrixPerspective);
//
//
//			kmGLMatrixMode(KM_GL_MODELVIEW);
//			kmGLLoadIdentity();
//			kmVec3 eye, center, up;
//
//			float eyeZ = size.height * zeye / size.height;
//
//			kmVec3Fill( &eye, size.width/2, size.height/2, eyeZ );
//			kmVec3Fill( &center, size.width/2, size.height/2, 0 );
//			kmVec3Fill( &up, 0, 1, 0);
//			kmMat4LookAt(&matrixLookup, &eye, &center, &up);
//			kmGLMultMatrix(&matrixLookup);
//			break;
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

#pragma mark helper

-(void)getFPSImageData:(unsigned char**)datapointer length:(NSUInteger*)len contentScale:(CGFloat *)scale
{
	// Mac Retina display?
	if (self.view.wantsBestResolutionOpenGLSurface &&
		self.view.window.backingScaleFactor == 2.0) {

		*datapointer = cc_fps_images_hd_png;
		*len = cc_fps_images_hd_len();
		*scale = 2;
	} else {

		*datapointer = cc_fps_images_png;
		*len = cc_fps_images_len();
		*scale = 1;
	}
}

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

// set the event dispatcher
-(void) setView:(CC_VIEW<CCDirectorView> *)view
{
	// Synchronize buffer swaps with vertical refresh rate
	[[view openGLContext] makeCurrentContext];
	GLint swapInt = 1;
	[[view openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
	
	[super setView:view];
}

@end

#endif // __CC_PLATFORM_MAC
