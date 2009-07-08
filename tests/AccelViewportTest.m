//
// AccelViewport Demo
// a cocos2d example by Alecu
// http://www.cocos2d-iphone.org
//
// To use the virtual accelerometer version, please go here:
// http://code.google.com/p/remote-accel/
//

// local import
//#import "VirtualAccelerometer.h"
#import "AccelViewportTest.h"

float randfloat() {
	return ((float)random())/RAND_MAX;
}

#define CLOUDS_SCALE 1.3f

@implementation AccelViewportDemo
-(id) init
{
	if( (self=[super init])) {

		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		Texture2D *tex = [[TextureMgr sharedTextureMgr] addPVRTCImage:@"clouds.pvrtc" bpp:4 hasAlpha:NO width:1024];
		clouds = [Sprite spriteWithTexture:tex];
		[clouds setScale: CLOUDS_SCALE];
		
		CGSize cs = clouds.texture.contentSize;
		cloudsSize = ccp(cs.width, cs.height);
		[self addChild: clouds z:0];

		CGSize s = [[Director sharedDirector] winSize];
		screenSize = ccp(s.width, s.height);
		
		halfCloudsSize = ccpMult(cloudsSize, 0.5f*CLOUDS_SCALE);
		CGPoint halfScreenSize = ccpMult(screenSize, 0.5f);
		cloudsCentered = halfScreenSize;
		CGPoint tl = ccpAdd(ccpSub(cloudsCentered, halfCloudsSize), halfScreenSize);
		CGPoint br = ccpSub(ccpAdd(cloudsCentered, halfCloudsSize), halfScreenSize);
		visibleArea = cpBBNew(tl.x, tl.y, br.x, br.y);
		
		[clouds setPosition: cloudsCentered];
		cloudsPos = cloudsCentered;

		for (int n=0; n<NUM_GROSSINIS; n++) {
			CGPoint pos = ccp((randfloat())*cloudsSize.x, (randfloat())*cloudsSize.y);
			grossini[n] = [self addNewSpritePosition:pos scale:0.15];
			[grossini[n] runAction:[Repeat actionWithAction:[RotateBy actionWithDuration:.5f*(n%5) angle:(n>NUM_GROSSINIS/2)?360:-360 ] times:100000]];
		}
			
	//	NSString *info = [NSString stringWithFormat:@"(%.1f,%.1f) (%.1f,%.1f)", tl.x, tl.y, br.x, br.y];
		NSString *info = @"Grossini's iPhone";
		
		label = [Label labelWithString:info fontName:@"Arial" fontSize:16];
		[self addChild: label];
		[label setPosition: ccp(s.width/2, s.height-50)];
	}
	return self;
}

-(Sprite *) addNewSpritePosition:(CGPoint)pos scale:(double)scle
{
	Sprite *g = [Sprite spriteWithFile:@"grossini.png"];
	[clouds addChild: g];
	[g setScale: (float) scle];
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

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];	
	CGPoint touchLocation = [touch locationInView: [touch view]];

	touchLocation = [[Director sharedDirector] convertCoordinate: touchLocation];
	CGPoint location = ccp(touchLocation.x, touchLocation.y);
	location = ccpSub(location, cloudsPos);
	location = ccpMult(location, 1.0f/CLOUDS_SCALE);
	location = ccpAdd(location, ccpMult(cloudsSize, 0.5f));

	NSString *info = [ NSString stringWithFormat: @"(%.1f,%.1f) (%.1f,%.1f) (%.1f,%.1f) (%.1f,%.1f)", 
					   touchLocation.x, touchLocation.y, cloudsSize.x, cloudsSize.y,
					   cloudsPos.x, cloudsPos.y, location.x, location.y ];
	
	[label setString: info];
	
	[grossini[num_g++%NUM_GROSSINIS] setPosition:location ];
	
	return kEventHandled;
}

// Implement this method to get the lastest data from the accelerometer 
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	float kFilteringFactor = 0.01f;
	
	accels[0] = acceleration.x * kFilteringFactor + accels[0] * (1.0f - kFilteringFactor);
	accels[1] = acceleration.y * kFilteringFactor + accels[1] * (1.0f - kFilteringFactor);
	accels[2] = acceleration.z * kFilteringFactor + accels[2] * (1.0f - kFilteringFactor);
	
	CGPoint tmp = ccp( (float) (cloudsSize.x*ACC_FACTOR*accels[1]), (float) (cloudsSize.y*ACC_FACTOR*-accels[0]));
	CGPoint dest = ccpAdd( cloudsCentered, tmp );
	
	// comentar esta linea para no limitar el area scrolleable
	dest = cpBBClampVect(visibleArea, dest);
	
	// velocidad inv. prop. a la distancia a recorrer
	CGPoint newPos = ccpAdd(cloudsPos, ccpMult(ccpSub(dest, cloudsPos), 0.1f) );
	[clouds setPosition:newPos];
	cloudsPos = newPos;
}

- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	return [self ccTouchesMoved:touches withEvent:event];
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
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:NO];
	
	// must be called before any othe call to the director
//	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];
	
	// multiple touches or not ?
//	[[Director sharedDirector] setMultipleTouchEnabled:YES];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];	
	
	// frames per second
	[[Director sharedDirector] setAnimationInterval:1.0/60];	

	// create OpenGL context and add it to window
	[[Director sharedDirector] attachInView:window];
	
	Scene *scene = [Scene node];
	AccelViewportDemo *layer = [AccelViewportDemo node];
	[scene addChild: layer];
	
	[window makeKeyAndVisible];
			 
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

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}

@end
