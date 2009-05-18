//
// Demo of calling Box2D testbed test case from a cocos2d Layer
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//
// Box2d Demo by Steve Oldmeadow
//

#import "Box2dTest.h"
#import "SphereStack.h"
#import "VerticalStack.h"

Settings settings;

@implementation Box2DTestLayer
-(id) init
{
	if((self=[super init])) {
		//currentTest = SphereStack::Create();	
		currentTest = VerticalStack::Create();	
		isTouchEnabled = YES;
	}
	return self;
}

-(void) dealloc
{
	if (currentTest != NULL) {
		delete currentTest;
	}	
	[super dealloc];
}	

-(void) draw
{
    glPushMatrix();
	//Scale can be used to zoom in and out of scene
	glScalef(10.0f, 10.0f, 1.0f);
	glEnableClientState(GL_VERTEX_ARRAY);
	//Make sure you call step from a draw method as step triggers
	//debug drawing which assumes OpenGL context is set up correctly.
	//NB: normally you would not want to call step from draw but all
	//testbed tests use debug drawing for rendering
	currentTest->Step(&settings);
	glPopMatrix();
}	

- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Fire a bullet when the screen is touched (mapped to ',' key on keyboard)
	currentTest->Keyboard(',');
	return kEventHandled; 
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
	[Director useFastDirector];

	// AnimationInterval doesn't work with FastDirector, yet
//	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];

	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];

	// And you can later, once the openGLView was created
	// you can change it's properties
	[[[Director sharedDirector] openGLView] setMultipleTouchEnabled:YES];
	
	
	// add layer
	Scene *scene = [Scene node];
	id box2dLayer = [[Box2DTestLayer alloc] init];
	[scene addChild:box2dLayer z:0];
	
	[box2dLayer setPosition:ccp(240,160)];

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
