//
//  CCAppController.m
//  cocos2d
//
//  Created by Donald Hutchison on 13/01/15.
//
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import "CCAppController.h"
#import "CCScene.h"
#import "CCBReader.h"
#import "CCDeviceInfo.h"
#import "CCAppDelegate.h"
#import "OALSimpleAudio.h"
#import "CCPackageManager.h"
#import "CCFileUtils.h"
#import "ccUtils.h"
#import "CCDirector_Private.h"

#if __CC_PLATFORM_ANDROID

#import "CCActivity.h"
#import "CCDirectorAndroid.h"

#endif

#if __CC_PLATFORM_MAC
#import "CCDirectorMac.h"
#endif

static CGFloat FindPOTScale(CGFloat size, CGFloat fixedSize)
{
    int scale = 1;
    while(fixedSize*scale < size) scale *= 2;

    return scale;
}

@implementation CCAppController
{
    NSDictionary *_cocosConfig;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _firstSceneName = @"MainScene";
    }

    return self;
}

- (void)setupApplication
{
#if __CC_PLATFORM_IOS
    [self setupIOS];
#elif __CC_PLATFORM_ANDROID
    [self setupAndroid];
#elif __CC_PLATFORM_MAC
    [self setupMac];
#else
/*
    Explicitly erroring out here as trying to configure under an unrecognised platform will cause spectacular failures
*/
#error "Unrecognised platform - CCAppController only supports application configuration on iOS, Mac or Android!"
#endif
}

/*
 Instantiate and return the first scene
 */
- (CCScene *)createFirstScene
{
    return [CCBReader loadAsScene:self.firstSceneName];
}

- (CCScene *)startScene
{
    NSAssert(_glView.director, @"Require a valid director to decode the CCB file!");

    [CCDirector pushCurrentDirector:_glView.director];
    CCScene *scene = [self createFirstScene];
    [CCDirector popCurrentDirector];

    return scene;
}

#pragma mark iOS setup

- (NSDictionary*)iosConfig
{
    NSString *configPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Published-iOS"];
    configPath = [configPath stringByAppendingPathComponent:@"configCocos2d.plist"];

    NSMutableDictionary *config = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];
    if(config == nil){
        config = [NSMutableDictionary dictionary];
    }
    
    // Fixed size. As wide as iPhone 5 at 2x and as high as the iPad at 2x.
    config[CCScreenModeFixedDimensions] = [NSValue valueWithCGSize:CGSizeMake(586, 384)];

    [CCBReader configureCCFileUtils];
    
    return config;
}

#if __CC_PLATFORM_IOS

- (void)setupIOS
{
    _cocosConfig = [self iosConfig];

    CCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate constructWindow];

    _glView = [appDelegate constructView:_cocosConfig withBounds:appDelegate.window.bounds];
    
    CCDirector *director = _glView.director;
    NSAssert(director, @"CCView failed to construct a director.");
    [self configureDirector:director withConfig:_cocosConfig withView:_glView];
    
    [CCDirector pushCurrentDirector:director];
    
    if([_cocosConfig[CCSetupScreenMode] isEqual:CCScreenModeFixed]){
        [self setupFixedScreenMode:_cocosConfig director:(CCDirectorIOS *) director];
    } else {
        [self setupFlexibleScreenMode:_cocosConfig director:director];
    }
    
    // Initialise OpenAL
    [OALSimpleAudio sharedInstance];

    [appDelegate constructNavController:_cocosConfig];
    [[CCPackageManager sharedManager] loadPackages];
    
    [appDelegate.window makeKeyAndVisible];
    [appDelegate forceOrientation];

    [CCDirector popCurrentDirector];
    
    [self runStartSceneiOS];
}

- (void)runStartSceneiOS
{
    CCDirector *director = _glView.director;
    [director presentScene:[self startScene]];
}

- (void)configureDirector:(CCDirector *)director withConfig:(NSDictionary *)config withView:(CC_VIEW <CCView> *)ccview
{
    CCDirectorIOS*directorIOS = (CCDirectorIOS*) director;
    directorIOS.wantsFullScreenLayout = YES;

    // Display FSP and SPF
    [directorIOS setDisplayStats:[config[CCSetupShowDebugStats] boolValue]];

    // set FPS at 60
    NSTimeInterval animationInterval = [(config[CCSetupAnimationInterval] ?: @(1.0/60.0)) doubleValue];
    [directorIOS setAnimationInterval:animationInterval];

    directorIOS.fixedUpdateInterval = [(config[CCSetupFixedUpdateInterval] ?: @(1.0/60.0)) doubleValue];

    // attach the openglView to the director
    [directorIOS setView:ccview];
}

- (void)setupFlexibleScreenMode:(NSDictionary *)config director:(CCDirector *)director
{
    // Setup tablet scaling if it was requested.
    if(	UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&	[config[CCSetupTabletScale2X] boolValue] )
    {
        // Set the director to use 2 points per pixel.
        director.contentScaleFactor *= 2.0;

        // Set the UI scale factor to show things at "native" size.
        director.UIScaleFactor = 0.5;

        // Let CCFileUtils know that "-ipad" textures should be treated as having a contentScale of 2.0.
        [[CCFileUtils sharedFileUtils] setiPadContentScaleFactor:2.0];
    }

    [director setProjection:CCDirectorProjection2D];
}

- (void)setupFixedScreenMode:(NSDictionary *)config director:(CCDirectorIOS *)director
{
    CGSize size = [CCDirector currentDirector].viewSizeInPixels;
    CGSize fixed = [config[CCScreenModeFixedDimensions] CGSizeValue];

    if([config[CCSetupScreenOrientation] isEqualToString:CCScreenOrientationPortrait]){
        CC_SWAP(fixed.width, fixed.height);
    }

    // Find the minimal power-of-two scale that covers both the width and height.
    CGFloat scaleFactor = MIN(FindPOTScale(size.width, fixed.width), FindPOTScale(size.height, fixed.height));

    director.contentScaleFactor = scaleFactor;
    director.UIScaleFactor = (float)(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 1.0 : 0.5);

    // Let CCFileUtils know that "-ipad" textures should be treated as having a contentScale of 2.0.
    [[CCFileUtils sharedFileUtils] setiPadContentScaleFactor: 2.0];

    director.designSize = fixed;
    [director setProjection:CCDirectorProjectionCustom];
}

#endif

#pragma mark Android setup

- (NSDictionary*)androidConfig
{
    [CCBReader configureCCFileUtils];
    
    NSString* configPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Published-Android"];

    configPath = [configPath stringByAppendingPathComponent:@"configCocos2d.plist"];
    NSMutableDictionary *config = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];

    config[CCScreenModeFixedDimensions] = [NSValue valueWithCGSize:CGSizeMake(586, 384)];

    return config;
}

#if __CC_PLATFORM_ANDROID

- (void)setupAndroid
{
    _cocosConfig = [self androidConfig];

    [self performAndroidNonGLConfiguration:_cocosConfig];

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


- (void)performAndroidNonGLConfiguration:(NSDictionary*)config
{
    CCActivity *activity = [CCActivity currentActivity];
    AndroidDisplayMetrics* metrics = [activity getDisplayMetrics];

    activity.cocos2dSetupConfig = config;
    [activity applyRequestedOrientation:config];
    [activity constructViewWithConfig:config andDensity:metrics.density];
    
    _glView = activity.glView;
    [activity scheduleInRunLoop];

    [[CCPackageManager sharedManager] loadPackages];
}

- (void)performAndroidGLConfiguration
{
    [self configureDirector:_glView.director withConfig:_cocosConfig withView:_glView];

    [self runStartSceneAndroid];
}

- (void)configureDirector:(CCDirector*)director withConfig:(NSDictionary *)config withView:(CCGLView*)view
{
    CCDirectorAndroid *androidDirector = (CCDirectorAndroid*)director;
    director.delegate = [CCActivity currentActivity];
    [director setView:view];

    if([config[CCSetupScreenMode] isEqual:CCScreenModeFixed])
    {
        [self setupFixedScreenMode:config];
    }
    else
    {
        [self setupFlexibleScreenMode:config];
    }
}

- (void)setupFlexibleScreenMode:(NSDictionary*)config
{
    CCDirectorAndroid *director = (CCDirectorAndroid*)_glView.director;

    NSInteger device = [CCDeviceInfo runningDevice];
    BOOL tablet = device == CCDeviceiPad || device == CCDeviceiPadRetinaDisplay;

    if(tablet && [config[CCSetupTabletScale2X] boolValue])
    {
        // Set the UI scale factor to show things at "native" size.
        director.UIScaleFactor = 0.5;

        // Let CCFileUtils know that "-ipad" textures should be treated as having a contentScale of 2.0.
        [[CCFileUtils sharedFileUtils] setiPadContentScaleFactor:2.0];
    }

    director.contentScaleFactor *= 1.83;

    [director setProjection:CCDirectorProjection2D];
}

- (void)setupFixedScreenMode:(NSDictionary*)config
{
    CCDirectorAndroid *director = (CCDirectorAndroid*)_glView.director;

    CGSize size = [CCDirector currentDirector].viewSizeInPixels;
    CGSize fixed = [config[CCScreenModeFixedDimensions] CGSizeValue];

    if([config[CCSetupScreenOrientation] isEqualToString:CCScreenOrientationPortrait])
    {
        CC_SWAP(fixed.width, fixed.height);
    }

    CGFloat scaleFactor = MAX(size.width/ fixed.width, size.height/ fixed.height);

    director.contentScaleFactor = scaleFactor;
    director.UIScaleFactor = 1;

    [[CCFileUtils sharedFileUtils] setiPadContentScaleFactor:2.0];

    director.designSize = fixed;
    [director setProjection:CCDirectorProjectionCustom];
}

- (void)runStartSceneAndroid
{
    CCDirector *androidDirector = _glView.director;

    [androidDirector presentScene:[self startScene]];
    [androidDirector setAnimationInterval:1.0/60.0];
}

#endif

#pragma mark Mac setup

/*
    Override to change mac window size
*/
-(CGSize)defaultWindowSize
{
    return CGSizeMake(480.0f, 320.0f);
}

- (NSDictionary*)macConfig
{
    [CCBReader configureCCFileUtils];
    
    NSMutableDictionary *macConfig = [NSMutableDictionary dictionary];

    macConfig[CCMacDefaultWindowSize] = [NSValue valueWithCGSize:[self defaultWindowSize]];

    return macConfig;
}

#if __CC_PLATFORM_MAC

-(void)setupMac
{
    _cocosConfig = [self macConfig];
    [self applyConfigurationToCocos:_cocosConfig];
    [self runStartSceneMac];
}



- (void)applyConfigurationToCocos:(NSDictionary*)config
{
    CCDirectorMac *director = (CCDirectorMac*) _glView.director;
    CGSize defaultWindowSize = [config[CCMacDefaultWindowSize] CGSizeValue];
    
    [self.window setFrame:CGRectMake(0.0f, 0.0f, defaultWindowSize.width, defaultWindowSize.height) display:true animate:false];
    [self.glView setFrame:self.window.frame];
    
    [director reshapeProjection:CC_SIZE_SCALE(defaultWindowSize, director.contentScaleFactor)];
    
    // Enable "moving" mouse event. Default no.
    [self.window setAcceptsMouseMovedEvents:NO];

    // Center main window
    [self.window center];

    [[CCPackageManager sharedManager] loadPackages];
}

- (void)runStartSceneMac
{
    CCDirectorMac *director = (CCDirectorMac*) _glView.director;
    [director presentScene:[self startScene]];
}

#endif

@end
