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
#import "Support/CGPointExtension.h"

#pragma mark -
#pragma mark TMXTiledMap

@interface TMXTiledMap (Private)
-(id) parseLayer:(TMXLayerInfo*)layer tileset:(TMXTilesetInfo*)tileset;
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
		mapSize_ = mapInfo->mapSize;
		tileSize_ = mapInfo->tileSize;
		mapOrientation_ = mapInfo->orientation;
		
		NSAssert( [mapInfo->tilesets count] == 1, @"TMXTiledMap: only supports 1 tileset");
		
		int idx=0;
		TMXTilesetInfo *tileset = [mapInfo->tilesets objectAtIndex:0];

		for( TMXLayerInfo *layerInfo in mapInfo->layers ) {
			if( layerInfo->visible ) {
				id child = [self parseLayer:layerInfo tileset:tileset];
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
-(id) parseLayer:(TMXLayerInfo*)layerInfo tileset:(TMXTilesetInfo*)tileset
{
	TMXLayer *layer = [TMXLayer layerWithTilesetName:tileset->sourceImage];
	
	layer.layerName = layerInfo->name;
	layer.layerSize = layerInfo->layerSize;
	layer.tiles = layerInfo->tiles;
	layer.tileset = tileset;
	layer.mapTileSize = tileSize_;
	layer.layerOrientation = mapOrientation_;
	
	// tell the layerinfo to release the ownership of the tiles map.
	layerInfo->ownTiles = NO;

	// XXX: quick hack that sets in the tileset the size of the image
	tileset->imageSize = [[layer texture] contentSize];
		
	// By default all the tiles are aliased
	// pros:
	//  - easier to render
	// cons:
	//  - difficult to scale / rotate / etc.
	[[layer texture] setAliasTexParameters];

	CFByteOrder o = CFByteOrderGetCurrent();
	
	for( unsigned int y=0; y < layerInfo->layerSize.height; y++ ) {
		for( unsigned int x=0; x < layerInfo->layerSize.width; x++ ) {

			unsigned int pos = x + layerInfo->layerSize.width * y;
			unsigned int gid = layerInfo->tiles[ pos ];

			// gid are stored in little endian.
			// if host is big endian, then swap
			if( o == CFByteOrderBigEndian )
				gid = CFSwapInt32( gid );
			
			// XXX: gid == 0 --> empty tile
			if( gid != 0 ) {
				AtlasSprite *tile = [layer addTileForGID:gid at:ccp(x,y)];
				[tile position]; // XXX
			}
		}
	}	
	
	return layer;
}

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

#pragma mark -
#pragma mark TMXLayer

@interface TMXLayer (Private)
-(CGPoint) positionForIsoAt:(CGPoint)pos;
-(CGPoint) positionForOrthoAt:(CGPoint)pos;
-(CGPoint) positionForHexAt:(CGPoint)pos;
@end

@implementation TMXLayer
@synthesize layerSize = layerSize_, layerName = layerName_, tiles=tiles_;
@synthesize tileset=tileset_;
@synthesize layerOrientation=layerOrientation_;
@synthesize mapTileSize=mapTileSize_;

+(id) layerWithTilesetName:(NSString*)name
{
	return [[[self alloc] initWithTilesetName:name] autorelease];
}

-(id) initWithTilesetName:(NSString*)name
{
	// XXX: a better guess should be done regarding the quantity of tiles
	if((self=[super initWithFile:name capacity:100])) {
		layerName_ = nil;
		layerSize_ = CGSizeZero;
		tiles_ = NULL;
	}
	return self;
}

- (void) dealloc
{
	[layerName_ release];
	[tileset_ release];
	
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
}

#pragma mark TMXLayer - obtaining tiles/gids

-(AtlasSprite*) tileAt:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y <= layerSize_.height, @"TMXLayer: invalid position");

	int t = pos.x + pos.y * layerSize_.height;
	return (AtlasSprite*) [self getChildByTag:t];
}

-(unsigned int) tileGIDAt:(CGPoint)pos
{
	NSAssert( pos.x < layerSize_.width && pos.y <= layerSize_.height, @"TMXLayer: invalid position");
	NSAssert( tiles_ != NULL, @"TMXLayer: the tiles map has been released");
	
	int idx = pos.x + pos.y * layerSize_.height;
	return tiles_[ idx ];
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
			tile = [self addTileForGID:gid at:pos];
		} else {
			CGRect rect = [tileset_ tileForGID:gid];
			[tile setTextureRect:rect];
		}
		
		// update gid on map
		int idx = pos.x + pos.y * layerSize_.height;
		tiles_[ idx ] = gid;
	}
}

-(AtlasSprite*) addTileForGID:(unsigned int)gid at:(CGPoint)pos
{
	CGRect rect = [tileset_ tileForGID:gid];
	
	int z = pos.x + pos.y * layerSize_.height;
	
	AtlasSprite *tile = [AtlasSprite spriteWithRect:rect spriteManager:self];
//	[tile setOpacity:layerInfo->opacity];
//	[tile setVisible:layerInfo->visible];
	
	tile.anchorPoint = CGPointZero;
	[self addChild:tile z:z tag:z];
	
	[tile setPosition: [self positionAt:pos]];
	
	return tile;
}

-(void) removeTileAt:(CGPoint)pos
{
	int z = pos.x + pos.y * layerSize_.height;
	[self removeChildByTag:z cleanup:YES];
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

