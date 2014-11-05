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
#import "../../CCDirector.h"
#import "../../ccMacros.h"
#import "../../CCConfiguration.h"
#import "CCScene.h"
#import "CCTouch.h"
#import "CCTouchEvent.h"

#import "CCDirector_Private.h"
#import "CCRenderDispatch.h"


extern EAGLContext *CCRenderDispatchSetupGL(EAGLRenderingAPI api, EAGLSharegroup *sharegroup);


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
	
	EAGLContext *_context;

	NSString *_pixelFormat;
	GLuint _depthFormat;
	BOOL _preserveBackbuffer;
	BOOL _discardFramebufferSupported;

	GLuint _depthBuffer;
	GLuint _colorRenderbuffer;
	GLuint _defaultFramebuffer;
	
	GLuint	_msaaSamples;
	GLuint _msaaFramebuffer;
	GLuint _msaaColorbuffer;
	
	GLint _backingWidth;
	GLint _backingHeight;
}

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
		_pixelFormat = format;
		_depthFormat = depth;
		_multiSampling = sampling;
		_preserveBackbuffer = retained;
		_msaaSamples = nSamples;
		
		// Default to the screen's native scale.
		UIScreen *screen = [UIScreen mainScreen];
		if([screen respondsToSelector:@selector(nativeScale)]){
			self.contentScaleFactor = screen.nativeScale;
		} else {
			self.contentScaleFactor = screen.scale;
		}

		if( ! [self setupSurfaceWithSharegroup:sharegroup] ) {
			return nil;
		}
        
        /** Multiple touch default enabled
         */
        self.multipleTouchEnabled = YES;

        _touchEvent = [[CCTouchEvent alloc] init];
	}

	return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	if( (self = [super initWithCoder:aDecoder]) ) {

		CAEAGLLayer* eaglLayer = (CAEAGLLayer*)[self layer];

		_pixelFormat = kEAGLColorFormatRGB565;
		_depthFormat = 0; // GL_DEPTH_COMPONENT24;
		_multiSampling= NO;
		_msaaSamples = 0;

		if( ! [self setupSurfaceWithSharegroup:nil] ) {
			return nil;
		}
    }

    return self;
}

-(BOOL) setupSurfaceWithSharegroup:(EAGLSharegroup*)sharegroup
{
	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

	eaglLayer.opaque = YES;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:_preserveBackbuffer], kEAGLDrawablePropertyRetainedBacking,
									_pixelFormat, kEAGLDrawablePropertyColorFormat, nil];

	// ES2 renderer only
#if CC_RENDER_DISPATCH_ENABLED
	_context = CCRenderDispatchSetupGL(kEAGLRenderingAPIOpenGLES2, sharegroup);
#else
	_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:sharegroup];
	
	if(!_context || ![EAGLContext setCurrentContext:_context]){
		return NO;
	}
#endif
	
	CCRenderDispatch(NO, ^{
		// Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
		glGenFramebuffers(1, &_defaultFramebuffer);
		glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
		
		glGenRenderbuffers(1, &_colorRenderbuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);

		if (_multiSampling){
			/* Create the MSAA framebuffer (offscreen) */
			glGenFramebuffers(1, &_msaaFramebuffer);
			glBindFramebuffer(GL_FRAMEBUFFER, _msaaFramebuffer);
		}

		CC_CHECK_GL_ERROR_DEBUG();
	});
	
	_discardFramebufferSupported = [[CCConfiguration sharedConfiguration] supportsDiscardFramebuffer];

	return YES;
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);

}

-(void)resizeFromLayer:(CAEAGLLayer *)layer
{
	CCRenderDispatch(NO, ^{
		GLint maxSamples;
		glGetIntegerv(GL_MAX_SAMPLES_APPLE, &maxSamples);
		GLint msaaSamples = MIN(maxSamples, _msaaSamples);
		
		glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);

		// Allocate color buffer backing based on the current layer size
		BOOL rb_status = [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
		NSAssert(rb_status, @"Failed to create renderbuffer.");

		glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
		glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);

		CCLOG(@"cocos2d: surface size: %dx%d", (int)_backingWidth, (int)_backingHeight);

		if(_multiSampling){
			glDeleteRenderbuffers(1, &_msaaColorbuffer);
			glGenRenderbuffers(1, &_msaaColorbuffer);
			
			glBindRenderbuffer(GL_RENDERBUFFER, _msaaColorbuffer);
			glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, msaaSamples, [self convertPixelFormat:_pixelFormat] , _backingWidth, _backingHeight);
			
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _msaaColorbuffer);
		}

		if(_depthFormat){
			glDeleteRenderbuffers(1, &_depthBuffer);
			glGenRenderbuffers(1, &_depthBuffer);

			glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
			
			if(_multiSampling){
				glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, msaaSamples, _depthFormat,_backingWidth, _backingHeight);
			} else {
				glRenderbufferStorage(GL_RENDERBUFFER, _depthFormat, _backingWidth, _backingHeight);
			}
			
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);

			if(_depthFormat == GL_DEPTH24_STENCIL8_OES){
				glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
			}
		}
		
		GLenum fb_status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
		NSAssert(fb_status == GL_FRAMEBUFFER_COMPLETE, @"Failed to make complete framebuffer object 0x%X", fb_status);
		CC_CHECK_GL_ERROR_DEBUG();
	});
}

- (void) layoutSubviews
{
	[self resizeFromLayer:(CAEAGLLayer*)self.layer];
    
	// Issue #914 #924
	CCDirector *director = [CCDirector sharedDirector];
	[director reshapeProjection:CGSizeMake( _backingWidth, _backingHeight)];

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
	{
		CCGLViewFence *fence = _fences.lastObject;
		if(fence.isReady){
			// If the fence is ready to be added, insert a sync point for it.
			[fence insertFence];
		}
	}
	
	if (_multiSampling){
		glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, _msaaFramebuffer);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, _defaultFramebuffer);
		glResolveMultisampleFramebufferAPPLE();
	}
    
	if(_discardFramebufferSupported){
		if(_multiSampling){
			if(_depthFormat){
				GLenum attachments[] = {GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT};
				glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, attachments);
			} else {
				GLenum attachments[] = {GL_COLOR_ATTACHMENT0};
				glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 1, attachments);
			}
		} else if(_depthFormat){
			GLenum attachments[] = { GL_DEPTH_ATTACHMENT};
			glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, attachments);
		}
	}
    
	glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
	if(![_context presentRenderbuffer:GL_RENDERBUFFER]){
		CCLOG(@"cocos2d: Failed to swap renderbuffer in %s\n", __FUNCTION__);
	}
    
	if(_multiSampling){
		glBindFramebuffer(GL_FRAMEBUFFER, _msaaFramebuffer);
	}
	
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

-(GLuint)fbo
{
	if(_multiSampling){
		return _msaaFramebuffer;
	} else {
		return _defaultFramebuffer;
	}
}

-(GLenum)convertPixelFormat:(NSString*)pixelFormat
{
	if([pixelFormat isEqualToString:@"EAGLColorFormat565"]){
		return GL_RGB565;
	} else {
		return GL_RGBA8_OES;
	}
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
