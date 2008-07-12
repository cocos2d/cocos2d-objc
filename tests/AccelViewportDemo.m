//
// AccelViewport Demo
// a cocos2d example
//

// cocos2d imports
#import "Scene.h"
#import "Layer.h"
#import "Director.h"
#import "Sprite.h"
#import "IntervalAction.h"
#import "InstantAction.h"
#import "Label.h"

// local import
#import "VirtualAccelerometer.h"
#import "AccelViewportDemo.h"

float randfloat() {
	return ((float)random())/RAND_MAX;
}

Class nextAction();

@implementation SpriteDemo
-(id) init
{
	[super init];

	isEventHandler = YES;

	cloudsSize = cpv(1416/2, 930/2);
	clouds = [[Sprite spriteFromFile:@"clouds.jpg"] retain];
	
	//[self add: grossini z:1];
	[self add: clouds z:0];

	CGRect s = [[Director sharedDirector] winSize];
	
	screenCenter = cpv(s.size.width/2, s.size.height/2);
	
	//[grossini setPosition: screenCenter];
	[clouds setPosition: screenCenter];
	cloudsPos = screenCenter;
	[clouds setScale: 1.5];	

	for (int n=0; n<NUM_BALLS; n++) {
		grossini[n] = [[Sprite spriteFromFile:@"grossini.png"] retain];
		[clouds add: grossini[n]];
		[grossini[n] setScale: .15];
		[grossini[n] setPosition: cpv((randfloat()-0.5)*cloudsSize.x, (randfloat()-0.5)*cloudsSize.y) ];
		[grossini[n] do:[Repeat actionWithAction:[RotateBy actionWithDuration:.5*(n%5) angle:(n>NUM_BALLS/2)?360:-360 ] times:100000]];
	}
	
	Label* label = [Label labelWithString:[self title] dimensions:CGSizeMake(s.size.width, 40) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:32];
	[self add: label];
	[label setPosition: cpv(s.size.width/2, s.size.height-50)];

	return self;
}

-(void) dealloc
{
	//[grossini release];
	[super dealloc];
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
	
	//id actionBy = [MoveBy actionWithDuration:2  position: cpv(80,80)];
	//[grossini do:actionBy];

	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 100)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
}


// Implement this method to get the lastest data from the accelerometer 
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	/*
	float angle = atan2(acceleration.y, acceleration.x);
	angle += 3.14159;
	angle *= -180.0/3.14159;	
	[grossini setRotation:angle];
	*/
	
	cpVect dest = cpvadd(screenCenter, cpv(cloudsSize.x*ACC_FACTOR*acceleration.y, cloudsSize.y*ACC_FACTOR*acceleration.x));
	if (cpvlength(cpvsub(cloudsPos, dest)) > 10) {
		id actionTo = [MoveTo actionWithDuration:.3 position:dest];
		[clouds do:actionTo];
		cloudsPos = dest;
	}
	//[clouds setPosition:dest];
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

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	Scene *scene = [Scene node];
	SpriteMove *layer = [SpriteMove node];
	[scene add: layer];
			 
	[[Director sharedDirector] runScene: scene];
}

@end
