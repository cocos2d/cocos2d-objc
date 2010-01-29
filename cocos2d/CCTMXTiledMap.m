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
#import "CCTMXLayer.h"
#import "CCTMXObjectGroup.h"
#import "CCSprite.h"
#import "CCSpriteSheet.h"
#import "CCTextureCache.h"
#import "Support/CGPointExtension.h"


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
@synthesize objectGroups=objectGroups_;
@synthesize properties=properties_;

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
		objectGroups_ = [mapInfo.objectGroups retain];
		properties_ = [mapInfo.properties retain];
				
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
	[objectGroups_ release];
	[properties_ release];
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
	for( CCTMXLayer *layer in children_ ) {
		if( [layer.layerName isEqual:layerName] )
			return layer;
	}
	
	// layer not found
	return nil;
}

-(CCTMXObjectGroup*) objectGroupNamed:(NSString *)groupName 
{
	for( CCTMXObjectGroup *objectGroup in objectGroups_ ) {
		if( [objectGroup.groupName isEqual:groupName] )
			return objectGroup;
		}
	
	// objectGroup not found
	return nil;
}

// XXX deprecated
-(CCTMXObjectGroup*) groupNamed:(NSString *)groupName 
{
	return [self objectGroupNamed:groupName];
}

-(id) propertyNamed:(NSString *)propertyName 
{
	return [properties_ valueForKey:propertyName];
}
@end

