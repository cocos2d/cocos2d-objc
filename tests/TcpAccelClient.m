//
// TcpAccelClient Demo
// a cocos2d example
//

// local import
#import "VirtualAccelerometer.h"
#import "TcpAccelClient.h"

Class nextAction();

@implementation SpriteDemo
-(id) init
{
	[super init];

	isTouchEnabled = YES;

	grossini = [[Sprite spriteFromFile:@"grossini.png"] retain];
	
	[self add: grossini z:1];

	CGRect s = [[Director sharedDirector] winSize];
	
	[grossini setPosition: cpv(60, s.size.height/3)];
	
	Label* label = [Label labelWithString:[self title] dimensions:CGSizeMake(s.size.width, 40) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:32];
	[self add: label];
	[label setPosition: cpv(s.size.width/2, s.size.height-50)];

	return self;
}

-(void) dealloc
{
	[grossini release];
	[super dealloc];
}

-(void) centerSprites
{
	CGRect s = [[Director sharedDirector] winSize];
	
	[grossini setPosition: cpv(s.size.width/3, s.size.height/2)];
}
-(NSString*) title
{
	return @"No title";
}
@end

@implementation SpriteMove
-(void) onEnter
{
	[super onEnter];
	
	id actionBy = [MoveBy actionWithDuration:2  position: cpv(80,80)];
	
	[grossini do:actionBy];

	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 100)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
}


// Implement this method to get the lastest data from the accelerometer 
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	float angle = atan2(acceleration.y, acceleration.x);
	angle += 3.14159;
	angle *= -180.0/3.14159;	
	[grossini setRotation:angle];
}


-(NSString *) title
{
	return @"VirtualAccelerometer";
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setLandscape: YES];

	Scene *scene = [Scene node];
	SpriteMove *layer = [SpriteMove node];
	[scene add: layer];
			 
	[[Director sharedDirector] runScene: scene];
	
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

@end
