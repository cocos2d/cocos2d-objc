//
// cocos2d performance touches test
//

#import "AppController.h"
#import "cocos2d.h"
#import "MainScene.h"

@implementation AppController

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:YES];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use fast director
	if( ! [CCDirector setDirectorType:CCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:CCDirectorTypeMainLoop];
		
//	[[CCDirector sharedDirector] setPixelFormat:kPixelFormatRGBA8888];

	[[CCDirector sharedDirector] attachInWindow:window];
	[CCDirector sharedDirector].displayFPS = YES;
	[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationPortrait];
	
	[window makeKeyAndVisible];
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	[[CCDirector sharedDirector] runWithScene:scene];
}

- (void)dealloc {
	[window release];
	[super dealloc];
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

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
