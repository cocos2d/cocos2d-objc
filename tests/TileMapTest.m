//
// Atlas Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "TileMapTest.h"

static int sceneIdx=-1;
static NSString *transitions[] = {
			@"TileMapTest",
			@"TileMapEditTest",
			@"TMXOrthoTest",
			@"TMXIsoTest",
			@"TMXHexTest",
};

enum {
	kTagTileMap = 1,
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

#pragma mark -
#pragma mark TileDmo

@implementation TileDemo
-(id) init
{
	if( (self=[super init] )) {

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
	}

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


#pragma mark -
#pragma mark TileMapTest

@implementation TileMapTest
-(id) init
{
	if( (self=[super init]) ) {
	
		
		TileMapAtlas *tilemap = [TileMapAtlas tileMapAtlasWithTileFile:@"tiles.png" mapFile:@"levelmap.tga" tileWidth:16 tileHeight:16];
		// Convert it to "alias" (GL_LINEAR filtering)
		[tilemap.texture setAliasTexParameters];
		
		// If you are not going to use the Map, you can free it now
		// NEW since v0.7
		[tilemap releaseMap];
		
		[self addChild:tilemap z:0 tag:kTagTileMap];
		
		tilemap.anchorPoint = ccp(0, 0.5f);
		
		id s = [ScaleBy actionWithDuration:4 scale:0.8f];
		id scaleBack = [s reverse];
		id go = [MoveBy actionWithDuration:8 position:ccp(-1650,0)];
		id goBack = [go reverse];
		
		id seq = [Sequence actions: s,
								go,
								goBack,
								scaleBack,
								nil];
		
		[tilemap runAction:seq];
	}
	
	return self;
}

-(NSString *) title
{
	return @"TileMapAtlas";
}

@end

#pragma mark -
#pragma mark TileMapEditTest

@implementation TileMapEditTest
-(id) init
{
	if( (self=[super init]) ) {
		
		
		TileMapAtlas *tilemap = [TileMapAtlas tileMapAtlasWithTileFile:@"tiles.png" mapFile:@"levelmap.tga" tileWidth:16 tileHeight:16];

		// Create an Aliased Atlas
		[tilemap.texture setAliasTexParameters];
		
		// If you are not going to use the Map, you can free it now
		// [tilemap releaseMap];
		// And if you are going to use, it you can access the data with:
		[self schedule:@selector(updateMap:) interval:0.2f];
		
		[self addChild:tilemap z:0 tag:kTagTileMap];
		
		tilemap.anchorPoint = ccp(0, 0);
		tilemap.position = ccp(-20,-200);
	}	
	return self;
}

-(void) updateMap:(ccTime) dt
{
	// IMPORTANT
	//   The only limitation is that you cannot change an empty, or assign an empty tile to a tile
	//   The value 0 not rendered so don't assign or change a tile with value 0

	TileMapAtlas *tilemap = (TileMapAtlas*) [self getChildByTag:kTagTileMap];
	
	//
	// For example you can iterate over all the tiles
	// using this code, but try to avoid the iteration
	// over all your tiles in every frame. It's very expensive
	//	for(int x=0; x < tilemap.tgaInfo->width; x++) {
	//		for(int y=0; y < tilemap.tgaInfo->height; y++) {
	//			ccColor3B c =[tilemap tileAt:ccg(x,y)];
	//			if( c.r != 0 ) {
	//				NSLog(@"%d,%d = %d", x,y,c.r);
	//			}
	//		}
	//	}
	
	// NEW since v0.7
	ccColor3B c =[tilemap tileAt:ccg(13,21)];		
	c.r++;
	c.r %= 50;
	if( c.r==0)
		c.r=1;
	
	// NEW since v0.7
	[tilemap setTile:c at:ccg(13,21)];			
	
}

-(NSString *) title
{
	return @"Editable TileMapAtlas";
}
@end

#pragma mark -
#pragma mark TMXOrthoTest

@implementation TMXOrthoTest
-(id) init
{
	if( (self=[super init]) ) {
		
		[[Director sharedDirector] set2Dprojection];

		TMXTiledMap *ortho = [TMXTiledMap tiledMapWithTMXFile:@"orthogonal-test2.tmx"];
		[self addChild:ortho z:0 tag:kTagTileMap];
		
		[ortho setScale:1.0f];
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Orthogonal test";
}
@end

#pragma mark -
#pragma mark TMXIsoTest

@implementation TMXIsoTest
-(id) init
{
	if( (self=[super init]) ) {
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Isometric test";
}
@end

#pragma mark -
#pragma mark TMXHexTest

@implementation TMXHexTest
-(id) init
{
	if( (self=[super init]) ) {
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Hex test";
}
@end


#pragma mark -
#pragma mark Application Delegate

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
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
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
