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
 */

#import "TextureAtlas.h"
#import "AtlasNode.h"
#import "Support/TGAlib.h"

/** TileMapAtlas is a subclass of AtlasNode.
 
 It knows how to render a map based of tiles.
 The tiles must be in a .PNG format while the map must be a .TGA file.
 
 For more information regarding the format, please see this post:
 http://blog.sapusmedia.com/2008/12/how-to-use-tilemap-editor-for-cocos2d.html
 
 All features from AtlasNode are valid in TileMapAtlas
 */
@interface TileMapAtlas : AtlasNode {
	
	/// info about the map file
	tImageTGA		*tgaInfo;
	
	/// x,y to altas dicctionary
	NSMutableDictionary	*posToAtlasIndex;
	
	/// numbers of tiles to render
	int				itemsToRender;
}

/** TileMap info */
@property (readonly) tImageTGA *tgaInfo;

/** creates the TileMap with a tile file (atlas) with a map file and the width and height of each tile */
+(id) tileMapAtlasWithTileFile:(NSString*)tile mapFile:(NSString*)map tileWidth:(int)w tileHeight:(int)h;

/** initializes the TileMap with a tile file (atlas) with a map file and the width and height of each tile */
-(id) initWithTileFile:(NSString*)tile mapFile:(NSString*)map tileWidth:(int)w tileHeight:(int)h;

/** returns a tile from position x,y.
 For the moment only channel R is used
 */
-(ccColor3B) tileAt: (ccGridSize) position;

/** sets a tile at position x,y.
 For the moment only channel R is used
 */
-(void) setTile:(ccColor3B)tile at:(ccGridSize)position;
/** dealloc the map from memory */
-(void) releaseMap;
@end
