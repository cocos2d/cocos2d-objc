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

#import "CCTMXLayer.h"
#import "CCTMXTiledMap.h"
#import "CCTMXXMLParser.h"
#import "CCSprite.h"
#import "CCSpriteSheet.h"
#import "CCTextureCache.h"
#import "Support/CGPointExtension.h"

#pragma mark -
#pragma mark CCSpriteSheet Extension

/* IMPORTANT XXX IMPORTNAT:
 * These 2 methods can't be part of CCTMXLayer since they call [super add...], and CCSpriteSheet#add SHALL not be called
 */
@implementation CCSpriteSheet (TMXTiledMapExtension)

/* Adds a quad into the texture atlas but it won't be added into the children array.
 This method should be called only when you are dealing with very big AtlasSrite and when most of the CCSprite won't be updated.
 For example: a tile map (CCTMXMap) or a label with lots of characgers (BitmapFontAtlas)
 */
-(void) addQuadFromSprite:(CCSprite*)sprite quadIndex:(unsigned int)index
{
	NSAssert( sprite != nil, @"Argument must be non-nil");
	NSAssert( [sprite isKindOfClass:[CCSprite class]], @"CCSpriteSheet only supports CCSprites as children");
	
	
	while(index >= textureAtlas_.capacity || textureAtlas_.capacity == textureAtlas_.totalQuads )
		[self increaseAtlasCapacity];

	//
	// update the quad directly. Don't add the sprite to the scene graph
	//

	[sprite useSpriteSheetRender:self];
	[sprite setAtlasIndex:index];

	ccV3F_C4B_T2F_Quad quad = [sprite quad];
	[textureAtlas_ insertQuad:&quad atIndex:index];
	
	// XXX: updateTransform will update the textureAtlas too using updateQuad.
	// XXX: so, it should be AFTER the insertQuad
	[sprite updateTransform];
}

/* This is the opposite of "addQuadFromSprite.
 It add the sprite to the children and descendants array, but it doesn't update add it to the texture atlas
 */
-(id) addSpriteWithoutQuad:(CCSprite*)child z:(unsigned int)z tag:(int)aTag
{
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( [child isKindOfClass:[CCSprite class]], @"CCSpriteSheet only supports CCSprites as children");
	
	// quad index is Z
	[child setAtlasIndex:z];
	
	// XXX: optimize with a binary search
	int i=0;
	for( CCSprite *c in descendants_ ) {
		if( c.atlasIndex >= z )
			break;
		i++;
	}
	[descendants_ insertObject:child atIndex:i];
	
	
	// IMPORTANT: Call super, and not self. Avoid adding it to the texture atlas array
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

// adding quad from sprite
-(void)addQuadFromSprite:(CCSprite*)sprite quadIndex:(unsigned int)index;

// adds an sprite without the quad
-(id)addSpriteWithoutQuad:(CCSprite*)child z:(int)z tag:(int)aTag;

// index
-(unsigned int) atlasIndexForExistantZ:(unsigned int)z;
-(unsigned int) atlasIndexForNewZ:(int)z;
@end

@implementation CCTMXLayer
@synthesize layerSize = layerSize_, layerName = layerName_, tiles=tiles_;
@synthesize tileset=tileset_;
@synthesize layerOrientation=layerOrientation_;
@synthesize mapTileSize=mapTileSize_;
@synthesize properties=properties_;

#pragma mark CCTMXLayer - init & alloc & dealloc

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
		self.properties = [NSMutableDictionary dictionaryWithDictionary:layerInfo.properties];
		
		atlasIndexArray_ = ccCArrayNew(totalNumberOfTiles);
		
		[self setContentSize: CGSizeMake( layerSize_.width * mapTileSize_.width, layerSize_.height * mapTileSize_.height )];

	}
	return self;
}

- (void) dealloc
{
	[layerName_ release];
	[tileset_ release];
	[reusedTile_ release];
	[properties_ release];
	
	if( atlasIndexArray_ ) {
		ccCArrayFree(atlasIndexArray_);
		atlasIndexArray_ = NULL;
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
	
	if( atlasIndexArray_ ) {
		ccCArrayFree(atlasIndexArray_);
		atlasIndexArray_ = NULL;
	}
}

#pragma mark CCTMXLayer - obtaining tiles/gids

-(CCSprite*) tileAt:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
	NSAssert( tiles_ && atlasIndexArray_, @"TMXLayer: the tiles map has been released");
	
	CCSprite *tile = nil;
	unsigned int gid = [self tileGIDAt:pos];
	
	// if GID == 0, then no tile is present
	if( gid ) {
		int z = pos.x + pos.y * layerSize_.width;
		tile = (CCSprite*) [self getChildByTag:z];
		
		// tile not created yet. create it
		if( ! tile ) {
			CGRect rect = [tileset_ rectForGID:gid];			
			tile = [[CCSprite alloc] initWithSpriteSheet:self rect:rect];
			[tile setPosition: [self positionAt:pos]];
			tile.anchorPoint = CGPointZero;
			
			unsigned int indexForZ = [self atlasIndexForExistantZ:z];
			[self addSpriteWithoutQuad:tile z:indexForZ tag:z];
			[tile release];
		}
	}
	return tile;
}

-(unsigned int) tileGIDAt:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
	NSAssert( tiles_ && atlasIndexArray_, @"TMXLayer: the tiles map has been released");
	
	int idx = pos.x + pos.y * layerSize_.width;
	return tiles_[ idx ];
}

#pragma mark CCTMXLayer - adding helper methods

-(CCSprite*) insertTileForGID:(unsigned int)gid at:(CGPoint)pos
{
	CGRect rect = [tileset_ rectForGID:gid];
	
	int z = pos.x + pos.y * layerSize_.width;
	
	if( ! reusedTile_ )
		reusedTile_ = [[CCSprite alloc] initWithSpriteSheet:self rect:rect];
	else
		[reusedTile_ initWithSpriteSheet:self rect:rect];
	
	[reusedTile_ setPosition: [self positionAt:pos]];
	reusedTile_.anchorPoint = CGPointZero;
	
	// get atlas index
	unsigned int indexForZ = [self atlasIndexForNewZ:z];
	
	// Optimization: add the quad without adding a child
	[self addQuadFromSprite:reusedTile_ quadIndex:indexForZ];
	
	// insert it into the local atlasindex array
	ccCArrayInsertValueAtIndex(atlasIndexArray_, (void*)z, indexForZ);
	
	// update possible children
	for( CCSprite *sprite in children_) {
		unsigned int ai = [sprite atlasIndex];
		if( ai >= indexForZ)
			[sprite setAtlasIndex: ai+1];
	}
	
	tiles_[z] = gid;
	
	return reusedTile_;
}

-(CCSprite*) updateTileForGID:(unsigned int)gid at:(CGPoint)pos
{
	CGRect rect = [tileset_ rectForGID:gid];
	
	int z = pos.x + pos.y * layerSize_.width;
	
	if( ! reusedTile_ )
		reusedTile_ = [[CCSprite alloc] initWithSpriteSheet:self rect:rect];
	else
		[reusedTile_ initWithSpriteSheet:self rect:rect];
	
	[reusedTile_ setPosition: [self positionAt:pos]];
	reusedTile_.anchorPoint = CGPointZero;
	
	// get atlas index
	unsigned int indexForZ = [self atlasIndexForExistantZ:z];

	[reusedTile_ setAtlasIndex:indexForZ];
	[reusedTile_ updateTransform];
	tiles_[z] = gid;
	
	return reusedTile_;
}


// used only when parsing the map. useless after the map was parsed
// since lot's of assumptions are no longer true
-(CCSprite*) appendTileForGID:(unsigned int)gid at:(CGPoint)pos
{
	CGRect rect = [tileset_ rectForGID:gid];
	
	int z = pos.x + pos.y * layerSize_.width;
	
	if( ! reusedTile_ )
		reusedTile_ = [[CCSprite alloc] initWithSpriteSheet:self rect:rect];
	else
		[reusedTile_ initWithSpriteSheet:self rect:rect];
	
	[reusedTile_ setPosition: [self positionAt:pos]];
	reusedTile_.anchorPoint = CGPointZero;
	
	// optimization:
	// The difference between appendTileForGID and insertTileforGID is that append is faster, since
	// it appends the tile at the end of the texture atlas
	unsigned int indexForZ = atlasIndexArray_->num;
	
	// don't add it using the "standard" way.
	[self addQuadFromSprite:reusedTile_ quadIndex:indexForZ];
	
	// append should be after addQuadFromSprite since it modifies the quantity values
	ccCArrayInsertValueAtIndex(atlasIndexArray_, (void*)z, indexForZ);
	
	return reusedTile_;
}

#pragma mark CCTMXLayer - atlasIndex and Z

int compareInts (const void * a, const void * b)
{
	return ( *(int*)a - *(int*)b );
}

-(unsigned int) atlasIndexForExistantZ:(unsigned int)z
{
	int key=z;
	int *item = bsearch((void*)&key, (void*)&atlasIndexArray_->arr[0], atlasIndexArray_->num, sizeof(void*), compareInts);
	
	NSAssert( item, @"TMX atlas index not found. Shall not happen");

	int index = ((int)item - (int)atlasIndexArray_->arr) / sizeof(void*);
	return index;
}

-(unsigned int)atlasIndexForNewZ:(int)z
{
	// XXX: This can be improved with a sort of binary search
	unsigned int i=0;
	for( i=0; i< atlasIndexArray_->num ; i++) {
		int val = (int) atlasIndexArray_->arr[i];
		if( z < val )
			break;
	}	
	return i;
}

#pragma mark CCTMXLayer - adding / remove tiles

-(void) setTileGID:(unsigned int)gid at:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
	NSAssert( tiles_ && atlasIndexArray_, @"TMXLayer: the tiles map has been released");
		
	unsigned int currentGID = [self tileGIDAt:pos];
	
	if( currentGID != gid ) {
		
		// setting gid=0 is equal to remove the tile
		if( gid == 0 )
			[self removeTileAt:pos];

		// empty tile. create a new one
		else if( currentGID == 0 )
			[self insertTileForGID:gid at:pos];

		// modifying an existing tile with a non-empty tile
		else {

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

-(void) removeChild:(CCSprite*)sprite cleanup:(BOOL)cleanup
{
	// allows removing nil objects
	if( ! sprite )
		return;

	NSAssert( [children_ containsObject:sprite], @"Tile does not belong to TMXLayer");
	
	unsigned int atlasIndex = [sprite atlasIndex];
	unsigned int zz = (unsigned int) atlasIndexArray_->arr[atlasIndex];
	tiles_[zz] = 0;
	ccCArrayRemoveValueAtIndex(atlasIndexArray_, atlasIndex);
	[super removeChild:sprite cleanup:cleanup];
}

-(void) removeTileAt:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y < layerSize_.height && pos.x >=0 && pos.y >=0, @"TMXLayer: invalid position");
	NSAssert( tiles_ && atlasIndexArray_, @"TMXLayer: the tiles map has been released");

	unsigned int gid = [self tileGIDAt:pos];
	
	if( gid ) {
		
		unsigned int z = pos.x + pos.y * layerSize_.width;
		unsigned atlasIndex = [self atlasIndexForExistantZ:z];
		
		// remove tile from GID map
		tiles_[z] = 0;

		// remove tile from atlas position array
		ccCArrayRemoveValueAtIndex(atlasIndexArray_, atlasIndex);
		
		// remove it from sprites and/or texture atlas
		id sprite = [self getChildByTag:z];
		if( sprite )
			[super removeChild:sprite cleanup:YES];
		else {
			[textureAtlas_ removeQuadAtIndex:atlasIndex];

			// update possible children
			for( CCSprite *sprite in children_) {
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

-(id) propertyNamed:(NSString *)propertyName 
{
	return [properties_ valueForKey:propertyName];
}
@end

