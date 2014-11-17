//
//  CCActivity.m
//  Cocos2d
//
//  Created by Philippe Hausler on 6/12/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCActivity.h"

#if __CC_PLATFORM_ANDROID

#import <android/native_window.h>
#import <bridge/runtime.h>

#import "cocos2d.h"
#import "CCBReader.h"
#import "CCGLView.h"
#import "CCScene.h"
#import <android/looper.h>

#define USE_MAIN_THREAD 0 // enable to run on OpenGL/Cocos2D on the android main thread

// Provided from foundation
@interface NSValue (NSValueGeometryExtensions)

+ (NSValue *)valueWithCGPoint:(CGPoint)point;
+ (NSValue *)valueWithCGSize:(CGSize)size;
+ (NSValue *)valueWithCGRect:(CGRect)rect;
+ (NSValue *)valueWithCGAffineTransform:(CGAffineTransform)transform;

- (CGPoint)CGPointValue;
- (CGSize)CGSizeValue;
- (CGRect)CGRectValue;
- (CGAffineTransform)CGAffineTransformValue;

@end

extern ANativeWindow *ANativeWindow_fromSurface(JNIEnv *env, jobject surface);

static CCActivity *currentActivity = nil;

@implementation CCActivity {
    CCGLView *_glView;
    NSThread *_thread;
    BOOL _running;
    NSRunLoop *_gameLoop;
    NSMutableDictionary *_cocos2dSetupConfig;
}
@synthesize layout=_layout;

@bridge (callback) run = run;
@bridge (callback) onDestroy = onDestroy;
@bridge (callback) onPause = onPause;
@bridge (callback) onResume = onResume;
@bridge (callback) onLowMemory = onLowMemory;
@bridge (callback) surfaceCreated: = surfaceCreated;
@bridge (callback) surfaceDestroyed: = surfaceDestroyed;
@bridge (callback) surfaceChanged:format:width:height: = surfaceChanged;
@bridge (callback) onKeyDown:keyEvent: = onKeyDown;
@bridge (callback) onKeyUp:keyEvent: = onKeyUp;

- (void)dealloc
{
    currentActivity = nil;
    [_glView release];
    [_layout release];
    [_thread release];
    [_cocos2dSetupConfig release];
    [super dealloc];
}

+ (instancetype)currentActivity
{
    return currentActivity;
}

static void handler(NSException *e)
{
    NSLog(@"Unhandled exception %@", e);
}

- (void)run
{
    if (_running) {
        return;
    }
    NSSetUncaughtExceptionHandler(&handler);
    currentActivity = self;
    _running = YES;
    _layout = [[AndroidRelativeLayout alloc] initWithContext:self];
    AndroidDisplayMetrics *metrics = [[AndroidDisplayMetrics alloc] init];
    [self.windowManager.defaultDisplay getMetrics:metrics];
    
    // Configure Cocos2d with the options set in SpriteBuilder
    NSString* configPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Published-Android"];
    
    configPath = [configPath stringByAppendingPathComponent:@"configCocos2d.plist"];
    
    _cocos2dSetupConfig = [[NSMutableDictionary dictionaryWithContentsOfFile:configPath] retain];
    
    enum CCAndroidScreenMode screenMode = CCNativeScreenMode;
    
    if([_cocos2dSetupConfig[CCSetupScreenMode] isEqual:CCScreenModeFlexible] ||
       [_cocos2dSetupConfig[CCSetupScreenMode] isEqual:CCScreenModeFixed])
    {
        screenMode = CCScreenScaledAspectFitEmulationMode;
    }
    
    if([_cocos2dSetupConfig[CCSetupScreenOrientation] isEqual:CCScreenOrientationPortrait])
    {
        self.requestedOrientation = AndroidActivityInfoScreenOrientationSensorPortrait;
    }
    else if([_cocos2dSetupConfig[CCSetupScreenOrientation] isEqual:CCScreenOrientationLandscape])
    {
        self.requestedOrientation = AndroidActivityInfoScreenOrientationSensorLandscape;
    }
    else
    {
        self.requestedOrientation = AndroidActivityInfoScreenOrientationUnspecified;
    }
    
    _glView = [[CCGLView alloc] initWithContext:self screenMode:screenMode scaleFactor:metrics.density];
    [metrics release];
    [_glView.holder addCallback:self];
    [self.layout addView:_glView];
    [self setContentView:_layout];
    [[AndroidLooper currentLooper] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)onDestroy
{
    [[CCDirector sharedDirector] end];
    [super onDestroy];
    exit(0);
}

- (void)onResume
{
#if USE_MAIN_THREAD
    [self handleResume];
#else
    if(_thread == nil)
    {
        [super onResume];
        return;
    }
    
    [self performSelector:@selector(handleResume) onThread:_thread withObject:nil waitUntilDone:YES modes:@[NSDefaultRunLoopMode]];
#endif
    
    [super onResume];
}

- (void)handleResume
{
    [[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
    [[CCDirector sharedDirector] resume];
}

- (void)onPause
{
#if USE_MAIN_THREAD
    [self handlePause];
#else
    if(_thread == nil)
    {
        [super onPause];
        return;
    }
    
    [self performSelector:@selector(handlePause) onThread:_thread withObject:nil waitUntilDone:YES modes:@[NSDefaultRunLoopMode]];
#endif
    
    [super onPause];
}

- (void)handlePause
{
    [[CCDirector sharedDirector] pause];
    [[CCPackageManager sharedManager] savePackages];
}


- (void)onLowMemory
{
#if USE_MAIN_THREAD
    [self handleLowMemory];
#else
    if(_thread == nil)
    {
        [super onLowMemory];
        return;
    }

    [self performSelector:@selector(handleLowMemory) onThread:_thread withObject:nil waitUntilDone:YES modes:@[NSDefaultRunLoopMode]];
#endif

    [super onLowMemory];
}

- (void)handleLowMemory
{
    [[CCDirector sharedDirector] purgeCachedData];
    [[CCPackageManager sharedManager] savePackages];
}

- (void)reshape:(NSValue *)value
{
    CCDirectorAndroid *director = (CCDirectorAndroid*)[CCDirector sharedDirector];
	[director reshapeProjection:value.CGSizeValue]; // crashes sometimes..
}

- (void)surfaceChanged:(JavaObject<AndroidSurfaceHolder> *)holder format:(int)format width:(int)width height:(int)height
{
    if(_glView == nil)
        return;
    
    _glView.bounds = CGRectMake(0, 0, width/_glView.contentScaleFactor, height/_glView.contentScaleFactor);
    
#if USE_MAIN_THREAD
    [self reshape:[NSValue valueWithCGSize:CGSizeMake(width, height)]];
#else
    [self performSelector:@selector(reshape:) onThread:_thread withObject:[NSValue valueWithCGSize:CGSizeMake(width, height)] waitUntilDone:YES modes:@[NSDefaultRunLoopMode]];
#endif
}

- (void)setupView:(JavaObject<AndroidSurfaceHolder> *)holder
{
    ANativeWindow* window = ANativeWindow_fromSurface(bridge_getEnv(), bridge_getJava(holder.surface));
    [_glView setupView:window];
}

- (void)setupPaths
{
    [CCBReader configureCCFileUtils];
}

- (void)startGL:(JavaObject<AndroidSurfaceHolder> *)holder
{
    @autoreleasepool {
        
        _gameLoop = [NSRunLoop currentRunLoop];
        
        [_gameLoop addPort:[NSPort port] forMode:NSDefaultRunLoopMode]; // Ensure that _gameLoop always has a source.
        
        [self setupView:holder];
        
        [self setupPaths];
        
        CCDirectorAndroid *director = (CCDirectorAndroid*)[CCDirector sharedDirector];
        director.delegate = self;
        director.contentScaleFactor = _glView.contentScaleFactor;
        [CCTexture setDefaultAlphaPixelFormat:CCTexturePixelFormat_RGBA8888];
        [director setView:_glView];
        
        if([_cocos2dSetupConfig[CCSetupScreenMode] isEqual:CCScreenModeFixed])
        {
            CGSize fixed = {568, 384};
            if([_cocos2dSetupConfig[CCSetupScreenOrientation] isEqualToString:CCScreenOrientationPortrait])
            {
                CC_SWAP(fixed.width, fixed.height);
            }
            
            director.designSize = fixed;
            [director setProjection:CCDirectorProjectionCustom];
        }

        [[CCPackageManager sharedManager] loadPackages];

        [director runWithScene:[self startScene]];
        [director setAnimationInterval:1.0/60.0];
        [director startAnimation];
#if !USE_MAIN_THREAD
        [_gameLoop runUntilDate:[NSDate distantFuture]];
#endif
    }
}

- (CCScene *)startScene
{
    NSAssert([self class] != [CCActivity class], @"%s requires a subclass implementation", sel_getName(_cmd));
    return nil;
}

- (void)runOnGameThread:(dispatch_block_t)block
{
    [self runOnGameThread:block waitUntilDone:NO];
}

- (void)runOnGameThread:(dispatch_block_t)block waitUntilDone:(BOOL)waitUntilDone
{
#if !USE_MAIN_THREAD
    if (!waitUntilDone)
    {
        CFRunLoopPerformBlock([_gameLoop getCFRunLoop], kCFRunLoopDefaultMode, block);
    }
    else
    {
        [[Block_copy(block) autorelease] performSelector:@selector(invoke) onThread:_thread withObject:nil waitUntilDone:YES];
    }
#else
    EGLContext ctx = [self pushApplicationContext];
    block();
    [self popApplicationContext:ctx];
    
#endif
}

- (void)surfaceCreated:(JavaObject<AndroidSurfaceHolder> *)holder
{
#if USE_MAIN_THREAD
    [self startGL:holder];
#else
    if (_thread == nil)
    {
        _thread = [[NSThread alloc] initWithTarget:self selector:@selector(startGL:) object:holder];
        [_thread start];
    }
    else
    {
        [self performSelector:@selector(setupView:) onThread:_thread withObject:holder waitUntilDone:YES modes:@[NSDefaultRunLoopMode]];
        CCDirectorAndroid *director = (CCDirectorAndroid*)[CCDirector sharedDirector];
        [director performSelector:@selector(startAnimation) onThread:_thread withObject:nil waitUntilDone:YES modes:@[NSDefaultRunLoopMode]];
    }
#endif
}

- (void)surfaceDestroyed:(JavaObject<AndroidSurfaceHolder> *)holder
{
#if USE_MAIN_THREAD
    [self handleDestroy];
#else
    [self performSelector:@selector(handleDestroy) onThread:_thread withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
#endif
}

- (void)handleDestroy
{
    [[CCDirector sharedDirector] stopAnimation];
}

- (BOOL)onKeyDown:(int32_t)keyCode keyEvent:(AndroidKeyEvent *)event
{
    return NO;
}

- (BOOL)onKeyUp:(int32_t)keyCode keyEvent:(AndroidKeyEvent *)event
{
    return NO;
}

- (EGLContext)pushApplicationContext
{
    EGLDisplay display;
    EGLSurface surfaceR;
    EGLSurface surfaceD;
    
    EGLContext ctx = eglGetCurrentContext();
    
    EGLContext appContext = _glView.eglContext;
    if (appContext != ctx)
    {
        display = eglGetCurrentDisplay();
        surfaceD = eglGetCurrentSurface(EGL_DRAW);
        surfaceR = eglGetCurrentSurface(EGL_READ);
        
        EGLSurface surface = _glView.eglSurface;
        
        eglMakeCurrent(_glView.eglDisplay, surface, surface, appContext);
        return ctx;
    }
    
    return NULL;
}

- (void)popApplicationContext:(EGLContext)ctx
{
    if (ctx != NULL)
    {
        EGLDisplay display;
        EGLSurface surfaceR;
        EGLSurface surfaceD;
        
        display = eglGetCurrentDisplay();
        surfaceD = eglGetCurrentSurface(EGL_DRAW);
        surfaceR = eglGetCurrentSurface(EGL_READ);
        
        eglMakeCurrent(display, surfaceD, surfaceR, ctx);
    }
}

#pragma mark CCDirector Delegate

// Projection delegate is only used if the fixed resolution mode is enabled
-(GLKMatrix4)updateProjection
{
	CGSize sizePoint = [CCDirector sharedDirector].viewSize;
	CGSize fixed = [CCDirector sharedDirector].designSize;
	
	// Half of the extra size that will be cut off
	CGPoint offset = ccpMult(ccp(fixed.width - sizePoint.width, fixed.height - sizePoint.height), 0.5);
	
	return CCMatrix4MakeOrtho(offset.x, sizePoint.width + offset.x, offset.y, sizePoint.height + offset.y, -1024, 1024);
}

@end

#endif


