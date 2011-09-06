//
// cocos2d performance particle test
// Based on the test by Valentin Milea
//

#import "AppController.h"
#import "cocos2d.h"
#import "PerformanceNodeChildrenTest.h"

@implementation AppController

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// get instance of the shared director
	CCDirector *director = [CCDirector sharedDirector];

	// display FPS (useful when debugging)
	[director setDisplayFPS:YES];
	
	// frames per second
	[director setAnimationInterval:1.0/60];
	
	// create an OpenGL view
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]];
	
	// connect it to the director
	[director setOpenGLView:glView];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// glview is a child of the main window
	[window addSubview:glView];
	
	// Make the window visible
	[window makeKeyAndVisible];
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() testWithQuantityOfNodes:kNodesIncrease]];
	
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(dumpProfilerInfo:) forTarget:self interval:2 paused:NO];
	[director runWithScene:scene];
}

-(void) dumpProfilerInfo:(ccTime)dt
{
	CC_PROFILER_DISPLAY_TIMERS();
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
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
