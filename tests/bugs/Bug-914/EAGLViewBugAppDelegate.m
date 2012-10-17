//
//  EAGLViewBugAppDelegate.m
//  EAGLViewBug
//
//  Created by Wylan Werth on 7/5/10.
//  Copyright BanditBear Games 2010. All rights reserved.
//

#import "EAGLViewBugAppDelegate.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"
#import "bugViewController.h"

@implementation EAGLViewBugAppDelegate

@synthesize window;
@synthesize viewController=bugViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	// must be called before any othe call to the director
	[CCDirector setDirectorType:kCCDirectorTypeDisplayLink];

	// before creating any layer, set the landscape mode
	CCDirector *director = [CCDirector sharedDirector];

   	// Enable Retina display
	[director enableRetinaDisplay:YES];

    // Init the View Controller
	viewController = [[bugViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;


    //
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//

	[director setDeviceOrientation:kCCDeviceOrientationPortrait];

	[director setAnimationInterval:1.0/60];

	[director setDisplayFPS:YES];

	// make the OpenGLView a child of the view controller
    //[viewController setView:glView];

    // attach the openglView to the director
	[director setOpenGLView:(EAGLView*)viewController.view];

    [window addSubview:viewController.view];

    //needed for iOS6, recommend in 4 and 5
    [window setRootViewController:viewController];

    // make main window visible
	[window makeKeyAndVisible];



	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// When in iPhone RetinaDisplay, iPad, iPad RetinaDisplay mode, CCFileUtils will append the "-hd", "-ipad", "-ipadhd" to all loaded files
	// If the -hd, -ipad, -ipadhd files are not found, it will load the non-suffixed version
	[CCFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
    [CCFileUtils setiPhoneFourInchDisplaySuffix:@"-568h"];	// Default on iPhone RetinaFourInchDisplay is "-568h"
	[CCFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "" (empty string)
	[CCFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	// Run the intro Scene
	[[CCDirector sharedDirector] runWithScene: [HelloWorld scene]];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

- (void)applicationWillTerminate:(UIApplication *)application {

	CCDirector *director = [CCDirector sharedDirector];

	[[director openGLView] removeFromSuperview];

	[viewController release];

	[window release];

	[director end];

	// BUG: The view controller is not released... why ?
	NSLog(@"viewController rc:%d", [viewController retainCount] );

}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end


int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	int retVal = UIApplicationMain(argc, argv, nil, @"EAGLViewBugAppDelegate");
	[pool release];
	return retVal;
}

