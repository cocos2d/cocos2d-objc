/*

===== IMPORTANT =====

This is sample code demonstrating API, technology or techniques in development.
Although this sample code has been reviewed for technical accuracy, it is not
final. Apple is supplying this information to help you plan for the adoption of
the technologies and programming interfaces described herein. This information
is subject to change, and software implemented based on this sample code should
be tested with final operating system software and final documentation. Newer
versions of this sample code may be provided with future seeds of the API or
technology. For information about updates to this and other developer
documentation, view the New & Updated sidebars in subsequent documentation
seeds.

=====================

File: CCGLView.m
Abstract: Convenience class that wraps the CAEAGLLayer from CoreAnimation into a
UIView subclass.

Version: 1.3

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

/*
 Modified for cocos2d project
 */

// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
#import "../../ccMacros.h"
#if __CC_PLATFORM_IOS

#import <QuartzCore/QuartzCore.h>

#import "CCGLView.h"
#import "CCES2Renderer.h"
#import "../../CCDirector.h"
#import "../../ccMacros.h"
#import "../../CCConfiguration.h"
#import "CCScene.h"
#import "CCTouch.h"
#import "CCTouchEvent.h"

#import "CCDirector_Private.h"

//CLASS IMPLEMENTATIONS:


// TODO extract a common class for this?
@interface CCGLViewFence : NSObject

/// Is the fence ready to be inserted?
@property(nonatomic, readonly) BOOL isReady;
@property(nonatomic, readonly) BOOL isCompleted;

/// List of completion handlers to be called when the fence completes.
@property(nonatomic, readonly, strong) NSMutableArray *handlers;

@end


@implementation CCGLViewFence {
	GLsync _fence;
	BOOL _invalidated;
}

-(instancetype)init
{
	if((self = [super init])){
		_handlers = [NSMutableArray array];
	}
	
	return self;
}

-(void)insertFence
{
	_fence = glFenceSyncAPPLE(GL_SYNC_GPU_COMMANDS_COMPLETE_APPLE, 0);
	
	CC_CHECK_GL_ERROR_DEBUG();
}

-(BOOL)isReady
{
	// If there is a GL fence assigned, then the fence is waiting on it and not ready.
	return (_fence == NULL);
}

-(BOOL)isComplete
{
	if(_fence){
		if(glClientWaitSyncAPPLE(_fence, GL_SYNC_FLUSH_COMMANDS_BIT_APPLE, 0) == GL_ALREADY_SIGNALED_APPLE){
			glDeleteSyncAPPLE(_fence);
			_fence = NULL;
			
			CC_CHECK_GL_ERROR_DEBUG();
			return YES;
		} else {
			// Fence is still waiting
			return NO;
		}
	} else {
		// Fence has completed previously.
		return YES;
	}
}

@end

@implementation CCGLView {
    CCTouchEvent* _touchEvent;
	NSMutableArray *_fences;
}

@synthesize surfaceSize=_size;
@synthesize pixelFormat=_pixelformat, depthFormat=_depthFormat;
@synthesize context=_context;
@synthesize multiSampling=_multiSampling;

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

+ (id) viewWithFrame:(CGRect)frame
{
	return [[self alloc] initWithFrame:frame];
}

+ (id) viewWithFrame:(CGRect)frame pixelFormat:(NSString*)format
{
	return [[self alloc] initWithFrame:frame pixelFormat:format];
}

+ (id) viewWithFrame:(CGRect)frame pixelFormat:(NSString*)format depthFormat:(GLuint)depth
{
	return [[self alloc] initWithFrame:frame pixelFormat:format depthFormat:depth preserveBackbuffer:NO sharegroup:nil multiSampling:NO numberOfSamples:0];
}

+ (id) viewWithFrame:(CGRect)frame pixelFormat:(NSString*)format depthFormat:(GLuint)depth preserveBackbuffer:(BOOL)retained sharegroup:(EAGLSharegroup*)sharegroup multiSampling:(BOOL)multisampling numberOfSamples:(unsigned int)samples
{
	return [[self alloc] initWithFrame:frame pixelFormat:format depthFormat:depth preserveBackbuffer:retained sharegroup:sharegroup multiSampling:multisampling numberOfSamples:samples];
}

- (id) initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame pixelFormat:kEAGLColorFormatRGB565 depthFormat:0 preserveBackbuffer:NO sharegroup:nil multiSampling:NO numberOfSamples:0];
}

- (id) initWithFrame:(CGRect)frame pixelFormat:(NSString*)format
{
	return [self initWithFrame:frame pixelFormat:format depthFormat:0 preserveBackbuffer:NO sharegroup:nil multiSampling:NO numberOfSamples:0];
}

- (id) initWithFrame:(CGRect)frame pixelFormat:(NSString*)format depthFormat:(GLuint)depth preserveBackbuffer:(BOOL)retained sharegroup:(EAGLSharegroup*)sharegroup multiSampling:(BOOL)sampling numberOfSamples:(unsigned int)nSamples
{
	if((self = [super initWithFrame:frame]))
	{
		_pixelformat = format;
		_depthFormat = depth;
		_multiSampling = sampling;
		_requestedSamples = nSamples;
		_preserveBackbuffer = retained;
		
		// Default to "retina" being enabled.
		self.contentScaleFactor = [UIScreen mainScreen].scale;

		if( ! [self setupSurfaceWithSharegroup:sharegroup] ) {
			return nil;
		}
        
        /** Multiple touch default enabled
         */
        self.multipleTouchEnabled = YES;

		CC_CHECK_GL_ERROR_DEBUG();
        
        _touchEvent = [[CCTouchEvent alloc] init];
	}

	return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	if( (self = [super initWithCoder:aDecoder]) ) {

		CAEAGLLayer* eaglLayer = (CAEAGLLayer*)[self layer];

		_pixelformat = kEAGLColorFormatRGB565;
		_depthFormat = 0; // GL_DEPTH_COMPONENT24;
		_multiSampling= NO;
		_requestedSamples = 0;
		_size = [eaglLayer bounds].size;

		if( ! [self setupSurfaceWithSharegroup:nil] ) {
			return nil;
		}

		CC_CHECK_GL_ERROR_DEBUG();
    }

    return self;
}

-(BOOL) setupSurfaceWithSharegroup:(EAGLSharegroup*)sharegroup
{
	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

	eaglLayer.opaque = YES;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:_preserveBackbuffer], kEAGLDrawablePropertyRetainedBacking,
									_pixelformat, kEAGLDrawablePropertyColorFormat, nil];

	// ES2 renderer only
	_renderer = [[CCES2Renderer alloc] initWithDepthFormat:_depthFormat
										 withPixelFormat:[self convertPixelFormat:_pixelformat]
										  withSharegroup:sharegroup
									   withMultiSampling:_multiSampling
									 withNumberOfSamples:_requestedSamples];

	NSAssert( _renderer, @"OpenGL ES 2.0 is required");

	if (!_renderer)
		return NO;

	_context = [_renderer context];

    _discardFramebufferSupported = [[CCConfiguration sharedConfiguration] supportsDiscardFramebuffer];

	CC_CHECK_GL_ERROR_DEBUG();

	return YES;
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);

}

- (void) layoutSubviews
{
    [_renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    
	_size = [_renderer backingSize];
    
	// Issue #914 #924
	CCDirector *director = [CCDirector sharedDirector];
	[director reshapeProjection:_size];

	// Avoid flicker. Issue #350
	// Only draw if there is something to draw, otherwise it actually creates a flicker of the current glClearColor
//	if(director.runningScene){
//		NSThread *thread = [director runningThread];
//		[director performSelector:@selector(drawScene) onThread:thread withObject:nil waitUntilDone:YES];
//	}
}

// Find or make a fence that is ready to use.
-(CCGLViewFence *)getReadyFence
{
	// First checkf oldest (first in the array) fence is ready again.
	CCGLViewFence *fence = _fences.firstObject;;
	if(fence.isReady){
		// Remove the fence so it can be inserted at the end of the queue again.
		[_fences removeObjectAtIndex:0];
		return fence;
	} else {
		// No existing fences ready. Make a new one.
		return [[CCGLViewFence alloc] init];
	}
}

-(void)addFrameCompletionHandler:(dispatch_block_t)handler
{
	if(_fences == nil){
		_fences = [NSMutableArray arrayWithObject:[[CCGLViewFence alloc] init]];
	}
	
	CCGLViewFence *fence = _fences.lastObject;
	if(!fence.isReady){
		fence = [self getReadyFence];
		[_fences addObject:fence];
	}
	
	[fence.handlers addObject:handler];
}

-(void)beginFrame {}

-(void)presentFrame
{
    // IMPORTANT:
	// - preconditions
	//	-> _context MUST be the OpenGL context
	//	-> renderbuffer_ must be the the RENDER BUFFER
	
	{
		CCGLViewFence *fence = _fences.lastObject;
		if(fence.isReady){
			// If the fence is ready to be added, insert a sync point for it.
			[fence insertFence];
		}
	}
	
	if (_multiSampling)
	{
		/* Resolve from msaaFramebuffer to resolveFramebuffer */
		//glDisable(GL_SCISSOR_TEST);
		glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, [_renderer msaaFrameBuffer]);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, [_renderer defaultFrameBuffer]);
		glResolveMultisampleFramebufferAPPLE();
	}
    
	if( _discardFramebufferSupported)
	{
		if (_multiSampling)
		{
			if (_depthFormat)
			{
				GLenum attachments[] = {GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT};
				glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, attachments);
			}
			else
			{
				GLenum attachments[] = {GL_COLOR_ATTACHMENT0};
				glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 1, attachments);
			}
            
			glBindRenderbuffer(GL_RENDERBUFFER, [_renderer colorRenderBuffer]);
            
		}
        
		// not MSAA
		else if (_depthFormat ) {
			GLenum attachments[] = { GL_DEPTH_ATTACHMENT};
			glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, attachments);
		}
	}
    
	if(![_context presentRenderbuffer:GL_RENDERBUFFER])
		CCLOG(@"cocos2d: Failed to swap renderbuffer in %s\n", __FUNCTION__);
    
	// We can safely re-bind the framebuffer here, since this will be the
	// 1st instruction of the new main loop
	if( _multiSampling )
		glBindFramebuffer(GL_FRAMEBUFFER, [_renderer msaaFrameBuffer]);
	
	// Check the fences for completion.
	for(CCGLViewFence *fence in _fences){
		if(fence.isComplete){
			for(dispatch_block_t handler in fence.handlers) handler();
			[fence.handlers removeAllObjects];
		} else {
			break;
		}
	}
	
	CC_CHECK_GL_ERROR_DEBUG();
}

- (unsigned int) convertPixelFormat:(NSString*) pixelFormat
{
	// define the pixel format
	GLenum pFormat;


	if([pixelFormat isEqualToString:@"EAGLColorFormat565"])
		pFormat = GL_RGB565;
	else
		pFormat = GL_RGBA8_OES;

	return pFormat;
}

#pragma mark CCGLView - Touch Delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchEvent.timestamp = event.timestamp;
    [_touchEvent updateTouchesBegan:touches];
    [[CCDirector sharedDirector].responderManager touchesBegan:_touchEvent.currentTouches withEvent:_touchEvent];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchEvent.timestamp = event.timestamp;
    [_touchEvent updateTouchesMoved:touches];
    [[CCDirector sharedDirector].responderManager touchesMoved:_touchEvent.currentTouches withEvent:_touchEvent];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchEvent.timestamp = event.timestamp;
    [_touchEvent updateTouchesEnded:touches];
    [[CCDirector sharedDirector].responderManager touchesEnded:_touchEvent.currentTouches withEvent:_touchEvent];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchEvent.timestamp = event.timestamp;
    [_touchEvent updateTouchesCancelled:touches];
    [[CCDirector sharedDirector].responderManager touchesCancelled:_touchEvent.currentTouches withEvent:_touchEvent];
}
 
@end


#endif // __CC_PLATFORM_IOS
