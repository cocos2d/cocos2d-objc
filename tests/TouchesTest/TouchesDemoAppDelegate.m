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

	if( ! [CCDirector setDirectorType:CCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:CCDirectorTypeMainLoop];
	
	[[CCDirector sharedDirector] attachInWindow:window];
	[CCDirector sharedDirector].displayFPS = YES;

	[window makeKeyAndVisible];
	
//	[[CCTouchDispatcher sharedDispatcher] link];
	[[CCDirector sharedDirector] runWithScene:[PongScene node]];
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
	[[CCTextureMgr sharedTextureMgr] removeAllTextures];
}

@end
