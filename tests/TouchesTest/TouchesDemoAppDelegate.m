/* TouchesTest (c) Valentin Milea 2009
 */
#import "TouchesDemoAppDelegate.h"
#import "PongScene.h"
#import "cocos2d.h"


@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// Set multiple touches on
	UIView *view = [director_ view];
	[view setMultipleTouchEnabled:YES];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	return YES;
}

-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil){
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		[director_ runWithScene:[PongScene node]];
	}
}
@end
