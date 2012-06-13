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

-(id) init
{
	if( (self=[super init]) ) {
		useRetinaDisplay_ = YES;
	}
	
	return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Main Window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Director
	director_ = (CCDirectorIOS*)[CCDirector sharedDirector];
	[director_ setDisplayStats:NO];
	[director_ setAnimationInterval:1.0/60];
	
	// GL View
	CCGLView *__glView = [CCGLView viewWithFrame:[window_ bounds]
									 pixelFormat:kEAGLColorFormatRGB565
									 depthFormat:0 /* GL_DEPTH_COMPONENT24_OES */
							  preserveBackbuffer:NO
									  sharegroup:nil
								   multiSampling:NO
								 numberOfSamples:0
						  ];
	
	[director_ setView:__glView];
	[director_ setDelegate:self];
	director_.wantsFullScreenLayout = YES;

	// Retina Display ?
	[director_ enableRetinaDisplay:useRetinaDisplay_];
	
	// Navigation Controller
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;

	// AddSubView doesn't work on iOS6
	[window_ addSubview:navController_.view];
//	[window_ setRootViewController:navController_];

	[window_ makeKeyAndVisible];

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
	[director_ purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[director_ setNextDeltaTimeZero:YES];
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

	// Center window
	[self.window center];																		\
	
//	[director setProjection:kCCDirectorProjection2D];

	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	[director_ setResizeMode:kCCDirectorResize_NoScale]; // kCCDirectorResize_AutoScale
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


