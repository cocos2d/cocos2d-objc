/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
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
#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#import <sys/time.h>
 
#import "CCDirectorMac.h"
#import "CCEventDispatcher.h"
#import "MacGLView.h"

#import "../../CCNode.h"
#import "../../CCScheduler.h"
#import "../../ccMacros.h"

#pragma mark -
#pragma mark Director Mac extensions


@interface CCDirector ()
-(void) setNextScene;
-(void) showFPS;
-(void) calculateDeltaTime;
@end

@implementation CCDirector (MacExtension)
-(CGPoint) convertEventToGL:(NSEvent*)event
{
	NSPoint point = [openGLView_ convertPoint:[event locationInWindow] fromView:nil];
	CGPoint p = NSPointToCGPoint(point);
	
	return  [(CCDirectorMac*)self convertToLogicalCoordinates:p];
}

@end

#pragma mark -
#pragma mark Director Mac

@implementation CCDirectorMac

@synthesize isFullScreen = isFullScreen_;

-(id) init
{
	if( (self = [super init]) ) {
		isFullScreen_ = NO;
		resizeMode_ = kCCDirectorResize_AutoScale;
		
		fullScreenGLView_ = nil;
		fullScreenWindow_ = nil;
		windowGLView_ = nil;
		winOffset_ = CGPointZero;
	}
	
	return self;
}

- (void) dealloc
{
	[fullScreenGLView_ release];
	[fullScreenWindow_ release];
	[windowGLView_ release];
	[super dealloc];
}

//
// setFullScreen code taken from GLFullScreen example by Apple
//
- (void) setFullScreen:(BOOL)fullscreen
{
	// Mac OS X 10.6 and later offer a simplified mechanism to create full-screen contexts
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5

	if( isFullScreen_ != fullscreen ) {

		isFullScreen_ = fullscreen;
	
		if( fullscreen ) {
			
			// create the fullscreen view/window
			NSRect mainDisplayRect, viewRect;
			
			// Create a screen-sized window on the display you want to take over
			// Note, mainDisplayRect has a non-zero origin if the key window is on a secondary display
			mainDisplayRect = [[NSScreen mainScreen] frame];
			fullScreenWindow_ = [[NSWindow alloc] initWithContentRect:mainDisplayRect
															styleMask:NSBorderlessWindowMask
															  backing:NSBackingStoreBuffered
																defer:YES];
			
			// Set the window level to be above the menu bar
			[fullScreenWindow_ setLevel:NSMainMenuWindowLevel+1];
			
			// Perform any other window configuration you desire
			[fullScreenWindow_ setOpaque:YES];
			[fullScreenWindow_ setHidesOnDeactivate:YES];
			
			// Create a view with a double-buffered OpenGL context and attach it to the window
			// By specifying the non-fullscreen context as the shareContext, we automatically inherit the OpenGL objects (textures, etc) it has defined
			viewRect = NSMakeRect(0.0, 0.0, mainDisplayRect.size.width, mainDisplayRect.size.height);
			
			fullScreenGLView_ = [[MacGLView alloc] initWithFrame:viewRect shareContext:[openGLView_ openGLContext]];

			[fullScreenWindow_ setContentView:fullScreenGLView_];

			// Show the window
			[fullScreenWindow_ makeKeyAndOrderFront:self];
			
			[self setOpenGLView:fullScreenGLView_];

		} else {
			
			[fullScreenWindow_ release];
			[fullScreenGLView_ release];
			fullScreenWindow_ = nil;
			fullScreenGLView_ = nil;

			[[windowGLView_ openGLContext] makeCurrentContext];
			[self setOpenGLView:windowGLView_];
			
		}
		
		[openGLView_ setNeedsDisplay:YES];
	}
#else
#error Full screen is not supported for Mac OS 10.5 or older yet
#error If you don't want FullScreen support, you can safely remove these 2 lines
#endif
}

-(void) setOpenGLView:(MacGLView *)view
{
	[super setOpenGLView:view];
	
	// cache the NSWindow and NSOpenGLView created from the NIB
	if( ! isFullScreen_ && ! windowGLView_) {
		windowGLView_ = [view retain];
		originalWinSize_ = winSizeInPixels_;
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

		[openGLView_ setNeedsDisplay: YES];
		
		[self setProjection:projection_];
		
		if( mode == kCCDirectorResize_AutoScale ) {
			originalWinSize_ = winSizeInPixels_;
			CCLOG(@"cocos2d: Warning. Switching back to AutoScale might break some stuff. Experimental stuff");
		}
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
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			ccglOrtho(0, size.width, 0, size.height, -1024, 1024);
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();
			break;
			
		case kCCDirectorProjection3D:
			glViewport(offset.x, offset.y, widthAspect, heightAspect);
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			gluPerspective(60, (GLfloat)widthAspect/heightAspect, 0.1f, 1500.0f);
			
			glMatrixMode(GL_MODELVIEW);	
			glLoadIdentity();
			
			float eyeZ = size.height * [self getZEye] / winSizeInPixels_.height;

			gluLookAt( size.width/2, size.height/2, eyeZ,
					  size.width/2, size.height/2, 0,
					  0.0f, 1.0f, 0.0f);			
			break;
			
		case kCCDirectorProjectionCustom:
			if( projectionDelegate_ )
				[projectionDelegate_ updateProjection];
			break;
			
		default:
			CCLOG(@"cocos2d: Director: unrecognized projecgtion");
			break;
	}
	
	projection_ = projection;
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
@end


#pragma mark -
#pragma mark DirectorDisplayLink


@implementation CCDirectorDisplayLink

- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime
{
#if CC_DIRECTOR_MAC_USE_DISPLAY_LINK_THREAD
	if( ! runningThread_ )
		runningThread_ = [NSThread currentThread];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[self drawScene];
	[[CCEventDispatcher sharedDispatcher] dispatchQueuedEvents];
	
	[[NSRunLoop currentRunLoop] run];
	
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
#if ! CC_DIRECTOR_MAC_USE_DISPLAY_LINK_THREAD
	runningThread_ = [[NSThread alloc] initWithTarget:self selector:@selector(mainLoop) object:nil];
	[runningThread_ start];	
#endif
	
	gettimeofday( &lastUpdate_, NULL);
	
	// Create a display link capable of being used with all active displays
	CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
	
	// Set the renderer output callback function
	CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);
	
	// Set the display link for the current renderer
	CGLContextObj cglContext = [[openGLView_ openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = [[openGLView_ pixelFormat] CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
	
	// Activate the display link
	CVDisplayLinkStart(displayLink);
}

- (void) stopAnimation
{
	if( displayLink ) {
		CVDisplayLinkStop(displayLink);
		CVDisplayLinkRelease(displayLink);
		displayLink = NULL;
		
#if ! CC_DIRECTOR_MAC_USE_DISPLAY_LINK_THREAD
		[runningThread_ cancel];
		[runningThread_ release];
		runningThread_ = nil;
#endif
	}
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
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously	when resizing
	CGLLockContext([[openGLView_ openGLContext] CGLContextObj]);
	[[openGLView_ openGLContext] makeCurrentContext];
	
	/* calculate "global" dt */
	[self calculateDeltaTime];
	
	/* tick before glClear: issue #533 */
	if( ! isPaused_ ) {
		[[CCScheduler sharedScheduler] tick: dt];	
	}
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	/* to avoid flickr, nextScene MUST be here: after tick and before draw.
	 XXX: Which bug is this one. It seems that it can't be reproduced with v0.9 */
	if( nextScene_ )
		[self setNextScene];
	
	glPushMatrix();
	
	
	// By default enable VertexArray, ColorArray, TextureCoordArray and Texture2D
	CC_ENABLE_DEFAULT_GL_STATES();
	
	/* draw the scene */
	[runningScene_ visit];
	
	/* draw the notification node */
	[notificationNode_ visit];

	if( displayFPS_ )
		[self showFPS];
	
#if CC_ENABLE_PROFILERS
	[self showProfilers];
#endif
	
	CC_DISABLE_DEFAULT_GL_STATES();
	
	glPopMatrix();
			
	[[openGLView_ openGLContext] flushBuffer];	
	CGLUnlockContext([[openGLView_ openGLContext] CGLContextObj]);
}

// set the event dispatcher
-(void) setOpenGLView:(MacGLView *)view
{
	if( view != openGLView_ ) {
		
		[super setOpenGLView:view];
				
		CCEventDispatcher *eventDispatcher = [CCEventDispatcher sharedDispatcher];
		[openGLView_ setEventDelegate: eventDispatcher];
		[eventDispatcher setDispatchEvents: YES];
		
		// Enable Touches. Default no.
		[view setAcceptsTouchEvents:NO];
//		[view setAcceptsTouchEvents:YES];
		

		// Synchronize buffer swaps with vertical refresh rate
		[[view openGLContext] makeCurrentContext];
		GLint swapInt = 1;
		[[view openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval]; 
	}
}

@end

#endif // __MAC_OS_X_VERSION_MAX_ALLOWED
