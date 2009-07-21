//
// Interval Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//


#import "IntervalTest.h"


@implementation Layer1
-(id) init
{
	[super init];
		
	// sun
	ParticleSystem* sun = [ParticleSun node];
	sun.position = ccp(480-32,320-32);

	sun.totalParticles = 130;
	sun.life = 0.6f;
	[self addChild:sun];

	// timers
	label1 = [Label labelWithString:@"0" fontName:@"Courier" fontSize:32];
	label2 = [Label labelWithString:@"0" fontName:@"Courier" fontSize:32];
	label3 = [Label labelWithString:@"0" fontName:@"Courier" fontSize:32];
	
	[self schedule: @selector(step1:) interval: 0.5f];
	[self schedule: @selector(step2:) interval:1.0f];
	[self schedule: @selector(step3:) interval: 1.5f];
	
	label1.position = ccp(80,160);
	label2.position = ccp(240,160);
	label3.position = ccp(400,160);
	
	[self addChild:label1];
	[self addChild:label2];
	[self addChild:label3];
	
	// Sprite
	Sprite *sprite = [Sprite spriteWithFile:@"grossini.png"];
	sprite.position = ccp(40,50);
	
	id jump = [JumpBy actionWithDuration:3 position:ccp(400,0) height:50 jumps:4];
	
	[self addChild:sprite];
	[sprite runAction: [RepeatForever actionWithAction:
					[Sequence actions: jump, [jump reverse], nil]
						]
	 ];

	// pause button
	MenuItem *item1 = [MenuItemFont itemFromString: @"Pause" target:self selector:@selector(pause:)];
	Menu *menu = [Menu menuWithItems: item1, nil];
	menu.position = ccp(480/2, 270);

	[self addChild: menu];
		
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) pause: (id) sender
{
	[[Director sharedDirector] pause];
	
	// Dialog
	UIAlertView* dialog = [[UIAlertView alloc] init];
	[dialog setDelegate:self];
	[dialog setTitle:@"Game Paused"];
	[dialog setMessage:@"Game paused"];
	[dialog addButtonWithTitle:@"Resume"];
	[dialog show];	
	[dialog release];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{	
	[[Director sharedDirector] resume];
}

-(void) step1: (ccTime) delta
{
//	time1 +=delta;
	time1 +=1;
	[label1 setString: [NSString stringWithFormat:@"%2.1f", time1] ];
}

-(void) step2: (ccTime) delta
{
//	time2 +=delta;
	time2 +=1;
	[label2 setString: [NSString stringWithFormat:@"%2.1f", time2] ];
}

-(void) step3: (ccTime) delta
{
//	time3 +=delta;
	time3 +=1;
	[label3 setString: [NSString stringWithFormat:@"%2.1f", time3] ];
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
	[[Director sharedDirector] setDisplayFPS:YES];

	// frames per second
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];	

	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	

	Scene *scene = [Scene node];

	[scene addChild: [Layer1 node] z:0];

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
