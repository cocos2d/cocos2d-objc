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

@interface LayerData : NSObject
{
@public
	NSString		*name;
	CGSize			layerSize;
	unsigned char	*tiles;
	BOOL			visible;
	GLubyte			opacity;
}
@end

@interface TilesetData : NSObject
{
@public
	NSString	*name;
	int			firstGid;
	CGSize		tileSize;
	int			spacing;
	int			margin;
	
	// filename containing the tiles (should be spritesheet / texture atlas)
	NSString	*sourceImage;
	
	// size in pixels of the image
	CGSize		imageSize;
}
-(CGRect) tileForGID:(unsigned int)gid;
@end
@interface MapData : NSObject
{
	
	NSMutableString		*currentLayer;
	NSMutableString		*currentString;
    BOOL				storingCharacters;	
	int					layerAttribs;
	
@public
	int	orientation;
	
	
	// map width & height
	CGSize	mapSize;
	
	// tiles width & height
	CGSize	tileSize;
	
	// Layers
	NSMutableArray *layers;
	
	// tilesets
	NSMutableArray *tilesets;
}

/** creates a TMX Format with a tmx file */
+(id) formatWithTMXFile:(NSString*)tmxFile;
/** initializes a TMX format witha  tmx file */
-(id) initWithTMXFile:(NSString*)tmxFile;
@end

/** TMXTiledMap knows how to parse and render an TMX map.
 
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
 - It only supports the TMX format (the JSON format is not supported)
 
 
 @since v0.8.1
 */
@interface TMXTiledMap : CocosNode
{
	MapData *map_;
}

/** returns the metadata of the map like: orientation, size, tile size, the tileset used, layers used, etc
 */
@property(readonly) MapData *map;

/** creates a TMX Tiled Map with a TMX file */
+(id) tiledMapWithTMXFile:(NSString*)tmxFile;

/** initializes a TMX Tiled Map with a TMX file */
-(id) initWithTMXFile:(NSString*)tmxFile;

/** return the AtlasSpriteManager for the specific layer */
-(AtlasSpriteManager*) layerNamed:(NSString *)layerName;

@end

