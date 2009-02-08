//
// Streak Demo
// a cocos2d example
//
// Example by Jason Booth (slipster216)

// cocos import
#import "cocos2d.h"
#import "StreakTest.h"



@implementation StreakTest
-(id) init
{
	[super init];
	CGSize s = [[Director sharedDirector] winSize];
  
	Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:32];
	[self add: label];
	[label setPosition: cpv(s.width/2, s.height-50)];
  
	return self;
}

-(void) dealloc
{
	[root release];
  [target release];
	[super dealloc];
}

-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];
  
  // the root object just rotates around
	root = [[Sprite spriteWithFile:@"r1.png"] retain];
	[self add: root z:1];
	[root setPosition: cpv(s.width/2, s.height/2)];
  
  // the target object is offset from root, and the streak is moved to follow it
  target = [Sprite spriteWithFile:@"r1.png"];
  [root add:target];
  [target setPosition:cpv(100,0)];
  // create the streak object and add it to the scene
  streak = [MotionStreak streakWithFade:3 minSeg:3 image:@"streak.png" width:32 length:32 color:0xFFFFFF];
  [self add:streak];
  // schedule an update on each frame so we can syncronize the streak with the target
  [self schedule:@selector(onUpdate:)];
  
	id a1 = [RotateBy actionWithDuration:2 angle:360];
  
	id action1 = [RepeatForever actionWithAction:a1];
	id motion = [MoveBy actionWithDuration:2 position:cpv(100,0)];
  [root do:[RepeatForever actionWithAction:[Sequence actions:motion, [motion reverse], nil]]];
	[root do:action1];
}

-(void)onUpdate:(ccTime)delta
{
//  cpVect p = [target absolutePosition];
//  float r = [root rotation];
  [streak setPosition:[target absolutePosition]];
}

-(NSString *) title
{
	return @"MotionStreak";
}

@end



// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:NO];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setLandscape: YES];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];
  
	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];		
	
	Scene *scene = [Scene node];
	[scene add: [StreakTest node]];
  
	[[Director sharedDirector] runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}
@end
