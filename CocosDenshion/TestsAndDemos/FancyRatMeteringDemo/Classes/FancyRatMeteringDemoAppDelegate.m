//
//  DenshionAudioVisualDemoAppDelegate.m
//  DenshionAudioVisualDemo
//
//  Created by Lam Pham on 2/5/10.
//  Copyright FancyRatStudios Inc. 2010. All rights reserved.
//

#import "RootViewController.h"
#import "FancyRatMeteringDemoAppDelegate.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"

@implementation FancyRatMeteringDemoAppDelegate

@synthesize window=window_, viewController=viewController_, navigationController=navigationController_;

- (void) applicationDidFinishLaunching:(UIApplication*)application
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
	
		
	[director pushScene: [HelloWorld scene]];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
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
	[[CCDirector sharedDirector] end];
	[window_ release];
	[super dealloc];
}

@end
