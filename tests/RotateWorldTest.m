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
	if( (self=[super init] ) ) {

		float x,y;
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		x = size.width;
		y = size.height;

		NSArray *array = [UIFont familyNames];
		for( NSString *s in array )
			NSLog( @"%@",s );
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"cocos2d" fontName:@"Marker Felt" fontSize:64];

		[label setPosition: ccp(x/2,y/2)];
		
		[self addChild: label];
	}
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
	if( (self=[super init] ) ) {
		float x,y;
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		x = size.width;
		y = size.height;
		
		CCSprite *sprite = [CCSprite spriteWithFile: @"grossini.png"];
		CCSprite *spriteSister1 = [CCSprite spriteWithFile: @"grossinis_sister1.png"];
		CCSprite *spriteSister2 = [CCSprite spriteWithFile: @"grossinis_sister2.png"];
		
		[sprite setScale: 1.5f];
		[spriteSister1 setScale: 1.5f];
		[spriteSister2 setScale: 1.5f];
		
		[sprite setPosition: ccp(x/2,y/2)];
		[spriteSister1 setPosition: ccp(40,y/2)];
		[spriteSister2 setPosition: ccp(x-40,y/2)];

		CCAction *rot = [CCRotateBy actionWithDuration:16 angle:-3600];
		
		[self addChild: sprite];
		[self addChild: spriteSister1];
		[self addChild: spriteSister2];
		
		[sprite runAction: rot];

		CCActionInterval *jump1 = [CCJumpBy actionWithDuration:4 position:ccp(-400,0) height:100 jumps:4];
		CCActionInterval *jump2 = [jump1 reverse];
		
		CCActionInterval *rot1 = [CCRotateBy actionWithDuration:4 angle:360*2];
		CCActionInterval *rot2 = [rot1 reverse];
		
		[spriteSister1 runAction: [CCRepeat actionWithAction: [CCSequence actions:jump2, jump1, nil] times:5 ] ];
		[spriteSister2 runAction: [CCRepeat actionWithAction: [CCSequence actions:[[jump1 copy] autorelease], [[jump2 copy] autorelease], nil] times:5 ] ];
		
		[spriteSister1 runAction: [CCRepeat actionWithAction: [CCSequence actions: rot1, rot2, nil] times:5 ] ];
		[spriteSister2 runAction: [CCRepeat actionWithAction: [CCSequence actions: [[rot2 copy] autorelease], [[rot1 copy] autorelease], nil] times:5 ] ];
	}
	
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
	if( (self=[super init] ) ) {
		float x,y;
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		x = size.width;
		y = size.height;
		
		CCNode* blue =  [CCLayerColor layerWithColor:ccc4(0,0,255,255)];
		CCNode* red =   [CCLayerColor layerWithColor:ccc4(255,0,0,255)];
		CCNode* green = [CCLayerColor layerWithColor:ccc4(0,255,0,255)];
		CCNode* white = [CCLayerColor layerWithColor:ccc4(255,255,255,255)];

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

		CCAction * rot = [CCRotateBy actionWithDuration:8 angle:720];
		
		[blue runAction: rot];
		[red runAction: [[rot copy] autorelease]];
		[green runAction: [[rot copy] autorelease]];
		[white runAction: [[rot copy] autorelease]];
	}
	
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
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 5a. If it fails, it will use an NSTimer director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];
	
	// Sets landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// Turn on display FPS
	[director setDisplayFPS:YES];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"

	CCScene *scene = [CCScene node];

	MainLayer * mainLayer =[MainLayer node];
	
	[scene addChild: mainLayer];
	
	[scene runAction: [CCRotateBy actionWithDuration: 4 angle:-360]];
	
	[director runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}

@end
