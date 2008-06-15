//
// cocos2d for iphone
// main file
//

#import "Scene.h"
#import "Layer.h"
#import "Director.h"
#import "Sprite.h"
#import "IntervalAction.h"
#import "InstantAction.h"
#import "Label.h"
#import "MenuItem.h"
#import "Menu.h"

#import "Playground.h"

#import "OpenGL_Internal.h"

#import "Box2D.h"

@implementation Layer1
-(id) init
{
	[super init];
	
	isEventHandler = YES;
	
	CGRect wins = [[Director sharedDirector] winSize];
	
	Sprite *sprite = [Sprite spriteFromFile:@"grossini.png"];
	[sprite setPosition: CGPointMake(50,50)];
	[self add: sprite z:0 name:@"grossini"];
	
	// Define the size of the world. Simulation will still work
	// if bodies reach the end of the world, but it will be slower.
	b2AABB worldAABB;
	worldAABB.lowerBound.Set(-100.0f, -100.0f);
	worldAABB.upperBound.Set(500.0f, 500.0f);
	
	// Define the gravity vector.
	b2Vec2 gravity(0.0f, -10.0f);
	
	// Do we want to let bodies sleep?
	bool doSleep = true;
	
	// Construct a world object, which will hold and simulate the rigid bodies.
	world = new b2World(worldAABB, gravity, doSleep);
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(wins.size.width/2, 0);
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2PolygonDef groundShapeDef;
	
	// The extents are the half-widths of the box.
	groundShapeDef.SetAsBox(wins.size.width, 5.0f);
	
	// Add the ground shape to the ground body.
	groundBody->CreateShape(&groundShapeDef);
	
	// Define the dynamic body. We set its position and call the body factory.
	b2BodyDef bodyDef;
	bodyDef.position.Set( wins.size.width/2, 250.0f);
	bodyDef.userData = sprite;
		
	b2Body* body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonDef shapeDef;
	shapeDef.SetAsBox(51.0f/2, 109.0f/2);

	// Set the box density to be non-zero, so it will be dynamic.
	shapeDef.density = 1.0f;
	
	// Override the default friction.
	shapeDef.friction = 0.3f;
	
	// Add the shape to the body.
	body->CreateShape(&shapeDef);
	
	// Now tell the dynamic body to compute it's mass properties base
	// on its shape.
	body->SetMassFromShapes();
	
	// user data

	return self;
}

-(void) onEnter
{
	[super onEnter];
	[self schedule: @selector(step)];
}

-(void) onExit
{
	[super onExit];
	[self unschedule:@selector(step)];
}

-(void) step
{
	// Prepare for simulation. Typically we use a time step of 1/60 of a
	// second (60Hz) and 10 iterations. This provides a high quality simulation
	// in most game scenarios.
	float32 timeStep = 1.0f / 60.0f;
	int32 iterations = 10;
	
	world->Step(timeStep, iterations);
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		Sprite *sprite = (Sprite*) b->GetUserData();
		[sprite setPosition:CGPointMake( b->GetPosition().x, b->GetPosition().y) ];
		[sprite setRotation: RADIANS_TO_DEGREES(b->GetAngle())];
	}
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];	
	CGPoint location = [touch locationInView: [touch view]];
	
	location = [[Director sharedDirector] convertCoordinate: location];
	
	Sprite *sprite = [Sprite spriteFromFile:@"grossini.png"];
	[self add: sprite];
	
	// Define the dynamic body. We set its position and call the body factory.
	b2BodyDef bodyDef;
	bodyDef.position.Set( location.x, location.y);
	bodyDef.userData = sprite;
	
	b2Body* body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonDef shapeDef;
	shapeDef.SetAsBox(24.0f, 54.0f);
	
	// Set the box density to be non-zero, so it will be dynamic.
	shapeDef.density = 1.0f;
	
	// Override the default friction.
	shapeDef.friction = 0.1f;
	
	// Add the shape to the body.
	body->CreateShape(&shapeDef);
	
	// Now tell the dynamic body to compute it's mass properties base
	// on its shape.
	body->SetMassFromShapes();
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// before creating any layer, set the landscape mode
//	[[Director sharedDirector] setLandscape: YES];

		
	Scene *scene = [Scene node];

	[scene add: [Layer1 node] z:0];

	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	
	[[Director sharedDirector] runScene: scene];
}

@end