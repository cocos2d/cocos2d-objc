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

#import "AtlasNode.h"
#import "AtlasSpriteManager.h"

/** Possible oritentations of the TMX map */
enum
{
	/** Orthogonal orientation */
	TMXOrientationOrtho,
	
	/** Hexagonal orientation */
	TMXOrientationHex,
	
	/** Isometric orientation */
	TMXOrientationIso,
};

/** TMXLayer represents the TMX layer.
 
 It is a subclass of AtlasSpriteManager, so each "tile" is represented by an AtlasSprite.
 The benefits of using AtlasSprite objects as tiles are:
 - tiles (AtlasSprite) can be rotated/scaled/moved with a nice API
 
 @since v0.8.1
 */
@interface TMXLayer : AtlasSpriteManager
{
	NSString		*layerName_;
	CGSize			layerSize_;
	unsigned int	*tiles_;
}
/** name of the layer */
@property (readwrite,retain) NSString *layerName;
/** size of the layer in tiles */
@property (readwrite) CGSize layerSize;
/** pointer to the map of tiles */
@property (readwrite) unsigned int *tiles;

/** creates a TMX Layer with an tileset image name */
+(id) layerWithTilesetName:(NSString*)name;
/** initializes a TMX Layer with an tileset image name */
-(id) initWithTilesetName:(NSString*)name;
/** dealloc the map from memory */
-(void) releaseMap;
@end

/** TMXTiledMap knows how to parse and render a TMX map.
 
 It adds support for the TMX tiled map format used by http://www.mapeditor.org
 It supports isometric, hexagonal and orthogonal tiles.
 
 Features:
 - Each tile will be treated as an AtlasSprite
 - Each tile can be rotated / moved / scaled / tinted / "opacitied"
 - Tiles can be added/removed in runtime
 - The z-order of the tiles can be modified in runtime.
 - Each tile has an anchorPoint of (0,0)
 - The anchorPoint of the TMXTileMap is (0,0)
 - The TMX layers will be added as a child
 - The TMX layers will be aliased by default
 
 Limitations:
 - It only supports one tileset.
 - Embeded images are not supported
 - It only supports the XML format (the JSON format is not supported)
 
 Technical description:
   Each layer is created using an TMXLayer (subclass of AtlasSpriteManager). If you have 5 layers, then 5 TMXLayer will be created,
   unless the layer visibility is off. In that case, the layer won't be created at all.
   You can obtain the layers (TMXLayer objects) at runtime by:
  - [map getChildByTag: tag_number];  // 0=1st layer, 1=2nd layer, 2=3rd layer, etc...
  - [map layerNamed: name_of_the_layer];

 @since v0.8.1
 */
@interface TMXTiledMap : CocosNode
{
	CGSize		mapSize_;
	CGSize		tileSize_;
	int			mapOrientation_;
}

/** the map's size property measured in tiles */
@property (readonly) CGSize mapSize;
/** the tiles's size property measured in pixels */
@property (readonly) CGSize tileSize;
/** map orientation */
@property (readonly) int mapOrientation;

/** creates a TMX Tiled Map with a TMX file */
+(id) tiledMapWithTMXFile:(NSString*)tmxFile;

/** initializes a TMX Tiled Map with a TMX file */
-(id) initWithTMXFile:(NSString*)tmxFile;

/** return the TMXLayer for the specific layer */
-(TMXLayer*) layerNamed:(NSString *)layerName;

@end


