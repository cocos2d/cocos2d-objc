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
//#import "VirtualAccelerometer.h"
#import "AccelViewportDemo.h"

float randfloat() {
	return ((float)random())/RAND_MAX;
}

Class nextAction();

@implementation AccelViewportDemo
-(id) init
{
	[super init];

	isTouchEnabled = YES;
	isAccelerometerEnabled = YES;
	clouds = [[Sprite spriteFromFile:@"clouds.jpg"] retain];
	[clouds setScale: 1.6];
	
	CGSize cs = clouds.texture.contentSize;
	cloudsSize = cpv(cs.width, cs.height);
	[self add: clouds z:0];

	CGRect s = [[Director sharedDirector] winSize];
	cpVect screenSize = cpv(s.size.width, s.size.height);
	
	cloudsCentered = cpvmult(screenSize, 0.5);
	cpVect halfCloudsSize = cpvmult(cloudsSize, 0.5);
	cpVect tl = cpvsub(cloudsCentered, halfCloudsSize);
	cpVect br = cpvadd(cloudsCentered, halfCloudsSize);
	visibleArea = cpBBNew(tl.x, tl.y, br.x, br.y);
	
	[clouds setPosition: cloudsCentered];
	cloudsPos = cloudsCentered;

	int n =0;
/*
    grossini[n] = [self addNewSpritePosition:cpv(0,0) scale:1];
	[grossini[n] setRotation: 90 ];
	n++;
		
    grossini[n] = [self addNewSpritePosition:cloudsSize scale:1];
	n++;
*/	

	for (; n<NUM_BALLS; n++) {
		cpVect pos = cpv((randfloat())*cloudsSize.x, (randfloat())*cloudsSize.y);
		grossini[n] = [self addNewSpritePosition:pos scale:0.15];
		[grossini[n] do:[Repeat actionWithAction:[RotateBy actionWithDuration:.5*(n%5) angle:(n>NUM_BALLS/2)?360:-360 ] times:100000]];
	}
		
	NSString *info = [NSString stringWithFormat:@"(%.1f,%.1f) (%.1f,%.1f)", tl.x, tl.y, br.x, br.y];

	info = @"Grossini's iPhone";
	Label* label = [Label labelWithString:info dimensions:CGSizeMake(s.size.width, 40) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:32];
	[self add: label];
	[label setPosition: cpv(s.size.width/2, s.size.height-50)];

	return self;
}

-(Sprite *) addNewSpritePosition:(cpVect)pos scale:(double)scle
{
	Sprite *g = [[Sprite spriteFromFile:@"grossini.png"] retain];
	[clouds add: g];
	[g setScale: scle];
	[g setPosition: pos ];
	return g;
}

-(void) dealloc
{
	//[grossini release];
	[super dealloc];
}

-(void) onEnter
{
	[super onEnter];
	
	//id actionBy = [MoveBy actionWithDuration:2  position: cpv(80,80)];
	//[grossini do:actionBy];

	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 100)];
	//[[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];	
	CGPoint location = [touch locationInView: [touch view]];

	location = [[Director sharedDirector] convertCoordinate: location];
	double x = location.x+cloudsPos.x;
	double y = location.y+cloudsPos.y;
	[grossini[num_g++%NUM_BALLS] setPosition:cpv(x,y) ];
/*
	[self addNewSpritePosition:cpv(location.x, location.y) scale:0.20];
*/
}

// Implement this method to get the lastest data from the accelerometer 
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	/*
	float angle = atan2(acceleration.y, acceleration.x);
	angle += 3.14159;
	angle *= -180.0/3.14159;	
	[grossini setRotation:angle];
	*/

	double kFilteringFactor = 0.01;
	
	accels[0] = acceleration.x * kFilteringFactor + accels[0] * (1.0 - kFilteringFactor);
	accels[1] = acceleration.y * kFilteringFactor + accels[1] * (1.0 - kFilteringFactor);
	accels[2] = acceleration.z * kFilteringFactor + accels[2] * (1.0 - kFilteringFactor);
	
	cpVect dest = cpvadd(cloudsCentered, cpv(cloudsSize.x*ACC_FACTOR*accels[1], cloudsSize.y*ACC_FACTOR*-accels[0]));
	dest = cpBBClampVect(visibleArea, dest);
	
	// velocidad inv. prop. a la distancia a recorrer
	cpVect newPos = cpvadd(cloudsPos, cpvmult(cpvsub(dest, cloudsPos), 0.1) );
	[clouds setPosition:newPos];
	cloudsPos = newPos;
	
	/*
	if (cpvlength(cpvsub(cloudsPos, dest)) > 20) {
		id actionTo = [MoveTo actionWithDuration:.3 position:dest];
		[clouds do:actionTo];
		cloudsPos = dest;
	}
	 */
	//[clouds setPosition:dest];
}


-(NSString *) title
{
	return @"VirtualAccelerometer try2";
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
	AccelViewportDemo *layer = [AccelViewportDemo node];
	[scene add: layer];
			 
	[[Director sharedDirector] runScene: scene];
}

@end
