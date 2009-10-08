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

#import "TMXTiledMap.h"
#import "TMXXMLParser.h"
#import "AtlasSprite.h"
#import "TextureMgr.h"
#import "Support/CGPointExtension.h"

#pragma mark -
#pragma mark TMXLayer

@interface TMXLayer (Private)
-(CGPoint) positionForIsoAt:(CGPoint)pos;
-(CGPoint) positionForOrthoAt:(CGPoint)pos;
-(CGPoint) positionForHexAt:(CGPoint)pos;

// optimizations
-(AtlasSprite*) appendTileForGID:(unsigned int)gid at:(CGPoint)pos;
-(AtlasSprite*) insertTileForGID:(unsigned int)gid at:(CGPoint)pos;
-(unsigned int) atlasIndexForZ:(unsigned int)z;
@end

@implementation TMXLayer
@synthesize layerSize = layerSize_, layerName = layerName_, tiles=tiles_;
@synthesize tileset=tileset_;
@synthesize layerOrientation=layerOrientation_;
@synthesize mapTileSize=mapTileSize_;

+(id) layerWithTilesetInfo:(TMXTilesetInfo*)tilesetInfo layerInfo:(TMXLayerInfo*)layerInfo mapInfo:(TMXMapInfo*)mapInfo
{
	return [[[self alloc] initWithTilesetInfo:tilesetInfo layerInfo:layerInfo mapInfo:mapInfo] autorelease];
}

-(id) initWithTilesetInfo:(TMXTilesetInfo*)tilesetInfo layerInfo:(TMXLayerInfo*)layerInfo mapInfo:(TMXMapInfo*)mapInfo
{	
	// XXX: is 35% a good estimate ?
	CGSize size = layerInfo.layerSize;
	float totalNumberOfTiles = size.width * size.height;
	float capacity = totalNumberOfTiles * 0.35f + 1; // 35 percent is occupied ?
	
	Texture2D *tex = nil;
	if( tilesetInfo )
		tex = [[TextureMgr sharedTextureMgr] addImage:tilesetInfo.sourceImage];
	
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

#pragma mark TMXLayer - obtaining tiles/gids

-(AtlasSprite*) tileAt:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y <= layerSize_.height, @"TMXLayer: invalid position");
	
	AtlasSprite *tile = nil;
	unsigned int gid = [self tileGIDAt:pos];
	
	// if GID == 0, then no tile is present
	if( gid ) {
		int z = pos.x + pos.y * layerSize_.width;
		tile = (AtlasSprite*) [self getChildByTag:z];
		
		// tile not created yet. create it
		if( ! tile ) {
			CGRect rect = [tileset_ tileForGID:gid];			
			tile = [AtlasSprite spriteWithRect:rect spriteManager:self];
			[tile setPosition: [self positionAt:pos]];
			tile.anchorPoint = CGPointZero;
			
			unsigned int indexForZ = [self atlasIndexForZ:z];
			[self addChildWithoutQuad:tile z:indexForZ tag:z];
		}
	}
	return tile;
}

-(unsigned int) tileGIDAt:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y <= layerSize_.height, @"TMXLayer: invalid position");
	NSAssert( tiles_ != NULL, @"TMXLayer: the tiles map has been released");
	
	int idx = pos.x + pos.y * layerSize_.width;
	return tiles_[ idx ];
}

#pragma mark TMXLayer - adding helper methods

-(AtlasSprite*) insertTileForGID:(unsigned int)gid at:(CGPoint)pos
{
	CGRect rect = [tileset_ tileForGID:gid];
	
	int z = pos.x + pos.y * layerSize_.width;
	
	if( ! reusedTile )
		
		reusedTile = [[AtlasSprite spriteWithRect:rect spriteManager:self] retain];
	else
		[reusedTile initWithRect:rect spriteManager:self];
	
	[reusedTile setPosition: [self positionAt:pos]];
	reusedTile.anchorPoint = CGPointZero;
	
	// It needs to objetain the correct position of the texture atlas
	// it takes more time than appending it at the end
	unsigned int indexForZ = [self indexForNewChildAtZ:z];
	
	// don't add it using the "standard" way.
	[self addQuadFromSprite:reusedTile quadIndex:indexForZ];
	
	// append should after addQuadFromSprite since it modifies the quantity values
	ccCArrayInsertValueAtIndex(atlasIndexArray, (void*)z, indexForZ);
	
	// update possible children
	for( AtlasSprite *sprite in children) {
		unsigned int ai = [sprite atlasIndex];
		if( ai >= indexForZ)
			[sprite setAtlasIndex: ai+1];
	}
	
	return reusedTile;
}

-(AtlasSprite*) appendTileForGID:(unsigned int)gid at:(CGPoint)pos
{
	CGRect rect = [tileset_ tileForGID:gid];
	
	int z = pos.x + pos.y * layerSize_.width;
	
	if( ! reusedTile )
		reusedTile = [[AtlasSprite spriteWithRect:rect spriteManager:self] retain];
	else
		[reusedTile initWithRect:rect spriteManager:self];
	
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

int compareInts (const void * a, const void * b)
{
	return ( *(int*)a - *(int*)b );
}

-(unsigned int) atlasIndexForZ:(unsigned int)z
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

-(NSUInteger)indexForNewChildAtZ:(int)z
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

#pragma mark TMXLayer - adding / remove tiles

-(void) setTileGID:(unsigned int)gid at:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y <= layerSize_.height, @"TMXLayer: invalid position");
	NSAssert( tiles_ != NULL, @"TMXLayer: the tiles map has been released");
	
	unsigned int currentGID = [self tileGIDAt:pos];
	
	if( currentGID != gid ) {
		AtlasSprite *tile = [self tileAt:pos];
		if( ! tile ) {
			[self insertTileForGID:gid at:pos];
		} else {
			CGRect rect = [tileset_ tileForGID:gid];
			[tile setTextureRect:rect];
		}
		
		// update gid on map
		int idx = pos.x + pos.y * layerSize_.width;
		tiles_[ idx ] = gid;
	}
}

-(void) removeTileAt:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y <= layerSize_.height, @"TMXLayer: invalid position");

	unsigned int gid = [self tileGIDAt:pos];
	
	if( gid ) {
		
		unsigned int z = pos.x + pos.y * layerSize_.width;
		unsigned atlasIndex = [self atlasIndexForZ:z];
		
		// remove tile from GID map
		tiles_[z] = 0;

		// remove tile from atlas position array
		ccCArrayRemoveValue(atlasIndexArray, (void*) z);
		
		// remove it from sprites and/or texture atlas
		id sprite = [self getChildByTag:z];
		if( sprite )
			[self removeChildByTag:z cleanup:YES];
		else {
			[textureAtlas_ removeQuadAtIndex:atlasIndex];
		}
	}
}

#pragma mark TMXLayer - obtaining positions

-(CGPoint) positionAt:(CGPoint)pos
{
	CGPoint ret = CGPointZero;
	switch( layerOrientation_ ) {
		case TMXOrientationOrtho:
			ret = [self positionForOrthoAt:pos];
			break;
		case TMXOrientationIso:
			ret = [self positionForIsoAt:pos];
			break;
		case TMXOrientationHex:
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
#pragma mark TMXTiledMap

@interface TMXTiledMap (Private)
-(id) parseLayer:(TMXLayerInfo*)layer map:(TMXMapInfo*)mapInfo;
-(TMXTilesetInfo*) tilesetForLayer:(TMXLayerInfo*)layerInfo map:(TMXMapInfo*)mapInfo;
@end

@implementation TMXTiledMap
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

		TMXMapInfo *mapInfo = [TMXMapInfo formatWithTMXFile:tmxFile];
		
		NSAssert( [mapInfo.tilesets count] != 0, @"TMXTiledMap: Map not found. Please check the filename.");
		
		mapSize_ = mapInfo.mapSize;
		tileSize_ = mapInfo.tileSize;
		mapOrientation_ = mapInfo.orientation;
				
		int idx=0;

		for( TMXLayerInfo *layerInfo in mapInfo.layers ) {
			
			NSLog(@"parsing layer: %@", layerInfo.name);

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
-(id) parseLayer:(TMXLayerInfo*)layerInfo map:(TMXMapInfo*)mapInfo
{
	TMXTilesetInfo *tileset = [self tilesetForLayer:layerInfo map:mapInfo];
	TMXLayer *layer = [TMXLayer layerWithTilesetInfo:tileset layerInfo:layerInfo mapInfo:mapInfo];

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
	
	NSAssert( layerInfo.maxGID >= tileset.firstGid &&
			 layerInfo.minGID >= tileset.firstGid, @"TMX: Only 1 tilset per layer is supported");
	
	return layer;
}

-(TMXTilesetInfo*) tilesetForLayer:(TMXLayerInfo*)layerInfo map:(TMXMapInfo*)mapInfo
{
	TMXTilesetInfo *tileset = nil;
	CFByteOrder o = CFByteOrderGetCurrent();
	
	CGSize size = layerInfo.layerSize;

	id iter = [mapInfo.tilesets reverseObjectEnumerator];
	for( TMXTilesetInfo* tileset in iter) {
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

-(TMXLayer*) layerNamed:(NSString *)layerName 
{
	for( TMXLayer *layer in children ) {
		if( [layer.layerName isEqual:layerName] )
			return layer;
	}
	
	// layer not found
	return nil;
}
@end

