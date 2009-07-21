//
// Advanced Effects Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos2d import
#import "cocos2d.h"

// local import
#import "EffectsAdvancedTest.h"

enum {
	kTagTextLayer = 1,

	kTagSprite1 = 1,
	kTagSprite2 = 2,

	kTagBackground = 1,
	kTagLabel = 2,
};

#pragma mark - Classes

@interface Effect1 : TextLayer
{}
@end

@implementation Effect1
-(void) onEnter
{
	[super onEnter];
	
	id target = [self getChildByTag:kTagBackground];
	
	// To reuse a grid the grid size and the grid type must be the same.
	// in this case:
	//     Lens3D is Grid3D and it's size is (15,10)
	//     Waves3D is Grid3D and it's size is (15,10)
	
	CGSize size = [[Director sharedDirector] winSize];
	id lens = [Lens3D actionWithPosition:ccp(size.width/2,size.height/2) radius:240 grid:ccg(15,10) duration:0.0f];
	id waves = [Waves3D actionWithWaves:18 amplitude:15 grid:ccg(15,10) duration:10];

	id reuse = [ReuseGrid actionWithTimes:1];
	id delay = [DelayTime actionWithDuration:8];

	id orbit = [OrbitCamera actionWithDuration:5 radius:1 deltaRadius:2 angleZ:0 deltaAngleZ:180 angleX:0 deltaAngleX:-90];
	id orbit_back = [orbit reverse];

	[target runAction: [RepeatForever actionWithAction: [Sequence actions: orbit, orbit_back, nil]]];
	[target runAction: [Sequence actions: lens, delay, reuse, waves, nil]];	
}
-(NSString*) title
{
	return @"Lens + Waves3d and OrbitCamera";
}
@end

@interface Effect2 : TextLayer
{}
@end

@implementation Effect2
-(void) onEnter
{
	[super onEnter];
	
	id target = [self getChildByTag:kTagBackground];
	
	// To reuse a grid the grid size and the grid type must be the same.
	// in this case:
	//     ShakyTiles is TiledGrid3D and it's size is (15,10)
	//     Shuffletiles is TiledGrid3D and it's size is (15,10)
	//	   TurnOfftiles is TiledGrid3D and it's size is (15,10)
	id shaky = [ShakyTiles3D actionWithRange:4 shakeZ:NO grid:ccg(15,10) duration:5];
	id shuffle = [ShuffleTiles actionWithSeed:0 grid:ccg(15,10) duration:3];
	id turnoff = [TurnOffTiles actionWithSeed:0 grid:ccg(15,10) duration:3];
	id turnon = [turnoff reverse];
	
	// reuse 2 times:
	//   1 for shuffle
	//   2 for turn off
	//   turnon tiles will use a new grid
	id reuse = [ReuseGrid actionWithTimes:2];

	id delay = [DelayTime actionWithDuration:1];
	
//	id orbit = [OrbitCamera actionWithDuration:5 radius:1 deltaRadius:2 angleZ:0 deltaAngleZ:180 angleX:0 deltaAngleX:-90];
//	id orbit_back = [orbit reverse];
//
//	[target runAction: [RepeatForever actionWithAction: [Sequence actions: orbit, orbit_back, nil]]];
	[target runAction: [Sequence actions: shaky, delay, reuse, shuffle, [[delay copy] autorelease], turnoff, turnon, nil]];
}
-(NSString*) title
{
	return @"ShakyTiles + ShuffleTiles + TurnOffTiles";
}
@end

@interface Effect3 : TextLayer
{}
@end

@implementation Effect3
-(void) onEnter
{
	[super onEnter];
	
	id bg = [self getChildByTag:kTagBackground];
	id target1 = [bg getChildByTag:kTagSprite1];
	id target2 = [bg getChildByTag:kTagSprite2];	
	
	id waves = [Waves actionWithWaves:5 amplitude:20 horizontal:YES vertical:NO grid:ccg(15,10) duration:5];
	id shaky = [Shaky3D actionWithRange:4 shakeZ:NO grid:ccg(15,10) duration:5];
	
	[target1 runAction: [RepeatForever actionWithAction: waves]];
	[target2 runAction: [RepeatForever actionWithAction: shaky]];
	
	// moving background. Testing issue #244
	id move = [MoveBy actionWithDuration:3 position:ccp(200,0)];
	[bg runAction:[RepeatForever actionWithAction:[Sequence actions:move, [move reverse], nil]]];	
}
-(NSString*) title
{
	return @"Effects on 2 sprites";
}
@end

@interface Effect4 : TextLayer
{}
@end

@implementation Effect4
-(void) onEnter
{
	[super onEnter];
		
	id lens = [Lens3D actionWithPosition:ccp(100,180) radius:150 grid:ccg(32,24) duration:10];
//	id move = [MoveBy actionWithDuration:5 position:ccp(400,0)];
	id move = [JumpBy actionWithDuration:5 position:ccp(380,0) height:100 jumps:4];
	id move_back = [move reverse];
	id seq = [Sequence actions: move, move_back, nil];
	[[ActionManager sharedManager] addAction:seq target:lens paused:NO];

	[self runAction: lens];
}
-(NSString*) title
{
	return @"Jumpy Lens3D";
}
@end



#pragma mark Demo - order

static int actionIdx=-1;
static NSString *actionList[] =
{
	@"Effect3",
	@"Effect1",
	@"Effect2",
	@"Effect4",
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
	if( (self = [super init]) ) {
	
		float x,y;
		
		CGSize size = [[Director sharedDirector] winSize];
		x = size.width;
		y = size.height;
		
		Sprite *bg = [Sprite spriteWithFile:@"background3.png"];
		[self addChild: bg z:0 tag:kTagBackground];
		bg.anchorPoint = CGPointZero;
//		bg.position = ccp(x/2,y/2);
		
		Sprite *grossini = [Sprite spriteWithFile:@"grossinis_sister2.png"];
		[bg addChild:grossini z:1 tag:kTagSprite1];
		grossini.position = ccp(x/3.0f,200);
		id sc = [ScaleBy actionWithDuration:2 scale:5];
		id sc_back = [sc reverse];
	
		[grossini runAction: [RepeatForever actionWithAction: [Sequence actions:sc, sc_back, nil]]];

		Sprite *tamara = [Sprite spriteWithFile:@"grossinis_sister1.png"];
		[bg addChild:tamara z:1 tag:kTagSprite2];
		tamara.position = ccp(2*x/3.0f,200);
		id sc2 = [ScaleBy actionWithDuration:2 scale:5];
		id sc2_back = [sc2 reverse];
		[tamara runAction: [RepeatForever actionWithAction: [Sequence actions:sc2, sc2_back, nil]]];
		
		
		Label* label = [Label labelWithString:[self title] fontName:@"Marker Felt" fontSize:32];
		
		[label setPosition: ccp(x/2,y-80)];
		[self addChild: label];
		label.tag = kTagLabel;
		
		// menu
		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp(480/2-100,30);
		item2.position = ccp(480/2, 30);
		item3.position = ccp(480/2+100,30);
		[self addChild: menu z:1];

	}
	
	return self;
}

-(NSString*) title
{
	return @"No title";
}

-(void) restartCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [restartAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [nextAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [backAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

- (void) dealloc
{
	[super dealloc];
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
	
	// Use this pixel format to have transparent buffers
	// BUG: glClearColor() in FBO needs to be converted to RGB565
	[[Director sharedDirector] setPixelFormat:kRGBA8];

	// Create a depth buffer of 24 bits
	// Needed for the orbit + lens + waves examples
	// These means that openGL z-order will be taken into account
	[[Director sharedDirector] setDepthBufferFormat:kDepthBuffer16];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation: CCDeviceOrientationLandscapeRight];
	[[Director sharedDirector] setDisplayFPS:YES];
	
	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];	
	
	Scene *scene = [Scene node];
	[scene addChild: [nextAction() node]];	
	
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
