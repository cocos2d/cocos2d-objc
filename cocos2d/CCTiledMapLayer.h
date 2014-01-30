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
 */

#import "CCAtlasNode.h"
#import "CCSpriteBatchNode.h"
#import "CCTMXXMLParser.h"

@class CCTiledMapInfo;
@class CCTiledMapLayerInfo;
@class CCTiledMapTilesetInfo;

/** 
 
 CCTiledMapLayer represents the Tiled Map layer.

 If you modify a tile on runtime, then that tile will become a CCSprite otherwise no CCSprite objects are initially created.
 
 ### Notes
 Tiles can have tile flags for additional properties. 
 At the moment only flip horizontal and flip vertical are used. These bit flags are defined in CCTMXXMLParser.h.
 
 */

@interface CCTiledMapLayer : CCSpriteBatchNode {
    
    // Various Map data storage.
	CCTiledMapTilesetInfo	*_tileset;
	NSString                *_layerName;
	CGSize                  _layerSize;
	CGSize                  _mapTileSize; // TODO: in pixels or points?
	uint32_t                *_tiles;
	NSUInteger              _layerOrientation;
	NSMutableDictionary     *_properties;
    
    // TMX Layer Opacity.
	unsigned char           _opacity;

    // GID Range
	NSUInteger              _minGID;
	NSUInteger              _maxGID;

	// Only used when vertexZ is used.
	NSInteger               _vertexZvalue;
	BOOL                    _useAutomaticVertexZ;

	// Used for optimization.
	CCSprite                *_reusedTile;
	NSMutableArray          *_atlasIndexArray;
}


/// -----------------------------------------------------------------------
/// @name Accessing the Tile Map Layer Attributes
/// -----------------------------------------------------------------------

/** Name of the layer. */
@property (nonatomic,readwrite,strong) NSString *layerName;

/** Size of the layer in tiles. */
@property (nonatomic,readwrite) CGSize layerSize;

/** Size of the Map's tile, could be different from the tile size. */
@property (nonatomic,readwrite) CGSize mapTileSize;

/** Tile pointer. */
@property (nonatomic,readonly) uint32_t *tiles;

/** Tileset information for the layer. */
@property (nonatomic,readwrite,strong) CCTiledMapTilesetInfo *tileset;

/** Layer orientation method, which is the same as the map orientation method. */
@property (nonatomic,readwrite) NSUInteger layerOrientation;

/** Properties from the layer. They can be added using tiled. */
@property (nonatomic,readwrite,strong) NSMutableDictionary *properties;


/// -----------------------------------------------------------------------
/// @name Creating a CCTiledMapLayer Object
/// -----------------------------------------------------------------------

/**
 *  Create and return a CCTiledMapLayer using the specified tileset info, layerinfo and mapinfo values.
 *
 *  @param tilesetInfo Tileset Info to use.
 *  @param layerInfo   Layer Info to use.
 *  @param mapInfo     Map Info to use.
 *
 *  @return The CCTiledMapLayer Object.
 */
+(id) layerWithTilesetInfo:(CCTiledMapTilesetInfo*)tilesetInfo layerInfo:(CCTiledMapLayerInfo*)layerInfo mapInfo:(CCTiledMapInfo*)mapInfo;


/// -----------------------------------------------------------------------
/// @name Initializing a CCTiledMapLayer Object
/// -----------------------------------------------------------------------

/**
 *  Initializes and returns a CCTiledMapLayer using the specified tileset info, layerinfo and mapinfo values.
 *
 *  @param tilesetInfo Tileset Info to use.
 *  @param layerInfo   Layer Info to use.
 *  @param mapInfo     Map Info to use.
 *
 *  @return An initialized CCTiledMapLayer Object.
 */
-(id) initWithTilesetInfo:(CCTiledMapTilesetInfo*)tilesetInfo layerInfo:(CCTiledMapLayerInfo*)layerInfo mapInfo:(CCTiledMapInfo*)mapInfo;


/// -----------------------------------------------------------------------
/// @name Tile Map Layer Helpers
/// -----------------------------------------------------------------------

/**
 *  Returns the tile at the specified tile coordinates.
 *
 *  @param tileCoordinate Tile Coordinate to use.
 *
 *  @return CCSprite tile object.
 */
-(CCSprite*) tileAt:(CGPoint)tileCoordinate;

/**
 *  Returns the tile GID at the specified tile coordinates.
 *
 *  @param tileCoordinate Tile Coordinate to use.
 *
 *  @return Tile GID value.
 */
-(uint32_t) tileGIDAt:(CGPoint)tileCoordinate;

/*
 *  Returns the tile GID using the specified tile coordinates and flag options.
 *
 *  @param pos   Tile Coordinate to use.
 *  @param flags Flags options to use.
 *
 *  @return Tile GID value.
 */
-(uint32_t) tileGIDAt:(CGPoint)pos withFlags:(ccTMXTileFlags*)flags;

/**
 *  Sets the tile GID using the specified tile coordinates and GID value.
 *
 *  @param gid            GID value to use.
 *  @param tileCoordinate Tile Coordinate to use.
 */
-(void) setTileGID:(uint32_t)gid at:(CGPoint)tileCoordinate;

/**
 *  Sets the tile GID using the specified GID value, tile coordinates and flag option values.
 *
 *  @param gid   GID value to use.
 *  @param pos   Tile Coordinate to use.
 *  @param flags Flag options to use.
 */
-(void) setTileGID:(uint32_t)gid at:(CGPoint)pos withFlags:(ccTMXTileFlags)flags;

/**
 *  Remove tile at specified tile coordinates.
 *
 *  @param tileCoordinate Tile Coordinate to use.
 */
-(void) removeTileAt:(CGPoint)tileCoordinate;

/**
 *  Return the position in points of the tile specified by the tile coordinates.
 *
 *  @param tileCoordinate Tile Coordinate to use.
 *
 *  @return Return position of tile.
 */
-(CGPoint) positionAt:(CGPoint)tileCoordinate;

/**
 *  Return the value for the specified property name value.
 *
 *  @param propertyName Propery name to lookup.
 *
 *  @return Property name value.
 */
-(id) propertyNamed:(NSString *)propertyName;

/**
 *  @warning addchild:z:tag: is not supported on CCTMXLayer.  Instead use setTileGID:at: and tileAt: methods.
 *
 *  @param node Node to use.
 *  @param z    Z value to use.
 *  @param tag  Tag to use.
 */
-(void) addChild:(CCNode*)node z:(NSInteger)z tag:(NSInteger)tag;

@end
