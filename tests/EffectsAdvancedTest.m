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

@implementation Effect1
-(void) onEnter
{
	[super onEnter];
	
	id target = [self getChildByTag:kTagBackground];
	
	// To reuse a grid the grid size and the grid type must be the same.
	// in this case:
	//     Lens3D is Grid3D and it's size is (15,10)
	//     Waves3D is Grid3D and it's size is (15,10)
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	id lens = [CCLens3D actionWithPosition:ccp(size.width/2,size.height/2) radius:240 grid:ccg(15,10) duration:0.0f];
	id waves = [CCWaves3D actionWithWaves:18 amplitude:15 grid:ccg(15,10) duration:10];

	id reuse = [CCReuseGrid actionWithTimes:1];
	id delay = [CCDelayTime actionWithDuration:8];

	id orbit = [CCOrbitCamera actionWithDuration:5 radius:1 deltaRadius:2 angleZ:0 deltaAngleZ:180 angleX:0 deltaAngleX:-90];
	id orbit_back = [orbit reverse];

	[target runAction: [CCRepeatForever actionWithAction: [CCSequence actions: orbit, orbit_back, nil]]];
	[target runAction: [CCSequence actions: lens, delay, reuse, waves, nil]];	
}
-(NSString*) title
{
	return @"Lens + Waves3d and CCOrbitCamera";
}
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
	id shaky = [CCShakyTiles3D actionWithRange:4 shakeZ:NO grid:ccg(15,10) duration:5];
	id shuffle = [CCShuffleTiles actionWithSeed:0 grid:ccg(15,10) duration:3];
	id turnoff = [CCTurnOffTiles actionWithSeed:0 grid:ccg(15,10) duration:3];
	id turnon = [turnoff reverse];
	
	// reuse 2 times:
	//   1 for shuffle
	//   2 for turn off
	//   turnon tiles will use a new grid
	id reuse = [CCReuseGrid actionWithTimes:2];

	id delay = [CCDelayTime actionWithDuration:1];
	
//	id orbit = [CCOrbitCamera actionWithDuration:5 radius:1 deltaRadius:2 angleZ:0 deltaAngleZ:180 angleX:0 deltaAngleX:-90];
//	id orbit_back = [orbit reverse];
//
//	[target runAction: [RepeatForever actionWithAction: [Sequence actions: orbit, orbit_back, nil]]];
	[target runAction: [CCSequence actions: shaky, delay, reuse, shuffle, [[delay copy] autorelease], turnoff, turnon, nil]];
}
-(NSString*) title
{
	return @"ShakyTiles + ShuffleTiles + TurnOffTiles";
}
@end

@implementation Effect3
-(void) onEnter
{
	[super onEnter];
	
	id bg = [self getChildByTag:kTagBackground];
	id target1 = [bg getChildByTag:kTagSprite1];
	id target2 = [bg getChildByTag:kTagSprite2];	
	
	id waves = [CCWaves actionWithWaves:5 amplitude:20 horizontal:YES vertical:NO grid:ccg(15,10) duration:5];
	id shaky = [CCShaky3D actionWithRange:4 shakeZ:NO grid:ccg(15,10) duration:5];
	
	[target1 runAction: [CCRepeatForever actionWithAction: waves]];
	[target2 runAction: [CCRepeatForever actionWithAction: shaky]];
	
	// moving background. Testing issue #244
	id move = [CCMoveBy actionWithDuration:3 position:ccp(200,0)];
	[bg runAction:[CCRepeatForever actionWithAction:[CCSequence actions:move, [move reverse], nil]]];	
}
-(NSString*) title
{
	return @"Effects on 2 sprites";
}
@end

@implementation Effect4
-(void) onEnter
{
	[super onEnter];
		
	id lens = [CCLens3D actionWithPosition:ccp(100,180) radius:150 grid:ccg(32,24) duration:10];
//	id move = [MoveBy actionWithDuration:5 position:ccp(400,0)];
	id move = [CCJumpBy actionWithDuration:5 position:ccp(380,0) height:100 jumps:4];
	id move_back = [move reverse];
	id seq = [CCSequence actions: move, move_back, nil];
	[[CCActionManager sharedManager] addAction:seq target:lens paused:NO];

	[self runAction: lens];
}
-(NSString*) title
{
	return @"Jumpy Lens3D";
}
@end

#pragma mark -
#pragma mark Effect5

@implementation Effect5
-(void) onEnter
{
	[super onEnter];
	
	id effect = [CCLiquid actionWithWaves:1 amplitude:20 grid:ccg(32,24) duration:2];	

	id stopEffect = [CCSequence actions:
					 effect,
					 [CCDelayTime actionWithDuration:2],
					 [CCStopGrid action],
					 [CCDelayTime actionWithDuration:2],
					 [[effect copy] autorelease],
					 nil];
	
	id bg = [self getChildByTag:kTagBackground];
	[bg runAction:stopEffect];
}

-(NSString*) title
{
	return @"Test Stop-Copy-Restart";
}
@end

#pragma mark -
#pragma mark Issue631

@implementation Issue631
-(void) onEnter
{
	[super onEnter];
		
//	id effect = [CCLiquid actionWithWaves:1 amplitude:20 grid:ccg(32,24) duration:2];
//	id effect = [CCShaky3D actionWithRange:16 shakeZ:NO grid:ccg(5, 5) duration:5.0f];
	id effect = [CCSequence actions:[CCDelayTime actionWithDuration:2.0f], [CCShaky3D actionWithRange:16 shakeZ:NO grid:ccg(5, 5) duration:5.0f], nil];

	// cleanup
	id bg = [self getChildByTag:kTagBackground];
	[self removeChild:bg cleanup:YES];

	// background
	CCLayerColor *layer = [CCLayerColor layerWithColor:(ccColor4B){255,0,0,255}];
	[self addChild:layer z:-10];
	CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
	[sprite setPosition:ccp(50,80)];
	[layer addChild:sprite z:10];
	
	// foreground
	CCLayerColor *layer2 = [CCLayerColor layerWithColor:(ccColor4B){0, 255,0,255}];
	CCSprite *fog = [CCSprite spriteWithFile:@"Fog.png"];
	[fog setBlendFunc:(ccBlendFunc){GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}];
	[layer2 addChild:fog z:1];
	[self addChild:layer2 z:1];
	
	[layer2 runAction:[CCRepeatForever actionWithAction:effect]];
}

-(NSString*) title
{
	return @"Testing Opacity";
}

-(NSString*) subtitle
{
	return @"Effect image should be 100% opaque. Testing issue #631";
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
	@"Effect5",
	@"Issue631",
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
	if( (self = [super init]) ) {
	
		float x,y;
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		x = size.width;
		y = size.height;
		
		CCSprite *bg = [CCSprite spriteWithFile:@"background3.png"];
		[self addChild: bg z:0 tag:kTagBackground];
//		bg.anchorPoint = CGPointZero;
		bg.position = ccp(x/2,y/2);
		
		CCSprite *grossini = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		[bg addChild:grossini z:1 tag:kTagSprite1];
		grossini.position = ccp(x/3.0f,200);
		id sc = [CCScaleBy actionWithDuration:2 scale:5];
		id sc_back = [sc reverse];
	
		[grossini runAction: [CCRepeatForever actionWithAction: [CCSequence actions:sc, sc_back, nil]]];

		CCSprite *tamara = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		[bg addChild:tamara z:1 tag:kTagSprite2];
		tamara.position = ccp(2*x/3.0f,200);
		id sc2 = [CCScaleBy actionWithDuration:2 scale:5];
		id sc2_back = [sc2 reverse];
		[tamara runAction: [CCRepeatForever actionWithAction: [CCSequence actions:sc2, sc2_back, nil]]];
		
		
		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Marker Felt" fontSize:32];
		
		[label setPosition: ccp(x/2,y-40)];
		[self addChild: label z:100];
		label.tag = kTagLabel;
		
		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF *l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
			[self addChild:l z:101];
			[l setPosition:ccp(size.width/2, size.height-80)];
		}		
		
		// menu
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp(size.width/2-100,30);
		item2.position = ccp(size.width/2, 30);
		item3.position = ccp(size.width/2+100,30);
		[self addChild: menu z:101];

	}
	
	return self;
}

-(NSString*) title
{
	return @"No title";
}

-(NSString*) subtitle
{
	return nil;
}

-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [restartAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [backAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

- (void) dealloc
{
	[super dealloc];
}

@end

// CLASS IMPLEMENTATIONS

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
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
								   depthFormat:GL_DEPTH_COMPONENT16_OES];
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
	[scene addChild: [nextAction() node]];

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

- (void)applicationWillTerminate:(UIApplication *)application
{	
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	[director end];
}

// purge memroy
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

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

@implementation cocos2dmacAppDelegate

@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{	
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
	[director setDisplayFPS:YES];
	
	[director setOpenGLView:glView_];
	
//	[director setProjection:kCCDirectorProjection2D];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	[director setResizeMode:kCCDirectorResize_AutoScale];	
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	[director runWithScene:scene];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
#endif
