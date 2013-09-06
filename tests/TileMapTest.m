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

	@"TMXIsoZorder",
	@"TMXOrthoZorder",
	@"TMXIsoVertexZ",
	@"TMXOrthoVertexZ",
	@"TMXOrthoTest",
	@"TMXOrthoTest2",
	@"TMXOrthoTest3",
	@"TMXOrthoTest4",
	@"TMXIsoTest",
	@"TMXIsoTest1",
	@"TMXIsoTest2",
	@"TMXUncompressedTest",
	@"TMXHexTest",
	@"TMXReadWriteTest",
	@"TMXTilesetTest",
	@"TMXOrthoObjectsTest",
	@"TMXIsoObjectsTest",
    @"TMXGIDObjectsTest",
	@"TMXTilePropertyTest",
	@"TMXResizeTest",
	@"TMXIsoMoveLayer",
	@"TMXOrthoMoveLayer",
	@"TMXOrthoFlipTest",
	@"TMXOrthoFlipRunTimeTest",
	@"TMXOrthoFromXMLTest",
	@"TMXBug987",
	@"TMXBug787",

	@"TileMapTest",
	@"TileMapEditTest",
};

enum {
	kTagTileMap = 1,
};

Class nextAction(void);
Class backAction(void);
Class restartAction(void);


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

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];

		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF *l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
			[self addChild:l z:1];
			[l setPosition:ccp(s.width/2, s.height-80)];
		}

		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];

		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];

		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - item2.contentSize.width*2, item2.contentSize.height/2);
		item2.position = ccp( s.width/2, item2.contentSize.height/2);
		item3.position = ccp( s.width/2 + item2.contentSize.width*2, item2.contentSize.height/2);
		[self addChild: menu z:1];
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

#ifdef __CC_PLATFORM_IOS

-(void) touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [ touches anyObject ];
	CGPoint touchLocation = [touch locationInView: [touch view]];
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];

	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];

	CGPoint diff = ccpSub(touchLocation,prevLocation);

	CCNode *node = [self getChildByTag:kTagTileMap];
	CGPoint currentPos = [node position];
	[node setPosition: ccpAdd(currentPos, diff)];
}
#elif defined(__CC_PLATFORM_MAC)

- (void)mouseDragged:(NSEvent *)theEvent
{
	CCNode *node = [self getChildByTag:kTagTileMap];
	CGPoint currentPos = [node position];
	[node setPosition: ccpAdd(currentPos, CGPointMake( theEvent.deltaX, -theEvent.deltaY) )];
}
#endif

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

-(NSString*) title
{
	return @"No title";
}
-(NSString*) subtitle
{
	return @"drag the screen";
}
@end


#pragma mark -
#pragma mark TileMapTest

@implementation TileMapTest
-(id) init
{
	if( (self=[super init]) ) {


		CCTileMapAtlas *map = [CCTileMapAtlas tileMapAtlasWithTileFile:@"TileMaps/tiles.png" mapFile:@"TileMaps/levelmap.tga" tileWidth:16 tileHeight:16];
		// Convert it to "anti alias" (GL_LINEAR filtering)
		[map.texture setAntiAliasTexParameters];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		// If you are not going to use the Map, you can free it now
		// NEW since v0.7
		[map releaseMap];

		[self addChild:map z:0 tag:kTagTileMap];

		map.anchorPoint = ccp(0, 0.5f);

		CCScaleBy *scale = [CCScaleBy actionWithDuration:4 scale:0.8f];
		CCActionInterval *scaleBack = [scale reverse];

		id seq = [CCSequence actions: scale,
								scaleBack,
								nil];

		[map runAction:[CCRepeatForever actionWithAction:seq]];
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


		CCTileMapAtlas *map = [CCTileMapAtlas tileMapAtlasWithTileFile:@"TileMaps/tiles.png" mapFile:@"TileMaps/levelmap.tga" tileWidth:16 tileHeight:16];

		// Create an Aliased Atlas
		[map.texture setAliasTexParameters];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		// If you are not going to use the Map, you can free it now
		// [tilemap releaseMap];
		// And if you are going to use, it you can access the data with:
		[self schedule:@selector(updateMap:) interval:0.2f];

		[self addChild:map z:0 tag:kTagTileMap];

		map.anchorPoint = ccp(0, 0);
		map.position = ccp(-20,-200);
	}
	return self;
}

-(void) updateMap:(ccTime) dt
{
	// IMPORTANT
	//   The only limitation is that you cannot change an empty, or assign an empty tile to a tile
	//   The value 0 not rendered so don't assign or change a tile with value 0

	CCTileMapAtlas *tilemap = (CCTileMapAtlas*) [self getChildByTag:kTagTileMap];

	//
	// For example you can iterate over all the tiles
	// using this code, but try to avoid the iteration
	// over all your tiles in every frame. It's very expensive
	//	for(int x=0; x < tilemap.tgaInfo->width; x++) {
	//		for(int y=0; y < tilemap.tgaInfo->height; y++) {
	//			ccColor3B c =[tilemap tileAt:CGSizeMake(x,y)];
	//			if( c.r != 0 ) {
	//				NSLog(@"%d,%d = %d", x,y,c.r);
	//			}
	//		}
	//	}

	// NEW since v0.7
	ccColor3B c =[tilemap tileAt:ccp(13,21)];
	c.r++;
	c.r %= 50;
	if( c.r==0)
		c.r=1;

	// NEW since v0.7
	[tilemap setTile:c at:ccp(13,21)];

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

		//
		// Test orthogonal with 3d camera and anti-alias textures
		//
		// it should not flicker. No artifacts should appear
		//

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test2.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		for( CCSpriteBatchNode* child in [map children] ) {
			[[child texture] setAntiAliasTexParameters];
		}

		float x, y, z;
		[[map camera] eyeX:&x eyeY:&y eyeZ:&z];
		[[map camera] setEyeX:x-200 eyeY:y eyeZ:z+300];
	}
	return self;
}

-(void) onEnter
{
	[super onEnter];
	[[CCDirector sharedDirector] setProjection:kCCDirectorProjection3D];
}

-(void) onExit
{
	[[CCDirector sharedDirector] setProjection:kCCDirectorProjection2D];
	[super onExit];
}


-(NSString *) title
{
	return @"TMX Orthogonal test";
}
@end

#pragma mark -
#pragma mark TMXOrthoTest2

@implementation TMXOrthoTest2
-(id) init
{
	if( (self=[super init]) ) {
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test1.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		for( CCSpriteBatchNode* child in [map children] ) {
			[[child texture] setAntiAliasTexParameters];
		}

		[map runAction:[CCScaleBy actionWithDuration:2 scale:0.5f]];

	}
	return self;
}

-(NSString *) title
{
	return @"TMX Ortho test2";
}
@end

#pragma mark -
#pragma mark TMXOrthoTest3

@implementation TMXOrthoTest3
-(id) init
{
	if( (self=[super init]) ) {
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test3.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		for( CCSpriteBatchNode* child in [map children] ) {
			[[child texture] setAntiAliasTexParameters];
		}

		[map setScale:0.2f];
		[map setAnchorPoint:ccp(0.5f, 0.5f)];
	}
	return self;
}

-(NSString *) title
{
	return @"TMX anchorPoint test";
}
@end

#pragma mark -
#pragma mark TMXOrthoTest4

@implementation TMXOrthoTest4
-(id) init
{
	if( (self=[super init]) ) {
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test4.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s1 = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s1.width,s1.height);

		for( CCSpriteBatchNode* child in [map children] ) {
			[[child texture] setAntiAliasTexParameters];
		}

		[map setAnchorPoint:ccp(0, 0)];

		CCTMXLayer *layer = [map layerNamed:@"Layer 0"];
		CGSize s = [layer layerSize];

		CCSprite *sprite;
		sprite = [layer tileAt:ccp(0,0)];
		[sprite setScale:2];
		sprite = [layer tileAt:ccp(s.width-1, 0)];
		[sprite setScale:2];
		sprite = [layer tileAt:ccp(0, s.height-1)];
		[sprite setScale:2];
		sprite = [layer tileAt:ccp(s.width-1, s.height-1)];
		[sprite setScale:2];

		[self schedule:@selector(removeSprite:) interval:2];
	}
	return self;
}

-(void) removeSprite:(ccTime)dt
{
	[self unschedule:_cmd];

	CCTMXTiledMap *map = (CCTMXTiledMap*) [self getChildByTag:kTagTileMap];
	CCTMXLayer *layer = [map layerNamed:@"Layer 0"];
	CGSize s = [layer layerSize];

	CCSprite *sprite = [layer tileAt:ccp(s.width-1,0)];
	[layer removeChild:sprite cleanup:YES];
}

-(NSString *) title
{
	return @"TMX width/height test";
}
@end



#pragma mark -
#pragma mark TMXIsoTest

@implementation TMXIsoTest
-(id) init
{
	if( (self=[super init]) ) {
		CCLayerColor *color = [CCLayerColor layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		// move map to the center of the screen
		CGSize ms = [map mapSize];
		CGSize ts = [map tileSize];
		[map runAction:[CCMoveTo actionWithDuration:1.0f position:ccp( -ms.width * ts.width/2, -ms.height * ts.height/2 ) ]];

	}
	return self;
}

-(NSString *) title
{
	return @"TMX Isometric test 0";
}
@end

#pragma mark -
#pragma mark TMXIsoTest1

@implementation TMXIsoTest1
-(id) init
{
	if( (self=[super init]) ) {
		CCLayerColor *color = [CCLayerColor layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test1.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		[map setAnchorPoint:ccp(0.5f, 0.5f)];
	}
	return self;
}

-(NSString *) title
{
	return @"TMX Isometric test + anchorPoint";
}
@end

#pragma mark -
#pragma mark TMXIsoTest2

@implementation TMXIsoTest2
-(id) init
{
	if( (self=[super init]) ) {
		CCLayerColor *color = [CCLayerColor layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test2.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		// move map to the center of the screen
		CGSize ms = [map mapSize];
		CGSize ts = [map tileSize];
		[map runAction:[CCMoveTo actionWithDuration:1.0f position:ccp( -ms.width * ts.width/2, -ms.height * ts.height/2 ) ]];

	}
	return self;
}

-(NSString *) title
{
	return @"TMX Isometric test 2";
}
@end

@implementation TMXUncompressedTest
-(id) init
{
	if( (self=[super init]) ) {
		CCLayerColor *color = [CCLayerColor layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test2-uncompressed.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		// move map to the center of the screen
		CGSize ms = [map mapSize];
		CGSize ts = [map tileSize];
		[map runAction:[CCMoveTo actionWithDuration:1.0f position:ccp( -ms.width * ts.width/2, -ms.height * ts.height/2 ) ]];

		// testing release map
		for( CCTMXLayer *layer in [map children])
			[layer releaseMap];

	}
	return self;
}

-(NSString *) title
{
	return @"TMX Uncompressed test";
}
@end


#pragma mark -
#pragma mark TMXHexTest

@implementation TMXHexTest
-(id) init
{
	if( (self=[super init]) ) {
		CCLayerColor *color = [CCLayerColor layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/hexa-test.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
	}
	return self;
}

-(NSString *) title
{
	return @"TMX Hex test";
}
@end

#pragma mark -
#pragma mark TMXReadWriteTest

@implementation TMXReadWriteTest
-(id) init
{
	if( (self=[super init]) ) {

		gid = 0;

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test2.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);


		CCTMXLayer *layer = [map layerNamed:@"Layer 0"];
		[layer.texture setAntiAliasTexParameters];

		map.scale = 1;

		CCSprite *tile0 = [layer tileAt:ccp(1,63)];
		CCSprite *tile1 = [layer tileAt:ccp(2,63)];
		CCSprite *tile2 = [layer tileAt:ccp(1,62)];
		CCSprite *tile3 = [layer tileAt:ccp(2,62)];
		tile0.anchorPoint = ccp(0.5f, 0.5f);
		tile1.anchorPoint = ccp(0.5f, 0.5f);
		tile2.anchorPoint = ccp(0.5f, 0.5f);
		tile3.anchorPoint = ccp(0.5f, 0.5f);

		id move = [CCMoveBy actionWithDuration:0.5f position:ccp(0,160)];
		id rotate = [CCRotateBy actionWithDuration:2 angle:360];
		id scale = [CCScaleBy actionWithDuration:2 scale:5];
		id opacity = [CCFadeOut actionWithDuration:2];
		id fadein = [CCFadeIn actionWithDuration:2];
		id scaleback = [CCScaleTo actionWithDuration:1 scale:1];
		id finish = [CCCallFuncN actionWithTarget:self selector:@selector(removeSprite:)];
		id seq0 = [CCSequence actions:move, rotate, scale, opacity, fadein, scaleback, finish, nil];
		id seq1 = [[seq0 copy] autorelease];
		id seq2 = [[seq0 copy] autorelease];
		id seq3 = [[seq0 copy] autorelease];

		[tile0 runAction:seq0];
		[tile1 runAction:seq1];
		[tile2 runAction:seq2];
		[tile3 runAction:seq3];


		gid = [layer tileGIDAt:ccp(0,63)];
		NSLog(@"Tile GID at:(0,63) is: %d", gid);

		[self schedule:@selector(updateCol:) interval:2.0f];
		[self schedule:@selector(repaintWithGID:) interval:2.05f];
		[self schedule:@selector(removeTiles:) interval:1];


		NSLog(@"++++atlas quantity: %u", (unsigned int) [[layer textureAtlas] totalQuads]);
		NSLog(@"++++children: %u", (unsigned int) [[layer children] count]);

		gid2 = 0;

	}
	return self;
}

-(void) removeSprite:(id) sender
{
	NSLog(@"removing tile: %@", sender);
	id p = [sender parent];
	[p removeChild:sender cleanup:YES];
	NSLog(@"atlas quantity: %u", (unsigned int) [[p textureAtlas] totalQuads]);
}

-(void) updateCol:(ccTime)dt
{
	id map = [self getChildByTag:kTagTileMap];
	CCTMXLayer *layer = (CCTMXLayer*) [map getChildByTag:0];

	NSLog(@"++++atlas quantity: %u", (unsigned int) [[layer textureAtlas] totalQuads]);
	NSLog(@"++++children: %u", (unsigned int) [[layer children] count]);

	CGSize s = [layer layerSize];
	for( int y=0; y< s.height; y++ ) {
		[layer setTileGID:gid2 at:ccp(3,y)];
	}
	gid2 = (gid2 + 1) % 80;
}
-(void) repaintWithGID:(ccTime)dt
{
//	[self unschedule:_cmd];

	id map = [self getChildByTag:kTagTileMap];
	CCTMXLayer *layer = (CCTMXLayer*) [map getChildByTag:0];

	CGSize s = [layer layerSize];
	for( int x=0; x<s.width;x++) {
		int y = s.height-1;
		unsigned int tmpgid = [layer tileGIDAt:ccp(x,y)];
		[layer setTileGID:tmpgid+1 at:ccp(x,y)];
	}
}

-(void) removeTiles:(ccTime)dt
{
	[self unschedule:_cmd];

	id map = [self getChildByTag:kTagTileMap];
	CCTMXLayer *layer = (CCTMXLayer*) [map getChildByTag:0];
	CGSize s = [layer layerSize];
	for( int y=0; y< s.height; y++ ) {
		[layer removeTileAt:ccp(5,y)];
	}

}

-(NSString *) title
{
	return @"TMX Read/Write test";
}
@end

#pragma mark -
#pragma mark TMXTilesetTest

@implementation TMXTilesetTest
-(id) init
{
	if( (self=[super init]) ) {

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test5.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		CCTMXLayer *layer;
		layer = [map layerNamed:@"Layer 0"];
		[layer.texture setAntiAliasTexParameters];

		layer = [map layerNamed:@"Layer 1"];
		[layer.texture setAntiAliasTexParameters];

		layer = [map layerNamed:@"Layer 2"];
		[layer.texture setAntiAliasTexParameters];

	}
	return self;
}

-(NSString *) title
{
	return @"TMX Tileset test";
}
@end

#pragma mark -
#pragma mark TMXOrthoObjectsTest

@implementation TMXOrthoObjectsTest
-(id) init
{
	if( (self=[super init]) ) {

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/ortho-objects.tmx"];
		[self addChild:map z:-1 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		NSLog(@"----> Iterating over all the group objets");
		CCTMXObjectGroup *group = [map objectGroupNamed:@"Object Group 1"];
		for( NSDictionary *dict in group.objects) {
			NSLog(@"object: %@", dict);
		}

		NSLog(@"----> Fetching 1 object by name");
		NSDictionary *platform = [group objectNamed:@"platform"];
		NSLog(@"platform: %@", platform);
	}
	return self;
}

-(void) draw
{
	CCTMXTiledMap *map = (CCTMXTiledMap*) [self getChildByTag:kTagTileMap];
	CCTMXObjectGroup *group = [map objectGroupNamed:@"Object Group 1"];
	for( NSDictionary *dict in group.objects) {
		int x = [[dict objectForKey:@"x"] intValue];
		int y = [[dict objectForKey:@"y"] intValue];
		int width = [[dict objectForKey:@"width"] intValue];
		int height = [[dict objectForKey:@"height"] intValue];

		glLineWidth(3);

		ccDrawLine( ccp(x,y), ccp(x+width,y) );
		ccDrawLine( ccp(x+width,y), ccp(x+width,y+height) );
		ccDrawLine( ccp(x+width,y+height), ccp(x,y+height) );
		ccDrawLine( ccp(x,y+height), ccp(x,y) );


		glLineWidth(1);
	}
}

-(NSString *) title
{
	return @"TMX Ortho object test";
}

-(NSString*) subtitle
{
	return @"You should see a white box around the 3 platforms";
}
@end

#pragma mark -
#pragma mark TMXIsoObjectsTest

@implementation TMXIsoObjectsTest
-(id) init
{
	if( (self=[super init]) ) {

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test-objectgroup.tmx"];
		[self addChild:map z:-1 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		CCTMXObjectGroup *group = [map objectGroupNamed:@"Object Group 1"];
		for( NSDictionary *dict in group.objects) {
			NSLog(@"object: %@", dict);
		}
	}
	return self;
}

-(void) draw
{
	CCTMXTiledMap *map = (CCTMXTiledMap*) [self getChildByTag:kTagTileMap];
	CCTMXObjectGroup *group = [map objectGroupNamed:@"Object Group 1"];
	for( NSDictionary *dict in group.objects) {
		int x = [[dict objectForKey:@"x"] intValue];
		int y = [[dict objectForKey:@"y"] intValue];
		int width = [[dict objectForKey:@"width"] intValue];
		int height = [[dict objectForKey:@"height"] intValue];

		glLineWidth(3);

		ccDrawLine( ccp(x,y), ccp(x+width,y) );
		ccDrawLine( ccp(x+width,y), ccp(x+width,y+height) );
		ccDrawLine( ccp(x+width,y+height), ccp(x,y+height) );
		ccDrawLine( ccp(x,y+height), ccp(x,y) );


		glLineWidth(1);
	}
}

-(NSString *) title
{
	return @"TMX Iso object test";
}

-(NSString*) subtitle
{
	return @"You need to parse them manually. See bug #810";
}
@end

#pragma mark -
#pragma mark TMXGIDObjectsTest

@implementation TMXGIDObjectsTest
-(id) init
{
	if( (self=[super init]) ) {

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/test-object-layer.tmx"];
		[self addChild:map z:-1 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		NSLog(@"----> Iterating over all the group objets");
		CCTMXObjectGroup *group = [map objectGroupNamed:@"Object Group 1"];
		for( NSDictionary *dict in group.objects) {
			NSLog(@"object: %@", dict);
		}
	}
	return self;
}

-(void) draw
{
	CCTMXTiledMap *map = (CCTMXTiledMap*) [self getChildByTag:kTagTileMap];
	CCTMXObjectGroup *group = [map objectGroupNamed:@"Object Group 1"];
	for( NSDictionary *dict in group.objects) {
		int x = [[dict objectForKey:@"x"] intValue];
		int y = [[dict objectForKey:@"y"] intValue];
		int width = [[dict objectForKey:@"width"] intValue];
		int height = [[dict objectForKey:@"height"] intValue];

		glLineWidth(3);

		ccDrawLine( ccp(x,y), ccp(x+width,y) );
		ccDrawLine( ccp(x+width,y), ccp(x+width,y+height) );
		ccDrawLine( ccp(x+width,y+height), ccp(x,y+height) );
		ccDrawLine( ccp(x,y+height), ccp(x,y) );


		glLineWidth(1);
	}
}

-(NSString *) title
{
	return @"TMX GID objects";
}

-(NSString*) subtitle
{
	return @"Tiles are created from an object group";
}
@end


#pragma mark -
#pragma mark TMXTilePropertyTest

@implementation TMXTilePropertyTest
-(id) init
{
	if( (self = [super init]) ){
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/ortho-tile-property.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		for(int i=1;i<=20;i++){
			NSLog(@"GID:%i, Properties:%@", i, [map propertiesForGID:i]);
		}
	}
	return self;
}

-(NSString *) title
{
	return @"TMX Tile Property Test";
}
-(NSString*) subtitle
{
	return @"In the console you should see tile properties";
}
@end

#pragma mark -
#pragma mark TMXResizeTest

@implementation TMXResizeTest
-(id) init
{
	if( (self=[super init]) ) {

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test5.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		CCTMXLayer *layer;
		layer = [map layerNamed:@"Layer 0"];

		CGSize ls = [layer layerSize];
		for (NSUInteger y = 0; y < ls.height; y++) {
			for (NSUInteger x = 0; x < ls.width; x++) {
				[layer setTileGID:1  at:ccp( x, y )];
			}
		}
	}
	return self;
}

-(NSString *) title
{
	return @"TMX resize test";
}

-(NSString *) subtitle
{
	return @"Should not crash. Testing issue #740";
}
@end

#pragma mark -
#pragma mark TMXIsoZorder

@implementation TMXIsoZorder
-(id) init
{
	if( (self=[super init]) ) {

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test-zorder.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		[map setPosition:ccp(-s.width/2,0)];

		tamara = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		[map addChild:tamara z: [[map children] count]];
		[tamara retain];
		int mapWidth = map.mapSize.width * map.tileSize.width;
		//[tamara setPositionInPixels:ccp( mapWidth/2,0)];

        [tamara setPosition:CC_POINT_PIXELS_TO_POINTS(ccp( mapWidth/2,0))];
		[tamara setAnchorPoint:ccp(0.5f,0)];


		id move = [CCMoveBy actionWithDuration:10 position:ccp(300,250)];
		id back = [move reverse];
		id seq = [CCSequence actions:move, back, nil];
		[tamara runAction: [CCRepeatForever actionWithAction:seq]];

		[self schedule:@selector(repositionSprite:)];

	}
	return self;
}

-(void) dealloc
{
	[tamara release];
	[super dealloc];
}

-(void) repositionSprite:(ccTime)dt
{
	CGPoint p =[tamara position];
    p = CC_POINT_POINTS_TO_PIXELS(p);

	CCNode *map = [self getChildByTag:kTagTileMap];

	// there are only 4 layers. (grass and 3 trees layers)
	// if tamara < 48, z=4
	// if tamara < 96, z=3
	// if tamara < 144,z=2

	int newZ = 4 - (p.y / 48);
	newZ = MAX(newZ,0);

	[map reorderChild:tamara z:newZ];
}

-(NSString *) title
{
	return @"TMX Iso Zorder";
}

-(NSString *) subtitle
{
	return @"Sprite should hide behind the trees";
}
@end

#pragma mark -
#pragma mark TMXOrthoZorder

@implementation TMXOrthoZorder
-(id) init
{
	if( (self=[super init]) ) {

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test-zorder.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		tamara = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		[map addChild:tamara z: [[map children] count]];
		[tamara retain];
		[tamara setAnchorPoint:ccp(0.5f,0)];


		id move = [CCMoveBy actionWithDuration:10 position:ccp(400,450)];
		id back = [move reverse];
		id seq = [CCSequence actions:move, back, nil];
		[tamara runAction: [CCRepeatForever actionWithAction:seq]];

		[self schedule:@selector(repositionSprite:)];

	}
	return self;
}

-(void) dealloc
{
	[tamara release];
	[super dealloc];
}

-(void) repositionSprite:(ccTime)dt
{
	CGPoint p = [tamara position];
    p = CC_POINT_POINTS_TO_PIXELS(p);
	CCNode *map = [self getChildByTag:kTagTileMap];

	// there are only 4 layers. (grass and 3 trees layers)
	// if tamara < 81, z=4
	// if tamara < 162, z=3
	// if tamara < 243,z=2

	// -10: customization for this particular sample
	int newZ = 4 - ( (p.y-10) / 81);
	newZ = MAX(newZ,0);

	[map reorderChild:tamara z:newZ];
}

-(NSString *) title
{
	return @"TMX Ortho Zorder";
}

-(NSString *) subtitle
{
	return @"Sprite should hide behind the trees";
}
@end

#pragma mark - TMXIsoVertexZ

@implementation TMXIsoVertexZ
-(id) init
{
	if( (self=[super init]) ) {

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test-vertexz.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		[map setPosition:ccp(-s.width/2,0)];

		// because I'm lazy, I'm reusing a tile as an sprite, but since this method uses vertexZ, you
		// can use any CCSprite and it will work OK.
		CCTMXLayer *layer = [map layerNamed:@"Trees"];
		tamara = [layer tileAt:ccp(29,29)];
		[tamara retain];

		id move = [CCMoveBy actionWithDuration:10 position:ccpMult( ccp(300,250), 1/CC_CONTENT_SCALE_FACTOR() ) ];
		id back = [move reverse];
		id seq = [CCSequence actions:move, back, nil];
		[tamara runAction: [CCRepeatForever actionWithAction:seq]];

		[self schedule:@selector(repositionSprite:)];

	}
	return self;
}

-(void) dealloc
{
	[tamara release];
	[super dealloc];
}

-(void) repositionSprite:(ccTime)dt
{
	// tile height is 64x32
	// map size: 30x30
	CGPoint p = [tamara position];
	p = CC_POINT_POINTS_TO_PIXELS(p);
	float newZ = -(p.y+32) /16;
	[tamara setVertexZ: newZ];
}

-(void) onEnter
{
	[super onEnter];

	// TIP: 2d projection should be used
	[[CCDirector sharedDirector] setProjection:kCCDirectorProjection2D];
}

-(void) onExit
{
	// At exit use any other projection.
	//	[[CCDirector sharedDirector] setProjection:kCCDirectorProjection3D];
	[super onExit];
}

-(NSString *) title
{
	return @"TMX Iso VertexZ";
}

-(NSString *) subtitle
{
	return @"Sprite should hide behind the trees";
}
@end

#pragma mark - TMXOrthoVertexZ

@implementation TMXOrthoVertexZ
-(id) init
{
	if( (self=[super init]) ) {

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test-vertexz.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		// because I'm lazy, I'm reusing a tile as an sprite, but since this method uses vertexZ, you
		// can use any CCSprite and it will work OK.
		CCTMXLayer *layer = [map layerNamed:@"trees"];

		tamara = [layer tileAt:ccp(0,11)];
		NSLog(@"%@ vertexZ: %f", tamara, tamara.vertexZ);
		[tamara retain];

		id move = [CCMoveBy actionWithDuration:10 position:ccpMult( ccp(400,450), 1/CC_CONTENT_SCALE_FACTOR()) ];
		id back = [move reverse];
		id seq = [CCSequence actions:move, back, nil];
		[tamara runAction: [CCRepeatForever actionWithAction:seq]];

		[self schedule:@selector(repositionSprite:)];

	}
	return self;
}

-(void) dealloc
{
	[tamara release];
	[super dealloc];
}

-(void) repositionSprite:(ccTime)dt
{
	// tile height is 101x81
	// map size: 12x12
	CGPoint p = [tamara position];
	p = CC_POINT_POINTS_TO_PIXELS(p);
	[tamara setVertexZ: -( (p.y+81) /81) ];
}

-(void) onEnter
{
	[super onEnter];

	// TIP: 2d projection should be used
	[[CCDirector sharedDirector] setProjection:kCCDirectorProjection2D];
}

-(void) onExit
{
	// At exit use any other projection.
	//	[[CCDirector sharedDirector] setProjection:kCCDirectorProjection3D];
	[super onExit];
}

-(NSString *) title
{
	return @"TMX Ortho vertexZ";
}

-(NSString *) subtitle
{
	return @"Sprite should hide behind the trees";
}
@end

#pragma mark - TMXIsoMoveLayer

@implementation TMXIsoMoveLayer
-(id) init
{
	if( (self=[super init]) ) {

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test-movelayer.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		[map setPosition:ccp(-700,-50)];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

	}
	return self;
}

-(NSString *) title
{
	return @"TMX Iso Move Layer";
}

-(NSString *) subtitle
{
	return @"Trees should be horizontally aligned";
}
@end

#pragma mark -
#pragma mark TMXOrthoMoveLayer

@implementation TMXOrthoMoveLayer
-(id) init
{
	if( (self=[super init]) ) {

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test-movelayer.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

	}
	return self;
}

-(NSString *) title
{
	return @"TMX Ortho Move Layer";
}

-(NSString *) subtitle
{
	return @"Trees should be horizontally aligned";
}
@end

#pragma mark -
#pragma mark TMXOrthoFlipTest

@implementation TMXOrthoFlipTest
-(id) init
{
	if( (self=[super init]) ) {
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/ortho-rotation-test.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		for( CCSpriteBatchNode* child in [map children] ) {
			[[child texture] setAntiAliasTexParameters];
		}

		id action = [CCScaleBy actionWithDuration:2 scale:0.5f];
		[map runAction:action];
	}
	return self;
}

-(NSString *) title
{
	return @"TMX tile flip test";
}
@end

#pragma mark -
#pragma mark TMXOrthoFlipRunTimeTest

@implementation TMXOrthoFlipRunTimeTest
-(id) init
{
	if( (self=[super init]) ) {		
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/ortho-rotation-test.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		for( CCSpriteBatchNode* child in [map children] ) {
			[[child texture] setAntiAliasTexParameters];
		}
		
		id action = [CCScaleBy actionWithDuration:2 scale:0.5f];
		[map runAction:action];
		
		[self schedule:@selector(flipIt:) interval:1];
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX tile flip run time test";
}

-(NSString *) subtitle
{
	return @"in 2 sec bottom left tiles will flip";
}

- (void) flipIt:(ccTime)dt
{
	CCTMXTiledMap *map = (CCTMXTiledMap*) [self getChildByTag:kTagTileMap]; 
	CCTMXLayer *layer = [map layerNamed:@"Layer 0"]; 
	
	//blue diamond 
	CGPoint tileCoord = ccp(1,10);
	ccTMXTileFlags flags;
	uint32_t GID = [layer tileGIDAt:tileCoord withFlags:&flags];
	// Vertical
	if( flags & kCCTMXTileVerticalFlag )
		flags &= ~kCCTMXTileVerticalFlag;
	else
		flags |= kCCTMXTileVerticalFlag;
	[layer setTileGID:GID  at:tileCoord withFlags:flags];
	
	
	tileCoord = ccp(1,8);	
	GID = [layer tileGIDAt:tileCoord withFlags:&flags];
	// Vertical
	if( flags & kCCTMXTileVerticalFlag )
		flags &= ~kCCTMXTileVerticalFlag;
	else
		flags |= kCCTMXTileVerticalFlag;	
	[layer setTileGID:GID at:tileCoord withFlags:flags];

	
	tileCoord = ccp(2,8);
	GID = [layer tileGIDAt:tileCoord withFlags:&flags];
	// Horizontal
	if( flags & kCCTMXTileHorizontalFlag )
		flags &= ~kCCTMXTileHorizontalFlag;
	else
		flags |= kCCTMXTileHorizontalFlag;	
	[layer setTileGID:GID at:tileCoord withFlags:flags];	
}
@end



#pragma mark -
#pragma mark TMXOrthoFromXMLTest

@implementation TMXOrthoFromXMLTest
-(id) init
{
	if( (self=[super init]) ) {
		NSString* resources = @"TileMaps";		// partial paths are OK as resource paths.
		NSString* file = [resources stringByAppendingPathComponent:@"orthogonal-test1.tmx"];
		NSError* error = nil;
		NSString* str = [NSString stringWithContentsOfFile:[[CCFileUtils sharedFileUtils] fullPathForFilename:file] encoding:NSUTF8StringEncoding error:&error];
		NSAssert3(!error, @"Unable to open file %@, %@ (%ld)", file, [error localizedDescription], (long)[error code]);

		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithXML:str resourcePath:resources];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		for( CCSpriteBatchNode* child in [map children] ) {
			[[child texture] setAntiAliasTexParameters];
		}

		id action = [CCScaleBy actionWithDuration:2 scale:0.5f];
		[map runAction:action];
	}
	return self;
}

-(NSString *) title
{
	return @"TMX created from XML test";
}
@end


#pragma mark -
#pragma mark TMXBug987

@implementation TMXBug987
-(id) init
{
	if( (self=[super init]) ) {
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/orthogonal-test6.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s1 = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s1.width,s1.height);

		for( CCSpriteBatchNode* child in [map children] ) {
			[[child texture] setAntiAliasTexParameters];
		}

		[map setAnchorPoint:ccp(0, 0)];

		CCTMXLayer *layer = [map layerNamed:@"Tile Layer 1"];

		[layer setTileGID:3 at:ccp(2,2)];
	}
	return self;
}

-(NSString *) title
{
	return @"TMX Bug 987";
}
-(NSString *) subtitle
{
	return @"You should see an square";
}

@end

#pragma mark -
#pragma mark TMXBug787

@implementation TMXBug787
-(id) init
{
	if( (self=[super init]) ) {
		CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMaps/iso-test-bug787.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		map.scale = 0.25f;
	}
	return self;
}

-(NSString *) title
{
	return @"TMX Bug 787";
}
-(NSString *) subtitle
{
	return @"You should see a map";
}

@end

// CLASS IMPLEMENTATIONS

#pragma mark -
#pragma mark AppController - iPhone

#ifdef __CC_PLATFORM_IOS

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Don't call super
	// Init the window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


	// Create an CCGLView with a RGB8 color buffer, and a depth buffer of 24-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:GL_DEPTH_COMPONENT24_OES
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

	// for rotation and other messages
	[director_ setDelegate:self];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director setProjection:kCCDirectorProjection3D];


	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;

	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];

	// make main window visible
	[window_ makeKeyAndVisible];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
//	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

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
		[scene addChild: [nextAction() node]];
		[director runWithScene:scene];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end

#pragma mark -
#pragma mark AppController - Mac

#elif defined(__CC_PLATFORM_MAC)

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// don't call super. Window is created manually
//	[super applicationDidFinishLaunching:aNotification];

	CGSize winSize = CGSizeMake(640,480);

	//
	// CC_DIRECTOR_INIT:
	// 1. It will create an NSWindow with a given size
	// 2. It will create a CCGLView and it will associate it with the NSWindow
	// 3. It will register the CCGLView to the CCDirector
	//
	// If you want to create a fullscreen window, you should do it AFTER calling this macro
	//
	CC_DIRECTOR_INIT(winSize);

	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	[director_ setResizeMode:kCCDirectorResize_AutoScale];

	//
	// Run all the test with 2d projection
	//
	[director_ setProjection:kCCDirectorProjection2D];

    [director_ setDisplayStats:YES];

	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];

	[director_ runWithScene:scene];
}
@end
#endif

