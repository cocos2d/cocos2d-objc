//
// Accelerometer + physics + touches example
// a cocos2d example
// http://www.cocos2d-iphone.org
//

#import "ChipmunkAccelTouchTest.h"

enum {
	kTagAtlasSpriteManager = 1,
};

static void
eachShape(void *ptr, void* unused)
{
	cpShape *shape = (cpShape*) ptr;
	Sprite *sprite = shape->data;
	if( sprite ) {
		cpBody *body = shape->body;
		
		// TIP: cocos2d and chipmunk uses the same struct to store it's position
		// chipmunk uses: cpVect, and cocos2d uses CGPoint but in reality the are the same
		// since v0.7.1 you can mix them if you want.
		
		// before v0.7.1
//		[sprite setPosition: ccp( body->p.x, body->p.y)];
		
		// since v0.7.1 (eaier)
		[sprite setPosition: body->p];
		
		[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
	}
}

@implementation Layer1
-(void) addNewSpriteX: (float)x y:(float)y
{
	int posx, posy;

	AtlasSpriteManager *mgr = (AtlasSpriteManager*) [self getChildByTag:kTagAtlasSpriteManager];
	
	posx = (CCRANDOM_0_1() * 200);
	posy = (CCRANDOM_0_1() * 200);
	
	posx = (posx % 4) * 85;
	posy = (posy % 3) * 121;
	
	AtlasSprite *sprite = [AtlasSprite spriteWithRect:CGRectMake(posx, posy, 85, 121) spriteManager:mgr];
	[mgr addChild: sprite];
	
	sprite.position = ccp(x,y);
	
	int num = 4;
	CGPoint verts[] = {
		ccp(-24,-54),
		ccp(-24, 54),
		ccp( 24, 54),
		ccp( 24,-54),
	};
	
	cpBody *body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, CGPointZero));
	
	// TIP:
	// since v0.7.1 you can assign CGPoint to chipmunk instead of cpVect.
	// cpVect == CGPoint
	body->p = ccp(x, y);
	cpSpaceAddBody(space, body);
	
	cpShape* shape = cpPolyShapeNew(body, num, verts, CGPointZero);
	shape->e = 0.5f; shape->u = 0.5f;
	shape->data = sprite;
	cpSpaceAddShape(space, shape);
	
}
-(id) init
{
	if( (self=[super init])) {
	
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		
		CGSize wins = [[Director sharedDirector] winSize];
		cpInitChipmunk();
		
		cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
		space = cpSpaceNew();
		cpSpaceResizeStaticHash(space, 400.0f, 40);
		cpSpaceResizeActiveHash(space, 100, 600);

		space->gravity = ccp(0, 0);
		space->elasticIterations = space->iterations;

		cpShape *shape;
		
		// bottom
		shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(wins.width,0), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);

		// top
		shape = cpSegmentShapeNew(staticBody, ccp(0,wins.height), ccp(wins.width,wins.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);

		// left
		shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(0,wins.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);

		// right
		shape = cpSegmentShapeNew(staticBody, ccp(wins.width,0), ccp(wins.width,wins.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		AtlasSpriteManager *mgr = [AtlasSpriteManager spriteManagerWithFile:@"grossini_dance_atlas.png" capacity:100];
		[self addChild:mgr z:0 tag:kTagAtlasSpriteManager];
		
		[self addNewSpriteX: 200 y:200];

		[self schedule: @selector(step:)];
	}

	return self;
}

-(void) onEnter
{
	[super onEnter];

	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
}

-(void) step: (ccTime) delta
{
	int steps = 2;
	CGFloat dt = delta/(CGFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
	cpSpaceHashEach(space->activeShapes, &eachShape, nil);
	cpSpaceHashEach(space->staticShapes, &eachShape, nil);
}


- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
				
		location = [[Director sharedDirector] convertCoordinate: location];
		
		[self addNewSpriteX: location.x y:location.y];
	}
	return kEventHandled;
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
#define kFilterFactor 0.05f
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;

	CGPoint v = ccp( accelX, accelY);

	space->gravity = ccpMult(v, 200);
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
	[window setMultipleTouchEnabled:YES];
	
	// must be called before any othe call to the director
//	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
//	[[Director sharedDirector] setLandscape: YES];
	
	// AnimationInterval doesn't work with FastDirector, yet
//	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];

	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];

	// And you can later, once the openGLView was created
	// you can change it's properties
	[[[Director sharedDirector] openGLView] setMultipleTouchEnabled:YES];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];	
	
	// add layer
	Scene *scene = [Scene node];
	[scene addChild: [Layer1 node] z:0];
	
	// add the label
	CGSize s = [[Director sharedDirector] winSize];
	Label* label = [Label labelWithString:@"Multi touch the screen" fontName:@"Marker Felt" fontSize:36];
	label.position = ccp( s.width / 2, s.height - 30);
	[scene addChild:label z:-1];

	[window makeKeyAndVisible];

	[[Director sharedDirector] runWithScene: scene];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
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

@end
