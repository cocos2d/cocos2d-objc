/* TouchesTest (c) Valentin Milea 2009
 */
#import "TouchesDemoAppDelegate.h"
#import "PongScene.h"
#import "cocos2d.h"

@implementation AppController

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:YES];

	[Director useFastDirector];
	
	[[Director sharedDirector] attachInWindow:window];
	[Director sharedDirector].displayFPS = YES;

	[window makeKeyAndVisible];
	
//	[[TouchDispatcher sharedDispatcher] link];
	[[Director sharedDirector] runWithScene:[PongScene node]];
}

-(void)dealloc
{
	[super dealloc];
}

-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

@end
