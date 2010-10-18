//
// cocos2d Hello Events example
// http://www.cocos2d-iphone.org
//

// IMPORTANT:
//  This example ONLY shows the basic steps to render a label on the screen.
//  Some advanced options regarding the initialization were removed to simplify the sample.

// Needed for UIWindow, NSAutoReleasePool, and other objects
#import <UIKit/UIKit.h>

// Import the interfaces
#import "HelloEvents.h"

// A simple 'define' used as a tag
enum {
	kTagSprite = 1,
};

// HelloWorld implementation
@implementation HelloEvents

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
		// isTouchEnabled is an property of Layer (the super class).
		// When it is YES, then the touches will be enabled
		self.isTouchEnabled = YES;

		// isTouchEnabled is property of Layer (the super class).
		// When it is YES, then the accelerometer will be enabled
		self.isAccelerometerEnabled = YES;

		//
		// CCLabel
		//
		
		// create and initialize a CCLabelTTF
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello Events" fontName:@"Marker Felt" fontSize:64];

		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		// "ccp" is a helper macro that creates a point. It means: "CoCos Point"
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];

		//
		// Sprite
		//
		
		CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
		sprite.position = ccp( 50, 50);
		
		// z is the z-order. Greater values means on top of lower values.
		// Default z value is 0. So the sprite will be on top of the label.
		// Add the sprite with a tag, so we can later 'get' the sprite by this tag
		[self addChild:sprite z:1 tag:kTagSprite];		
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (CCLabel)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}


// This callback will be called because 'isTouchesEnabled' is YES.
// Possible events:
//   * ccTouchesBegan
//   * ccTouchesMoved
//   * ccTouchesEnded
//   * cctouchesCancelled
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	if( touch ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		// IMPORTANT:
		// The touches are always in "portrait" coordinates. You need to convert them to your current orientation
		CGPoint convertedPoint = [[CCDirector sharedDirector] convertToGL:location];
		
		CCNode *sprite = [self getChildByTag:kTagSprite];
		
		// we stop the all running actions
		[sprite stopAllActions];
		
		// and we run a new action
		[sprite runAction: [CCMoveTo actionWithDuration:1 position:convertedPoint]];
		
	}	
}

// This callback will be called because 'isAccelerometerEnabled' is YES.
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	CCNode *sprite = [self getChildByTag:kTagSprite];

	// Convert the coordinates to 'landscape' coords
	// since they are always in 'portrait' coordinates
	CGPoint converted = ccp( (float)-acceleration.y, (float)acceleration.x);	
	
	// update the rotation based on the z-rotation
	// the sprite will always be 'standing up'
	sprite.rotation = (float) CC_RADIANS_TO_DEGREES( atan2f( converted.x, converted.y) + M_PI );
	
	// update the scale based on the length of the acceleration
	// the higher the acceleration, the higher the scale factor
	sprite.scale = 0.5f + sqrtf( (converted.x * converted.x) + (converted.y * converted.y) );
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

	// Create and initialize our HelloEvents Layer
	CCLayer *layer = [HelloEvents node];
	// add our HelloEvents Layer as a child of the main scene
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

