//
// RotateWorld
// a cocos2d example
//


// local import
#import "RotateWorld.h"

@implementation TextLayer
-(id) init
{
	if( ! [super init] )
		return nil;
	float x,y;
	
	CGSize size = [[Director sharedDirector] winSize];
	x = size.width;
	y = size.height;

	NSArray *array = [UIFont familyNames];
	for( NSString *s in array )
		NSLog( s );
	Label* label = [Label labelWithString:@"cocos2d" fontName:@"Marker Felt" fontSize:64];

	[label setPosition: cpv(x/2,y/2)];
	
	[self add: label];
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

@end

@implementation SpriteLayer
-(id) init
{
	if( ! [super init] )
		return nil;
	float x,y;
	
	CGSize size = [[Director sharedDirector] winSize];
	x = size.width;
	y = size.height;
	
	Sprite *sprite = [Sprite spriteWithFile: @"grossini.png"];
	Sprite *spriteSister1 = [Sprite spriteWithFile: @"grossinis_sister1.png"];
	Sprite *spriteSister2 = [Sprite spriteWithFile: @"grossinis_sister2.png"];
	
	[sprite setScale: 1.5];
	[spriteSister1 setScale: 1.5];
	[spriteSister2 setScale: 1.5];
	
	[sprite setPosition: cpv(x/2,y/2)];
	[spriteSister1 setPosition: cpv(40,y/2)];
	[spriteSister2 setPosition: cpv(x-40,y/2)];

	Action *rot = [RotateBy actionWithDuration:16 angle:-3600];
	
	[self add: sprite];
	[self add: spriteSister1];
	[self add: spriteSister2];
	
	[sprite do: rot];

	IntervalAction *jump1 = [JumpBy actionWithDuration:4 position:cpv(-400,0) height:100 jumps:4];
	IntervalAction *jump2 = [jump1 reverse];
	
	IntervalAction *rot1 = [RotateBy actionWithDuration:4 angle:360*2];
	IntervalAction *rot2 = [rot1 reverse];
	
	[spriteSister1 do: [Repeat actionWithAction: [Sequence actions:jump2, jump1, nil] times:5 ] ];
	[spriteSister2 do: [Repeat actionWithAction: [Sequence actions:[[jump1 copy] autorelease], [[jump2 copy] autorelease], nil] times:5 ] ];
	
	[spriteSister1 do: [Repeat actionWithAction: [Sequence actions: rot1, rot2, nil] times:5 ] ];
	[spriteSister2 do: [Repeat actionWithAction: [Sequence actions: [[rot2 copy] autorelease], [[rot1 copy] autorelease], nil] times:5 ] ];
	
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}
@end

@implementation MainLayer
-(id) init
{
	if( ! [super init] )
		return nil;
	float x,y;
	
	CGSize size = [[Director sharedDirector] winSize];
	x = size.width;
	y = size.height;
	
	id blue =  [ColorLayer layerWithColor: 0x0000ffff];
	id red =   [ColorLayer layerWithColor: 0xff0000ff];
	id green = [ColorLayer layerWithColor: 0x00ff00ff];
	id white = [ColorLayer layerWithColor: 0xffffffff];

	[blue setScale: 0.5];
	[blue setPosition: cpv(-x/4,-y/4)];
	[blue add: [SpriteLayer node]];
	
	[red setScale: 0.5];
	[red setPosition: cpv(x/4,-y/4)];

	[green setScale: 0.5];
	[green setPosition: cpv(-x/4,y/4)];
	[green add: [TextLayer node]];

	[white setScale: 0.5];
	[white setPosition: cpv(x/4,y/4)];

	[self add: blue z:-1];
	[self add: white];
	[self add: green];
	[self add: red];

	Action * rot = [RotateBy actionWithDuration:8 angle:720];
	
	[blue do: rot];
	[red do: [[rot copy] autorelease]];
	[green do: [[rot copy] autorelease]];
	[white do: [[rot copy] autorelease]];
	
	return self;
}
- (void) dealloc
{
	[super dealloc];
}

@end

// CLASS IMPLEMENTATIONS
@implementation AppController

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:YES];
		
	// must be called before any othe call to the director
//	[Director useFastDirector];
	
	// Attach cocos2d to the window
	[[Director sharedDirector] attachInWindow:window];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setLandscape: YES];

	// Setup the OpenGL Propertys
	[[Director sharedDirector] set3Dprojection];
	[[Director sharedDirector] setAlphaBlending:YES];
//	[[Director sharedDirector] setDepthTest:YES];
//	[[Director sharedDirector] setTexture2D:YES];
		
	// Show FPS, useful when debugging performance
	[[Director sharedDirector] setDisplayFPS:YES];

	// frames per second
	[[Director sharedDirector] setAnimationInterval:1.0/60];

	Scene *scene = [Scene node];

	MainLayer * mainLayer =[MainLayer node];
	
	[scene add: mainLayer];
	
	[scene do: [RotateBy actionWithDuration: 4 angle:-360]];
	
	// Make the window visible
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
