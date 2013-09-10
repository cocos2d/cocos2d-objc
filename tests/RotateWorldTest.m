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
//		[white setPosition: ccp(x/4,y/4)];		
		white.anchorPoint = ccp(0.5f, 0.5f);
		[white setPosition: ccp(x/4*3,y/4*3)];

		[self addChild: blue z:-1];
		[self addChild: green];
		[self addChild: red];
		[self addChild: white];

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

#pragma mark - AppController - iOS

#if defined(__CC_PLATFORM_IOS)

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	return YES;
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil){
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		CCScene *scene = [CCScene node];
		MainLayer * mainLayer =[MainLayer node];
		[scene addChild: mainLayer];
		[scene runAction: [CCRotateBy actionWithDuration: 4 angle:-360]];
		[director runWithScene:scene];
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end

#pragma mark - AppController - Mac

#elif defined(__CC_PLATFORM_MAC)

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];
	
	CCScene *scene = [CCScene node];
	
	MainLayer * mainLayer =[MainLayer node];
	
	[scene addChild: mainLayer];
	
	[scene runAction: [CCRotateBy actionWithDuration: 4 angle:-360]];
	
	[director_ runWithScene:scene];
}
@end
#endif

