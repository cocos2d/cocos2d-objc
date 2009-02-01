//
// cocos2d for iphone
// Accelerometer + physics example
//


#import "OpenGL_Internal.h"

#import "Chipmunk_Accel.h"


static void
eachShape(void *ptr, void* unused)
{
	cpShape *shape = (cpShape*) ptr;
	Sprite *sprite = shape->data;
	if( sprite ) {
		cpBody *body = shape->body;
		[sprite setPosition: cpv( body->p.x, body->p.y)];
		[sprite setRotation: RADIANS_TO_DEGREES( -body->a )];
	}
}

@implementation Layer1
-(void) addNewSpriteX: (float)x y:(float)y
{
	Sprite *sprite = [Sprite spriteWithFile:@"grossini.png"];
	[self add: sprite];
	
	sprite.position = cpv(x,y);
	
	int num = 4;
	cpVect verts[] = {
		cpv(-24,-54),
		cpv(-24, 54),
		cpv( 24, 54),
		cpv( 24,-54),
	};
	
	cpBody *body = cpBodyNew(1.0, cpMomentForPoly(1.0, num, verts, cpvzero));
	body->p = cpv(x, y);
	cpSpaceAddBody(space, body);
	
	cpShape* shape = cpPolyShapeNew(body, num, verts, cpvzero);
	shape->e = 0.5; shape->u = 0.5;
	shape->data = sprite;
	cpSpaceAddShape(space, shape);
	
}
-(id) init
{
	[super init];
	
	isTouchEnabled = YES;
	isAccelerometerEnabled = YES;
	
	CGRect wins = [[Director sharedDirector] winSize];
	cpInitChipmunk();
	
	cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
	space = cpSpaceNew();
	cpSpaceResizeStaticHash(space, 400.0, 40);
	cpSpaceResizeActiveHash(space, 100, 600);

	space->gravity = cpv(0, 0);
	space->elasticIterations = space->iterations;

	cpShape *shape;
	
	// bottom
	shape = cpSegmentShapeNew(staticBody, cpv(0,0), cpv(wins.size.width,0), 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);

	// top
	shape = cpSegmentShapeNew(staticBody, cpv(0,wins.size.height), cpv(wins.size.width,wins.size.height), 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);

	// left
	shape = cpSegmentShapeNew(staticBody, cpv(0,0), cpv(0,wins.size.height), 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);

	// right
	shape = cpSegmentShapeNew(staticBody, cpv(wins.size.width,0), cpv(wins.size.width,wins.size.height), 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);
	
	[self addNewSpriteX: 200 y:200];

	[self schedule: @selector(step:)];

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
	cpFloat dt = delta/(cpFloat)steps;
	
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
	
#define kFilterFactor 0.05
	
	float accelX = acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;

	cpVect v = cpv( accelX, accelY);

	space->gravity = cpvmult(v, 200);
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
	
	// before creating any layer, set the landscape mode
//	[[Director sharedDirector] setLandscape: YES];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];

	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];

	// And you can later, once the openGLView was created
	// you can change it's properties
	[[[Director sharedDirector] openGLView] setMultipleTouchEnabled:YES];
	
		
	Scene *scene = [Scene node];

	[scene add: [Layer1 node] z:0];

	[window makeKeyAndVisible];

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
