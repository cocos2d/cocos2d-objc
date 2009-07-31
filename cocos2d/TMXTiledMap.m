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
#import "TMXInfo.h"
#import "AtlasSprite.h"
#import "Support/CGPointExtension.h"

#pragma mark -
#pragma mark TMXTiledMap

@interface TMXTiledMap (Private)
-(id) parseLayer:(TMXLayerInfo*)layer tileset:(TMXTilesetInfo*)tileset map:(TMXMapInfo*)map;
-(void) setOrthoTile:(CocosNode*)tile at:(CGPoint)pos tileSize:(CGSize)tileSize layerSize:(CGSize)layerSize;
-(void) setIsoTile:(CocosNode*)tile at:(CGPoint)pos tileSize:(CGSize)tileSize layerSize:(CGSize)layerSize;
-(void) setHexTile:(CocosNode*)tile at:(CGPoint)pos tileSize:(CGSize)tileSize layerSize:(CGSize)layerSize;
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

		TMXMapInfo *map = [TMXMapInfo formatWithTMXFile:tmxFile];
		mapSize_ = map->mapSize;
		tileSize_ = map->tileSize;
		mapOrientation_ = map->orientation;
		
		NSAssert( [map->tilesets count] == 1, @"TMXTiledMap: only supports 1 tileset");
		
		int idx=0;
		TMXTilesetInfo *tileset = [map->tilesets objectAtIndex:0];
		

		for( TMXLayerInfo *layer in map->layers ) {
			id child = [self parseLayer:layer tileset:tileset map:map];
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

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

// private
-(id) parseLayer:(TMXLayerInfo*)layer tileset:(TMXTilesetInfo*)tileset map:(TMXMapInfo*)map
{
	TMXLayer *mgr = [TMXLayer layerWithTilesetName:tileset->sourceImage];
	
	mgr.layerName = layer->name;
	mgr.layerSize = layer->layerSize;
	mgr.tiles = layer->tiles;
	layer->ownTiles = NO;

	tileset->imageSize = [[mgr texture] contentSize];
		
	// By default all the tiles are aliased
	// pros:
	//  - easier to render
	// cons:
	//  - difficult to scale / rotate / etc.
	[[mgr texture] setAliasTexParameters];

	CFByteOrder o = CFByteOrderGetCurrent();
	
	for( unsigned int y=0; y < layer->layerSize.height; y++ ) {
		for( unsigned int x=0; x < layer->layerSize.width; x++ ) {

			unsigned int pos = x + layer->layerSize.width * y;
			unsigned int gid = layer->tiles[ pos ];

			// gid are stored in little endian.
			// if host is big endian, then swap
			if( o == CFByteOrderBigEndian )
				gid = CFSwapInt32( gid );
			
			// XXX: gid == 0 --> empty tile
			if( gid != 0 ) {
				CGRect rect;

				rect = [tileset tileForGID:gid];

				AtlasSprite *tile = [AtlasSprite spriteWithRect:rect spriteManager:mgr];
				[tile setOpacity:layer->opacity];
				[tile setVisible:layer->visible];
				
				tile.anchorPoint = CGPointZero;
				[mgr addChild:tile z:0 tag:pos];
				
				switch( map->orientation ) {
					case TMXOrientationOrtho:
						[self setOrthoTile:tile at:ccp(x,y) tileSize:tileset->tileSize layerSize:layer->layerSize];
						break;
					case TMXOrientationIso:
						[self setIsoTile:tile at:ccp(x,y) tileSize:tileset->tileSize layerSize:layer->layerSize];
						break;
					case TMXOrientationHex:
						[self setHexTile:tile at:ccp(x,y) tileSize:tileset->tileSize layerSize:layer->layerSize];
						break;						
				}
			}
		}
	}	
	
	return mgr;
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

-(void) setOrthoTile:(CocosNode*)tile at:(CGPoint)pos tileSize:(CGSize)tileSize layerSize:(CGSize)layerSize
{
	int x = pos.x * tileSize.width + 0.49f;
	int y = (layerSize.height - pos.y) * tileSize.height + 0.49f;
	[tile setPosition:ccp( x,y)];
}

-(void) setIsoTile:(CocosNode*)tile at:(CGPoint)pos tileSize:(CGSize)tileSize layerSize:(CGSize)layerSize
{
	int x = tileSize.width /2  *(pos.x - pos.y) + 0.49f;
	int y = (layerSize.height - (pos.x + pos.y)) * tileSize.height/2 + 0.49f;
	[tile setPosition:ccp(x, y)];
}

-(void) setHexTile:(CocosNode*)tile at:(CGPoint)pos tileSize:(CGSize)tileSize layerSize:(CGSize)layerSize
{
	float diffY = 0;
	if( (int)pos.x % 2 == 1 )
		diffY = -tileSize.height/2 ;
	
	int x =  pos.x * tileSize.width*3/4 + 0.49f;
	int y =  (layerSize.height - pos.y) * tileSize.height + diffY + 0.49f;
	
	[tile setPosition:ccp(x, y)];
}
@end

#pragma mark -
#pragma mark TMXLayer

@implementation TMXLayer
@synthesize layerSize = layerSize_, layerName = layerName_, tiles=tiles_;

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
	
	if( tiles_ ) {
		free(tiles_);
		tiles_ = NULL;
	}
		
	[super dealloc];
}

@end

