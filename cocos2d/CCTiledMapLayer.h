/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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

 If you modify a tile on runtime, then, that tile will become a CCSprite and all the additioanl benefits that entails.  Otherwise no CCSprite objects are created.
 
 ### Notes
 Tiles can have tile flags for additional properties. 
 At the moment only flip horizontal and flip vertical are used. These bit flags are defined in CCTMXXMLParser.h.
 
 */
@interface CCTiledMapLayer : CCSpriteBatchNode {
    
    // Various Map data storage.
	CCTiledMapTilesetInfo	*_tileset;
	NSString                *_layerName;
	CGSize                  _layerSize;
	CGSize                  _mapTileSize;
	uint32_t                *_tiles;
	NSUInteger              _layerOrientation;
	NSMutableDictionary     *_properties;
    
    // TMX Layer Opacity
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

/** returns the tile (CCSprite) at a given a tile coordinate.
 The returned CCSprite will be already added to the CCTMXLayer. Don't add it again.
 The CCSprite can be treated like any other CCSprite: rotated, scaled, translated, opacity, color, etc.
 You can remove either by calling:
	- [layer removeChild:sprite cleanup:cleanup];
	- or [layer removeTileAt:ccp(x,y)];
 */
-(CCSprite*) tileAt:(CGPoint)tileCoordinate;

/** returns the tile gid at a given tile coordinate.
 if it returns 0, it means that the tile is empty.
 This method requires the the tile map has not been previously released (eg. don't call [layer releaseMap])
 */
-(uint32_t) tileGIDAt:(CGPoint)tileCoordinate;

/** returns the tile gid at a given tile coordinate. It also returns the tile flags.
 This method requires the the tile map has not been previously released (eg. don't call [layer releaseMap])
 */
-(uint32_t) tileGIDAt:(CGPoint)pos withFlags:(ccTMXTileFlags*)flags;

/** sets the tile gid (gid = tile global id) at a given tile coordinate.
 The Tile GID can be obtained by using the method "tileGIDAt" or by using the TMX editor -> Tileset Mgr +1.
 If a tile is already placed at that position, then it will be removed.
 */
-(void) setTileGID:(uint32_t)gid at:(CGPoint)tileCoordinate;

/** sets the tile gid (gid = tile global id) at a given tile coordinate.
 The Tile GID can be obtained by using the method "tileGIDAt" or by using the TMX editor -> Tileset Mgr +1.
 If a tile is already placed at that position, then it will be removed.
 
 Use withFlags if the tile flags need to be changed as well
 */

-(void) setTileGID:(uint32_t)gid at:(CGPoint)pos withFlags:(ccTMXTileFlags)flags;

/** removes a tile at given tile coordinate */
-(void) removeTileAt:(CGPoint)tileCoordinate;

/** returns the position in points of a given tile coordinate */
-(CGPoint) positionAt:(CGPoint)tileCoordinate;

/** return the value for the specific property name */
-(id) propertyNamed:(NSString *)propertyName;

/** CCTMXLayer doesn't support adding a CCSprite manually.
 @warning addchild:z:tag: is not supported on CCTMXLayer. Instead of setTileGID:at:/tileAt:
 */
-(void) addChild: (CCNode*)node z:(NSInteger)z tag:(NSInteger)tag;

@end
