/* TouchesTest (c) Valentin Milea 2009
 */
#import "TouchesDemoAppDelegate.h"
#import "PongScene.h"
#import "cocos2d.h"

@implementation AppController

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 5a. If it fails, it will use an NSTimer director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];
	
	// Turn on display FPS
	[director setDisplayFPS:YES];
	
	// Set multiple touches on
	EAGLView *glView = [director openGLView];
	[glView setMultipleTouchEnabled:YES];	
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
//	[[CCTouchDispatcher sharedDispatcher] link];
	[director runWithScene:[PongScene node]];
}

-(void)dealloc
{
	[super dealloc];
}

-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

@end
