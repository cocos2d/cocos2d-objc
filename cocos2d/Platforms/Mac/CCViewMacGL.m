//
//  CCViewMacGL.m
//  cocos2d
//
//  Created by Oleg Osin on 1/12/15.
//
//


// Only compile this code on Mac. These files should not be included on your iOS project.
// But in case they are included, it won't be compiled.
#import "ccMacros.h"
#if __CC_PLATFORM_MAC

#import "CCGL.h"
#import "CCViewMacGL.h"
#import "CCDirectorMac.h"
#import "CCGLFence.h"
#import "CCDirector_Private.h"

@implementation CCViewMacGL {
    NSMutableArray *_fences;
}
@synthesize director = _director;


-(void)awakeFromNib
{
    _director = [CCDirector director];
    _director.view = self;
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
    
    NSRect rect = [self convertRectToBacking:self.bounds];
    
    CCDirector *director = _director;
    [director reshapeProjection: NSSizeToCGSize(rect.size) ];
    
    // avoid flicker
    // Only draw if there is something to draw, otherwise it actually creates a flicker of the current glClearColor
    if(director.runningScene){
        [director mainLoopBody];
    }
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

// Find or make a fence that is ready to use.
-(CCGLFence *)getReadyFence
{
    // First checkf oldest (first in the array) fence is ready again.
    CCGLFence *fence = _fences.firstObject;;
    if(fence.isReady){
        // Remove the fence so it can be inserted at the end of the queue again.
        [_fences removeObjectAtIndex:0];
        return fence;
    } else {
        // No existing fences ready. Make a new one.
        return [[CCGLFence alloc] init];
    }
}

-(void)addFrameCompletionHandler:(dispatch_block_t)handler
{
    if(_fences == nil){
        _fences = [NSMutableArray arrayWithObject:[[CCGLFence alloc] init]];
    }
    
    CCGLFence *fence = _fences.lastObject;
    if(!fence.isReady){
        fence = [self getReadyFence];
        [_fences addObject:fence];
    }
    
    [fence.handlers addObject:handler];
}

-(void)beginFrame
{
    [self lockOpenGLContext];
}

-(void)presentFrame
{
    {
        CCGLFence *fence = _fences.lastObject;
        if(fence.isReady){
            // If the fence is ready to be added, insert a sync point for it.
            [fence insertFence];
        }
    }
    
    [self.openGLContext flushBuffer];
    
    // Check the fences for completion.
    for(CCGLFence *fence in _fences){
        if(fence.isCompleted){
            for(dispatch_block_t handler in fence.handlers) handler();
            [fence.handlers removeAllObjects];
        } else {
            break;
        }
    }
    
    [self unlockOpenGLContext];
}

-(GLuint)fbo
{
    return 0;
}

- (void) dealloc
{
    CCLOGINFO(@"cocos2d: deallocing %@", self);
}

#pragma mark CCGLView - Mouse Delegate

- (void)mouseDown:(NSEvent *)theEvent
{
    // dispatch mouse to responder manager
    [CCDirector bindDirector:_director];
    [_director.responderManager mouseDown:theEvent];
    [CCDirector bindDirector:nil];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    // dispatch mouse to responder manager
    [CCDirector bindDirector:_director];
    [_director.responderManager mouseDragged:theEvent];
    [CCDirector bindDirector:nil];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    // dispatch mouse to responder manager
    [CCDirector bindDirector:_director];
    [_director.responderManager mouseUp:theEvent];
    [CCDirector bindDirector:nil];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    // dispatch mouse to responder manager
    [CCDirector bindDirector:_director];
    [_director.responderManager mouseMoved:theEvent];
    [CCDirector bindDirector:nil];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    // dispatch mouse to responder manager
    [CCDirector bindDirector:_director];
    [_director.responderManager mouseEntered:theEvent];
    [CCDirector bindDirector:nil];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    // dispatch mouse to responder manager
    [CCDirector bindDirector:_director];
    [_director.responderManager mouseExited:theEvent];
    [CCDirector bindDirector:nil];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    // dispatch mouse to responder manager
    [CCDirector bindDirector:_director];
    [_director.responderManager rightMouseDown:theEvent];
    [CCDirector bindDirector:nil];
}

- (void)rightMouseDragged:(NSEvent *)theEvent
{
    // dispatch mouse to responder manager
    [CCDirector bindDirector:_director];
    [_director.responderManager rightMouseDragged:theEvent];
    [CCDirector bindDirector:nil];
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    // dispatch mouse to responder manager
    [CCDirector bindDirector:_director];
    [_director.responderManager rightMouseUp:theEvent];
    [CCDirector bindDirector:nil];
}

- (void)otherMouseDown:(NSEvent *)theEvent
{
    // dispatch mouse to responder manager
    [CCDirector bindDirector:_director];
    [_director.responderManager otherMouseDown:theEvent];
    [CCDirector bindDirector:nil];
}

- (void)otherMouseDragged:(NSEvent *)theEvent
{
    // dispatch mouse to responder manager
    [CCDirector bindDirector:_director];
    [_director.responderManager otherMouseDragged:theEvent];
    [CCDirector bindDirector:nil];
}

- (void)otherMouseUp:(NSEvent *)theEvent
{
    // dispatch mouse to responder manager
    [CCDirector bindDirector:_director];
    [_director.responderManager otherMouseUp:theEvent];
    [CCDirector bindDirector:nil];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    // dispatch mouse to responder manager
    [CCDirector bindDirector:_director];
    [_director.responderManager scrollWheel:theEvent];
    [CCDirector bindDirector:nil];
}

- (void) keyDown:(NSEvent *)theEvent {
    // dispatch keyboard to responder manager
    [CCDirector bindDirector:_director];
    [_director.responderManager keyDown:theEvent];
    [CCDirector bindDirector:nil];
}

- (void) keyUp:(NSEvent *)theEvent {
    // dispatch keyboard to responder manager
    [CCDirector bindDirector:_director];
    [_director.responderManager keyUp:theEvent];
    [CCDirector bindDirector:nil];
}


@end

#endif // __CC_PLATFORM_MAC
