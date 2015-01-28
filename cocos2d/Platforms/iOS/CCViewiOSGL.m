//
//  CCViewiOSGL.m
//  cocos2d
//
//  Created by Oleg Osin on 1/8/15.
//
//


// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
#import "ccMacros.h"
#if __CC_PLATFORM_IOS

#import <QuartzCore/QuartzCore.h>

#import "CCViewiOSGL.h"
#import "CCDirector.h"
#import "ccMacros.h"
#import "CCDeviceInfo.h"
#import "CCScene.h"
#import "CCTouch.h"
#import "CCTouchEvent.h"

#import "CCDirector_Private.h"
#import "CCRenderDispatch.h"

#import "CCGLFence.h"

extern EAGLContext *CCRenderDispatchSetupGL(EAGLRenderingAPI api, EAGLSharegroup *sharegroup);

@implementation CCViewiOSGL {
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

@synthesize director = _director;

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
        
        _director = [CCDirector director];
        _director.view = self;
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
    
    _discardFramebufferSupported = [[CCDeviceInfo sharedDeviceInfo] supportsDiscardFramebuffer];
    
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
    [_director reshapeProjection:CGSizeMake( _backingWidth, _backingHeight)];
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

-(void)beginFrame {}

-(void)presentFrame
{
    {
        CCGLFence *fence = _fences.lastObject;
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
    for(CCGLFence *fence in _fences){
        if(fence.isCompleted){
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
    
    [CCDirector pushCurrentDirector:_director];
    [_touchEvent updateTouchesBegan:touches];
    [_director.responderManager touchesBegan:_touchEvent.currentTouches withEvent:_touchEvent];
    [CCDirector popCurrentDirector];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchEvent.timestamp = event.timestamp;
    
    [CCDirector pushCurrentDirector:_director];
    [_touchEvent updateTouchesMoved:touches];
    [_director.responderManager touchesMoved:_touchEvent.currentTouches withEvent:_touchEvent];
    [CCDirector popCurrentDirector];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchEvent.timestamp = event.timestamp;
    
    [CCDirector pushCurrentDirector:_director];
    [_touchEvent updateTouchesEnded:touches];
    [_director.responderManager touchesEnded:_touchEvent.currentTouches withEvent:_touchEvent];
    [CCDirector popCurrentDirector];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchEvent.timestamp = event.timestamp;
    
    [CCDirector pushCurrentDirector:_director];
    [_touchEvent updateTouchesCancelled:touches];
    [_director.responderManager touchesCancelled:_touchEvent.currentTouches withEvent:_touchEvent];
    [CCDirector popCurrentDirector];
}

@end

#endif
