//
// cocos2d Hello Actions example
// http://www.cocos2d-iphone.org
//

// IMPORTANT:
//  This example ONLY shows the basic steps to render a label on the screen.
//  Some advanced options regarding the initialization were removed to simplify the sample.
//  Once you understand this example, read "HelloActions" sample.

// Needed for UIWindow, NSAutoReleasePool, and other objects
#import <UIKit/UIKit.h>

// Import the interfaces
#import "HelloActions.h"

// HelloWorld implementation
@implementation HelloActions

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
		//
		// Label
		//
		
		// create and initialize a Label
		Label* label = [Label labelWithString:@"Hello Actions" fontName:@"Marker Felt" fontSize:64];

		// ask director the the window size
		CGSize size = [[Director sharedDirector] winSize];
	
		// position the label on the center of the screen
		// "ccp" is a helper macro that creates a point. It means: "CoCos Point"
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];
		
		// objective-c can be an static or dynamic language.
		// "id" is a reserved word that means "this is an object, but I don't care it's type"
		// scales the label 2.5x in 3 seconds.
		id action = [ScaleBy actionWithDuration:3.0f scale:2.5f];
		
		// tell the "label" to run the action
		// The action will be execute once this Layer appears on the screen (not before).
		[label runAction:action];
		
		//
		// Sprite
		//
		
		Sprite *sprite = [Sprite spriteWithFile:@"grossini.png"];
		sprite.position = ccp( 0, 50);
		
		// z is the z-order. Greater values means on top of lower values.
		// default z value is 0.
		// So the sprite will be on top of the label.
		[self addChild:sprite z:1];
		
		// create a RotateBy action.
		// "By" means relative. "To" means absolute.
		id rotateAction = [RotateBy actionWithDuration:4 angle:180*4];
		
		// create a JumpBy action.
		id jumpAction = [JumpBy actionWithDuration:4 position:ccp(size.width,0) height:100 jumps:4];
		
		// spawn is an action that executes 2 or more actions at the same time
		id fordward = [Spawn actions:rotateAction, jumpAction, nil];
		
		// almost all actions supports the "reverse" method. 
		// It will create a new actions that is the reversed action.
		id backwards = [fordward reverse];
		
		// Sequence is an action that executes one action after another one
		id sequence = [Sequence actions: fordward, backwards, nil];
		
		// Finally, you can repeat an action as many times as you want.
		// You can repeat an action forever using the "RepeatForEver" action.
		id repeat = [Repeat actionWithAction:sequence times:2];
		
		// Tell the sprite to execute the actions.
		// The action will be execute once this Layer appears on the screen (not before).
		[sprite runAction:repeat];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end

//
// Application Delegate implementation.
// Probably all your games will have a similar Application Delegate.
// For the moment it's not that important if you don't understand the following code.
//
@implementation AppController

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

	// Create and initialize our HelloActions Layer
	Layer *layer = [HelloActions node];
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


//
// main entry point. Like any c or c++ program, the "main" is the entry point
//
int main(int argc, char *argv[]) {
	// it is safe to leave these lines as they are.
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	UIApplicationMain(argc, argv, nil, @"AppController");
	[pool release];
	return 0;
}

