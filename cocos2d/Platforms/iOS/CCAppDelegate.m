//
//  CCAppDelegate.m
//  cocos2d-ios
//
//  Created by Viktor on 12/6/13.
//
//

#import "../../ccMacros.h"
#ifdef __CC_PLATFORM_IOS

#import "CCAppDelegate.h"
#import "CCTexture.h"
#import "CCFileUtils.h"

NSString* const CCConfigPixelFormat = @"CCConfigPixelFormat";
NSString* const CCConfigScreenMode = @"CCConfigScreenMode";
NSString* const CCConfigScreenOrientation = @"CCConfigScreenOrientation";
NSString* const CCConfigAnimationInterval = @"CCConfigAnimationInterval";


@interface CCNavigationController ()
{
    CCAppDelegate* __weak _appDelegate;
    CCScreenOrientation _screenOrientation;
}
@property (nonatomic,weak) CCAppDelegate* appDelegate;
@property (nonatomic, assign) CCScreenOrientation screenOrientation;
@end

@implementation CCNavigationController

@synthesize appDelegate = _appDelegate;
@synthesize screenOrientation = _screenOrientation;

// The available orientations should be defined in the Info.plist file.
// And in iOS 6+ only, you can override it in the Root View controller in the "supportedInterfaceOrientations" method.
// Only valid for iOS 6+. NOT VALID for iOS 4 / 5.
-(NSUInteger)supportedInterfaceOrientations
{
    if (_screenOrientation == CCScreenOrientationLandscape)
    {
        return UIInterfaceOrientationMaskLandscape;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

// Supported orientations. Customize it for your own needs
// Only valid on iOS 4 / 5. NOT VALID for iOS 6.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (_screenOrientation == CCScreenOrientationLandscape)
    {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    }
    else
    {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    }
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil) {
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
		[director runWithScene: [_appDelegate startScene]];
	}
}
@end


@implementation CCAppDelegate

@synthesize window=window_, navController=navController_;

- (CCScene*) startScene
{
    NSAssert(NO, @"Override CCAppDelegate and implement the startScene method");
    return NULL;
}

- (void) setupCocos2dWithOptions:(NSDictionary*)config
{
    // Default configuration
    NSString* pixelFormat = kEAGLColorFormatRGBA8;
    CCScreenMode screenMode = CCScreenModeFlexible;
    CCScreenOrientation screenOrientation = CCScreenOrientationLandscape;
    NSTimeInterval animationInterval = 1.0/60;
    
    if (config)
    {
        // Read pixelFormat
        if ([config objectForKey:CCConfigPixelFormat])
        {
            pixelFormat = [config objectForKey:CCConfigPixelFormat];
        }
        
        // Read screenMode
        if ([config objectForKey:CCConfigScreenMode])
        {
            screenMode = [[config objectForKey:CCConfigScreenMode] intValue];
        }
        
        // Read screenOrientation
        if ([config objectForKey:CCConfigScreenOrientation])
        {
            screenOrientation = [[config objectForKey:CCConfigScreenOrientation] intValue];
        }
        
        // Read animationInterval
        if ([config objectForKey:CCConfigAnimationInterval])
        {
            animationInterval = [[config objectForKey:CCConfigAnimationInterval] doubleValue];
        }
    }
    
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	
	// CCGLView creation
	// viewWithFrame: size of the OpenGL view. For full screen use [_window bounds]
	//  - Possible values: any CGRect
	// pixelFormat: Format of the render buffer. Use RGBA8 for better color precision (eg: gradients). But it takes more memory and it is slower
	//	- Possible values: kEAGLColorFormatRGBA8, kEAGLColorFormatRGB565
	// depthFormat: Use stencil if you plan to use CCClippingNode. Use Depth if you plan to use 3D effects, like CCCamera or CCNode#vertexZ
	//  - Possible values: 0, GL_DEPTH_COMPONENT24_OES, GL_DEPTH24_STENCIL8_OES
	// sharegroup: OpenGL sharegroup. Useful if you want to share the same OpenGL context between different threads
	//  - Possible values: nil, or any valid EAGLSharegroup group
	// multiSampling: Whether or not to enable multisampling
	//  - Possible values: YES, NO
	// numberOfSamples: Only valid if multisampling is enabled
	//  - Possible values: 0 to glGetIntegerv(GL_MAX_SAMPLES_APPLE)
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:pixelFormat
								   depthFormat:0
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
	
	CCDirectorIOS* director = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
	//[director_ setDisplayStats:YES];
	
	// set FPS at 60
	[director setAnimationInterval:animationInterval];
	
	// attach the openglView to the director
	[director setView:glView];
	
	// 2D projection
	[director setProjection:CCDirectorProjection2D];
	//	[director setProjection:kCCDirectorProjection3D];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change this setting at any time.
	[CCTexture setDefaultAlphaPixelFormat:CCTexturePixelFormat_RGBA8888];
	
	// Create a Navigation Controller with the Director
	navController_ = [[CCNavigationController alloc] initWithRootViewController:director];
	navController_.navigationBarHidden = YES;
    navController_.appDelegate = self;
    navController_.screenOrientation = screenOrientation;
    
	// for rotation and other messages
	[director setDelegate:navController_];
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == [CCDirector sharedDirector] )
		[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
	if( [navController_ visibleViewController] == [CCDirector sharedDirector] )
		[[CCDirector sharedDirector] resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == [CCDirector sharedDirector] )
		[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == [CCDirector sharedDirector] )
		[[CCDirector sharedDirector] startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	[[CCDirector sharedDirector] end];
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end

#endif
