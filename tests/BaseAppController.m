//
//  AppController.m
//  cocos2d-ios
//
//  Created by Ricardo Quesada on 12/17/11.
//  Copyright (c) 2011 Sapus Media. All rights reserved.
//

#import "BaseAppController.h"

// CLASS IMPLEMENTATIONS
#ifdef __CC_PLATFORM_IOS

#import <UIKit/UIKit.h>

#import "cocos2d.h"
@implementation BaseAppController

@synthesize window=window_, navController=navController_, director=director_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Will create a CCDirector and will associate the view with the director
	// 9. Will create a UINavigationControlView with the director.
	CC_DIRECTOR_INIT();

	return YES;
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
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

- (void) dealloc
{
	[window_ release];
	[navController_ release];

	[super dealloc];
}
@end

#elif defined(__CC_PLATFORM_MAC)

@implementation BaseAppController

@synthesize window=window_, glView=glView_, director = director_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	director_ = (CCDirectorMac*) [CCDirector sharedDirector];

	[director_ setDisplayStats:YES];

	[director_ setView:glView_];

	//	[director setProjection:kCCDirectorProjection2D];

	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	[director_ setResizeMode:kCCDirectorResize_AutoScale];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

@end

#endif // __CC_PLATFORM_MAC


