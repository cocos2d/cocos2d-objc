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

enum
{
	TMXOrientationOrtho,
	TMXOrientationHex,
	TMXOrientationIso,
};

/** TMXLayerFormat is computer-friendaly version of the XML representation **/
@interface TMXLayerFormat : NSObject
{
@public
	NSString		*name;
	CGSize			layerSize;
	unsigned char	*tiles;
}
@end

/** TMXTilesetFormat is computer-friendaly version of the XML representation **/
@interface TMXTilesetFormat : NSObject
{
@public
	NSString	*name;
	int			firstGid;
	CGSize		tileSize;
	int			spacing;
	int			margin;
	
	// filename containing the tiles (should be spritesheet / texture atlas)
	NSString	*image;
}
@end

enum {
	TMXLayerAttribNone = 1 << 0,
	TMXLayerAttribBase64 = 1 << 1,
	TMXLayerAttribGzip = 1 << 2,
};

/** TMXMapFormat is the computer-friendly version of the XML representation */
@interface TMXMapFormat : NSObject
{
@public
	int	orientation;
	
	// tmp variables
	NSMutableString *currentString;
    BOOL			storingCharacters;	
	int				layerAttribs;
	
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


/** TiledMapTMX is a subclass of AtlasSpriteManger.
 
 It adds support for the TMX tiled map format used by http://www.mapeditor.org
 It supports isometric, hexagonal and orthogonal tiles.

 Features:
   - Each tile will be treated as an AtlasSprite
   - Each tile can be rotated / moved / scaled / tinted / "opacitied"
   - Tiles can be added/removed in runtime
   - The z-order of the tiles can be modified in runtime.
 
 Limitations:
   - It only supports one tileset.
   - Embeded images are not supported
   - It only supports the TMX format (the JSON format is not supported)

   
 @since v0.8.1
 */
@interface TiledMapTMX : AtlasSpriteManager <CocosNodeRGBA>
{
	// texture RGBA
	GLubyte		opacity_;
	ccColor3B	color_;
	BOOL opacityModifyRGB_;
}

/** conforms to CocosNodeRGBA protocol */
@property (readonly) GLubyte opacity;
/** conforms to CocosNodeRGBA protocol */
@property (readonly) ccColor3B color;


/** creates a TMX Tiled Map with a TMX file */
+(id) tiledMapWithTMXFile:(NSString*)tmxFile;

/** initializes a TMX Tiled Map with a TMX file */
-(id) initWithTMXFile:(NSString*)tmxFile;
@end


