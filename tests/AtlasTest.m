//
// Atlas Demo
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//

// cocos import
#import "cocos2d.h"

// local import
#import "AtlasTest.h"
static int sceneIdx=-1;
static NSString *transitions[] = {
			@"Atlas1",
			@"Atlas2",
			@"Atlas3",
			@"Atlas4",
			@"Atlas5",
			@"Atlas6",
};

enum {
	kTagTileMap = 1,
	kTagSpriteManager = 1,
	kTagAnimation1 = 1,
	kTagBitmapAtlas1 = 1,
	kTagBitmapAtlas2 = 2,
	kTagBitmapAtlas3 = 3,
};

enum {
	kTagSprite1,
	kTagSprite2,
	kTagSprite3,
	kTagSprite4,
	kTagSprite5,
	kTagSprite6,
	kTagSprite7,
	kTagSprite8,
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

#pragma mark Example Atlas 1

@implementation Atlas1


-(id) init
{
	if( ![super init] )
		return nil;
	
	textureAtlas = [[TextureAtlas textureAtlasWithFile: @"atlastest.png" capacity:3] retain];
	
	CGSize s = [[Director sharedDirector] winSize];

	//
	// Notice: u,v tex coordinates are inverted
	//
	ccV3F_C4B_T2F_Quad quads[] = {
		{
			{{0,0,0},{0,0,255,255},{0.0f,1.0f},},				// bottom left
			{{s.width,0,0},{0,0,255,0},{1.0f,1.0f},},			// bottom right
			{{0,s.height,0},{0,0,255,0},{0.0f,0.0f},},			// top left
			{{s.width,s.height,0},{0,0,255,255},{1.0f,0.0f},},	// top right
		},		
		{
			{{40,40,0},{255,255,255,255},{0.0f,0.2f},},			// bottom left
			{{120,80,0},{255,0,0,255},{0.5f,0.2f},},			// bottom right
			{{40,160,0},{255,255,255,255},{0.0f,0.0f},},		// top left
			{{160,160,0},{0,255,0,255},{0.5f,0.0f},},			// top right
		},

		{
			{{s.width/2,40,0},{255,0,0,255},{0.0f,1.0f},},		// bottom left
			{{s.width,40,0},{0,255,0,255},{1.0f,1.0f},},		// bottom right
			{{s.width/2-50,200,0},{0,0,255,255},{0.0f,0.0f},},		// top left
			{{s.width,100,0},{255,255,0,255},{1.0f,0.0f},},		// top right
		},
		
	};
	
	
	for( int i=0;i<3;i++) {
		[textureAtlas updateQuad:&quads[i] atIndex:i];
	}
		
//	[textureAtlas removeQuadAtIndex:0];

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
	glEnableClientState( GL_COLOR_ARRAY);
	
	glEnable( GL_TEXTURE_2D);

	[textureAtlas drawQuads];

//	[textureAtlas drawNumberOfQuads:3];
		
	glDisable( GL_TEXTURE_2D);
	
	glDisableClientState(GL_COLOR_ARRAY);
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
	
	[self addChild:label];
	[label retain];

	label.position = ccp(10,100);

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


#pragma mark Example Atlas3

/*
* Use this editor to generate bitmap font atlas:
*  http://slick.cokeandcode.com/demos/hiero.jnlp
*/
@implementation Atlas3
-(id) init
{
	if( (self=[super init]) ) {
		
		BitmapFontAtlas *label1 = [BitmapFontAtlas bitmapFontAtlasWithString:@"Bitmap Font Atlas" fntFile:@"bitmapFontTest2.fnt" alignment:UITextAlignmentLeft];
		[self addChild:label1 z:0 tag:kTagBitmapAtlas1];
		
		BitmapFontAtlas *label2 = [BitmapFontAtlas bitmapFontAtlasWithString:@"Bitmap Font Atlas" fntFile:@"bitmapFontTest2.fnt" alignment:UITextAlignmentCenter];
		[self addChild:label2 z:0 tag:kTagBitmapAtlas2];
		
		BitmapFontAtlas *label3 = [BitmapFontAtlas bitmapFontAtlasWithString:@"Bitmap Font Atlas" fntFile:@"bitmapFontTest2.fnt" alignment:UITextAlignmentRight];
		[self addChild:label3 z:0 tag:kTagBitmapAtlas3];
		
		
		CGSize s = [[Director sharedDirector] winSize];	
		label1.position = ccp( 0, 40);
		label2.position = ccp( s.width/2, s.height/2);
		label3.position = ccp( s.width, s.height/2+40);
		
		[self schedule:@selector(step:)];
	}
	
	return self;
}

-(void) step:(ccTime) dt
{
	time += dt;
	NSString *string = [NSString stringWithFormat:@"%2.2f Test", time];
	
	BitmapFontAtlas *label1 = (BitmapFontAtlas*) [self getChildByTag:kTagBitmapAtlas1];
	[label1 setString:string];
	
	BitmapFontAtlas *label2 = (BitmapFontAtlas*) [self getChildByTag:kTagBitmapAtlas2];
	[label2 setString:string];
	
	BitmapFontAtlas *label3 = (BitmapFontAtlas*) [self getChildByTag:kTagBitmapAtlas3];
	[label3 setString:string];
}

-(NSString*) title
{
	return @"BitmapFontAtlas test #1";
}
@end

#pragma mark Example Atlas4

/*
 * Use this editor to generate bitmap font atlas:
 *  http://slick.cokeandcode.com/demos/hiero.jnlp
 */

@implementation Atlas4
-(id) init
{
	if( (self=[super init]) ) {
		
		// Upper Label
		BitmapFontAtlas *label = [BitmapFontAtlas bitmapFontAtlasWithString:@"Bitmap Font Atlas" fntFile:@"bitmapFontTest.fnt" alignment:UITextAlignmentCenter];
		[self addChild:label];
		
		CGSize s = [[Director sharedDirector] winSize];
		
		label.position = ccp(s.width/2, s.height/2);
		
		
		AtlasSprite *BChar = (AtlasSprite*) [label getChildByTag:0];
		AtlasSprite *FChar = (AtlasSprite*) [label getChildByTag:7];
		AtlasSprite *AChar = (AtlasSprite*) [label getChildByTag:12];
		
		
		id rotate = [RotateBy actionWithDuration:2 angle:360];
		id rot_4ever = [RepeatForever actionWithAction:rotate];
		
		id scale = [ScaleBy actionWithDuration:2 scale:1.5f];
		id scale_back = [scale reverse];
		id scale_seq = [Sequence actions:scale, scale_back,nil];
		id scale_4ever = [RepeatForever actionWithAction:scale_seq];
		
		id jump = [JumpBy actionWithDuration:0.5f position:CGPointZero height:60 jumps:1];
		id jump_4ever = [RepeatForever actionWithAction:jump];
		
		id fade_out = [FadeOut actionWithDuration:1];
		id fade_in = [FadeIn actionWithDuration:1];
		id seq = [Sequence actions:fade_out, fade_in, nil];
		id fade_4ever = [RepeatForever actionWithAction:seq];
		
		[BChar runAction:rot_4ever];
		[BChar runAction:scale_4ever];
		[FChar runAction:jump_4ever];
		[AChar runAction:fade_4ever];
		
		
		// Bottom Label
		BitmapFontAtlas *label2 = [BitmapFontAtlas bitmapFontAtlasWithString:@"00.0" fntFile:@"bitmapFontTest.fnt" alignment:UITextAlignmentCenter];
		[self addChild:label2 z:0 tag:kTagBitmapAtlas2];
		label2.position = ccp(s.width/2.0f, 80);
		
		AtlasSprite *lastChar = (AtlasSprite*) [label2 getChildByTag:3];
		[lastChar runAction: [[rot_4ever copy] autorelease]];
		
		[self schedule:@selector(step:) interval:0.1f];
	}
	
	return self;
}
-(NSString*) title
{
	return @"BitmapFontAtlas test #2";
}
-(void) step:(ccTime) dt
{
	time += dt;
	NSString *string = [NSString stringWithFormat:@"%04.1f", time];
	
	BitmapFontAtlas *label1 = (BitmapFontAtlas*) [self getChildByTag:kTagBitmapAtlas2];
	[label1 setString:string];	
}

@end

#pragma mark Example Atlas 5

@implementation Atlas5
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
		
		CGSize size = tilemap.contentSize;
		tilemap.transformAnchor = ccp(0, size.height/2);
		
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
	return @"Atlas: TileMapAtlas";
}

@end

#pragma mark Example Atlas 6

@implementation Atlas6
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
		
		tilemap.transformAnchor = ccp(0, 0);
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
	return @"Atlas: Editable TileMapAtlas";
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
	[Director useFastDirector];
	
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
