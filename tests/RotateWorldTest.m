//
// RotateWorld demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//


// local import
#import "RotateWorldTest.h"

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

	[label setPosition: ccp(x/2,y/2)];
	
	[self addChild: label];
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
	
	[sprite setScale: 1.5f];
	[spriteSister1 setScale: 1.5f];
	[spriteSister2 setScale: 1.5f];
	
	[sprite setPosition: ccp(x/2,y/2)];
	[spriteSister1 setPosition: ccp(40,y/2)];
	[spriteSister2 setPosition: ccp(x-40,y/2)];

	Action *rot = [RotateBy actionWithDuration:16 angle:-3600];
	
	[self addChild: sprite];
	[self addChild: spriteSister1];
	[self addChild: spriteSister2];
	
	[sprite runAction: rot];

	IntervalAction *jump1 = [JumpBy actionWithDuration:4 position:ccp(-400,0) height:100 jumps:4];
	IntervalAction *jump2 = [jump1 reverse];
	
	IntervalAction *rot1 = [RotateBy actionWithDuration:4 angle:360*2];
	IntervalAction *rot2 = [rot1 reverse];
	
	[spriteSister1 runAction: [Repeat actionWithAction: [Sequence actions:jump2, jump1, nil] times:5 ] ];
	[spriteSister2 runAction: [Repeat actionWithAction: [Sequence actions:[[jump1 copy] autorelease], [[jump2 copy] autorelease], nil] times:5 ] ];
	
	[spriteSister1 runAction: [Repeat actionWithAction: [Sequence actions: rot1, rot2, nil] times:5 ] ];
	[spriteSister2 runAction: [Repeat actionWithAction: [Sequence actions: [[rot2 copy] autorelease], [[rot1 copy] autorelease], nil] times:5 ] ];
	
	
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
	
	CocosNode* blue =  [ColorLayer layerWithColor:ccc4(0,0,255,255)];
	CocosNode* red =   [ColorLayer layerWithColor:ccc4(255,0,0,255)];
	CocosNode* green = [ColorLayer layerWithColor:ccc4(0,255,0,255)];
	CocosNode* white = [ColorLayer layerWithColor:ccc4(255,255,255,255)];

	[blue setScale: 0.5f];
	[blue setPosition: ccp(-x/4,-y/4)];
	[blue addChild: [SpriteLayer node]];
	
	[red setScale: 0.5f];
	[red setPosition: ccp(x/4,-y/4)];

	[green setScale: 0.5f];
	[green setPosition: ccp(-x/4,y/4)];
	[green addChild: [TextLayer node]];

	[white setScale: 0.5f];
	[white setPosition: ccp(x/4,y/4)];

	[self addChild: blue z:-1];
	[self addChild: white];
	[self addChild: green];
	[self addChild: red];

	Action * rot = [RotateBy actionWithDuration:8 angle:720];
	
	[blue runAction: rot];
	[red runAction: [[rot copy] autorelease]];
	[green runAction: [[rot copy] autorelease]];
	[white runAction: [[rot copy] autorelease]];
	
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
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	// Show FPS, useful when debugging performance
	[[Director sharedDirector] setDisplayFPS:YES];

	// frames per second
	[[Director sharedDirector] setAnimationInterval:1.0/60];

	Scene *scene = [Scene node];

	MainLayer * mainLayer =[MainLayer node];
	
	[scene addChild: mainLayer];
	
	[scene runAction: [RotateBy actionWithDuration: 4 angle:-360]];
	
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
