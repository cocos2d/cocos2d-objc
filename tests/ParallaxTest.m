//
// Parallax Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "ParallaxTest.h"

enum {
	kTagNode,
	kTagGrossini,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
			@"Parallax1",
			@"Parallax2",
};

Class nextAction()
{
	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	int total = ( sizeof(transitions) / sizeof(transitions[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;	
	
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}


@implementation ParallaxDemo
-(id) init
{
	[super init];


	CGSize s = [[Director sharedDirector] winSize];
		
	Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:32];
	[self addChild: label z:1];
	[label setPosition: ccp(s.width/2, s.height-50)];
	
	MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
	MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
	MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
	
	Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
	
	menu.position = CGPointZero;
	item1.position = ccp( s.width/2 - 100,30);
	item2.position = ccp( s.width/2, 30);
	item3.position = ccp( s.width/2 + 100,30);
	[self addChild: menu z:1];	

	return self;
}

-(void) dealloc
{
	[super dealloc];
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

-(NSString*) title
{
	return @"No title";
}
@end

#pragma mark Example Parallax 1

@implementation Parallax1
-(id) init
{
	if( ![super init] )
		return nil;

	// Top Layer, a simple image
	Sprite *cocosImage = [Sprite spriteWithFile:@"powered.png"];
	// scale the image (optional)
	cocosImage.scale = 2.5f;
	// change the transform anchor point to 0,0 (optional)
	cocosImage.anchorPoint = ccp(0,0);
	

	// Middle layer: a Tile map atlas
	TileMapAtlas *tilemap = [TileMapAtlas tileMapAtlasWithTileFile:@"tiles.png" mapFile:@"levelmap.tga" tileWidth:16 tileHeight:16];
	[tilemap releaseMap];
	
	// change the transform anchor to 0,0 (optional)
	tilemap.anchorPoint = ccp(0, 0);

	// Aliased images
//	[tilemap.texture setAliasTexParameters];
	

	// background layer: another image
	Sprite *background = [Sprite spriteWithFile:@"background.png"];
	// scale the image (optional)
	background.scale = 1.5f;
	// change the transform anchor point (optional)
	background.anchorPoint = ccp(0,0);

	
	// create a void node, a parent node
	ParallaxNode *voidNode = [ParallaxNode node];
	
	// NOW add the 3 layers to the 'void' node

	// background image is moved at a ratio of 0.4x, 0.5y
	[voidNode addChild:background z:-1 parallaxRatio:ccp(0.4f,0.5f) positionOffset:CGPointZero];
	
	// tiles are moved at a ratio of 2.2x, 1.0y
	[voidNode addChild:tilemap z:1 parallaxRatio:ccp(2.2f,1.0f) positionOffset:ccp(0,-200)];
	
	// top image is moved at a ratio of 3.0x, 2.5y
	[voidNode addChild:cocosImage z:2 parallaxRatio:ccp(3.0f,2.5f) positionOffset:ccp(200,1000)];
	
	
	// now create some actions that will move the 'void' node
	// and the children of the 'void' node will move at different
	// speed, thus, simulation the 3D environment
	id goUp = [MoveBy actionWithDuration:4 position:ccp(0,-500)];
	id goDown = [goUp reverse];
	id go = [MoveBy actionWithDuration:8 position:ccp(-1000,0)];
	id goBack = [go reverse];
	id seq = [Sequence actions:
			  goUp,
			  go,
			  goDown,
			  goBack,
			  nil];	
	[voidNode runAction: [RepeatForever actionWithAction:seq ] ];
	
	[self addChild:voidNode];
	
	return self;
	
}

-(NSString *) title
{
	return @"Parallax: parent and 3 children";
}
@end

#pragma mark Example Parallax 2

@implementation Parallax2
-(id) init
{
	if( (self=[super init] )) {

		self.isTouchEnabled = YES;
		
		// Top Layer, a simple image
		Sprite *cocosImage = [Sprite spriteWithFile:@"powered.png"];
		// scale the image (optional)
		cocosImage.scale = 2.5f;
		// change the transform anchor point to 0,0 (optional)
		cocosImage.anchorPoint = ccp(0,0);
		
		
		// Middle layer: a Tile map atlas
		TileMapAtlas *tilemap = [TileMapAtlas tileMapAtlasWithTileFile:@"tiles.png" mapFile:@"levelmap.tga" tileWidth:16 tileHeight:16];
		[tilemap releaseMap];
		
		// change the transform anchor to 0,0 (optional)
		tilemap.anchorPoint = ccp(0, 0);
		
		// Aliased images
//		[tilemap.texture setAliasTexParameters];
		
		
		// background layer: another image
		Sprite *background = [Sprite spriteWithFile:@"background.png"];
		// scale the image (optional)
		background.scale = 1.5f;
		// change the transform anchor point (optional)
		background.anchorPoint = ccp(0,0);
		
		
		// create a void node, a parent node
		ParallaxNode *voidNode = [ParallaxNode node];
		
		// NOW add the 3 layers to the 'void' node
		
		// background image is moved at a ratio of 0.4x, 0.5y
		[voidNode addChild:background z:-1 parallaxRatio:ccp(0.4f,0.5f) positionOffset:CGPointZero];
		
		// tiles are moved at a ratio of 1.0, 1.0y
		[voidNode addChild:tilemap z:1 parallaxRatio:ccp(1.0f,1.0f) positionOffset:ccp(0,-200)];
		
		// top image is moved at a ratio of 3.0x, 2.5y
		[voidNode addChild:cocosImage z:2 parallaxRatio:ccp(3.0f,2.5f) positionOffset:ccp(200,1000)];
		[self addChild:voidNode z:0 tag:kTagNode];

	}
	
	return self;
}

-(void) registerWithTouchDispatcher
{
	[[TouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];	

	touchLocation = [[Director sharedDirector] convertCoordinate: touchLocation];
	prevLocation = [[Director sharedDirector] convertCoordinate: prevLocation];

	CGPoint diff = ccpSub(touchLocation,prevLocation);
	
	CocosNode *node = [self getChildByTag:kTagNode];
	CGPoint currentPos = [node position];
	[node setPosition: ccpAdd(currentPos, diff)];
}


-(NSString *) title
{
	return @"Parallax: drag screen";
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
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];	

	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];	
	
	Scene *scene = [Scene node];
	[scene addChild: [nextAction() node]];
			 
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
