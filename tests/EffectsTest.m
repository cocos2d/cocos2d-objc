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
	return [self actionWithRange:5 shakeZ:YES grid:ccg(15,10) duration:t];
}
@end
@implementation Waves3DDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithWaves:5 amplitude:40 grid:ccg(15,10) duration:t];
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
	return [self actionWithPosition:ccp(size.width/2,size.height/2) radius:240 grid:ccg(15,10) duration:t];
}
@end
@implementation Ripple3DDemo
+(id) actionWithDuration:(ccTime)t
{
	CGSize size = [[CCDirector sharedDirector] winSize];
	return [self actionWithPosition:ccp(size.width/2,size.height/2) radius:240 waves:4 amplitude:160 grid:ccg(32,24) duration:t];
}
@end
@implementation LiquidDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithWaves:4 amplitude:20 grid:ccg(16,12) duration:t];
}
@end
@implementation WavesDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithWaves:4 amplitude:20 horizontal:YES vertical:YES grid:ccg(16,12) duration:t];
}
@end
@implementation TwirlDemo
+(id) actionWithDuration:(ccTime)t
{
	CGSize size = [[CCDirector sharedDirector] winSize];
	return [self actionWithPosition:ccp(size.width/2, size.height/2) twirls:1 amplitude:2.5f grid:ccg(12,8) duration:t];
}
@end
@implementation ShakyTiles3DDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithRange:5 shakeZ:YES grid:ccg(16,12) duration:t];
}
@end
@implementation ShatteredTiles3DDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithRange:5 shatterZ:YES grid:ccg(16,12) duration:t];
}
@end
@implementation ShuffleTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id shuffle = [CCShuffleTiles actionWithSeed:25 grid:ccg(16,12) duration:t];
	id shuffle_back = [shuffle reverse];
	id delay = [CCDelayTime actionWithDuration:2];

	return [CCSequence actions: shuffle, delay, shuffle_back, nil];
}
@end
@implementation FadeOutTRTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id fadeout = [CCFadeOutTRTiles actionWithSize:ccg(16,12) duration:t];
	id back = [fadeout reverse];
	id delay = [CCDelayTime actionWithDuration:0.5f];

	return [CCSequence actions: fadeout, delay, back, nil];
}
@end
@implementation FadeOutBLTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id fadeout = [CCFadeOutBLTiles actionWithSize:ccg(16,12) duration:t];
	id back = [fadeout reverse];
	id delay = [CCDelayTime actionWithDuration:0.5f];
	
	return [CCSequence actions: fadeout, delay, back, nil];
}
@end
@implementation FadeOutUpTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id fadeout = [CCFadeOutUpTiles actionWithSize:ccg(16,12) duration:t];
	id back = [fadeout reverse];
	id delay = [CCDelayTime actionWithDuration:0.5f];
	
	return [CCSequence actions: fadeout, delay, back, nil];
}
@end
@implementation FadeOutDownTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id fadeout = [CCFadeOutDownTiles actionWithSize:ccg(16,12) duration:t];
	id back = [fadeout reverse];
	id delay = [CCDelayTime actionWithDuration:0.5f];
	
	return [CCSequence actions: fadeout, delay, back, nil];
}
@end
@implementation TurnOffTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id action = [CCTurnOffTiles actionWithSeed:25 grid:ccg(48,32) duration:t];
	id back = [action reverse];
	id delay = [CCDelayTime actionWithDuration:0.5f];
	
	return [CCSequence actions: action, delay, back, nil];
}
@end
@implementation WavesTiles3DDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithWaves:4 amplitude:120 grid:ccg(15,10) duration:t];
}
@end
@implementation JumpTiles3DDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithJumps:2 amplitude:30 grid:ccg(15,10) duration:t];
}
@end
@implementation SplitRowsDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithRows:9 duration:t];
}
@end
@implementation SplitColsDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithCols:9 duration:t];
}
@end

@implementation PageTurn3DDemo
+(id) actionWithDuration:(ccTime)t
{
	return [self actionWithSize:ccg(15,10) duration:t];
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
	if( (self=[super initWithColor: ccc4(32,32,32,255)] )) {
	
		float x,y;
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		x = size.width;
		y = size.height;
		
		CCNode *node = [CCNode node];
		Class effectClass = restartAction();
		[node runAction:[effectClass actionWithDuration:3]];
		[self addChild: node z:0 tag:kTagBackground];
		
		CCSprite *bg = [CCSprite spriteWithFile:@"background3.png"];
		[node addChild: bg z:0];
//		bg.anchorPoint = CGPointZero;
		bg.position = ccp(size.width/2, size.height/2);
		
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
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp(size.width/2-100,30);
		item2.position = ccp(size.width/2, 30);
		item3.position = ccp(size.width/2+100,30);
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

-(void) newOrientation
{
	ccDeviceOrientation orientation = [[CCDirector sharedDirector] deviceOrientation];
	switch (orientation) {
		case CCDeviceOrientationLandscapeLeft:
			orientation = CCDeviceOrientationPortrait;
			break;
		case CCDeviceOrientationPortrait:
			orientation = CCDeviceOrientationLandscapeRight;
			break;						
		case CCDeviceOrientationLandscapeRight:
			orientation = CCDeviceOrientationPortraitUpsideDown;
			break;
		case CCDeviceOrientationPortraitUpsideDown:
			orientation = CCDeviceOrientationLandscapeLeft;
			break;
	}
	[[CCDirector sharedDirector] setDeviceOrientation:orientation];
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
//	[self newOrientation];
	nextAction();
	[self newScene];
}	

-(void) backCallback:(id) sender
{
//	[self newOrientation];
	backAction();
	[self newScene];
}	

-(void) restartCallback:(id) sender
{
	[self newOrientation];
	[self newScene];
}	
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// must be called before any othe call to the director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeMainLoop];
	
	// get instance of the shared director
	CCDirector *director = [CCDirector sharedDirector];
	
	// before creating any layer, set the landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// display FPS (useful when debugging)
	[director setDisplayFPS:YES];
	
	// frames per second
	[director setAnimationInterval:1.0/60];
	
	// create an OpenGL view
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:0];
	[glView setMultipleTouchEnabled:YES];
	
	// connect it to the director
	[director setOpenGLView:glView];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// glview is a child of the main window
	[window addSubview:glView];
	
	// Make the window visible
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"
	
	CCScene *scene = [CCScene node];
	[scene addChild: [TextLayer node] z:0 tag:kTagTextLayer];
	
	[director runWithScene: scene];	
}

- (void) dealloc
{
	[window release];
	[super dealloc];
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

@end
