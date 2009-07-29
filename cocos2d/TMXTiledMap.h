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
}

/** creates a TMX Tiled Map with a TMX file */
+(id) tiledMapWithTMXFile:(NSString*)tmxFile;

/** initializes a TMX Tiled Map with a TMX file */
-(id) initWithTMXFile:(NSString*)tmxFile;
@end

