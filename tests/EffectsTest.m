//
// Effects Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//
// Demo by Ernesto Corvi and On-Core
//

// cocos2d import
#import "cocos2d.h"

// local import
#import "EffectsTest.h"

enum {
	kTagTextLayer = 1,

	kTagBackground = 1,
	kTagLabel = 2,
};

#pragma mark - Classes

@interface Shaky3DDemo : CCShaky3D
+(id) actionWithDuration:(ccTime)t;
@end
@interface Waves3DDemo : CCWaves3D
+(id) actionWithDuration:(ccTime)t;
@end
@interface FlipX3DDemo : CCFlipX3D
+(id) actionWithDuration:(ccTime)t;
@end
@interface FlipY3DDemo : CCFlipY3D
+(id) actionWithDuration:(ccTime)t;
@end
@interface Lens3DDemo : CCLens3D
+(id) actionWithDuration:(ccTime)t;
@end
@interface Ripple3DDemo : CCRipple3D
+(id) actionWithDuration:(ccTime)t;
@end
@interface LiquidDemo : CCLiquid
+(id) actionWithDuration:(ccTime)t;
@end
@interface WavesDemo : CCWaves
+(id) actionWithDuration:(ccTime)t;
@end
@interface TwirlDemo : CCTwirl
+(id) actionWithDuration:(ccTime)t;
@end
@interface ShakyTiles3DDemo : CCShakyTiles3D
+(id) actionWithDuration:(ccTime)t;
@end
@interface ShatteredTiles3DDemo : CCShatteredTiles3D
+(id) actionWithDuration:(ccTime)t;
@end
@interface ShuffleTilesDemo : CCShuffleTiles
+(id) actionWithDuration:(ccTime)t;
@end
@interface FadeOutTRTilesDemo : CCFadeOutTRTiles
+(id) actionWithDuration:(ccTime)t;
@end
@interface FadeOutBLTilesDemo : CCFadeOutBLTiles
+(id) actionWithDuration:(ccTime)t;
@end
@interface FadeOutUpTilesDemo : CCFadeOutUpTiles
+(id) actionWithDuration:(ccTime)t;
@end
@interface FadeOutDownTilesDemo : CCFadeOutDownTiles
+(id) actionWithDuration:(ccTime)t;
@end
@interface TurnOffTilesDemo : CCTurnOffTiles
+(id) actionWithDuration:(ccTime)t;
@end
@interface WavesTiles3DDemo : CCWavesTiles3D
+(id) actionWithDuration:(ccTime)t;
@end
@interface JumpTiles3DDemo : CCJumpTiles3D
+(id) actionWithDuration:(ccTime)t;
@end
@interface SplitRowsDemo : CCSplitRows
+(id) actionWithDuration:(ccTime)t;
@end
@interface SplitColsDemo : CCSplitCols
+(id) actionWithDuration:(ccTime)t;
@end
@interface PageTurn3DDemo : CCPageTurn3D
+(id) actionWithDuration:(ccTime)t;
@end



@implementation Shaky3DDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithDuration:t size:CGSizeMake(15,10) range:5 shakeZ:NO];
}
@end
@implementation Waves3DDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithDuration:t size:CGSizeMake(15,10) waves:5 amplitude:40];
}
@end
@implementation FlipX3DDemo
+(id) actionWithDuration:(ccTime)t
{
	id flipx  = [CCFlipX3D actionWithDuration:t];
	id flipx_back = [flipx reverse];
	id delay = [CCDelayTime actionWithDuration:2];

	return [CCSequence actions: flipx, delay, flipx_back, nil];
}
@end
@implementation FlipY3DDemo
+(id) actionWithDuration:(ccTime)t
{
	id flipy = [CCFlipY3D actionWithDuration:t];
	id flipy_back = [flipy reverse];
	id delay = [CCDelayTime actionWithDuration:2];

	return [CCSequence actions: flipy, delay, flipy_back, nil];
}
@end
@implementation Lens3DDemo
+(id) actionWithDuration:(ccTime)t
{
	CGSize size = [[CCDirector sharedDirector] winSize];
	return [self actionWithDuration:t size:CGSizeMake(15,10) position:ccp(size.width/2,size.height/2) radius:240];
}
@end
@implementation Ripple3DDemo
+(id) actionWithDuration:(ccTime)t
{
	CGSize size = [[CCDirector sharedDirector] winSize];
	return [self actionWithDuration:t size:CGSizeMake(32,24) position:ccp(size.width/2,size.height/2) radius:240 waves:4 amplitude:160];
}
@end
@implementation LiquidDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithDuration:t size:CGSizeMake(16,12) waves:4 amplitude:20];
}
@end
@implementation WavesDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithDuration:t size:CGSizeMake(16,12) waves:4 amplitude:20 horizontal:YES vertical:YES];
}
@end
@implementation TwirlDemo
+(id) actionWithDuration:(ccTime)t
{
	CGSize size = [[CCDirector sharedDirector] winSize];
	return [self actionWithDuration:t size:CGSizeMake(12,8) position:ccp(size.width/2, size.height/2) twirls:1 amplitude:2.5f];
}
@end
@implementation ShakyTiles3DDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithDuration:t size:CGSizeMake(16, 12) range:5 shakeZ:NO];
}
@end
@implementation ShatteredTiles3DDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithDuration:t size:CGSizeMake(16,12) range:5 shatterZ:NO];
}
@end
@implementation ShuffleTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id shuffle = [CCShuffleTiles actionWithDuration:t size:CGSizeMake(16,12) seed:25];
	id shuffle_back = [shuffle reverse];
	id delay = [CCDelayTime actionWithDuration:2];

	return [CCSequence actions: shuffle, delay, shuffle_back, nil];
}
@end
@implementation FadeOutTRTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id fadeout = [CCFadeOutTRTiles actionWithDuration:t size:CGSizeMake(16,12)];
	id back = [fadeout reverse];
	id delay = [CCDelayTime actionWithDuration:0.5f];

	return [CCSequence actions: fadeout, delay, back, nil];
}
@end
@implementation FadeOutBLTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id fadeout = [CCFadeOutBLTiles actionWithDuration:t size:CGSizeMake(16,12)];
	id back = [fadeout reverse];
	id delay = [CCDelayTime actionWithDuration:0.5f];

	return [CCSequence actions: fadeout, delay, back, nil];
}
@end
@implementation FadeOutUpTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id fadeout = [CCFadeOutUpTiles actionWithDuration:t size:CGSizeMake(16,12)];
	id back = [fadeout reverse];
	id delay = [CCDelayTime actionWithDuration:0.5f];

	return [CCSequence actions: fadeout, delay, back, nil];
}
@end
@implementation FadeOutDownTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id fadeout = [CCFadeOutDownTiles actionWithDuration:t size:CGSizeMake(16,12)];
	id back = [fadeout reverse];
	id delay = [CCDelayTime actionWithDuration:0.5f];

	return [CCSequence actions: fadeout, delay, back, nil];
}
@end
@implementation TurnOffTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id action = [CCTurnOffTiles actionWithDuration:t size:CGSizeMake(16,12) seed:25];
	id back = [action reverse];
	id delay = [CCDelayTime actionWithDuration:0.5f];

	return [CCSequence actions: action, delay, back, nil];
}
@end
@implementation WavesTiles3DDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithDuration:t size:CGSizeMake(16,12) waves:4 amplitude:120];
}
@end
@implementation JumpTiles3DDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithDuration:t size:CGSizeMake(16,12) jumps:2 amplitude:30];
}
@end
@implementation SplitRowsDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithDuration:t rows:9];
}
@end
@implementation SplitColsDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithDuration:t cols:9];
}
@end

@implementation PageTurn3DDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithDuration:t size:CGSizeMake(15,10)];
}
@end


#pragma mark Demo - order

static int actionIdx=0;
static NSString *actionList[] =
{
	@"Shaky3DDemo",
	@"Waves3DDemo",
	@"FlipX3DDemo",
	@"FlipY3DDemo",
	@"Lens3DDemo",
	@"Ripple3DDemo",
	@"LiquidDemo",
	@"WavesDemo",
	@"TwirlDemo",
	@"ShakyTiles3DDemo",
	@"ShatteredTiles3DDemo",
	@"ShuffleTilesDemo",
	@"FadeOutTRTilesDemo",
	@"FadeOutBLTilesDemo",
	@"FadeOutUpTilesDemo",
	@"FadeOutDownTilesDemo",
	@"TurnOffTilesDemo",
	@"WavesTiles3DDemo",
	@"JumpTiles3DDemo",
	@"SplitRowsDemo",
	@"SplitColsDemo",
	@"PageTurn3DDemo",
};

static NSString *effectsList[] =
{
	@"Shaky3D",
	@"Waves3D",
	@"FlipX3D",
	@"FlipY3D",
	@"Lens3D",
	@"Ripple3D",
	@"Liquid",
	@"Waves",
	@"Twirl",
	@"ShakyTiles3D",
	@"ShatteredTiles3D",
	@"ShuffleTiles",
	@"FadeOutTRTiles",
	@"FadeOutBLTiles",
	@"FadeOutUpTiles",
	@"FadeOutDownTiles",
	@"TurnOffTiles",
	@"WavesTiles3D",
	@"JumpTiles3D",
	@"SplitRows",
	@"SplitCols",
	@"PageTurn3D",
};

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

Class nextAction()
{
	actionIdx++;
	actionIdx = actionIdx % ( sizeof(actionList) / sizeof(actionList[0]) );
	NSString *r = actionList[actionIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	actionIdx--;
	int total = ( sizeof(actionList) / sizeof(actionList[0]) );
	if( actionIdx < 0 )
		actionIdx += total;
	NSString *r = actionList[actionIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = actionList[actionIdx];
	Class c = NSClassFromString(r);
	return c;
}

@implementation TextLayer
-(id) init
{
	if( (self=[super initWithColor: ccc4(32,128,32,255)] )) {

		float x,y;

		CGSize s = [[CCDirector sharedDirector] winSize];
		x = s.width;
		y = s.height;

		CCNode *node = [CCNode node];
		Class effectClass = restartAction();
		[node runAction:[effectClass actionWithDuration:3]];
		[self addChild: node z:0 tag:kTagBackground];

		CCSprite *bg = [CCSprite spriteWithFile:@"background3.png"];
		[node addChild: bg z:0];
//		bg.anchorPoint = CGPointZero;
		bg.position = ccp(s.width/2, s.height/2);

		CCSprite *grossini = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		[node addChild:grossini z:1];
		grossini.position = ccp(x/3,y/2);
		id sc = [CCScaleBy actionWithDuration:2 scale:5];
		id sc_back = [sc reverse];
		[grossini runAction: [CCRepeatForever actionWithAction: [CCSequence actions:sc, sc_back, nil]]];

		CCSprite *tamara = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		[node addChild:tamara z:1];
		tamara.position = ccp(2*x/3,y/2);
		id sc2 = [CCScaleBy actionWithDuration:2 scale:5];
		id sc2_back = [sc2 reverse];
		[tamara runAction: [CCRepeatForever actionWithAction: [CCSequence actions:sc2, sc2_back, nil]]];


		CCLabelTTF *label = [CCLabelTTF labelWithString:effectsList[actionIdx] fontName:@"Marker Felt" fontSize:32];

		[label setPosition: ccp(x/2,y-80)];
		[self addChild: label];
		label.tag = kTagLabel;

		// menu
		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - item2.contentSize.width*2, item2.contentSize.height/2);
		item2.position = ccp( s.width/2, item2.contentSize.height/2);
		item3.position = ccp( s.width/2 + item2.contentSize.width*2, item2.contentSize.height/2);
		[self addChild: menu z:1];

		[self schedule:@selector(checkAnim:)];
	}

	return self;
}

-(void)checkAnim:(ccTime)t
{
	CCNode *s2 = [self getChildByTag:kTagBackground];
	if ( [s2 numberOfRunningActions] == 0 && s2.grid != nil )
		s2.grid = nil;
}

-(void) newScene
{
	CCScene *s = [CCScene node];
	id child = [TextLayer node];
	[s addChild:child];
	[[CCDirector sharedDirector] replaceScene:s];
}

-(void) nextCallback:(id) sender
{
	nextAction();
	[self newScene];
}

-(void) backCallback:(id) sender
{
	backAction();
	[self newScene];
}

-(void) restartCallback:(id) sender
{
	[self newScene];
}
@end

#ifdef __CC_PLATFORM_IOS

// CLASS IMPLEMENTATIONS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Don't call super
//	[super applicationDidFinishLaunching:application didFinishLaunchingWithOptions:launchOptions];

	// Init the window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


	// Create an CCGLView with a RGB8 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:0 //GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];

	director_.wantsFullScreenLayout = YES;
	// Display Milliseconds Per Frame
	[director_ setDisplayStats:YES];

	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];

	// attach the openglView to the director
	[director_ setView:glView];

	// 3D projection
	[director_ setProjection:kCCDirectorProjection3D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	[director_ setDelegate:self];

	// set the Navigation Controller as the root view controller
	[window_ addSubview:navController_.view];

	
	// make main window visible
	[window_ makeKeyAndVisible];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];

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
		[scene addChild: [TextLayer node] z:0 tag:kTagTextLayer];
		[director runWithScene: scene];
	}
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end

#elif defined(__CC_PLATFORM_MAC)

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];

	CCScene *scene = [CCScene node];
	[scene addChild: [TextLayer node] z:0 tag:kTagTextLayer];

	// Disable depth test for this test
	[director_ setDepthTest:NO];

	[director_ runWithScene:scene];
}
@end
#endif
