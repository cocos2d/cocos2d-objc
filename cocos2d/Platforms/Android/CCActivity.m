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
}
@synthesize layout=_layout;

@bridge (callback) run = run;
@bridge (callback) onDestroy = onDestroy;
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
    _glView = [[CCGLView alloc] initWithContext:self scaleFactor:metrics.density];
    [metrics release];
    [_glView.holder addCallback:self];
    [self.layout addView:_glView];
    [self setContentView:_layout];
    [[AndroidLooper currentLooper] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)onDestroy
{
    [super onDestroy];
    exit(0);
}

- (void)onLowMemory
{
    // TODO: do something sensible here
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
        
        [self setupView:holder];
        
        [self setupPaths];
        
        CCDirectorAndroid *director = (CCDirectorAndroid*)[CCDirector sharedDirector];
        director.contentScaleFactor = _glView.contentScaleFactor;
        [CCTexture setDefaultAlphaPixelFormat:CCTexturePixelFormat_RGBA8888];
        [director setView:_glView];
        
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
    if (!waitUntilDone)
    {
        CFRunLoopPerformBlock([_gameLoop getCFRunLoop], kCFRunLoopDefaultMode, block);
    }
    else
    {
        [[Block_copy(block) autorelease] performSelector:@selector(invoke) onThread:_thread withObject:nil waitUntilDone:YES];
    }
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
    CCDirectorAndroid *director = (CCDirectorAndroid*)[CCDirector sharedDirector];
#if USE_MAIN_THREAD
    [director stopAnimation];
#else
    [director performSelector:@selector(stopAnimation) onThread:_thread withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
#endif
}


- (BOOL)onKeyDown:(int32_t)keyCode keyEvent:(AndroidKeyEvent *)event
{
    return NO;
}

- (BOOL)onKeyUp:(int32_t)keyCode keyEvent:(AndroidKeyEvent *)event
{
    return NO;
}

@end

#endif
