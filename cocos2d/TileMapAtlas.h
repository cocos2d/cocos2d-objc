/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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
#import "TGAlib.h"

/** A TileMap that laods the font from a Texture Atlas */
@interface TileMapAtlas : AtlasNode {
	
	/// info about the map file
	tImageTGA		*tgaInfo;
	
	/// x,y to altas dicctionary
	NSMutableDictionary	*posToAtlasIndex;
	
	/// size of the map in pixels
	CGSize			contentSize;
	
	/// numbers of tiles to render
	int				itemsToRender;
}

/** content size of the TileMap */
@property (readonly) CGSize contentSize;

/** TileMap info */
@property (readonly) tImageTGA *tgaInfo;

/** creates the TileMap with a tile file (atlas) with a map file and the width and height of each tile */
+(id) tileMapAtlasWithTileFile:(NSString*)tile mapFile:(NSString*)map tileWidth:(int)w tileHeight:(int)h;

/** initializes the TileMap with a tile file (atlas) with a map file and the width and height of each tile */
-(id) initWithTileFile:(NSString*)tile mapFile:(NSString*)map tileWidth:(int)w tileHeight:(int)h;

/** returns a tile from position x,y.
 For the moment only channel R is used
 */
-(ccRGBB) tileAt: (ccGrid) position;

/** sets a tile at position x,y.
 For the moment only channel R is used
 */
-(void) setTile:(ccRGBB)tile at:(ccGrid)position;
/** dealloc the map from memory */
-(void) releaseMap;
@end
