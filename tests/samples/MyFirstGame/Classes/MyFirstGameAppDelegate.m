//
// cocos2d template example
// http://www.cocos2d-iphone.org
//

#import "MyFirstGameAppDelegate.h"
#import "HelloWorldLayer.h"

@implementation MyFirstGameAppDelegate

// window is a property. @synthesize will create the accesors methods
@synthesize window;

// Application entry point
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// create an initilize the main UIWindow
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Attach cocos2d to the window
	[[Director sharedDirector] attachInWindow:window];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	
	// Make the window visible
	[window makeKeyAndVisible];
	
	// Create and initialize parent and empty Scene
	Scene *scene = [Scene node];
	
	// Create and initialize our HelloWorld Layer
	Layer *layer = [HelloWorld node];
	// add our HelloWorld Layer as a child of the main scene
	[scene addChild:layer];
	
	// Run!
	[[Director sharedDirector] runWithScene: scene];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}

@end