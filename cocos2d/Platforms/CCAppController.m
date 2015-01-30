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

#if __CC_PLATFORM_ANDROID

#import "CCActivity.h"

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

#endif

}


/*
    The first scene to start the application with, can be overridden in subclass
 */
- (CCScene *)startScene
{
    return [CCBReader loadAsScene:self.firstSceneName];
}

#pragma mark iOS setup

#if __CC_PLATFORM_IOS

- (void)setupIOS
{
    _cocosConfig = [self iosConfig];

    [CCBReader configureCCFileUtils];

    [self applyConfigurationToCocos:_cocosConfig];
    [self setFirstScene];
}

- (NSDictionary*)iosConfig
{
    NSString *configPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Published-iOS"];
    configPath = [configPath stringByAppendingPathComponent:@"configCocos2d.plist"];

    NSMutableDictionary *config = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];

    // Fixed size. As wide as iPhone 5 at 2x and as high as the iPad at 2x.
    config[CCScreenModeFixedDimensions] = [NSValue valueWithCGSize:CGSizeMake(586, 384)];

    return config;
}

- (void)applyConfigurationToCocos:(NSDictionary*)config
{
    CCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate constructWindow];

    CCDirector *director = [CCDirector currentDirector];

    CC_VIEW <CCDirectorView> *ccview = [appDelegate constructView:config withBounds:appDelegate.window.bounds];
    [self configureDirector:director withConfig:config withView:ccview];

    if([config[CCSetupScreenMode] isEqual:CCScreenModeFixed]){
        [self setupFixedScreenMode:config director:director];
    } else {
        [self setupFlexibleScreenMode:config director:director];
    }

    // Initialise OpenAL
    [OALSimpleAudio sharedInstance];

    [appDelegate constructNavController:config];

    [[CCPackageManager sharedManager] loadPackages];

    [appDelegate.window makeKeyAndVisible];
    [appDelegate forceOrientation];
}

- (void)configureDirector:(CCDirector *)director withConfig:(NSDictionary *)config withView:(CC_VIEW <CCDirectorView> *)ccview
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

- (void)setFirstScene
{
    CCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.startScene = [self startScene];
}

#endif

#pragma mark Android setup

#if __CC_PLATFORM_ANDROID

- (void)setupAndroid
{
    _cocosConfig = [self androidConfig];
    [CCBReader configureCCFileUtils];

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

- (NSDictionary*)androidConfig
{
    NSString* configPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Published-Android"];

    configPath = [configPath stringByAppendingPathComponent:@"configCocos2d.plist"];
    NSMutableDictionary *config = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];

    config[CCScreenModeFixedDimensions] = [NSValue valueWithCGSize:CGSizeMake(586, 384)];

    return config;
}

- (void)performAndroidNonGLConfiguration:(NSDictionary*)config
{
    CCActivity *activity = [CCActivity currentActivity];
    AndroidDisplayMetrics* metrics = [activity getDisplayMetrics];

    activity.cocos2dSetupConfig = config;
    [activity applyRequestedOrientation:config];
    [activity constructViewWithConfig:config andDensity:metrics.density];
    [activity scheduleInRunLoop];

    [[CCPackageManager sharedManager] loadPackages];
}

- (void)performAndroidGLConfiguration
{
    CCActivity *activity = [CCActivity currentActivity];
    [self configureDirector:[CCDirector currentDirector] withConfig:_cocosConfig withView:activity.glView];

    [self runStartSceneAndroid];
}

- (void)configureDirector:(CCDirector*)director withConfig:(NSDictionary *)config withView:(CCGLView*)view
{
    CCDirectorAndroid *androidDirector = (CCDirectorAndroid*)director;
    director.delegate = [CCActivity currentActivity];
    [CCTexture setDefaultAlphaPixelFormat:CCTexturePixelFormat_RGBA8888];
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
    CCDirectorAndroid *director = (CCDirectorAndroid*)[CCDirector currentDirector];

    NSInteger device = [[CCConfiguration sharedConfiguration] runningDevice];
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
    CCDirectorAndroid *director = (CCDirectorAndroid*)[CCDirector currentDirector];

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
    CCDirectorAndroid *androidDirector = (CCDirectorAndroid*)[CCDirector currentDirector];

    [androidDirector runWithScene:[self startScene]];
    [androidDirector setAnimationInterval:1.0/60.0];
    [androidDirector startAnimation];
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

#if __CC_PLATFORM_MAC

-(void)setupMac
{
    _cocosConfig = [self macConfig];
    [CCBReader configureCCFileUtils];
    [self applyConfigurationToCocos:_cocosConfig];
    [self runStartSceneMac];
}

- (NSDictionary*)macConfig
{
    NSMutableDictionary *macConfig = [NSMutableDictionary dictionary];
    
    macConfig[CCMacDefaultWindowSize] = [NSValue valueWithCGSize:[self defaultWindowSize]];
    
    return macConfig;
}

- (void)applyConfigurationToCocos:(NSDictionary*)config
{
    CCDirectorMac *director = (CCDirectorMac*) [CCDirector currentDirector];

    CGSize defaultWindowSize = [config[CCMacDefaultWindowSize] CGSizeValue];
    [self.window setFrame:CGRectMake(0.0f, 0.0f, defaultWindowSize.width, defaultWindowSize.height) display:true animate:false];
    [self.glView setFrame:self.window.frame];

    // connect the OpenGL view with the director
    [director setView:self.glView];

    // Enable "moving" mouse event. Default no.
    [self.window setAcceptsMouseMovedEvents:NO];

    // Center main window
    [self.window center];

    [[CCPackageManager sharedManager] loadPackages];
}

- (void)runStartSceneMac
{
    CCDirectorMac *director = (CCDirectorMac*) [CCDirector currentDirector];
    [director runWithScene:[self startScene]];
}

#endif

@end
