//
//  CCGLView.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 5/22/14.
//
//

#import "cocos2d.h"
#import "CCGLView.h"

#if __CC_PLATFORM_ANDROID

#import <android/native_window.h>
#import <bridge/runtime.h>
#import "CCTouchEvent.h"
#import "CCTouch.h"
#import "CCActivity.h"
#import "CCResponderManager.h"
#import "CCTouchAndroid.h"
#import <CoreGraphics/CGGeometry.h>

#import <AndroidKit/AndroidMotionEvent.h>
#import <AndroidKit/AndroidGestureDetector.h>

static const CGSize FIXED_SIZE = {586, 384};

static NSMutableDictionary *touches = nil;
static CCTouchEvent *currentEvent = nil;

@implementation CCGLView {
    NSMutableSet *_gestureDetectors;
}


- (id)initWithContext:(AndroidContext *)context screenMode:(enum CCAndroidScreenMode)screenMode  scaleFactor:(float)scaleFactor
{
    self = [self initWithContext:context];
    if (self)
    {
        _contentScaleFactor = scaleFactor;
        _screenMode = screenMode;
    }
    return self;
}

- (void)dealloc
{
    [_gestureDetectors release];
    [super dealloc];
}

- (void)addGestureDetector:(AndroidGestureDetector *)detector
{
    if (_gestureDetectors == nil) {
        _gestureDetectors = [[NSMutableSet alloc] init];
    }
    
    [_gestureDetectors addObject:detector];
}

- (void)removeGestureDetector:(AndroidGestureDetector *)detector
{
    [_gestureDetectors removeObject:detector];
}

- (BOOL)onTouchEvent:(AndroidMotionEvent *)event
{
    assert(pthread_main_np());
    @autoreleasepool {
        BOOL cancelTouch = NO;
        for (AndroidGestureDetector *detector in _gestureDetectors) {
            cancelTouch = [detector onTouchEvent:event];
        }
        
        
        static dispatch_once_t once = 0L;
        dispatch_once(&once, ^{
            touches = [[NSMutableDictionary alloc] init];
            currentEvent = [[CCTouchEvent alloc] init];
        });
        
        CCTouchEvent *ev = nil;
        CCTouchPhase phase = CCTouchPhaseStationary;
        switch (event.action & AndroidMotionEventActionMask) {
            case AndroidMotionEventActionPointerDown:
            case AndroidMotionEventActionDown:
                phase = CCTouchPhaseBegan;
                break;
            case AndroidMotionEventActionMove:
                phase = CCTouchPhaseMoved;
                break;
            case AndroidMotionEventActionPointerUp:
            case AndroidMotionEventActionUp:
                phase = CCTouchPhaseEnded;
                break;
            case AndroidMotionEventActionCancel:
                phase = CCTouchPhaseCancelled;
                break;
            default:
                return NO;
        }
        
        if(cancelTouch)
        {
            phase = CCTouchPhaseCancelled;
        }
        
        NSTimeInterval timestamp = event.eventTime * 1000.0;
        currentEvent.timestamp = timestamp;
        NSMutableSet *eventTouches = [NSMutableSet set];
        int32_t pointerIndex = -1;
        if (phase == CCTouchPhaseBegan ||
            phase == CCTouchPhaseEnded) {
            pointerIndex = event.actionIndex;
        }
        for (int32_t i = 0; i < event.pointerCount; i++) {
            if ((phase == CCTouchPhaseBegan ||
                 phase == CCTouchPhaseEnded) && i != pointerIndex) {
                continue;
            }
            NSNumber *identifier = @([event pointerIdForPointerIndex:i]);
            CGPoint pt;
            pt.x = [event xForPointerIndex:i] / _contentScaleFactor;
            pt.y = [event yForPointerIndex:i] / _contentScaleFactor;
            CCTouchAndroid *touch = touches[identifier];
            if (touch == nil) {
                touch = [[CCTouchAndroid alloc] init];
                touches[identifier] = touch;
                [touch release];
            }
            
            [touch update:pt phase:phase timestamp:timestamp];
            [eventTouches addObject:touch];
        }
        
        
        switch (phase) {
            case CCTouchPhaseBegan:
                [currentEvent updateTouchesBegan:eventTouches];
                break;
            case CCTouchPhaseMoved:
                [currentEvent updateTouchesMoved:eventTouches];
                break;
            case CCTouchPhaseEnded:
                [currentEvent updateTouchesEnded:eventTouches];
                break;
            case CCTouchPhaseCancelled:
                [currentEvent updateTouchesCancelled:eventTouches];
                break;
            default:
                break;
        }
        
        [[CCActivity currentActivity] runOnGameThread:^{
            CCResponderManager *mgr = [[CCDirector sharedDirector] responderManager];
            switch (phase) {
                case CCTouchPhaseBegan:
                    [mgr touchesBegan:eventTouches withEvent:currentEvent];
                    break;
                case CCTouchPhaseMoved:
                    [mgr touchesMoved:eventTouches withEvent:currentEvent];
                    break;
                case CCTouchPhaseEnded:
                    [mgr touchesEnded:eventTouches withEvent:currentEvent];
                    break;
                case CCTouchPhaseCancelled:
                    [mgr touchesCancelled:eventTouches withEvent:currentEvent];
                    break;
                default:
                    break;
            }
            
        } waitUntilDone:YES];
    }
    
    return YES;
}

static inline void logConfig(EGLDisplay display, EGLConfig conf) {
    EGLint value;
    
    eglGetConfigAttrib(display, conf, EGL_RED_SIZE, &value);
    NSLog(@"EGL_RED_SIZE = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_GREEN_SIZE, &value);
    NSLog(@"EGL_GREEN_SIZE = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_BLUE_SIZE, &value);
    NSLog(@"EGL_BLUE_SIZE = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_ALPHA_SIZE, &value);
    NSLog(@"EGL_ALPHA_SIZE = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_DEPTH_SIZE, &value);
    NSLog(@"EGL_DEPTH_SIZE = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_STENCIL_SIZE, &value);
    NSLog(@"EGL_STENCIL_SIZE = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_BUFFER_SIZE, &value);
    NSLog(@"EGL_BUFFER_SIZE = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_CONFIG_ID, &value);
    NSLog(@"EGL_CONFIG_ID = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_LEVEL, &value);
    NSLog(@"EGL_LEVEL = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_MAX_PBUFFER_WIDTH, &value);
    NSLog(@"EGL_MAX_PBUFFER_WIDTH = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_MAX_PBUFFER_HEIGHT, &value);
    NSLog(@"EGL_MAX_PBUFFER_HEIGHT = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_MAX_PBUFFER_PIXELS, &value);
    NSLog(@"EGL_MAX_PBUFFER_PIXELS = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_NATIVE_VISUAL_ID, &value);
    NSLog(@"EGL_NATIVE_VISUAL_ID = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_NATIVE_VISUAL_TYPE, &value);
    NSLog(@"EGL_NATIVE_VISUAL_TYPE = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_SAMPLE_BUFFERS, &value);
    NSLog(@"EGL_SAMPLE_BUFFERS = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_SAMPLES, &value);
    NSLog(@"EGL_SAMPLES = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_TRANSPARENT_TYPE, &value);
    NSLog(@"EGL_TRANSPARENT_TYPE = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_CONFIG_CAVEAT, &value);
    NSLog(@"EGL_CONFIG_CAVEAT = %d (%d,%d,%d)", value, EGL_NONE, EGL_SLOW_CONFIG, EGL_NON_CONFORMANT_CONFIG);
    
    eglGetConfigAttrib(display, conf, EGL_NATIVE_RENDERABLE, &value);
    NSLog(@"EGL_NATIVE_RENDERABLE = %d", value);
    
    eglGetConfigAttrib(display, conf, EGL_SURFACE_TYPE, &value);
    NSLog(@"EGL_SURFACE_TYPE = %d EGL_WINDOW_BIT=%d EGL_PBUFFER_BIT=%d EGL_PIXMAP_BIT=%d", value, EGL_WINDOW_BIT, EGL_PBUFFER_BIT, EGL_PIXMAP_BIT);
}

- (BOOL)setupView:(ANativeWindow*)window
{
    const EGLint configAttribs[] = {
        EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
        EGL_BLUE_SIZE, 8,
        EGL_GREEN_SIZE, 8,
        EGL_RED_SIZE, 8,
        EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
//        EGL_CONTEXT_CLIENT_VERSION, 2,
        EGL_NONE
    };
    
    const EGLint contextAttribs[] = {
        EGL_CONTEXT_CLIENT_VERSION, 2,
        EGL_NONE
    };

    EGLint numConfigs;
    EGLint format;
    EGLint width;
    EGLint height;
    GLfloat ratio;
    
    if(!eglBindAPI(EGL_OPENGL_ES_API))
        NSLog(@"EGL ERROR - Failed to bind egl API");
    
    _eglDisplay = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if(_eglDisplay == EGL_NO_DISPLAY)
    {
        NSLog(@"eglGetDisplay() returned error %d", eglGetError());
        return NO;
    }
    
    if(eglGetError() != EGL_SUCCESS) { NSLog(@"EGL ERROR: %i", eglGetError()); };
    
    if(!eglInitialize(_eglDisplay, NULL, NULL))
    {
        NSLog(@"eglInitialize() returned error %d", eglGetError());
        return NO;
    }
    
    if(eglGetError() != EGL_SUCCESS) { NSLog(@"EGL ERROR: %i", eglGetError()); };
    
    eglGetConfigs(_eglDisplay, nil, 0, &numConfigs);
    
    EGLConfig *configs = alloca(numConfigs * sizeof(EGLConfig));
    eglGetConfigs(_eglDisplay, configs, numConfigs, &numConfigs);
    
     // TODO: Fixme, these values should be more easily configured
    BOOL depthBuffer = YES;
    BOOL stencilBuffer = YES;
    static EGLint colorSizes[4] = { 8, 8, 8, 8 };
    switch ([CCTexture defaultAlphaPixelFormat])
    {
        case CCTexturePixelFormat_RGBA8888:
            colorSizes[0] = 8;
            colorSizes[1] = 8;
            colorSizes[2] = 8;
            colorSizes[3] = 8;
            break;
        case CCTexturePixelFormat_RGB565:
            colorSizes[0] = 5;
            colorSizes[1] = 6;
            colorSizes[2] = 5;
            colorSizes[3] = 0;
            break;
        case CCTexturePixelFormat_RGBA4444:
            colorSizes[0] = 4;
            colorSizes[1] = 4;
            colorSizes[2] = 4;
            colorSizes[3] = 4;
            break;
    }
    BOOL isATC = NO;
    
    
    qsort_b(configs, numConfigs, sizeof(EGLConfig), ^int(const void *A, const void *B) {
        EGLConfig configA = *(EGLConfig *)A;
        EGLConfig configB = *(EGLConfig *)B;
        
        int result = 0;
        EGLint value = 0;
        EGLint sizeA = 0;
        EGLint sizeB = 0;
        EGLint colorSizesA[4];
        EGLint colorSizesB[4];
        BOOL nonConformantA = NO, slowA = NO, nonWindowA = NO;
        BOOL nonConformantB = NO, slowB = NO, nonWindowB = NO;

        eglGetConfigAttrib(_eglDisplay, (EGLConfig)configA, EGL_CONFIG_CAVEAT, &value);
        if (value == EGL_NON_CONFORMANT_CONFIG) {
            nonConformantA = YES;
        } else if (value == EGL_SLOW_CONFIG) {
            slowA = YES;
        }
        
        eglGetConfigAttrib(_eglDisplay, (EGLConfig)configB, EGL_CONFIG_CAVEAT, &value);
        if (value == EGL_NON_CONFORMANT_CONFIG) {
            nonConformantB = YES;
        } else if (value == EGL_SLOW_CONFIG) {
            slowB = YES;
        }
        
        if (nonConformantA && nonConformantB) {
            return 0;
        } else if (nonConformantA) {
            return 1;
        } else if (nonConformantB) {
            return -1;
        }
        
        if (slowA && slowB) {
            return 0;
        } else if (slowA && !isATC) {
            return 1;
        } else if (slowB && !isATC) {
            return -1;
        } else if (slowA && isATC) {
            result--;
        } else if (slowB && isATC) {
            result++;
        }
        
        eglGetConfigAttrib(_eglDisplay, (EGLConfig)configA, EGL_SURFACE_TYPE, &value);
        if ((value & EGL_WINDOW_BIT) == 0) {
            nonWindowA = YES;
        }

        if ((value & EGL_PBUFFER_BIT) == 0) {
            result -= 2;
        }
        
        if ((value & EGL_PIXMAP_BIT) == 0) {
            result -= 2;
        }
        
        eglGetConfigAttrib(_eglDisplay, (EGLConfig)configB, EGL_SURFACE_TYPE, &value);
        if ((value & EGL_WINDOW_BIT) == 0) {
            nonWindowB = YES;
        }
        if ((value & EGL_PBUFFER_BIT) == 0) {
            result += 2;
        }
        
        if ((value & EGL_PIXMAP_BIT) == 0) {
            result += 2;
        }
        
        if (nonWindowA && nonWindowB) {
            return 0;
        } else if (nonWindowA) {
            return 1;
        } else if (nonWindowB) {
            return -1;
        }
        
        if (depthBuffer) {
            eglGetConfigAttrib(_eglDisplay, (EGLConfig)configA, EGL_DEPTH_SIZE, &sizeA);
            eglGetConfigAttrib(_eglDisplay, (EGLConfig)configB, EGL_DEPTH_SIZE, &sizeB);
            
            if (sizeA <= 0 && sizeB <= 0) {
                return 0;
            } else if (sizeA <= 0) {
                return 1;
            } else if (sizeB <= 0) {
                return -1;
            }
        }
        
        if (stencilBuffer) {
            eglGetConfigAttrib(_eglDisplay, (EGLConfig)configA, EGL_STENCIL_SIZE, &sizeA);
            eglGetConfigAttrib(_eglDisplay, (EGLConfig)configB, EGL_STENCIL_SIZE, &sizeB);
            
            if (sizeA <= 0 && sizeB <= 0) {
                return 0;
            } else if (sizeA <= 0) {
                return 1;
            } else if (sizeB <= 0) {
                return -1;
            }
        }

        eglGetConfigAttrib(_eglDisplay, (EGLConfig)configA, EGL_NATIVE_RENDERABLE, &value);

        if (value > 0) {
            result -= isATC ? 64 : 8;
        }
        
        eglGetConfigAttrib(_eglDisplay, (EGLConfig)configB, EGL_NATIVE_RENDERABLE, &value);
        
        if (value > 0) {
            result += isATC ? 64 : 8;
        }
        
        eglGetConfigAttrib(_eglDisplay, (EGLConfig)configA, EGL_RED_SIZE, &colorSizesA[0]);
        eglGetConfigAttrib(_eglDisplay, (EGLConfig)configA, EGL_GREEN_SIZE, &colorSizesA[1]);
        eglGetConfigAttrib(_eglDisplay, (EGLConfig)configA, EGL_BLUE_SIZE, &colorSizesA[2]);
        eglGetConfigAttrib(_eglDisplay, (EGLConfig)configA, EGL_ALPHA_SIZE, &colorSizesA[3]);

        eglGetConfigAttrib(_eglDisplay, (EGLConfig)configB, EGL_RED_SIZE, &colorSizesB[0]);
        eglGetConfigAttrib(_eglDisplay, (EGLConfig)configB, EGL_GREEN_SIZE, &colorSizesB[1]);
        eglGetConfigAttrib(_eglDisplay, (EGLConfig)configB, EGL_BLUE_SIZE, &colorSizesB[2]);
        eglGetConfigAttrib(_eglDisplay, (EGLConfig)configB, EGL_ALPHA_SIZE, &colorSizesB[3]);
        
        if (colorSizesA[0] == colorSizes[0] &&
            colorSizesA[1] == colorSizes[1] &&
            colorSizesA[2] == colorSizes[2] &&
            colorSizesA[3] == colorSizes[3]) {
            result -= 4;
        }
        
        if (colorSizesB[0] == colorSizes[0] &&
            colorSizesB[1] == colorSizes[1] &&
            colorSizesB[2] == colorSizes[2] &&
            colorSizesB[3] == colorSizes[3]) {
            result += 4;
        }
        
        return result;
    });
    
    _eglConfiguration = configs[0];
    
    logConfig(_eglDisplay, _eglConfiguration);

    if(!eglChooseConfig(_eglDisplay, configAttribs, &_eglConfiguration, 1, &numConfigs))
    {
        NSLog(@"eglChooseConfig() returned error %d", eglGetError());
        return NO;
    }

    if(eglGetError() != EGL_SUCCESS) { NSLog(@"EGL ERROR: %i", eglGetError()); };
    
    if(!eglGetConfigAttrib(_eglDisplay, _eglConfiguration, EGL_NATIVE_VISUAL_ID, &format))
    {
        NSLog(@"eglGetConfigAttrib() returned error %d", eglGetError());
        return NO;
    }
    
    if(eglGetError() != EGL_SUCCESS) { NSLog(@"EGL ERROR: %i", eglGetError()); };
    
    ANativeWindow_setBuffersGeometry(window, 0, 0, format);
    
    if(!(_eglSurface = eglCreateWindowSurface(_eglDisplay, _eglConfiguration, window, 0)))
    {
        NSLog(@"eglCreateWindowSurface() returned error %d", eglGetError());
        return NO;
    }
    
    if(eglGetError() != EGL_SUCCESS) { NSLog(@"EGL ERROR: %i", eglGetError()); };
    
    if(_eglContext == nil)
    {
        if(!(_eglContext = eglCreateContext(_eglDisplay, _eglConfiguration, 0, contextAttribs)))
        {
            NSLog(@"eglCreateContext() returned error %d", eglGetError());
            return NO;
        
        }
    }
    
    if(eglGetError() != EGL_SUCCESS) { NSLog(@"EGL ERROR: %i", eglGetError()); };
    
    if(!eglMakeCurrent(_eglDisplay, _eglSurface, _eglSurface, _eglContext))
    {
        NSLog(@"eglMakeCurrent() returned error %d", eglGetError());
        return NO;
    }
    
    if(eglGetError() != EGL_SUCCESS) { NSLog(@"EGL ERROR: %i", eglGetError()); };
    
    if(!eglQuerySurface(_eglDisplay, _eglSurface, EGL_WIDTH, &width) ||
        !eglQuerySurface(_eglDisplay, _eglSurface, EGL_HEIGHT, &height))
    {
        NSLog(@"eglQuerySurface() returned error %d", eglGetError());
        return NO;
    }

	CCLOG(@"cocos2d: surface size: %dx%d", (int)width, (int)height);

    switch (_screenMode)
    {
        case CCNativeScreenMode:
        {
            width /= _contentScaleFactor;
            height /= _contentScaleFactor;
        }
        break;
        
        case CCScreenScaledAspectFitEmulationMode:
        {
            CGSize size = CGSizeMake(width, height);
            if (width > height)
                size = CGSizeMake(height, width);
            
            _contentScaleFactor = size.width / FIXED_SIZE.width;
            
            width /= _contentScaleFactor;
            height /= _contentScaleFactor;
        }
        break;
            
            
        default:
            CCLOGWARN(@"WARNING: Failed to identify screen mode");
        break;
            
    }
    
    
    if(eglGetError() != EGL_SUCCESS) { NSLog(@"EGL ERROR: %i", eglGetError()); };
    
    _bounds = CGRectMake(0, 0, width, height);
    
    return YES;
}

- (void)swapBuffers
{
    eglSwapBuffers(_eglDisplay, _eglSurface);
}

#warning TODO temporary
-(void)addFrameCompletionHandler:(dispatch_block_t)handler
{
	handler();
}

-(void)beginFrame {}

#warning TODO temporary
-(void)presentFrame
{
	[self swapBuffers];
}

-(GLuint)fbo
{
	return 0;
}

@end
#endif // __CC_PLATFORM_ANDROID



