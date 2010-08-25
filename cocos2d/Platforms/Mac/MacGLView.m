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

/*
 * Idea of subclassing NSOpenGLView was taken from  "TextureUpload" Apple's sample
 */

#import "MacGLView.h"
#import <OpenGL/gl.h>

#import "../../CCDirector.h"


@implementation MacGLView

@synthesize eventDelegate = eventDelegate_;

+(void) load_
{
	NSLog(@"%@ loaded", self);
}

- (id) initWithFrame:(NSRect)frameRect
{
    NSOpenGLPixelFormatAttribute attrs[] =
    {
		NSOpenGLPFAAccelerated,
		NSOpenGLPFANoRecovery,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize, 24,
		0
    };
	
    NSOpenGLPixelFormat *pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	
    if (!pf)
		NSLog(@"No OpenGL pixel format");
	
    if (self = [super initWithFrame:frameRect pixelFormat:[pf autorelease]])
	{
		[[self openGLContext] makeCurrentContext];

		// Synchronize buffer swaps with vertical refresh rate
		GLint swapInt = 1;
		[[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval]; 
		
		
		// event delegate
		eventDelegate_ = nil;
	}
	
	return self;
}
	
- (void) reshape
{
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously when resizing
	CGLLockContext([[self openGLContext] CGLContextObj]);
	
	NSRect rect = [self bounds];
	
	CCDirector *director = [CCDirector sharedDirector];
	[director reshapeProjection: NSSizeToCGSize(rect.size) ];
	
	// avoid flicker
	[director drawScene];
//	[self setNeedsDisplay:YES];
	
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}

- (void) dealloc
{	

	[super dealloc];
}

#pragma mark MacGLView - Mouse events
- (void)mouseDown:(NSEvent *)theEvent {
	[eventDelegate_ mouseDown:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent {
	[eventDelegate_ mouseUp:theEvent];
}

- (void)mouseMoved:(NSEvent *)theEvent {
	[eventDelegate_ mouseMoved:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent {
	[eventDelegate_ mouseDragged:theEvent];
}

#pragma mark MacGLView - Key events

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

- (void)keyDown:(NSEvent *)theEvent {
	[eventDelegate_ keyDown:theEvent];
}

- (void)keyUp:(NSEvent *)theEvent {
	[eventDelegate_ keyUp:theEvent];
}

#pragma mark MacGLView - Touch events
- (void)touchesBeganWithEvent:(NSEvent *)event
{
	[eventDelegate_ touchesBeganWithEvent:event];
}

- (void)touchesMovedWithEvent:(NSEvent *)event
{
	[eventDelegate_ touchesMovedWithEvent:event];
}

- (void)touchesEndedWithEvent:(NSEvent *)event
{
	[eventDelegate_ touchesEndedWithEvent:event];
}

- (void)touchesCancelledWithEvent:(NSEvent *)event
{
	[eventDelegate_ touchesCancelledWithEvent:event];
}

@end
