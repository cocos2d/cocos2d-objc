//
// cocos2d performance particle test
// Based on the test by Valentin Milea
//

#import "cocos2d.h"

#import "AppController.h"
#import "PerformanceTextureTest.h"

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Init the window
	
	CC_DIRECTOR_INIT();
	
	// display FPS (useful when debugging)
	[director_ setDisplayStats:YES];

	CCScene *scene = [nextAction() node];
	[director_ pushScene:scene];
	
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void) dumpProfilerInfo:(ccTime)dt
{
	CC_PROFILER_DISPLAY_TIMERS();
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
