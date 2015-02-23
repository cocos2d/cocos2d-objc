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

#import "CCSpriteBatchNode.h"
#import "CCTMXXMLParser.h"
#import "CCTiledMap.h"
#import "CCMathTypesAndroid.h"

@class CCTiledMapInfo;
@class CCTiledMapLayerInfo;
@class CCTiledMapTilesetInfo;

/** 
 CCTiledMapLayer represents a tile layer in a Tiled map.

 If you modify a tile on runtime, then that tile will be converted into a CCSprite. Accessing all tiles of a layer
 will turn them all into sprites, possibly adding a significant memory overhead.
 */

@interface CCTiledMapLayer : CCNode<CCShaderProtocol, CCTextureProtocol, CCBlendProtocol> 

/// -----------------------------------------------------------------------
/// @name Creating a Tiled Map Layer
/// -----------------------------------------------------------------------

/**
 *  Create and return a CCTiledMapLayer using the specified tileset info, layerinfo and mapinfo values.
 *
 *  @param tilesetInfo Tileset Info to use.
 *  @param layerInfo   Layer Info to use.
 *  @param mapInfo     Map Info to use.
 *
 *  @return The CCTiledMapLayer Object.
 *  @see CCTiledMapTilesetInfo
 *  @see CCTiledMapLayerInfo
 *  @see CCTiledMapInfo
 */
+(instancetype) layerWithTilesetInfo:(CCTiledMapTilesetInfo*)tilesetInfo layerInfo:(CCTiledMapLayerInfo*)layerInfo mapInfo:(CCTiledMapInfo*)mapInfo;

/**
 *  Initializes and returns a CCTiledMapLayer using the specified tileset info, layerinfo and mapinfo values.
 *
 *  @param tilesetInfo Tileset Info to use.
 *  @param layerInfo   Layer Info to use.
 *  @param mapInfo     Map Info to use.
 *
 *  @return An initialized CCTiledMapLayer Object.
 *  @see CCTiledMapTilesetInfo
 *  @see CCTiledMapLayerInfo
 *  @see CCTiledMapInfo
 */
-(id) initWithTilesetInfo:(CCTiledMapTilesetInfo*)tilesetInfo layerInfo:(CCTiledMapLayerInfo*)layerInfo mapInfo:(CCTiledMapInfo*)mapInfo;

/// -----------------------------------------------------------------------
/// @name Tiled Map Layer Attributes
/// -----------------------------------------------------------------------

/** Name of the tile layer. */
@property (nonatomic,readwrite,strong) NSString *layerName;

/** Size of the layer, in tiles. */
@property (nonatomic,readwrite) CGSize layerSize;

/** Size of the Map's tiles, could be different from the tile size but typically is the same. */
@property (nonatomic,readwrite) CGSize mapTileSize;

/** Layer orientation. Is always the same as the map's orientation.
 @see CCTiledMapOrientation */
@property (nonatomic,readwrite) CCTiledMapOrientation layerOrientation;

/// -----------------------------------------------------------------------
/// @name Modifying Tiles by Global Identifier (GID)
/// -----------------------------------------------------------------------

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
 *  @see ccTMXTileFlags
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
 *  @see ccTMXTileFlags
 */
-(void) setTileGID:(uint32_t)gid at:(CGPoint)pos withFlags:(ccTMXTileFlags)flags;

/**
 *  Remove tile at specified tile coordinates.
 *
 *  @param tileCoordinate Tile Coordinate to use.
 */
-(void) removeTileAt:(CGPoint)tileCoordinate;

/// -----------------------------------------------------------------------
/// @name Accessing Tiles and Tileset
/// -----------------------------------------------------------------------

/** Tile pointer. */
@property (nonatomic,readonly) uint32_t *tiles;

/** Tileset information for the layer.
 @see CCTiledMapTilesetInfo */
@property (nonatomic,readwrite,strong) CCTiledMapTilesetInfo *tileset;

/// -----------------------------------------------------------------------
/// @name Converting Coordinates
/// -----------------------------------------------------------------------

/**
 *  Return the position in points of the tile specified by the tile coordinates.
 *
 *  @param tileCoordinate Tile Coordinate to use.
 *
 *  @return Return position of tile.
 */
-(CGPoint) positionAt:(CGPoint)tileCoordinate;

/**
 *  Return the position in tile coordinates of the tile specified by position in points.
 *
 *  @param position Position in points.
 *
 *  @return Coordinate of the tile at that position.
 */
-(CGPoint) tileCoordinateAt:(CGPoint)position;

/// -----------------------------------------------------------------------
/// @name Accessing Tiled Layer Properties
/// -----------------------------------------------------------------------

/** Properties from the layer. They can be added using tiled. */
@property (nonatomic,readwrite,strong) NSMutableDictionary *properties;

/**
 *  Return the value for the specified property name value.
 *
 *  @param propertyName Propery name to lookup.
 *
 *  @return Property name value.
 */
-(id) propertyNamed:(NSString *)propertyName;


// purposefully undocumented: users should not use this method
/*
 *  @warning addchild:z:tag: is not supported on CCTMXLayer.  Instead use setTileGID:at: and tileAt: methods.
 *
 *  @param node Node to use.
 *  @param z    Z value to use.
 *  @param tag  Tag to use.
 *  @see CCNode
 */
-(void) addChild:(CCNode*)node z:(NSInteger)z tag:(NSInteger)tag;

@end
