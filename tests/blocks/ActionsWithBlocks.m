//
// cocos2d Actions with blocks example
// http://www.cocos2d-iphone.org
//
// Example by Stuart Carnie ( http://manomio.com/ )

// Import the interfaces
#import "ActionsWithBlocks.h"


// HelloWorld implementation
@implementation ActionsWithBlocks

-(void)callbackTest:(id)sender {
}

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
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Actions with Blocks" fontName:@"Marker Felt" fontSize:64];

		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];

		// position the label on the center of the screen
		// "ccp" is a helper macro that creates a point. It means: "CoCos Point"
		label.position =  ccp( size.width /2 , size.height/2 );

		// add the label as a child to this Layer
		[self addChild: label];

		// objective-c can be an static or dynamic language.
		// "id" is a reserved word that means "this is an object, but I don't care its type"
		// scales the label 2.5x in 3 seconds.
		id action = [CCScaleBy actionWithDuration:3.0f scale:2.5f];

		// blocks are allocated on the stack, and so you must make a copy of the block if it is
		// going to be used outside the current scope.  The BCA (Block Copy Autorelease) macro
		// does this, as follows: [[block copy] autorelease]
		id blockAction = [CCCallBlock actionWithBlock:
						  ^{
							  [label setString:@"Called Block!"];
						  }];

		void (^reusableBlock)(CCNode*) = ^(CCNode *n) {
			// do something generic with node
			CCLOG(@"called reusable block for %@", n);
		};

		// tell the "label" to run the action
		// The action will be execute once this Layer appears on the screen (not before).
		[label runAction:[CCSequence actions:action, blockAction, [CCCallBlockN actionWithBlock:reusableBlock], nil]];

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
		id sequence = [CCSequence actions: fordward, backwards, [CCCallBlockN actionWithBlock:reusableBlock], nil];

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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// display FPS (useful when debugging)
	[director_ setDisplayStats:YES];

	// frames per second
	[director_ setAnimationInterval:1.0/60];

	// enable multiple touches
	[director_.view setMultipleTouchEnabled:YES];

	// Create and initialize parent and empty Scene
	CCScene *scene = [CCScene node];

	// Create and initialize our HelloActions Layer
	CCLayer *layer = [ActionsWithBlocks node];
	// add our HelloWorld Layer as a child of the main scene
	[scene addChild:layer];

	// Run!
	[director_ pushScene: scene];

	return YES;
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

