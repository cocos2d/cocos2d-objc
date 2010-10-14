//
//  Box2DAppDelegate.m
//  Box2D
//
//  Box2D iPhone port by Simon Oliver - http://www.simonoliver.com - http://www.handcircus.com
//

//
// File heavily modified for cocos2d integration
// http://www.cocos2d-iphone.org
//


#import <UIKit/UIKit.h>
#import "Box2DAppDelegate.h"
#import "Box2DView.h"
#import "cocos2d.h"

@implementation Box2DAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    [application setStatusBarHidden:true];
	
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. Parents EAGLView to the main window
	// 4. Creates Display Link Director
	// 4a. If it fails, it will use an NSTimer director
	// 5. It will try to run at 60 FPS
	// 6. Display FPS: NO
	// 7. Device orientation: Portrait
	// 8. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];
	
	// Sets landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// Turn on display FPS
	[director setDisplayFPS:YES];	
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if ([UIScreen instancesRespondToSelector:@selector(scale)])
		[director setContentScaleFactor:[[UIScreen mainScreen] scale]];
	
	CCScene *scene = [CCScene node];
	[scene addChild: [MenuLayer menuWithEntryID:0]];
	
	[director runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

- (void)dealloc {
	[window release];
	[super dealloc];
}

@end
