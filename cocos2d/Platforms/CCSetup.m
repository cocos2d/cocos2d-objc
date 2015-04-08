/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2015 Cocos2D Authors
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

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

#import "CCSetup_Private.h"
#import "CCDirector_Private.h"

#import "CCScene.h"
#import "CCBReader.h"
#import "CCDeviceInfo.h"
#import "OALSimpleAudio.h"
#import "CCPackageManager.h"
#import "CCFileLocator.h"
#import "ccUtils.h"

#import "CCDeprecated.h"

#if __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>
#endif

#if __CC_PLATFORM_ANDROID
#import "CCActivity.h"
#import "CCDirectorAndroid.h"

#import <AndroidKit/AndroidWindowManager.h>
#import <AndroidKit/AndroidDisplay.h>
#endif

#if __CC_PLATFORM_MAC
#import "CCDirectorMac.h"
#endif


#if __CC_PLATFORM_MAC
@interface CCSetup() <NSWindowDelegate>
@end
#endif


Class CCTextureClass;
Class CCGraphicsBufferClass;
Class CCGraphicsBufferBindingsClass;
Class CCRenderStateClass;
Class CCRenderCommandDrawClass;
Class CCFrameBufferObjectClass;


NSString * const CCSetupPixelFormat = @"CCSetupPixelFormat";
NSString * const CCSetupScreenMode = @"CCSetupScreenMode";
NSString * const CCSetupScreenOrientation = @"CCSetupScreenOrientation";
NSString * const CCSetupFrameSkipInterval = @"CCSetupFrameSkipInterval";
NSString * const CCSetupFixedUpdateInterval = @"CCSetupFixedUpdateInterval";
NSString * const CCSetupShowDebugStats = @"CCSetupShowDebugStats";
NSString * const CCSetupTabletScale2X = @"CCSetupTabletScale2X";

NSString * const CCSetupDepthFormat = @"CCSetupDepthFormat";
NSString * const CCSetupPreserveBackbuffer = @"CCSetupPreserveBackbuffer";
NSString * const CCSetupMultiSampling = @"CCSetupMultiSampling";
NSString * const CCSetupNumberOfSamples = @"CCSetupNumberOfSamples";
NSString * const CCSetupScreenModeFixedDimensions = @"CCScreenModeFixedDimensions";

NSString * const CCScreenOrientationLandscape = @"CCScreenOrientationLandscape";
NSString * const CCScreenOrientationPortrait = @"CCScreenOrientationPortrait";
NSString * const CCScreenOrientationAll = @"CCScreenOrientationAll";

NSString * const CCScreenModeFlexible = @"CCScreenModeFlexible";
NSString * const CCScreenModeFixed = @"CCScreenModeFixed";

NSString * const CCMacDefaultWindowSize = @"CCMacDefaultWindowSize";


static CGFloat FindPOTScale(CGFloat size, CGFloat fixedSize)
{
    int scale = 1;
    while(fixedSize*scale < size) scale *= 2;

    return scale;
}

@implementation CCSetup {
    CCGraphicsAPI _graphicsAPI;
}

-(instancetype)init
{
    if((self = [super init])){
        _contentScale = 1.0;
        _assetScale = 1.0;
        _UIScale = 1.0;
        _fixedUpdateInterval = 1.0/60.0;
    }
    
    return self;
}

-(NSString *)spriteBuilderResourceDirectory
{
#if __CC_PLATFORM_ANDROID
    return @"Published-Android";
#else
    // TODO this probably doesn't make sense in the future...
    return @"Published-iOS";
#endif
}

-(void)setupForSpriteBuilder;
{
    [CCFileLocator sharedFileLocator].searchPaths = [@[
        [[NSBundle mainBundle] pathForResource:[self spriteBuilderResourceDirectory] ofType:nil],
    ] arrayByAddingObjectsFromArray:[CCFileLocator sharedFileLocator].searchPaths];
}

-(NSDictionary *)setupConfig
{
    // TODO iOS path here?
    NSString *configPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[self spriteBuilderResourceDirectory]];
    configPath = [configPath stringByAppendingPathComponent:@"configCocos2d.plist"];

    NSMutableDictionary *config = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];
    if(config == nil){
        config = [NSMutableDictionary dictionary];
    }
    
    // TODO??
    // Fixed size. As wide as iPhone 5 at 2x and as high as the iPad at 2x.
    config[CCSetupScreenModeFixedDimensions] = [NSValue valueWithCGSize:CGSizeMake(586, 384)];
    
    return config;
}

- (CCScene *)createFirstScene
{
    return [CCBReader loadAsScene:@"MainScene"];
}

- (CCScene *)startScene
{
    NSAssert(self.view.director, @"Require a valid director to decode the CCB file!");
    CCScene *scene = [self createFirstScene];

    return scene;
}

//MARK iOS setup

#if __CC_PLATFORM_IOS

- (void)setupApplication
{
    self.contentScale = [UIScreen mainScreen].scale;
    self.UIScale = 1;
    
    _config = [self setupConfig];
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _view = [[CCViewiOSGL alloc] initWithFrame:_window.bounds pixelFormat:kEAGLColorFormatRGBA8 depthFormat:GL_DEPTH24_STENCIL8_OES preserveBackbuffer:NO sharegroup:nil multiSampling:NO numberOfSamples:0];
    
    // TODO need a custom subclass that starts/stops rendering.
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view = _view;
    viewController.wantsFullScreenLayout = YES;
    _window.rootViewController = viewController;
    
    // Need to force the window to be visible to set the initial view size on iOS < 8
    [_window makeKeyAndVisible];
    
    CCDirector *director = self.view.director;
    NSAssert(director, @"CCView failed to construct a director.");
    [CCDirector pushCurrentDirector:director];
    
    [director setDisplayStats:[_config[CCSetupShowDebugStats] boolValue]];

    director.frameSkipInterval = [(_config[CCSetupFrameSkipInterval] ?: @(1)) unsignedIntegerValue];
    self.fixedUpdateInterval = [(_config[CCSetupFixedUpdateInterval] ?: @(1.0/60.0)) doubleValue];
    
    // TODO? Fixed screen mode is being replaced.
//    if([_cocosConfig[CCSetupScreenMode] isEqual:CCScreenModeFixed]){
//        [self setupFixedScreenMode:_cocosConfig director:(CCDirectorIOS *) director];
//    } else {
//        [self setupFlexibleScreenMode:_cocosConfig director:director];
//    }
    
    // Setup tablet scaling if it was requested.
    if(	UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&	[_config[CCSetupTabletScale2X] boolValue] )
    {
        self.contentScale *= 2.0;
        self.UIScale *= 0.5;
    }
    
    self.assetScale = self.contentScale;
    
    // Initialise OpenAL
    [OALSimpleAudio sharedInstance];

    [[CCPackageManager sharedManager] loadPackages];

    [director presentScene:[self startScene]];
}

//- (void)setupFixedScreenMode:(NSDictionary *)config director:(CCDirector *)director
//{
//    CGSize size = [CCDirector currentDirector].viewSizeInPixels;
//    CGSize fixed = [config[CCScreenModeFixedDimensions] CGSizeValue];
//
//    if([config[CCSetupScreenOrientation] isEqualToString:CCScreenOrientationPortrait]){
//        CC_SWAP(fixed.width, fixed.height);
//    }
//
//    // Find the minimal power-of-two scale that covers both the width and height.
//    CGFloat scaleFactor = MIN(FindPOTScale(size.width, fixed.width), FindPOTScale(size.height, fixed.height));
//
//    director.contentScaleFactor = scaleFactor;
//    director.UIScaleFactor = (float)(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 1.0 : 0.5);
//    
//    // TODO
////    // Let CCFileUtils know that "-ipad" textures should be treated as having a contentScale of 2.0.
////    [[CCFileUtils sharedFileUtils] setiPadContentScaleFactor: 2.0];
//
//    director.designSize = fixed;
//    [director setProjection:CCDirectorProjectionCustom];
//}

#endif

//MARK Android setup

#if __CC_PLATFORM_ANDROID

- (void)setupApplication
{
    _config = [self setupConfig];
    
    CCActivity *activity = [CCActivity currentActivity];
    AndroidDisplayMetrics* metrics = [activity getDisplayMetrics];

    activity.cocos2dSetupConfig = _config;
    [activity applyRequestedOrientation:_config];
    [activity constructViewWithConfig:_config andDensity:metrics.density];
    
    _view = activity.glView;
    [activity scheduleInRunLoop];

    CCDirector *director = _view.director;
    NSAssert(director, @"CCView failed to construct a director.");
    [CCDirector pushCurrentDirector:director];
    
    [director setDisplayStats:[_config[CCSetupShowDebugStats] boolValue]];

    director.frameSkipInterval = [(_config[CCSetupFrameSkipInterval] ?: @(1)) unsignedIntegerValue];
    self.fixedUpdateInterval = [(_config[CCSetupFixedUpdateInterval] ?: @(1.0/60.0)) doubleValue];
    
    // Initialise OpenAL
    [OALSimpleAudio sharedInstance];

    [[CCPackageManager sharedManager] loadPackages];

    /*
        Unlike iOS, GL is not initialized on Android before the application is constructed.
        We must explicitly hang off of Android's `surfaceCreated` callback, at which point
        we can continue with configuring cocos's GL dependant properties.
    */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(performAndroidGLConfiguration)
                                          name:@"GL_INITIALIZED"
                                          object:nil];
}

#define CC_MINIMUM_TABLET_SCREEN_DIAGONAL 6.0

// Oleg's Original code from CCConfiguration.m
-(BOOL)isTablet
{
    AndroidDisplayMetrics *metrics = [[AndroidDisplayMetrics alloc] init];
    [[CCActivity currentActivity].windowManager.defaultDisplay metricsForDisplayMetrics:metrics];

    double yInches= metrics.heightPixels/metrics.ydpi;
    double xInches= metrics.widthPixels/metrics.xdpi;
    double diagonalInches = sqrt(xInches*xInches + yInches*yInches);
    return (diagonalInches > CC_MINIMUM_TABLET_SCREEN_DIAGONAL);
}

- (void)performAndroidGLConfiguration
{
    self.contentScale = _view.contentScaleFactor;
    
    BOOL tablet = [self isTablet];
    if(tablet && [_config[CCSetupTabletScale2X] boolValue])
    {
        self.contentScale *= 2.0;
        self.UIScale *= 0.5;
    }
    
    self.assetScale = self.contentScale;
    
    [_view.director startRunLoop];
    
    [self runStartSceneAndroid];
}

//- (void)setupFlexibleScreenMode:(NSDictionary*)config
//{
//    CCDirectorAndroid *director = (CCDirectorAndroid*)_view.director;
//
//    NSInteger device = [CCDeviceInfo runningDevice];
//    BOOL tablet = device == CCDeviceiPad || device == CCDeviceiPadRetinaDisplay;
//
//    if(tablet && [config[CCSetupTabletScale2X] boolValue])
//    {
//        // Set the UI scale factor to show things at "native" size.
//        director.UIScaleFactor = 0.5;
//
//        // Let CCFileUtils know that "-ipad" textures should be treated as having a contentScale of 2.0.
//        [[CCFileUtils sharedFileUtils] setiPadContentScaleFactor:2.0];
//    }
//
//    director.contentScaleFactor *= 1.83;
//
//    [director setProjection:CCDirectorProjection2D];
//}
//
//- (void)setupFixedScreenMode:(NSDictionary*)config
//{
//    CCDirectorAndroid *director = (CCDirectorAndroid*)_glView.director;
//
//    CGSize size = [CCDirector currentDirector].viewSizeInPixels;
//    CGSize fixed = [config[CCScreenModeFixedDimensions] CGSizeValue];
//
//    if([config[CCSetupScreenOrientation] isEqualToString:CCScreenOrientationPortrait])
//    {
//        CC_SWAP(fixed.width, fixed.height);
//    }
//
//    CGFloat scaleFactor = MAX(size.width/ fixed.width, size.height/ fixed.height);
//
//    director.contentScaleFactor = scaleFactor;
//    director.UIScaleFactor = 1;
//
//    [[CCFileUtils sharedFileUtils] setiPadContentScaleFactor:2.0];
//
//    director.designSize = fixed;
//    [director setProjection:CCDirectorProjectionCustom];
//}

- (void)runStartSceneAndroid
{
    CCDirector *androidDirector = _view.director;

    [androidDirector presentScene:[self startScene]];
    [androidDirector setAnimationInterval:1.0/60.0];
}

#endif

//MARK Mac setup

#if __CC_PLATFORM_MAC

- (void)setupApplication
{
    self.contentScale = 2;
    self.UIScale = 0.5;
    self.assetScale = 2;
    
    _config = [self setupConfig];
    
    CGRect rect = CGRectMake(0, 0, 1024, 768);
    NSUInteger styleMask = NSClosableWindowMask | NSResizableWindowMask | NSTitledWindowMask;
    _window = [[NSWindow alloc] initWithContentRect:rect styleMask:styleMask backing:NSBackingStoreBuffered defer:NO screen:[NSScreen mainScreen]];
    _window.delegate = self;
    
    NSOpenGLPixelFormat * pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:(NSOpenGLPixelFormatAttribute[]) {
        NSOpenGLPFAWindow,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFADepthSize, 32,
        0
    }];

    _view = [[CCViewMacGL alloc] initWithFrame:CGRectZero pixelFormat:pixelFormat];
    _view.wantsBestResolutionOpenGLSurface = YES;
    _window.contentView = _view;
    
    [_window center];
    [_window makeFirstResponder:_view];
    [_window makeKeyAndOrderFront:self];
    _window.acceptsMouseMovedEvents = YES;
    
    CCDirector *director = _view.director;
    NSAssert(director, @"CCView failed to construct a director.");
    [CCDirector pushCurrentDirector:director];
    
    [director setDisplayStats:[_config[CCSetupShowDebugStats] boolValue]];

    director.frameSkipInterval = [(_config[CCSetupFrameSkipInterval] ?: @(1)) unsignedIntegerValue];
    self.fixedUpdateInterval = [(_config[CCSetupFixedUpdateInterval] ?: @(1.0/60.0)) doubleValue];
    
    // Initialise OpenAL
    [OALSimpleAudio sharedInstance];

    [[CCPackageManager sharedManager] loadPackages];

    [director presentScene:[self startScene]];
}

-(void)windowWillClose:(NSNotification *)notification
{
    [[NSApplication sharedApplication] terminate:self];
}

#endif

-(void)setGraphicsAPI:(CCGraphicsAPI)graphicsAPI
{
    NSAssert(_graphicsAPI == CCGraphicsAPIInvalid, @"The graphics API cannot be changed after startup!");
    switch(graphicsAPI){
        case CCGraphicsAPIGL:
            CCTextureClass = NSClassFromString(@"CCTextureGL");
			CCGraphicsBufferClass = NSClassFromString(@"CCGraphicsBufferGLBasic");
			CCGraphicsBufferBindingsClass = NSClassFromString(@"CCGraphicsBufferBindingsGL");
			CCRenderStateClass = NSClassFromString(@"CCRenderStateGL");
			CCRenderCommandDrawClass = NSClassFromString(@"CCRenderCommandDrawGL");
			CCFrameBufferObjectClass = NSClassFromString(@"CCFrameBufferObjectGL");
            break;
#if __CC_METAL_SUPPORTED_AND_ENABLED
        case CCGraphicsAPIMetal:
            if(!MTLCreateSystemDefaultDevice || !MTLCreateSystemDefaultDevice() || getenv("CC_FORCE_GL")){
                CCLOG(@"Metal Renderer not available. Falling back to GL.");
                
                self.graphicsAPI = CCGraphicsAPIGL;
                return;
            }
            
            CCTextureClass = NSClassFromString(@"CCTextureMetal");
            CCGraphicsBufferClass = NSClassFromString(@"CCGraphicsBufferMetal");
            CCGraphicsBufferBindingsClass = NSClassFromString(@"CCGraphicsBufferBindingsMetal");
            CCRenderStateClass = NSClassFromString(@"CCRenderStateMetal");
            CCRenderCommandDrawClass = NSClassFromString(@"CCRenderCommandDrawMetal");
            CCFrameBufferObjectClass = NSClassFromString(@"CCFrameBufferObjectMetal");
            break;
#endif
        default:
            NSAssert(NO, @"Invalid graphics API");
    }
    
    NSAssert(CCTextureClass, @"CCTextureClass not configured.");
    NSAssert(CCGraphicsBufferClass, @"CCGraphicsBufferClass not configured.");
    NSAssert(CCGraphicsBufferBindingsClass, @"CCGraphicsBufferBindingsClass not configured.");
    NSAssert(CCRenderStateClass, @"CCRenderStateClass not configured.");
    NSAssert(CCRenderCommandDrawClass, @"CCRenderCommandDrawClass not configured.");
    NSAssert(CCFrameBufferObjectClass, @"CCFrameBufferObjectClass not configured.");
    
    _graphicsAPI = graphicsAPI;
}

-(CCGraphicsAPI)graphicsAPI
{
    if(_graphicsAPI == CCGraphicsAPIInvalid){
#if __CC_METAL_SUPPORTED_AND_ENABLED
        self.graphicsAPI = CCGraphicsAPIMetal;
#else
        self.graphicsAPI = CCGraphicsAPIGL;
#endif
    }
    
    return _graphicsAPI;
}

//MARK: Singleton

static CCSetup *
CCSetupSingleton(Class klass, BOOL useCustom)
{
    static CCSetup *sharedSetup = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSCAssert(useCustom || klass != [CCSetup class], @"You must either create a CCSetup subclass for your app or call [CCSetup createCustomSetup] if you are integrating Cocos2D into an existing app.");
        sharedSetup = [[klass alloc] init];
    });
    
    return sharedSetup;
}

+(void)createCustomSetup
{
    CCSetupSingleton([self class], YES);
}

+(instancetype)sharedSetup
{
    return CCSetupSingleton([self class], NO);
}

@end
