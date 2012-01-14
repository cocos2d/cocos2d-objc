//
// cocos2d performance touches test
//

#import "AppController.h"
#import "cocos2d.h"
#import "MainScene.h"

@implementation AppController

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an CCGLView with 0-bit depth format, and RGB565 render buffer
	// 2. CCGLView multiple touches: disabled
	// 3. Parents CCGLView to the main window
	// 4. Creates Display Link Director
	// 4a. If it fails, it will use an NSTimer director
	// 5. It will try to run at 60 FPS
	// 6. Display FPS: NO
	// 7. Device orientation: Portrait
	// 8. Connects the director to the CCGLView
	//
	CC_DIRECTOR_INIT();

	// get instance of the shared director
	CCDirector *director = [CCDirector sharedDirector];

	// before creating any layer, set the landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// display FPS (useful when debugging)
	[director setDisplayStats:YES];

	// set multiple touches ON
	CCGLView *glView = [director openGLView];
	[glView setMultipleTouchEnabled:YES];

	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];

	[director pushScene:scene];
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

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

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
