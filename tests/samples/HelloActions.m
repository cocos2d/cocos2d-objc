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
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello Actions" fontName:@"Marker Felt" fontSize:64];

		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		// "ccp" is a helper macro that creates a point. It means: "CoCos Point"
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];
		
		// objective-c can be an static or dynamic language.
		// "id" is a reserved word that means "this is an object, but I don't care it's type"
		// scales the label 2.5x in 3 seconds.
		id action = [CCScaleBy actionWithDuration:3.0f scale:2.5f];
		
		// tell the "label" to run the action
		// The action will be execute once this Layer appears on the screen (not before).
		[label runAction:action];
		
		//
		// Sprite
		//
		
		CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
		sprite.position = ccp( 0, 50);
		
		// z is the z-order. Greater values means on top of lower values.
		// default z value is 0.
		// So the sprite will be on top of the label.
		[self addChild:sprite z:1];
		
		// create a RotateBy action.
		// "By" means relative. "To" means absolute.
		id rotateAction = [CCRotateBy actionWithDuration:4 angle:180*4];
		
		// create a JumpBy action.
		id jumpAction = [CCJumpBy actionWithDuration:4 position:ccp(size.width,0) height:100 jumps:4];
		
		// spawn is an action that executes 2 or more actions at the same time
		id fordward = [CCSpawn actions:rotateAction, jumpAction, nil];
		
		// almost all actions supports the "reverse" method. 
		// It will create a new actions that is the reversed action.
		id backwards = [fordward reverse];
		
		// Sequence is an action that executes one action after another one
		id sequence = [CCSequence actions: fordward, backwards, nil];
		
		// Finally, you can repeat an action as many times as you want.
		// You can repeat an action forever using the "RepeatForEver" action.
		id repeat = [CCRepeat actionWithAction:sequence times:2];
		
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
	
	// Sets landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// Turn on display FPS
	[director setDisplayFPS:YES];
	
	// Set multiple touches on
	EAGLView *glView = [director openGLView];
	[glView setMultipleTouchEnabled:YES];	
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Create and initialize parent and empty Scene
	CCScene *scene = [CCScene node];

	// Create and initialize our HelloActions Layer
	CCLayer *layer = [HelloActions node];
	// add our HelloWorld Layer as a child of the main scene
	[scene addChild:layer];

	// Run!
	[director runWithScene: scene];
}

- (void) dealloc
{
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
	CC_DIRECTOR_END();
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

