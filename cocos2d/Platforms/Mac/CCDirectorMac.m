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
 */

// Only compile this code on Mac. These files should not be included on your iOS project.
// But in case they are included, it won't be compiled.
#import "../../ccMacros.h"
#ifdef __CC_PLATFORM_MAC

#import <sys/time.h>

#import "CCDirectorMac.h"
#import "CCEventDispatcher.h"
#import "CCGLView.h"
#import "CCWindow.h"

#import "../../CCNode.h"
#import "../../CCScheduler.h"
#import "../../ccMacros.h"
#import "../../CCGLProgram.h"
#import "../../ccGLStateCache.h"

// external
#import "kazmath/kazmath.h"
#import "kazmath/GL/matrix.h"

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

	return  [(CCDirectorMac*)self convertToLogicalCoordinates:p];
}

-(void) setEventDispatcher:(CCEventDispatcher *)dispatcher
{
	NSAssert(NO, @"override me");
}

-(CCEventDispatcher *) eventDispatcher
{
	NSAssert(NO, @"override me");
	return nil;
}
@end

#pragma mark -
#pragma mark Director Mac

@implementation CCDirectorMac

@synthesize isFullScreen = isFullScreen_;
@synthesize originalWinSize = originalWinSize_;

-(id) init
{
	if( (self = [super init]) ) {
		isFullScreen_ = NO;
		resizeMode_ = kCCDirectorResize_AutoScale;

        originalWinSize_ = CGSizeZero;
		fullScreenWindow_ = nil;
		windowGLView_ = nil;
		winOffset_ = CGPointZero;

		eventDispatcher_ = [[CCEventDispatcher alloc] init];
	}

	return self;
}

- (void) dealloc
{
	[eventDispatcher_ release];
	[view_ release];
    [superViewGLView_ release];
	[fullScreenWindow_ release];
	[windowGLView_ release];

	[super dealloc];
}

//
// setFullScreen code taken from GLFullScreen example by Apple
//
- (void) setFullScreen:(BOOL)fullscreen
{
//	isFullScreen_ = !isFullScreen_;
//		
//	if (isFullScreen_)
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

    if (isFullScreen_ == fullscreen)
		return;

	CCGLView *openGLview = (CCGLView*) self.view;

    if( fullscreen ) {
        originalWinRect_ = [openGLview frame];

        // Cache normal window and superview of openGLView
        if(!windowGLView_)
            windowGLView_ = [[openGLview window] retain];

        [superViewGLView_ release];
        superViewGLView_ = [[openGLview superview] retain];


        // Get screen size
        NSRect displayRect = [[NSScreen mainScreen] frame];

        // Create a screen-sized window on the display you want to take over
        fullScreenWindow_ = [[CCWindow alloc] initWithFrame:displayRect fullscreen:YES];

        // Remove glView from window
        [openGLview removeFromSuperview];

        // Set new frame
        [openGLview setFrame:displayRect];

        // Attach glView to fullscreen window
        [fullScreenWindow_ setContentView:openGLview];

        // Show the fullscreen window
        [fullScreenWindow_ makeKeyAndOrderFront:self];
		[fullScreenWindow_ makeMainWindow];

    } else {

        // Remove glView from fullscreen window
        [openGLview removeFromSuperview];

        // Release fullscreen window
        [fullScreenWindow_ release];
        fullScreenWindow_ = nil;

        // Attach glView to superview
        [superViewGLView_ addSubview:openGLview];

        // Set new frame
        [openGLview setFrame:originalWinRect_];

        // Show the window
        [windowGLView_ makeKeyAndOrderFront:self];
		[windowGLView_ makeMainWindow];
    }
	
	// issue #1189
	[windowGLView_ makeFirstResponder:openGLview];

    isFullScreen_ = fullscreen;

    [openGLview retain]; // Retain +1

    // re-configure glView
    [self setView:openGLview];

    [openGLview release]; // Retain -1

    [openGLview setNeedsDisplay:YES];
#else
#error Full screen is not supported for Mac OS 10.5 or older yet
#error If you don't want FullScreen support, you can safely remove these 2 lines
#endif
}

-(void) setView:(CCGLView *)view
{
	if( view != view_) {

		[super setView:view];

		// cache the NSWindow and NSOpenGLView created from the NIB
		if( !isFullScreen_ && CGSizeEqualToSize(originalWinSize_, CGSizeZero))
		{
			originalWinSize_ = winSizeInPixels_;
		}
	}
}

-(int) resizeMode
{
	return resizeMode_;
}

-(void) setResizeMode:(int)mode
{
	if( mode != resizeMode_ ) {

		resizeMode_ = mode;

        [self setProjection:projection_];
        [self.view setNeedsDisplay: YES];
	}
}

-(void) setProjection:(ccDirectorProjection)projection
{
	CGSize size = winSizeInPixels_;

	CGPoint offset = CGPointZero;
	float widthAspect = size.width;
	float heightAspect = size.height;


	if( resizeMode_ == kCCDirectorResize_AutoScale && ! CGSizeEqualToSize(originalWinSize_, CGSizeZero ) ) {

		size = originalWinSize_;

		float aspect = originalWinSize_.width / originalWinSize_.height;
		widthAspect = winSizeInPixels_.width;
		heightAspect = winSizeInPixels_.width / aspect;

		if( heightAspect > winSizeInPixels_.height ) {
			widthAspect = winSizeInPixels_.height * aspect;
			heightAspect = winSizeInPixels_.height;
		}

		winOffset_.x = (winSizeInPixels_.width - widthAspect) / 2;
		winOffset_.y =  (winSizeInPixels_.height - heightAspect) / 2;

		offset = winOffset_;

	}

	switch (projection) {
		case kCCDirectorProjection2D:

			glViewport(offset.x, offset.y, widthAspect, heightAspect);
			kmGLMatrixMode(KM_GL_PROJECTION);
			kmGLLoadIdentity();

			kmMat4 orthoMatrix;
			kmMat4OrthographicProjection(&orthoMatrix, 0, size.width, 0, size.height, -1024, 1024);
			kmGLMultMatrix( &orthoMatrix );

			kmGLMatrixMode(KM_GL_MODELVIEW);
			kmGLLoadIdentity();
			break;


		case kCCDirectorProjection3D:
		{

			float zeye = [self getZEye];

			glViewport(offset.x, offset.y, widthAspect, heightAspect);
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

			float eyeZ = size.height * zeye / winSizeInPixels_.height;

			kmVec3Fill( &eye, size.width/2, size.height/2, eyeZ );
			kmVec3Fill( &center, size.width/2, size.height/2, 0 );
			kmVec3Fill( &up, 0, 1, 0);
			kmMat4LookAt(&matrixLookup, &eye, &center, &up);
			kmGLMultMatrix(&matrixLookup);
			break;
		}

		case kCCDirectorProjectionCustom:
			if( [delegate_ respondsToSelector:@selector(updateProjection)] )
				[delegate_ updateProjection];
			break;

		default:
			CCLOG(@"cocos2d: Director: unrecognized projection");
			break;
	}

	projection_ = projection;

	ccSetProjectionMatrixDirty();
}


// If scaling is supported, then it should always return the original size
// otherwise it should return the "real" size.
-(CGSize) winSize
{
	if( resizeMode_ == kCCDirectorResize_AutoScale )
		return originalWinSize_;

	return winSizeInPixels_;
}

-(CGSize) winSizeInPixels
{
	return [self winSize];
}

- (CGPoint) convertToLogicalCoordinates:(CGPoint)coords
{
	CGPoint ret;

	if( resizeMode_ == kCCDirectorResize_NoScale )
		ret = coords;

	else {

		float x_diff = originalWinSize_.width / (winSizeInPixels_.width - winOffset_.x * 2);
		float y_diff = originalWinSize_.height / (winSizeInPixels_.height - winOffset_.y * 2);

		float adjust_x = (winSizeInPixels_.width * x_diff - originalWinSize_.width ) / 2;
		float adjust_y = (winSizeInPixels_.height * y_diff - originalWinSize_.height ) / 2;

		ret = CGPointMake( (x_diff * coords.x) - adjust_x, ( y_diff * coords.y ) - adjust_y );
	}

	return ret;
}

-(void) setEventDispatcher:(CCEventDispatcher *)dispatcher
{
	if( dispatcher != eventDispatcher_ ) {
		[eventDispatcher_ release];
		eventDispatcher_ = [dispatcher retain];
	}
}

-(CCEventDispatcher *) eventDispatcher
{
	return eventDispatcher_;
}
@end


#pragma mark -
#pragma mark DirectorDisplayLink


@implementation CCDirectorDisplayLink

- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime
{
#if (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_DISPLAY_LINK_THREAD)
	if( ! runningThread_ )
		runningThread_ = [NSThread currentThread];

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[self drawScene];

	// Process timers and other events
	[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:nil];

	[pool release];
		
#else
	[self performSelector:@selector(drawScene) onThread:runningThread_ withObject:nil waitUntilDone:YES];
#endif

    return kCVReturnSuccess;
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    CVReturn result = [(CCDirectorDisplayLink*)displayLinkContext getFrameForTime:outputTime];
    return result;
}

- (void) startAnimation
{
    if(isAnimating_)
        return;

	CCLOG(@"cocos2d: startAnimation");
#if (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_OWN_THREAD)
	runningThread_ = [[NSThread alloc] initWithTarget:self selector:@selector(mainLoop) object:nil];
	[runningThread_ start];
#elif (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_MAIN_THREAD)
    runningThread_ = [NSThread mainThread];
#endif

	gettimeofday( &lastUpdate_, NULL);

	// Create a display link capable of being used with all active displays
	CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);

	// Set the renderer output callback function
	CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);

	// Set the display link for the current renderer
	CCGLView *openGLview = (CCGLView*) self.view;
	CGLContextObj cglContext = [[openGLview openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = [[openGLview pixelFormat] CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);

	// Activate the display link
	CVDisplayLinkStart(displayLink);
    
    isAnimating_ = YES;
}

- (void) stopAnimation
{
    if(!isAnimating_)
        return;

	CCLOG(@"cocos2d: stopAnimation");

	if( displayLink ) {
		CVDisplayLinkStop(displayLink);
		CVDisplayLinkRelease(displayLink);
		displayLink = NULL;

#if CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_OWN_THREAD
		[runningThread_ cancel];
		[runningThread_ release];
		runningThread_ = nil;
#elif (CC_DIRECTOR_MAC_THREAD == CC_MAC_USE_MAIN_THREAD)
        runningThread_ = nil;
#endif
	}
    
    isAnimating_ = NO;
}

-(void) dealloc
{
	if( displayLink ) {
		CVDisplayLinkStop(displayLink);
		CVDisplayLinkRelease(displayLink);
	}
	[super dealloc];
}

//
// Mac Director has its own thread
//
-(void) mainLoop
{
	while( ![[NSThread currentThread] isCancelled] ) {
		// There is no autorelease pool when this method is called because it will be called from a background thread
		// It's important to create one or you will leak objects
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		[[NSRunLoop currentRunLoop] run];

		[pool release];
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
	if( ! isPaused_ )
		[scheduler_ update: dt];

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	/* to avoid flickr, nextScene MUST be here: after tick and before draw.
	 XXX: Which bug is this one. It seems that it can't be reproduced with v0.9 */
	if( nextScene_ )
		[self setNextScene];

	kmGLPushMatrix();


	/* draw the scene */
	[runningScene_ visit];

	/* draw the notification node */
	[notificationNode_ visit];

	if( displayStats_ )
		[self showStats];

	kmGLPopMatrix();

	totalFrames_++;
	

	// flush buffer
	[self.view.openGLContext flushBuffer];	

	[self.view unlockOpenGLContext];

	if( displayStats_ )
		[self calculateMPF];
}

// set the event dispatcher
-(void) setView:(CCGLView *)view
{
	[super setView:view];

	[view setEventDelegate:eventDispatcher_];
	[eventDispatcher_ setDispatchEvents: YES];

	// Enable Touches. Default no.
	// Only available on OS X 10.6+
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
	[view setAcceptsTouchEvents:NO];
//		[view setAcceptsTouchEvents:YES];
#endif


	// Synchronize buffer swaps with vertical refresh rate
	[[view openGLContext] makeCurrentContext];
	GLint swapInt = 1;
	[[view openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
}

@end

#endif // __CC_PLATFORM_MAC
