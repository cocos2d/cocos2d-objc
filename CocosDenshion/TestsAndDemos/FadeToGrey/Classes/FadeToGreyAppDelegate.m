//
//  FadeToGreyAppDelegate.m
//  FadeToGrey
//
//  Created by Stephen Oldmeadow on 5/03/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FadeToGreyAppDelegate.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"
#import "RootViewController.h"

@implementation FadeToGreyAppDelegate

@synthesize window=window_, viewController=viewController_, navigationController=navigationController_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Init the window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// get instance of the shared director
	CCDirector *director = [CCDirector sharedDirector];

	// display FPS (useful when debugging)
	[director setDisplayStats:kCCDirectorStatsFPS];
	
	// frames per second
	[director setAnimationInterval:1.0/60];
	
	// create an OpenGL view
	EAGLView *glView = [EAGLView viewWithFrame:[window_ bounds]];
	[glView setMultipleTouchEnabled:YES];
	
	// connect it to the director
	[director setOpenGLView:glView];
	
	// Init the View Controller
	viewController_ = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController_.wantsFullScreenLayout = YES;
	
	// make the OpenGLView a child of the view controller
	[viewController_ setView:glView];
	
	navigationController_ = [[UINavigationController alloc] initWithRootViewController:viewController_];
	navigationController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navigationController_];
	
	[viewController_ release];
	[navigationController_ release];
	
	// Make the window visible
	[window_ makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	
	[director pushScene: [HelloWorld scene]];
	
	return YES;
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	FadeToGreyAppDelegate *app = [[UIApplication sharedApplication] delegate];
	UINavigationController *nav = [app navigationController];
	
	if( [nav visibleViewController] == viewController_ )
		[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	FadeToGreyAppDelegate *app = [[UIApplication sharedApplication] delegate];
	UINavigationController *nav = [app navigationController];	
	
	if( [nav visibleViewController] == viewController_ )
		[[CCDirector sharedDirector] resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	FadeToGreyAppDelegate *app = [[UIApplication sharedApplication] delegate];
	UINavigationController *nav = [app navigationController];	
	
	if( [nav visibleViewController] == viewController_ )
		[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	FadeToGreyAppDelegate *app = [[UIApplication sharedApplication] delegate];
	UINavigationController *nav = [app navigationController];	
	
	if( [nav visibleViewController] == viewController_ )
		[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{	
	CCDirector *director = [CCDirector sharedDirector];
	[[director openGLView] removeFromSuperview];
	[director end];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[viewController_ release];
	[window_ release];
	[super dealloc];
}

@end
