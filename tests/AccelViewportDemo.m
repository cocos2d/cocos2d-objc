//
// AccelViewport Demo
// a cocos2d example by Alecu
//
// To use the virtual accelerometer version, please go here:
// http://code.google.com/p/remote-accel/
//

// local import
//#import "VirtualAccelerometer.h"
#import "AccelViewportDemo.h"

float randfloat() {
	return ((float)random())/RAND_MAX;
}

#define CLOUDS_SCALE 1.6

@implementation AccelViewportDemo
-(id) init
{
	[super init];

	isTouchEnabled = YES;
	isAccelerometerEnabled = YES;
	clouds = [[Sprite spriteFromFile:@"clouds.jpg"] retain];
	[clouds setScale: CLOUDS_SCALE];
	
	CGSize cs = clouds.texture.contentSize;
	cloudsSize = cpv(cs.width, cs.height);
	[self add: clouds z:0];

	CGRect s = [[Director sharedDirector] winSize];
	screenSize = cpv(s.size.width, s.size.height);
	
	halfCloudsSize = cpvmult(cloudsSize, 0.5*CLOUDS_SCALE);
	cpVect halfScreenSize = cpvmult(screenSize, 0.5);
	cloudsCentered = halfScreenSize;
	cpVect tl = cpvadd(cpvsub(cloudsCentered, halfCloudsSize), halfScreenSize);
	cpVect br = cpvsub(cpvadd(cloudsCentered, halfCloudsSize), halfScreenSize);
	visibleArea = cpBBNew(tl.x, tl.y, br.x, br.y);
	
	[clouds setPosition: cloudsCentered];
	cloudsPos = cloudsCentered;

	for (int n=0; n<NUM_GROSSINIS; n++) {
		cpVect pos = cpv((randfloat())*cloudsSize.x, (randfloat())*cloudsSize.y);
		grossini[n] = [self addNewSpritePosition:pos scale:0.15];
		[grossini[n] do:[Repeat actionWithAction:[RotateBy actionWithDuration:.5*(n%5) angle:(n>NUM_GROSSINIS/2)?360:-360 ] times:100000]];
	}
		
	NSString *info = [NSString stringWithFormat:@"(%.1f,%.1f) (%.1f,%.1f)", tl.x, tl.y, br.x, br.y];

	info = @"Grossini's iPhone";
	
	label = [Label labelWithString:info dimensions:CGSizeMake(s.size.width, 20) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:16];
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
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 100)];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];	
	CGPoint touchLocation = [touch locationInView: [touch view]];

	touchLocation = [[Director sharedDirector] convertCoordinate: touchLocation];
	cpVect location = cpv(touchLocation.x, touchLocation.y);
	location = cpvsub(location, cloudsPos);
	location = cpvmult(location, 1.0/CLOUDS_SCALE);
	location = cpvadd(location, cpvmult(cloudsSize, 0.5));

	NSString *info = [ NSString stringWithFormat: @"(%.1f,%.1f) (%.1f,%.1f) (%.1f,%.1f) (%.1f,%.1f)", 
					   touchLocation.x, touchLocation.y, cloudsSize.x, cloudsSize.y,
					   cloudsPos.x, cloudsPos.y, location.x, location.y ];
	
	[label setString: info];
	
	[grossini[num_g++%NUM_GROSSINIS] setPosition:location ];
}

// Implement this method to get the lastest data from the accelerometer 
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	double kFilteringFactor = 0.01;
	
	accels[0] = acceleration.x * kFilteringFactor + accels[0] * (1.0 - kFilteringFactor);
	accels[1] = acceleration.y * kFilteringFactor + accels[1] * (1.0 - kFilteringFactor);
	accels[2] = acceleration.z * kFilteringFactor + accels[2] * (1.0 - kFilteringFactor);
	
	cpVect dest = cpvadd(cloudsCentered, cpv(cloudsSize.x*ACC_FACTOR*accels[1], cloudsSize.y*ACC_FACTOR*-accels[0]));
	
	// comentar esta linea para no limitar el area scrolleable
	dest = cpBBClampVect(visibleArea, dest);
	
	// velocidad inv. prop. a la distancia a recorrer
	cpVect newPos = cpvadd(cloudsPos, cpvmult(cpvsub(dest, cloudsPos), 0.1) );
	[clouds setPosition:newPos];
	cloudsPos = newPos;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesMoved:touches withEvent:event];
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

@end
