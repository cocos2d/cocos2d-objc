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

/*
 * Idea of subclassing NSOpenGLView was taken from  "TextureUpload" Apple's sample
 */

// Only compile this code on Mac. These files should not be included on your iOS project.
// But in case they are included, it won't be compiled.
#import "../../ccMacros.h"
#ifdef __CC_PLATFORM_MAC

#import "../../Platforms/CCGL.h"
#import "CCGLView.h"
#import "CCDirectorMac.h"
#import "CCEventDispatcher.h"
#import "../../ccConfig.h"
#import "../../ccMacros.h"


@implementation CCGLView

@synthesize eventDelegate = eventDelegate_;

+(void) load_
{
	CCLOG(@"%@ loaded", self);
}

- (id) initWithFrame:(NSRect)frameRect
{
	self = [self initWithFrame:frameRect shareContext:nil];
	return self;
}

- (id) initWithFrame:(NSRect)frameRect shareContext:(NSOpenGLContext*)context
{
    NSOpenGLPixelFormatAttribute attribs[] =
    {
//		NSOpenGLPFAAccelerated,
//		NSOpenGLPFANoRecovery,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize, 24,

#if 0
		// Must specify the 3.2 Core Profile to use OpenGL 3.2
		NSOpenGLPFAOpenGLProfile,
		NSOpenGLProfileVersion3_2Core,
#endif

		0
    };

	NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];

	if (!pixelFormat)
		CCLOG(@"No OpenGL pixel format");

	if( (self = [super initWithFrame:frameRect pixelFormat:[pixelFormat autorelease]]) ) {

		if( context )
			[self setOpenGLContext:context];

		// event delegate
		eventDelegate_ = nil;
	}

	return self;
}

- (void) update
{
	// XXX: Should I do something here ?
	[super update];
}

- (void) prepareOpenGL
{
	// XXX: Initialize OpenGL context

	[super prepareOpenGL];
	
	// Make this openGL context current to the thread
	// (i.e. all openGL on this thread calls will go to this context)
	[[self openGLContext] makeCurrentContext];
	
	// Synchronize buffer swaps with vertical refresh rate
	GLint swapInt = 1;
	[[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];	

//	GLint order = -1;
//	[[self openGLContext] setValues:&order forParameter:NSOpenGLCPSurfaceOrder];
}

- (NSUInteger) depthFormat
{
	return 24;
}

- (void) reshape
{
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously when resizing

	[self lockOpenGLContext];

	NSRect rect = [self bounds];

	CCDirector *director = [CCDirector sharedDirector];
	[director reshapeProjection: NSSizeToCGSize(rect.size) ];

	// avoid flicker
	[director drawScene];
//	[self setNeedsDisplay:YES];
	
	[self unlockOpenGLContext];
}


-(void) lockOpenGLContext
{
	NSOpenGLContext *glContext = [self openGLContext];
	NSAssert( glContext, @"FATAL: could not get openGL context");

	[glContext makeCurrentContext];
	CGLLockContext([glContext CGLContextObj]);	
}

-(void) unlockOpenGLContext
{
	NSOpenGLContext *glContext = [self openGLContext];
	NSAssert( glContext, @"FATAL: could not get openGL context");

	CGLUnlockContext([glContext CGLContextObj]);
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);

	[super dealloc];
}

#define DISPATCH_EVENT(__event__, __selector__)												\
	id obj = eventDelegate_;																\
	CCEventObject *event = [[CCEventObject alloc] init];									\
	event->event = [__event__ retain];														\
	event->selector = __selector__;															\
	[obj performSelector:@selector(dispatchEvent:)											\
			onThread:[[CCDirector sharedDirector] runningThread]							\
		  withObject:event																	\
	   waitUntilDone:NO];																	\
	[event release];

#pragma mark CCGLView - Mouse events

- (void)mouseDown:(NSEvent *)theEvent
{
	DISPATCH_EVENT(theEvent, _cmd);
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	DISPATCH_EVENT(theEvent, _cmd);
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	DISPATCH_EVENT(theEvent, _cmd);
}

- (void)mouseUp:(NSEvent *)theEvent
{
	DISPATCH_EVENT(theEvent, _cmd);
}

- (void)rightMouseDown:(NSEvent *)theEvent {
	DISPATCH_EVENT(theEvent, _cmd);
}

- (void)rightMouseDragged:(NSEvent *)theEvent {
	DISPATCH_EVENT(theEvent, _cmd);
}

- (void)rightMouseUp:(NSEvent *)theEvent {
	DISPATCH_EVENT(theEvent, _cmd);
}

- (void)otherMouseDown:(NSEvent *)theEvent {
	DISPATCH_EVENT(theEvent, _cmd);
}

- (void)otherMouseDragged:(NSEvent *)theEvent {
	DISPATCH_EVENT(theEvent, _cmd);
}

- (void)otherMouseUp:(NSEvent *)theEvent {
	DISPATCH_EVENT(theEvent, _cmd);
}

- (void)mouseEntered:(NSEvent *)theEvent {
	DISPATCH_EVENT(theEvent, _cmd);
}

- (void)mouseExited:(NSEvent *)theEvent {
	DISPATCH_EVENT(theEvent, _cmd);
}

-(void) scrollWheel:(NSEvent *)theEvent {
	DISPATCH_EVENT(theEvent, _cmd);
}

#pragma mark CCGLView - Key events

-(BOOL) becomeFirstResponder
{
	return YES;
}

-(BOOL) acceptsFirstResponder
{
	return YES;
}

-(BOOL) resignFirstResponder
{
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
	DISPATCH_EVENT(theEvent, _cmd);
}

- (void)keyUp:(NSEvent *)theEvent
{
	DISPATCH_EVENT(theEvent, _cmd);
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	DISPATCH_EVENT(theEvent, _cmd);
}

#pragma mark CCGLView - Touch events
- (void)touchesBeganWithEvent:(NSEvent *)theEvent
{
	DISPATCH_EVENT(theEvent, _cmd);
}

- (void)touchesMovedWithEvent:(NSEvent *)theEvent
{
	DISPATCH_EVENT(theEvent, _cmd);
}

- (void)touchesEndedWithEvent:(NSEvent *)theEvent
{
	DISPATCH_EVENT(theEvent, _cmd);
}

- (void)touchesCancelledWithEvent:(NSEvent *)theEvent
{
	DISPATCH_EVENT(theEvent, _cmd);
}

@end

#endif // __CC_PLATFORM_MAC
