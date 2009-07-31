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

/*
 * Internal TMX parser
 *
 * IMPORTANT: These classed should not be documented using doxygen strings
 * since the user should not use them.
 *
 */
 

enum {
	TMXLayerAttribNone = 1 << 0,
	TMXLayerAttribBase64 = 1 << 1,
	TMXLayerAttribGzip = 1 << 2,
};

/* TMXLayerInfo contains the information about the layers like:
 - Layer name
 - Layer size
 - Layer opacity at creation time (it can be modified at runtime)
 - Whether the layer is visible (if it's not visible, then the CocosNode won't be created)
 
 This information is obtained from the TMX file.
 */
@interface TMXLayerInfo : NSObject
{
@public
	NSString		*name;
	CGSize			layerSize;
	unsigned int	*tiles;
	BOOL			visible;
	unsigned char	opacity;
	BOOL			ownTiles;
}
@end

/* TMXTilesetInfo contains the information about the tilesets like:
 - Tileset name
 - Tilset spacing
 - Tileset margin
 - size of the tiles
 - Image used for the tiles
 - Image size
 
 This information is obtained from the TMX file. 
 */
@interface TMXTilesetInfo : NSObject
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

/* TMXMapInfo contains the information about the map like:
 - Map orientation (hexagonal, isometric or orthogonal)
 - Tile size
 - Map size
 
 And it also contains:
 - Layers (an array of TMXLayerInfo objects)
 - Tilesets (an array of TMXTilesetInfo objects)
 
 This information is obtained from the TMX file.
 
 */
@interface TMXMapInfo : NSObject
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

