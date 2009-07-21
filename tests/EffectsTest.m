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

@interface Shaky3DDemo : Shaky3D 
+(id) actionWithDuration:(ccTime)t;
@end
@interface Waves3DDemo : Waves3D 
+(id) actionWithDuration:(ccTime)t;
@end
@interface FlipX3DDemo : FlipX3D
+(id) actionWithDuration:(ccTime)t;
@end
@interface FlipY3DDemo : FlipY3D
+(id) actionWithDuration:(ccTime)t;
@end
@interface Lens3DDemo : Lens3D
+(id) actionWithDuration:(ccTime)t;
@end
@interface Ripple3DDemo : Ripple3D
+(id) actionWithDuration:(ccTime)t;
@end
@interface LiquidDemo : Liquid 
+(id) actionWithDuration:(ccTime)t;
@end
@interface WavesDemo : Waves
+(id) actionWithDuration:(ccTime)t;
@end
@interface TwirlDemo : Twirl 
+(id) actionWithDuration:(ccTime)t;
@end
@interface ShakyTiles3DDemo : ShakyTiles3D
+(id) actionWithDuration:(ccTime)t;
@end
@interface ShatteredTiles3DDemo : ShatteredTiles3D 
+(id) actionWithDuration:(ccTime)t;
@end
@interface ShuffleTilesDemo : ShuffleTiles 
+(id) actionWithDuration:(ccTime)t;
@end
@interface FadeOutTRTilesDemo : FadeOutTRTiles 
+(id) actionWithDuration:(ccTime)t;
@end
@interface FadeOutBLTilesDemo : FadeOutBLTiles 
+(id) actionWithDuration:(ccTime)t;
@end
@interface FadeOutUpTilesDemo : FadeOutUpTiles 
+(id) actionWithDuration:(ccTime)t;
@end
@interface FadeOutDownTilesDemo : FadeOutDownTiles 
+(id) actionWithDuration:(ccTime)t;
@end
@interface TurnOffTilesDemo : TurnOffTiles 
+(id) actionWithDuration:(ccTime)t;
@end
@interface WavesTiles3DDemo : WavesTiles3D 
+(id) actionWithDuration:(ccTime)t;
@end
@interface JumpTiles3DDemo : JumpTiles3D 
+(id) actionWithDuration:(ccTime)t;
@end
@interface SplitRowsDemo : SplitRows
+(id) actionWithDuration:(ccTime)t;
@end
@interface SplitColsDemo : SplitCols
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
	id flipx  = [FlipX3D actionWithDuration:t];
	id flipx_back = [flipx reverse];
	id delay = [DelayTime actionWithDuration:2];
	
	return [Sequence actions: flipx, delay, flipx_back, nil];	
}
@end
@implementation FlipY3DDemo
+(id) actionWithDuration:(ccTime)t
{
	id flipy = [FlipY3D actionWithDuration:t];
	id flipy_back = [flipy reverse];
	id delay = [DelayTime actionWithDuration:2];
	
	return [Sequence actions: flipy, delay, flipy_back, nil];
}
@end
@implementation Lens3DDemo
+(id) actionWithDuration:(ccTime)t
{
	CGSize size = [[Director sharedDirector] winSize];
	return [self actionWithPosition:ccp(size.width/2,size.height/2) radius:240 grid:ccg(15,10) duration:t];
}
@end
@implementation Ripple3DDemo
+(id) actionWithDuration:(ccTime)t
{
	CGSize size = [[Director sharedDirector] winSize];
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
	CGSize size = [[Director sharedDirector] winSize];
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
	id shuffle = [ShuffleTiles actionWithSeed:25 grid:ccg(16,12) duration:t];
	id shuffle_back = [shuffle reverse];
	id delay = [DelayTime actionWithDuration:2];

	return [Sequence actions: shuffle, delay, shuffle_back, nil];
}
@end
@implementation FadeOutTRTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id fadeout = [FadeOutTRTiles actionWithSize:ccg(16,12) duration:t];
	id back = [fadeout reverse];
	id delay = [DelayTime actionWithDuration:0.5f];

	return [Sequence actions: fadeout, delay, back, nil];
}
@end
@implementation FadeOutBLTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id fadeout = [FadeOutBLTiles actionWithSize:ccg(16,12) duration:t];
	id back = [fadeout reverse];
	id delay = [DelayTime actionWithDuration:0.5f];
	
	return [Sequence actions: fadeout, delay, back, nil];
}
@end
@implementation FadeOutUpTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id fadeout = [FadeOutUpTiles actionWithSize:ccg(16,12) duration:t];
	id back = [fadeout reverse];
	id delay = [DelayTime actionWithDuration:0.5f];
	
	return [Sequence actions: fadeout, delay, back, nil];
}
@end
@implementation FadeOutDownTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id fadeout = [FadeOutDownTiles actionWithSize:ccg(16,12) duration:t];
	id back = [fadeout reverse];
	id delay = [DelayTime actionWithDuration:0.5f];
	
	return [Sequence actions: fadeout, delay, back, nil];
}
@end
@implementation TurnOffTilesDemo
+(id) actionWithDuration:(ccTime)t
{
	id action = [TurnOffTiles actionWithSeed:25 grid:ccg(48,32) duration:t];
	id back = [action reverse];
	id delay = [DelayTime actionWithDuration:0.5f];
	
	return [Sequence actions: action, delay, back, nil];
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
	@"SplitColsDemo"
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
	@"SplitCols"
};

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
		
		CGSize size = [[Director sharedDirector] winSize];
		x = size.width;
		y = size.height;
		
		CocosNode *node = [CocosNode node];
		[self addChild: node z:0 tag:kTagBackground];
		
		Sprite *bg = [Sprite spriteWithFile:@"background3.png"];
		[node addChild: bg z:0];
		bg.anchorPoint = CGPointZero;
	//	bg.position = ccp(-100,-100);
		
		Sprite *grossini = [Sprite spriteWithFile:@"grossinis_sister2.png"];
		[node addChild:grossini z:1];
		grossini.position = ccp(x/3,y/2);
		id sc = [ScaleBy actionWithDuration:2 scale:5];
		id sc_back = [sc reverse];
		[grossini runAction: [RepeatForever actionWithAction: [Sequence actions:sc, sc_back, nil]]];

		Sprite *tamara = [Sprite spriteWithFile:@"grossinis_sister1.png"];
		[node addChild:tamara z:1];
		tamara.position = ccp(2*x/3,y/2);
		id sc2 = [ScaleBy actionWithDuration:2 scale:5];
		id sc2_back = [sc2 reverse];
		[tamara runAction: [RepeatForever actionWithAction: [Sequence actions:sc2, sc2_back, nil]]];
		
		
		Label* label = [Label labelWithString:effectsList[actionIdx] fontName:@"Marker Felt" fontSize:32];
		
		[label setPosition: ccp(x/2,y-80)];
		[self addChild: label];
		label.tag = kTagLabel;
		
		// menu
		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp(size.width/2-100,30);
		item2.position = ccp(size.width/2, 30);
		item3.position = ccp(size.width/2+100,30);
		[self addChild: menu z:1];
		
		[self performSelector:@selector(restartCallback:) withObject:self afterDelay:0.1];
		
		[self schedule:@selector(checkAnim:)];
	}
	
	return self;
}

-(void)checkAnim:(ccTime)t
{
//	Scene *s2 = [Director sharedDirector].runningScene;
	CocosNode *s2 = [self getChildByTag:kTagBackground];
	if ( [s2 numberOfRunningActions] == 0 && s2.grid != nil )
		s2.grid = nil;
}

-(void) nextCallback:(id) sender
{
//	Scene *s = [Director sharedDirector].runningScene;
	id s2 = [self getChildByTag:kTagBackground];
	[s2 stopAllActions];
	Class effect = nextAction();
	Label *label = (Label *)[self getChildByTag:kTagLabel];
	[label setString:effectsList[actionIdx]];
	[s2 runAction:[effect actionWithDuration:3]];
}	

-(void) backCallback:(id) sender
{
//	Scene *s = [Director sharedDirector].runningScene;
	id s2 = [self getChildByTag:kTagBackground];
	[s2 stopAllActions];
	Class effect = backAction();
	Label *label = (Label *)[self getChildByTag:kTagLabel];
	[label setString:effectsList[actionIdx]];
	[s2 runAction:[effect actionWithDuration:3]];
}	

-(void) restartCallback:(id) sender
{
//	Scene *s = [Director sharedDirector].runningScene;
	id s2 = [self getChildByTag:kTagBackground];
	[s2 stopAllActions];
	Class effect = restartAction();
	Label *label = (Label *)[self getChildByTag:kTagLabel];
	[label setString:effectsList[actionIdx]];
	[s2 runAction:[effect actionWithDuration:3]];
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
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeRight];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];
	
	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	Scene *scene = [Scene node];
	[scene addChild: [TextLayer node] z:0 tag:kTagTextLayer];
	
	[[Director sharedDirector] runWithScene: scene];
}

- (void) dealloc
{
	[window dealloc];
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
