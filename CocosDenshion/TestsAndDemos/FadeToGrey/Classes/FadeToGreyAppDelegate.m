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

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// get instance of the shared director
	CCDirector *director = [CCDirector sharedDirector];

	// display FPS (useful when debugging)
	[director setDisplayFPS:YES];
	
	// frames per second
	[director setAnimationInterval:1.0/60];
	
	// create an OpenGL view
	EAGLView *glView = [EAGLView viewWithFrame:[window_ bounds]];
	[glView setMultipleTouchEnabled:YES];
	
	// connect it to the director
	[director setOpenGLView:glView];
	
	viewController_ = [[RootViewController alloc] init];
	[viewController_ setView:glView];
	
	[window_ addSubview:viewController_.view];
	
	// Make the window visible
	[window_ makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	
	[director runWithScene: [HelloWorld scene]];
}


- (void) applicationDidEnterBackground:(UIApplication *)application
{
	[[CCDirector sharedDirector] stopAnimation];
	[[CCDirector sharedDirector] pause];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] stopAnimation];
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] stopAnimation]; // call this to make sure you don't start a second display link!
	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[CCDirector sharedDirector] end];
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
