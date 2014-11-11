/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *
 * TMX Tiled Map support:
 * http://www.mapeditor.org
 *
 */

#import "CCTiledMap.h"
#import "CCTMXXMLParser.h"
#import "CCTiledMapLayer.h"
#import "CCTiledMapObjectGroup.h"
#import "CCSprite.h"
#import "CCTextureCache.h"
#import "Support/CGPointExtension.h"

#import "CCTiledMapLayer_Private.h"

#pragma mark -
#pragma mark CCTMXTiledMap

@interface CCTiledMap (Private)
-(id) parseLayer:(CCTiledMapLayerInfo*)layer map:(CCTiledMapInfo*)mapInfo;
-(CCTiledMapTilesetInfo*) tilesetForLayer:(CCTiledMapLayerInfo*)layerInfo map:(CCTiledMapInfo*)mapInfo;
-(void) buildWithMapInfo:(CCTiledMapInfo*)mapInfo;
@end

@implementation CCTiledMap
@synthesize mapSize = _mapSize;
@synthesize tileSize = _tileSize;
@synthesize mapOrientation = _mapOrientation;
@synthesize objectGroups = _objectGroups;
@synthesize properties = _properties;

+(id) tiledMapWithFile:(NSString*)tmxFile
{
	return [[self alloc] initWithFile:tmxFile];
}

+(id) tiledMapWithXML:(NSString*)tmxString resourcePath:(NSString*)resourcePath
{
	return [[self alloc] initWithXML:tmxString resourcePath:resourcePath];
}

-(void) buildWithMapInfo:(CCTiledMapInfo*)mapInfo
{
	_mapSize = mapInfo.mapSize;
	_tileSize = mapInfo.tileSize;
	_mapOrientation = mapInfo.orientation;
	_objectGroups = mapInfo.objectGroups;
	_properties = mapInfo.properties;
	_tileProperties = mapInfo.tileProperties;

	int idx=0;

	for( CCTiledMapLayerInfo *layerInfo in mapInfo.layers ) {

		if( layerInfo.visible ) {
			CCNode *child = [self parseLayer:layerInfo map:mapInfo];
            NSString* idxStr = [NSString stringWithFormat:@"%d",idx];
			[self addChild:child z:idx name:idxStr];

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

-(id) initWithXML:(NSString*)tmxString resourcePath:(NSString*)resourcePath
{
	if ((self=[super init])) {

		[self setContentSize:CGSizeZero];

		CCTiledMapInfo *mapInfo = [CCTiledMapInfo formatWithXML:tmxString resourcePath:resourcePath];

		NSAssert( [mapInfo.tilesets count] != 0, @"TMXTiledMap: Map not found. Please check the filename.");
		[self buildWithMapInfo:mapInfo];
	}

	return self;
}

-(id) initWithFile:(NSString*)tmxFile
{
	NSAssert(tmxFile != nil, @"TMXTiledMap: tmx file should not be nil");

	if ((self=[super init])) {

		[self setContentSize:CGSizeZero];

		CCTiledMapInfo *mapInfo = [CCTiledMapInfo formatWithTMXFile:tmxFile];

		NSAssert( [mapInfo.tilesets count] != 0, @"TMXTiledMap: Map not found. Please check the filename.");
		[self buildWithMapInfo:mapInfo];
	}

	return self;
}


// private
-(id) parseLayer:(CCTiledMapLayerInfo*)layerInfo map:(CCTiledMapInfo*)mapInfo
{
	CCTiledMapTilesetInfo *tileset = [self tilesetForLayer:layerInfo map:mapInfo];
	CCTiledMapLayer *layer = [CCTiledMapLayer layerWithTilesetInfo:tileset layerInfo:layerInfo mapInfo:mapInfo];

	// tell the layerinfo to release the ownership of the tiles map.
	layerInfo.ownTiles = NO;

	[layer setupTiles];

	return layer;
}

-(CCTiledMapTilesetInfo*) tilesetForLayer:(CCTiledMapLayerInfo*)layerInfo map:(CCTiledMapInfo*)mapInfo
{
	CGSize size = layerInfo.layerSize;

	id iter = [mapInfo.tilesets reverseObjectEnumerator];
	for( CCTiledMapTilesetInfo* tileset in iter) {
		for( unsigned int y = 0; y < size.height; y++ ) {
			for( unsigned int x = 0; x < size.width; x++ ) {

				unsigned int pos = x + size.width * y;
				unsigned int gid = layerInfo.tiles[ pos ];

				// gid are stored in little endian.
				// if host is big endian, then swap
				gid = CFSwapInt32LittleToHost( gid );

				// XXX: gid == 0 --> empty tile
				if( gid != 0 ) {

					// Optimization: quick return
					// if the layer is invalid (more than 1 tileset per layer) an assert will be thrown later
					if( (gid & kCCFlippedMask) >= tileset.firstGid )
						return tileset;
				}
			}
		}
	}

	// If all the tiles are 0, return empty tileset
	CCLOG(@"cocos2d: Warning: TMX Layer '%@' has no tiles", layerInfo.name);
	return nil;
}


// public

-(CCTiledMapLayer*) layerNamed:(NSString *)layerName
{
    for (CCTiledMapLayer *layer in _children) {
		if([layer isKindOfClass:[CCTiledMapLayer class]])
			if([layer.layerName isEqual:layerName])
				return layer;
	}

	// layer not found
	return nil;
}

-(CCTiledMapObjectGroup*) objectGroupNamed:(NSString *)groupName
{
	for( CCTiledMapObjectGroup *objectGroup in _objectGroups ) {
		if( [objectGroup.groupName isEqual:groupName] )
			return objectGroup;
	}

	// objectGroup not found
	return nil;
}

-(id) propertyNamed:(NSString *)propertyName
{
	return [_properties valueForKey:propertyName];
}
-(NSDictionary*)propertiesForGID:(unsigned int)GID{
	return [_tileProperties objectForKey:[NSNumber numberWithInt:GID]];
}
@end

