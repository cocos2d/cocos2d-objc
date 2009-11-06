/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
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

#import "CCAtlasNode.h"
#import "CCSpriteManager.h"
#import "Support/ccArray.h"


@class CCTMXMapInfo;
@class CCTMXLayer;
@class CCTMXLayerInfo;
@class CCTMXTilesetInfo;

/** Possible oritentations of the TMX map */
enum
{
	/** Orthogonal orientation */
	CCTMXOrientationOrtho,
	
	/** Hexagonal orientation */
	CCTMXOrientationHex,
	
	/** Isometric orientation */
	CCTMXOrientationIso,
};

/** CCTMXTiledMap knows how to parse and render a TMX map.
 
 It adds support for the TMX tiled map format used by http://www.mapeditor.org
 It supports isometric, hexagonal and orthogonal tiles.
 
 Features:
 - Each tile will be treated as an CCSprite
 - Each tile can be rotated / moved / scaled / tinted / "opacitied"
 - Tiles can be added/removed in runtime
 - The z-order of the tiles can be modified in runtime.
 - Each tile has an anchorPoint of (0,0)
 - The anchorPoint of the TMXTileMap is (0,0)
 - The TMX layers will be added as a child
 - The TMX layers will be aliased by default
 - The tileset image will be loaded using the TextureMgr
 - Each tile will have a unique tag
 - Each tile will have a unique z value. top-left: z=1, bottom-right: z=max z
 
 Limitations:
 - It only supports one tileset.
 - Embeded images are not supported
 - It only supports the XML format (the JSON format is not supported)
 
 Technical description:
   Each layer is created using an TMXLayer (subclass of CCSpriteManager). If you have 5 layers, then 5 TMXLayer will be created,
   unless the layer visibility is off. In that case, the layer won't be created at all.
   You can obtain the layers (TMXLayer objects) at runtime by:
  - [map getChildByTag: tag_number];  // 0=1st layer, 1=2nd layer, 2=3rd layer, etc...
  - [map layerNamed: name_of_the_layer];

 @since v0.8.1
 */
@interface CCTMXTiledMap : CCNode
{
	CGSize		mapSize_;
	CGSize		tileSize_;
	int			mapOrientation_;	
}

/** the map's size property measured in tiles */
@property (nonatomic,readonly) CGSize mapSize;
/** the tiles's size property measured in pixels */
@property (nonatomic,readonly) CGSize tileSize;
/** map orientation */
@property (nonatomic,readonly) int mapOrientation;

/** creates a TMX Tiled Map with a TMX file.*/
+(id) tiledMapWithTMXFile:(NSString*)tmxFile;

/** initializes a TMX Tiled Map with a TMX file */
-(id) initWithTMXFile:(NSString*)tmxFile;

/** return the TMXLayer for the specific layer */
-(CCTMXLayer*) layerNamed:(NSString *)layerName;
@end


/** CCTMXLayer represents the TMX layer.
 
 It is a subclass of CCSpriteManager, so each "tile" is represented by an CCSprite.
 The benefits of using CCSprite objects as tiles are:
 - tiles (CCSprite) can be rotated/scaled/moved with a nice API
 
 @since v0.8.1
 */
@interface CCTMXLayer : CCSpriteManager
{
	CCTMXTilesetInfo	*tileset_;
	NSString			*layerName_;
	CGSize				layerSize_;
	CGSize				mapTileSize_;
	unsigned int		*tiles_;
	int					layerOrientation_;
	
	// used for optimization
	CCSprite		*reusedTile;
	ccCArray		*atlasIndexArray;
}
/** name of the layer */
@property (nonatomic,readwrite,retain) NSString *layerName;
/** size of the layer in tiles */
@property (nonatomic,readwrite) CGSize layerSize;
/** size of the map's tile (could be differnt from the tile's size) */
@property (nonatomic,readwrite) CGSize mapTileSize;
/** pointer to the map of tiles */
@property (nonatomic,readwrite) unsigned int *tiles;
/** Tilset information for the layer */
@property (nonatomic,readwrite,retain) CCTMXTilesetInfo *tileset;
/** Layer orientation, which is the same as the map orientation */
@property (nonatomic,readwrite) int layerOrientation;


/** creates a CCTMXLayer with an tileset info, a layer info and a map info */
+(id) layerWithTilesetInfo:(CCTMXTilesetInfo*)tilesetInfo layerInfo:(CCTMXLayerInfo*)layerInfo mapInfo:(CCTMXMapInfo*)mapInfo;
/** initializes a CCTMXLayer with a tileset info, a layer info and a map info */
-(id) initWithTilesetInfo:(CCTMXTilesetInfo*)tilesetInfo layerInfo:(CCTMXLayerInfo*)layerInfo mapInfo:(CCTMXMapInfo*)mapInfo;

/** dealloc the map that contains the tile position from memory.
 Unless you want to know at runtime the tiles positions, you can safely call this method.
 If you are going to call [layer tileGIDAt:] then, don't release the map
 */
-(void) releaseMap;

/** returns the tile (CCSprite) at a given a tile coordinate */
-(CCSprite*) tileAt:(CGPoint)tileCoordinate;

/** returns the tile gid at a given tile coordinate.
 if it returns 0, it means that the tile is empty.
 This method requires the the tile map has not been previously released (eg. don't call [layer releaseMap])
 */
-(unsigned int) tileGIDAt:(CGPoint)tileCoordinate;

/** sets the tile gid (gid = tile global id) at a given tile coordinate.
 The Tile GID can be obtained by using the method "tileGIDAt" or by using the TMX editor -> Tileset Mgr +1.
 If a tile is already placed at that position, then it will be removed.
 */
-(void) setTileGID:(unsigned int)gid at:(CGPoint)tileCoordinate;

/** removes a tile at given tile coordinate */
-(void) removeTileAt:(CGPoint)tileCoordinate;

/** returns the position in pixels of a given tile coordinate */
-(CGPoint) positionAt:(CGPoint)tileCoordinate;
@end


