//
// Atlas Demo
// a cocos2d example
//

// cocos import
#import "cocos2d.h"

// local import
#import "TestAtlas.h"
static int sceneIdx=-1;
static NSString *transitions[] = {
			@"Atlas1",
			@"Atlas2",
			@"Atlas3",
			@"Atlas4",
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


@implementation AtlasDemo
-(id) init
{
	[super init];


	CGSize s = [[Director sharedDirector] winSize];
		
	Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:32];
	[self add: label z:1];
	[label setPosition: cpv(s.width/2, s.height-50)];
	
	MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
	MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
	MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
	
	Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
	
	menu.position = cpvzero;
	item1.position = cpv( s.width/2 - 100,30);
	item2.position = cpv( s.width/2, 30);
	item3.position = cpv( s.width/2 + 100,30);
	[self add: menu z:1];	

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) restartCallback: (id) sender
{
	Scene *s = [Scene node];
	[s add: [restartAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	Scene *s = [Scene node];
	[s add: [nextAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	Scene *s = [Scene node];
	[s add: [backAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}
@end

#pragma mark Example Atlas 1

@implementation Atlas1


-(id) init
{
	if( ![super init] )
		return nil;
	
	textureAtlas = [[TextureAtlas textureAtlasWithFile: @"atlastest.png" capacity:3] retain];

	ccQuad2 texCoords[] = {
		{0.0,0.2,	0.5,0.2,	0.0,0.0,	0.5,0.0},
		{0.2,0.6,	0.6,0.6,	0.2,0.2,	0.6,0.2},
		{0.0,1.0,	1.0,1.0,	0.0,0.0,	1.0,0.0},
	};
	
	ccQuad3	vertices[] = {
		{40,40,0,		120,80,0,		40,160,0,		160,160,0},
		{240,80,0,		480,80,0,		180,120,0,		420,120,0},
		{240,140,0,		360,200,0,		240,250,0,		360,310,0},
	};
	
	for( int i=0;i<3;i++) {
		[textureAtlas updateQuadWithTexture: &texCoords[i] vertexQuad: &vertices[i] atIndex:i];
	}
	
	return self;
}

-(void) dealloc
{
	[textureAtlas release];
	[super dealloc];
}


-(void) draw
{
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	
	glEnable( GL_TEXTURE_2D);
	
	[textureAtlas drawNumberOfQuads:3];
		
	glDisable( GL_TEXTURE_2D);
	
	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
}
					
-(NSString *) title
{
	return @"Atlas: TextureAtlas";
}
@end

#pragma mark Example Atlas 2

@implementation Atlas2
-(id) init
{
	if( ![super init] )
		return nil;
	
	label = [LabelAtlas labelAtlasWithString:@"123 Test" charMapFile:@"tuffy_bold_italic-charmap.png" itemWidth:48 itemHeight:64 startCharMap:' '];
	
	[self add:label];
	[label retain];

	label.position = cpv(10,100);

	[self schedule:@selector(step:)];
	return self;
	
}

-(void) step:(ccTime) dt
{
	time += dt;
	NSString *string = [NSString stringWithFormat:@"%2.2f Test", time];
	[label setString:string];
}

-(void) dealloc
{
	[label release];
	[super dealloc];
}

-(NSString *) title
{
	return @"Atlas: LabelAtlas";
}
@end

#pragma mark Example Atlas 3

@implementation Atlas3
-(id) init
{
	if( (self=[super init]) ) {
	
		// Create an Aliased Atlas
		[Texture2D saveTexParameters];
		[Texture2D setAliasTexParameters];
		
		TileMapAtlas *tilemap = [TileMapAtlas tileMapAtlasWithTileFile:@"tiles.png" mapFile:@"levelmap.tga" tileWidth:16 tileHeight:16];
				
		[Texture2D restoreTexParameters];
		
		// If you are not going to use the Map, you can free it now
		// NEW since v0.7
		[tilemap releaseMap];
		
		[self add:tilemap z:0 tag:kTagTileMap];
		
		CGSize size = tilemap.contentSize;
		tilemap.transformAnchor = cpv(0, size.height/2);
		
		id s = [ScaleBy actionWithDuration:4 scale:0.8];
		id scaleBack = [s reverse];
		id go = [MoveBy actionWithDuration:8 position:cpv(-1650,0)];
		id goBack = [go reverse];
		
		id seq = [Sequence actions: s,
								go,
								goBack,
								scaleBack,
								nil];
		
		[tilemap do:seq];
	}
	
	return self;
}

-(NSString *) title
{
	return @"Atlas: TileMapAtlas";
}

@end

#pragma mark Example Atlas 4

@implementation Atlas4
-(id) init
{
	if( (self=[super init]) ) {
		
		// Create an Aliased Atlas
		[Texture2D saveTexParameters];
		[Texture2D setAliasTexParameters];
		
		TileMapAtlas *tilemap = [TileMapAtlas tileMapAtlasWithTileFile:@"tiles.png" mapFile:@"levelmap.tga" tileWidth:16 tileHeight:16];
		
		[Texture2D restoreTexParameters];
		
		// If you are not going to use the Map, you can free it now
		// [tilemap releaseMap];
		// And if you are going to use, it you can access the data with:
		[self schedule:@selector(updateMap:) interval:0.2f];
		
		[self add:tilemap z:0 tag:kTagTileMap];
		
		tilemap.transformAnchor = cpv(0, 0);
		tilemap.position = cpv(-20,-200);
	}	
	return self;
}

-(void) updateMap:(ccTime) dt
{
	// IMPORTANT
	//   The only limitation is that you cannot change an empty, or assign an empty tile to a tile
	//   The value 0 not rendered so don't assign or change a tile with value 0

	TileMapAtlas *tilemap = (TileMapAtlas*) [self getByTag:kTagTileMap];
	
	//
	// For example you can iterate over all the tiles
	// using this code, but try to avoid the iteration
	// over all your tiles in every frame. It's very expensive
	//	for(int x=0; x < tilemap.tgaInfo->width; x++) {
	//		for(int y=0; y < tilemap.tgaInfo->height; y++) {
	//			ccRGBB c =[tilemap tileAt:ccg(x,y)];
	//			if( c.r != 0 ) {
	//				NSLog(@"%d,%d = %d", x,y,c.r);
	//			}
	//		}
	//	}
	
	// NEW since v0.7
	ccRGBB c =[tilemap tileAt:ccg(13,21)];		
	c.r++;
	c.r %= 50;
	if( c.r==0)
		c.r=1;
	
	// NEW since v0.7
	[tilemap setTile:c at:ccg(13,21)];			
	
}

-(NSString *) title
{
	return @"Atlas: Editable TileMapAtlas";
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
	[scene add: [nextAction() node]];
			 
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
