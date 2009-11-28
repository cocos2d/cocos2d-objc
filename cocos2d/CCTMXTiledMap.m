/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 * TMX Tiled Map support:
 * http://www.mapeditor.org
 *
 */

#import "CCTMXTiledMap.h"
#import "CCTMXXMLParser.h"
#import "CCSprite.h"
#import "CCSpriteSheet.h"
#import "CCTextureCache.h"
#import "Support/CGPointExtension.h"

#pragma mark -
#pragma mark CCSpriteSheet extension

@interface CCSpriteSheet (TileMapExtension)

/* Adds a quad into the texture atlas but it won't be added into the children array.
 This method should be called only when you are dealing with very big AtlasSrite and when most of the CCSprite won't be updated.
 For example: a tile map (CCTMXMap) or a label with lots of characgers (BitmapFontAtlas)
 @since v0.8.2
 */
-(void) addQuadFromSprite:(CCSprite*)sprite quadIndex:(unsigned int)index;

-(id)addSpriteWithoutQuad:(CCSprite*)child z:(int)z tag:(int)aTag;
@end

@implementation CCSpriteSheet (TileMapExtension)
-(void) addQuadFromSprite:(CCSprite*)sprite quadIndex:(unsigned int)index
{
	NSAssert( sprite != nil, @"Argument must be non-nil");
	NSAssert( [sprite isKindOfClass:[CCSprite class]], @"CCSpriteSheet only supports CCSprites as children");
	
	while(index >= textureAtlas_.capacity)
		[self increaseAtlasCapacity];

	[self insertChild:sprite inAtlasAtIndex:index];
	[sprite updateTransform];
}

-(id) addSpriteWithoutQuad:(CCSprite*)child z:(int)z tag:(int)aTag
{
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( [child isKindOfClass:[CCSprite class]], @"CCSpriteSheet only supports CCSprites as children");
	
	// quad index is Z
	[child setAtlasIndex:z];
	[descendants_ insertObject:child atIndex:z];
	[super addChild:child z:z tag:aTag];
	return self;	
}
@end


#pragma mark -
#pragma mark CCTMXLayer

@interface CCTMXLayer (Private)
-(CGPoint) positionForIsoAt:(CGPoint)pos;
-(CGPoint) positionForOrthoAt:(CGPoint)pos;
-(CGPoint) positionForHexAt:(CGPoint)pos;

// optimizations
-(CCSprite*) appendTileForGID:(unsigned int)gid at:(CGPoint)pos;
-(CCSprite*) insertTileForGID:(unsigned int)gid at:(CGPoint)pos;
-(CCSprite*) udpateTileForGID:(unsigned int)gid at:(CGPoint)pos;
-(unsigned int) atlasIndexForExistantZ:(unsigned int)z;
-(unsigned int) atlasIndexForNewZ:(int)z;
@end

@implementation CCTMXLayer
@synthesize layerSize = layerSize_, layerName = layerName_, tiles=tiles_;
@synthesize tileset=tileset_;
@synthesize layerOrientation=layerOrientation_;
@synthesize mapTileSize=mapTileSize_;

+(id) layerWithTilesetInfo:(CCTMXTilesetInfo*)tilesetInfo layerInfo:(CCTMXLayerInfo*)layerInfo mapInfo:(CCTMXMapInfo*)mapInfo
{
	return [[[self alloc] initWithTilesetInfo:tilesetInfo layerInfo:layerInfo mapInfo:mapInfo] autorelease];
}

-(id) initWithTilesetInfo:(CCTMXTilesetInfo*)tilesetInfo layerInfo:(CCTMXLayerInfo*)layerInfo mapInfo:(CCTMXMapInfo*)mapInfo
{	
	// XXX: is 35% a good estimate ?
	CGSize size = layerInfo.layerSize;
	float totalNumberOfTiles = size.width * size.height;
	float capacity = totalNumberOfTiles * 0.35f + 1; // 35 percent is occupied ?
	
	CCTexture2D *tex = nil;
	if( tilesetInfo )
		tex = [[CCTextureCache sharedTextureCache] addImage:tilesetInfo.sourceImage];
	
	if((self=[super initWithTexture:tex capacity:capacity])) {		
		self.layerName = layerInfo.name;
		self.layerSize = layerInfo.layerSize;
		self.tiles = layerInfo.tiles;
		self.tileset = tilesetInfo;
		self.mapTileSize = mapInfo.tileSize;
		self.layerOrientation = mapInfo.orientation;
		
		atlasIndexArray = ccCArrayNew(totalNumberOfTiles);
		
		[self setContentSize: CGSizeMake( layerSize_.width * mapTileSize_.width, layerSize_.height * mapTileSize_.height )];

	}
	return self;
}

- (void) dealloc
{
	[layerName_ release];
	[tileset_ release];
	[reusedTile release];
	
	if( atlasIndexArray ) {
		ccCArrayFree(atlasIndexArray);
		atlasIndexArray = NULL;
	}
	
	if( tiles_ ) {
		free(tiles_);
		tiles_ = NULL;
	}
	
	[super dealloc];
}

-(void) releaseMap
{
	if( tiles_) {
		free( tiles_);
		tiles_ = NULL;
	}
	
	if( atlasIndexArray ) {
		ccCArrayFree(atlasIndexArray);
		atlasIndexArray = NULL;
	}
}

#pragma mark CCTMXLayer - obtaining tiles/gids

-(CCSprite*) tileAt:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y <= layerSize_.height, @"TMXLayer: invalid position");
	NSAssert( tiles_ && atlasIndexArray, @"TMXLayer: the tiles map has been released");
	
	CCSprite *tile = nil;
	unsigned int gid = [self tileGIDAt:pos];
	
	// if GID == 0, then no tile is present
	if( gid ) {
		int z = pos.x + pos.y * layerSize_.width;
		tile = (CCSprite*) [self getChildByTag:z];
		
		// tile not created yet. create it
		if( ! tile ) {
			CGRect rect = [tileset_ rectForGID:gid];			
			tile = [self createSpriteWithRect:rect];
			[tile setPosition: [self positionAt:pos]];
			tile.anchorPoint = CGPointZero;
			
			unsigned int indexForZ = [self atlasIndexForExistantZ:z];
			[self addSpriteWithoutQuad:tile z:indexForZ tag:z];
		}
	}
	return tile;
}

-(unsigned int) tileGIDAt:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y <= layerSize_.height, @"TMXLayer: invalid position");
	NSAssert( tiles_ && atlasIndexArray, @"TMXLayer: the tiles map has been released");
	
	int idx = pos.x + pos.y * layerSize_.width;
	return tiles_[ idx ];
}

#pragma mark CCTMXLayer - adding helper methods

-(CCSprite*) insertTileForGID:(unsigned int)gid at:(CGPoint)pos
{
	CGRect rect = [tileset_ rectForGID:gid];
	
	int z = pos.x + pos.y * layerSize_.width;
	
	if( ! reusedTile )
		reusedTile = [[self createSpriteWithRect:rect] retain];
	else
		[self initSprite:reusedTile rect:rect];
	
	[reusedTile setPosition: [self positionAt:pos]];
	reusedTile.anchorPoint = CGPointZero;
	
	// get atlas index
	unsigned int indexForZ = [self atlasIndexForNewZ:z];
	
	// Optimization: add the quad without adding a child
	[self addQuadFromSprite:reusedTile quadIndex:indexForZ];
	
	// insert it into the local atlasindex array
	ccCArrayInsertValueAtIndex(atlasIndexArray, (void*)z, indexForZ);
	
	// update possible children
	for( CCSprite *sprite in children) {
		unsigned int ai = [sprite atlasIndex];
		if( ai >= indexForZ)
			[sprite setAtlasIndex: ai+1];
	}
	
	tiles_[z] = gid;
	
	return reusedTile;
}

-(CCSprite*) updateTileForGID:(unsigned int)gid at:(CGPoint)pos
{
	CGRect rect = [tileset_ rectForGID:gid];
	
	int z = pos.x + pos.y * layerSize_.width;
	
	if( ! reusedTile )
		reusedTile = [[self createSpriteWithRect:rect] retain];
	else
		[self initSprite:reusedTile rect:rect];
	
	[reusedTile setPosition: [self positionAt:pos]];
	reusedTile.anchorPoint = CGPointZero;
	
	// get atlas index
	unsigned int indexForZ = [self atlasIndexForExistantZ:z];

	[reusedTile setAtlasIndex:indexForZ];
	[reusedTile updateTransform];
	tiles_[z] = gid;
	
	return reusedTile;
}


// used only when parsing the map. useless after the map was parsed
// since lot's of assumptions are no longer true
-(CCSprite*) appendTileForGID:(unsigned int)gid at:(CGPoint)pos
{
	CGRect rect = [tileset_ rectForGID:gid];
	
	int z = pos.x + pos.y * layerSize_.width;
	
	if( ! reusedTile )
		reusedTile = [[self createSpriteWithRect:rect] retain];
	else
		[self initSprite:reusedTile rect:rect];
	
	[reusedTile setPosition: [self positionAt:pos]];
	reusedTile.anchorPoint = CGPointZero;
	
	// optimization:
	// The difference between appendTileForGID and insertTileforGID is that append is faster, since
	// it appends the tile at the end of the texture atlas
	unsigned int indexForZ = atlasIndexArray->num;
	
	// don't add it using the "standard" way.
	[self addQuadFromSprite:reusedTile quadIndex:indexForZ];
	
	// append should after addQuadFromSprite since it modifies the quantity values
	ccCArrayInsertValueAtIndex(atlasIndexArray, (void*)z, indexForZ);
	
	return reusedTile;
}

#pragma mark CCTMXLayer - atlasIndex and Z

int compareInts (const void * a, const void * b)
{
	return ( *(int*)a - *(int*)b );
}

-(unsigned int) atlasIndexForExistantZ:(unsigned int)z
{
	int key=z;
	int *item = bsearch((void*)&key, (void*)&atlasIndexArray->arr[0], atlasIndexArray->num, sizeof(void*), compareInts);
	
	if(item ) {
		int index = ((int)item - (int)atlasIndexArray->arr) / sizeof(void*);
		return index;
	}
	
	NSAssert( item, @"TMX atlas index not found. Shall not happen");
	return NSNotFound;
}

-(unsigned int)atlasIndexForNewZ:(int)z
{
	// XXX: This can be improved with a sort of binary search
	unsigned int i=0;
	for( i=0; i< atlasIndexArray->num ; i++) {
		int val = (int) atlasIndexArray->arr[i];
		if( z < val )
			break;
	}	
	return i;
}

#pragma mark CCTMXLayer - adding / remove tiles

-(void) setTileGID:(unsigned int)gid at:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y <= layerSize_.height, @"TMXLayer: invalid position");
	NSAssert( tiles_ && atlasIndexArray, @"TMXLayer: the tiles map has been released");
		
	unsigned int currentGID = [self tileGIDAt:pos];
	
	if( currentGID != gid ) {
		
		if( gid == 0 )
			return [self removeTileAt:pos];

		// empty tile. create a new one
		if( currentGID == 0 ) {
			[self insertTileForGID:gid at:pos];

		} else {

			unsigned int z = pos.x + pos.y * layerSize_.width;
			id sprite = [self getChildByTag:z];
			if( sprite ) {
				CGRect rect = [tileset_ rectForGID:gid];
				[sprite setTextureRect:rect];
				tiles_[z] = gid;
			} else {
				[self updateTileForGID:gid at:pos];
			}
		}
	}
}

-(void) removeTileAt:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y <= layerSize_.height, @"TMXLayer: invalid position");
	NSAssert( tiles_ && atlasIndexArray, @"TMXLayer: the tiles map has been released");

	unsigned int gid = [self tileGIDAt:pos];
	
	if( gid ) {
		
		unsigned int z = pos.x + pos.y * layerSize_.width;
		unsigned atlasIndex = [self atlasIndexForExistantZ:z];
		
		// remove tile from GID map
		tiles_[z] = 0;

		// remove tile from atlas position array
		ccCArrayRemoveValueAtIndex(atlasIndexArray, atlasIndex);
		
		// remove it from sprites and/or texture atlas
		id sprite = [self getChildByTag:z];
		if( sprite )
			[self removeChild:sprite cleanup:YES];
		else {
			[textureAtlas_ removeQuadAtIndex:atlasIndex];

			// update possible children
			for( CCSprite *sprite in children) {
				unsigned int ai = [sprite atlasIndex];
				if( ai >= atlasIndex) {
					[sprite setAtlasIndex: ai-1];
				}
			}
		}
	}
}

#pragma mark CCTMXLayer - obtaining positions

-(CGPoint) positionAt:(CGPoint)pos
{
	CGPoint ret = CGPointZero;
	switch( layerOrientation_ ) {
		case CCTMXOrientationOrtho:
			ret = [self positionForOrthoAt:pos];
			break;
		case CCTMXOrientationIso:
			ret = [self positionForIsoAt:pos];
			break;
		case CCTMXOrientationHex:
			ret = [self positionForHexAt:pos];
			break;
	}
	return ret;
}

-(CGPoint) positionForOrthoAt:(CGPoint)pos
{
	int x = pos.x * mapTileSize_.width + 0.49f;
	int y = (layerSize_.height - pos.y - 1) * mapTileSize_.height + 0.49f;
	return ccp(x,y);
}

-(CGPoint) positionForIsoAt:(CGPoint)pos
{
	int x = mapTileSize_.width /2 * ( layerSize_.width + pos.x - pos.y - 1) + 0.49f;
	int y = mapTileSize_.height /2 * (( layerSize_.height * 2 - pos.x - pos.y) - 2) + 0.49f;
	
	//	int x = mapTileSize_.width /2  *(pos.x - pos.y) + 0.49f;
	//	int y = (layerSize_.height - (pos.x + pos.y) - 1) * mapTileSize_.height/2 + 0.49f;
	return ccp(x, y);
}

-(CGPoint) positionForHexAt:(CGPoint)pos
{
	float diffY = 0;
	if( (int)pos.x % 2 == 1 )
		diffY = -mapTileSize_.height/2 ;
	
	int x =  pos.x * mapTileSize_.width*3/4 + 0.49f;
	int y =  (layerSize_.height - pos.y - 1) * mapTileSize_.height + diffY + 0.49f;
	return ccp(x,y);
}
@end

#pragma mark -
#pragma mark CCTMXTiledMap

@interface CCTMXTiledMap (Private)
-(id) parseLayer:(CCTMXLayerInfo*)layer map:(CCTMXMapInfo*)mapInfo;
-(CCTMXTilesetInfo*) tilesetForLayer:(CCTMXLayerInfo*)layerInfo map:(CCTMXMapInfo*)mapInfo;
@end

@implementation CCTMXTiledMap
@synthesize mapSize=mapSize_;
@synthesize tileSize=tileSize_;
@synthesize mapOrientation=mapOrientation_;

+(id) tiledMapWithTMXFile:(NSString*)tmxFile
{
	return [[[self alloc] initWithTMXFile:tmxFile] autorelease];
}

-(id) initWithTMXFile:(NSString*)tmxFile
{
	NSAssert(tmxFile != nil, @"TMXTiledMap: tmx file should not bi nil");

	if ((self=[super init])) {
		
		[self setContentSize:CGSizeZero];

		CCTMXMapInfo *mapInfo = [CCTMXMapInfo formatWithTMXFile:tmxFile];
		
		NSAssert( [mapInfo.tilesets count] != 0, @"TMXTiledMap: Map not found. Please check the filename.");
		
		mapSize_ = mapInfo.mapSize;
		tileSize_ = mapInfo.tileSize;
		mapOrientation_ = mapInfo.orientation;
				
		int idx=0;

		for( CCTMXLayerInfo *layerInfo in mapInfo.layers ) {
			
			if( layerInfo.visible ) {
				id child = [self parseLayer:layerInfo map:mapInfo];
				[self addChild:child z:idx tag:idx];
				
				// update content size with the max size
				CGSize childSize = [child contentSize];
				CGSize currentSize = [self contentSize];
				currentSize.width = MAX( currentSize.width, childSize.width );
				currentSize.height = MAX( currentSize.height, childSize.height );
				[self setContentSize:currentSize];
	
				idx++;
			}			
		}		
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

// private
-(id) parseLayer:(CCTMXLayerInfo*)layerInfo map:(CCTMXMapInfo*)mapInfo
{
	CCTMXTilesetInfo *tileset = [self tilesetForLayer:layerInfo map:mapInfo];
	CCTMXLayer *layer = [CCTMXLayer layerWithTilesetInfo:tileset layerInfo:layerInfo mapInfo:mapInfo];

	// tell the layerinfo to release the ownership of the tiles map.
	layerInfo.ownTiles = NO;

	// Optimization: quick hack that sets the image size on the tileset
	tileset.imageSize = [[layer texture] contentSize];
		
	// By default all the tiles are aliased
	// pros:
	//  - easier to render
	// cons:
	//  - difficult to scale / rotate / etc.
	[[layer texture] setAliasTexParameters];

	CFByteOrder o = CFByteOrderGetCurrent();
	
	CGSize s = layerInfo.layerSize;
	
	for( unsigned int y=0; y < s.height; y++ ) {
		for( unsigned int x=0; x < s.width; x++ ) {

			unsigned int pos = x + s.width * y;
			unsigned int gid = layerInfo.tiles[ pos ];

			// gid are stored in little endian.
			// if host is big endian, then swap
			if( o == CFByteOrderBigEndian )
				gid = CFSwapInt32( gid );
			
			// XXX: gid == 0 --> empty tile
			if( gid != 0 ) {
				[layer appendTileForGID:gid at:ccp(x,y)];
				
				// Optimization: update min and max GID rendered by the layer
				layerInfo.minGID = MIN(gid, layerInfo.minGID);
				layerInfo.maxGID = MAX(gid, layerInfo.maxGID);
			}
		}
	}
	
	// HACK:
	// remove all possible tiles from the dirtySprites set, since they don't need to be updated
//	ccCArrayRemoveAllValues(layer->dirtySprites_);
	
	NSAssert( layerInfo.maxGID >= tileset.firstGid &&
			 layerInfo.minGID >= tileset.firstGid, @"TMX: Only 1 tilset per layer is supported");
	
	return layer;
}

-(CCTMXTilesetInfo*) tilesetForLayer:(CCTMXLayerInfo*)layerInfo map:(CCTMXMapInfo*)mapInfo
{
	CCTMXTilesetInfo *tileset = nil;
	CFByteOrder o = CFByteOrderGetCurrent();
	
	CGSize size = layerInfo.layerSize;

	id iter = [mapInfo.tilesets reverseObjectEnumerator];
	for( CCTMXTilesetInfo* tileset in iter) {
		for( unsigned int y=0; y < size.height; y++ ) {
			for( unsigned int x=0; x < size.width; x++ ) {
				
				unsigned int pos = x + size.width * y;
				unsigned int gid = layerInfo.tiles[ pos ];
				
				// gid are stored in little endian.
				// if host is big endian, then swap
				if( o == CFByteOrderBigEndian )
					gid = CFSwapInt32( gid );
				
				// XXX: gid == 0 --> empty tile
				if( gid != 0 ) {
					
					// Optimization: quick return
					// if the layer is invalid (more than 1 tileset per layer) an assert will be thrown later
					if( gid >= tileset.firstGid )
						return tileset;
				}
			}
		}		
	}
	
	// If all the tiles are 0, return empty tileset
	CCLOG(@"cocos2d: Warning: TMX Layer '%@' has no tiles", layerInfo.name);
	return tileset;
}


// public

-(CCTMXLayer*) layerNamed:(NSString *)layerName 
{
	for( CCTMXLayer *layer in children ) {
		if( [layer.layerName isEqual:layerName] )
			return layer;
	}
	
	// layer not found
	return nil;
}
@end

