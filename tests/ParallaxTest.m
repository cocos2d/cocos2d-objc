//
// Parallax Demo
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//

// cocos import
#import "cocos2d.h"

// local import
#import "ParallaxTest.h"

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
	[label setPosition: CGPointMake(s.width/2, s.height-50)];
	
	MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
	MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
	MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
	
	Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
	
	menu.position = CGPointZero;
	item1.position = CGPointMake( s.width/2 - 100,30);
	item2.position = CGPointMake( s.width/2, 30);
	item3.position = CGPointMake( s.width/2 + 100,30);
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
	cocosImage.transformAnchor = CGPointMake(0,0);
	// position the image somewhere (optional)
	cocosImage.position = CGPointMake(200,1000);
	
	// Aliased images
	[Texture2D saveTexParameters];
	[Texture2D setAliasTexParameters];

	// Middle layer: a Tile map atlas
	TileMapAtlas *tilemap = [TileMapAtlas tileMapAtlasWithTileFile:@"tiles.png" mapFile:@"levelmap.tga" tileWidth:16 tileHeight:16];
	[tilemap releaseMap];
	
	// change the transform anchor to 0,0 (optional)
	tilemap.transformAnchor = CGPointMake(0, 0);
	// position the tilemap (optional)
	tilemap.position = CGPointMake(0,-200);
	
	[Texture2D restoreTexParameters];

	// background layer: another image
	Sprite *background = [Sprite spriteWithFile:@"background.png"];
	// scale the image (optional)
	background.scale = 1.5f;
	// change the transform anchor point (optional)
	background.transformAnchor = CGPointMake(0,0);

	
	// create a void node, a parent node
	CocosNode *voidNode = [CocosNode node];
	
	// NOW add the 3 layers to the 'void' node

	// background image is moved at a ratio of 0.4x, 0.5y
	[voidNode addChild:background z:-1 parallaxRatio:CGPointMake(0.4f,0.5f)];
	
	// tiles are moved at a ratio of 2.2x, 1.0y
	[voidNode addChild:tilemap z:1 parallaxRatio:CGPointMake(2.2f,1.0f)];
	
	// top image is moved at a ratio of 3.0x, 2.5y
	[voidNode addChild:cocosImage z:2 parallaxRatio:CGPointMake(3.0f,2.5f)];
	
	
	// now create some actions that will move the 'void' node
	// and the children of the 'void' node will move at different
	// speed, thus, simulation the 3D environment
	id goUp = [MoveBy actionWithDuration:4 position:CGPointMake(0,-500)];
	id goDown = [goUp reverse];
	id go = [MoveBy actionWithDuration:8 position:CGPointMake(-1000,0)];
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
	if( ![super init] )
		return nil;
	
	// Aliased images
	[Texture2D saveTexParameters];
	[Texture2D setAliasTexParameters];	
	
	// this node will be used as the parent (reference) for the parallax scroller
	TileMapAtlas *tilemap = [TileMapAtlas tileMapAtlasWithTileFile:@"tiles.png" mapFile:@"levelmap.tga" tileWidth:16 tileHeight:16];
	[tilemap releaseMap];
	
	[Texture2D restoreTexParameters];
	
	tilemap.transformAnchor = CGPointMake(0, 0);
	tilemap.position = CGPointMake(0,-200);
	
	Sprite *background = [Sprite spriteWithFile:@"background.png"];
	background.scale = 1.5f;
	background.transformAnchor = CGPointMake(0,0);
	
	// the parent contains data. The parent moves at (1,1)
	// while the child moves at the ratio of (0.4, 0.5)
	[tilemap addChild:background z:-1 parallaxRatio:CGPointMake(0.4f,0.5f)];
	
	id goUp = [MoveBy actionWithDuration:2 position:CGPointMake(-1000,-500)];
	id goDown = [goUp reverse];
	id seq = [Sequence actions:
			  goUp,
			  goDown,
			  nil];	
	[tilemap runAction: [RepeatForever actionWithAction:seq ] ];
	
	[self addChild:tilemap];
	
	return self;
	
}

-(NSString *) title
{
	return @"Parallax: parent & child";
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
	[[Director sharedDirector] setLandscape: YES];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];

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
