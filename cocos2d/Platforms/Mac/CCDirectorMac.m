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
	return NSPointToCGPoint(point);
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
		fullScreenGLView_ = nil;
		fullScreenWindow_ = nil;
		windowGLView_ = nil;
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
			
			[windowGLView_ setNeedsDisplay:YES];
		}
	}
#else
#error Full screen is not supported for Mac OS 10.5 or older yet
#endif
}

-(void) setOpenGLView:(MacGLView *)view
{
	[super setOpenGLView:view];
	
	// cache the NSWindow and NSOpenGLView created from the NIB
	if( ! isFullScreen_ && ! windowGLView_) {
		windowGLView_ = [view retain];
	}
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
