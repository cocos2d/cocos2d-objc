/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */

#import "TextureAtlas.h"
#import "AtlasNode.h"
#import "TGAlib.h"

/** A TileMap that laods the font from a Texture Atlas */
@interface TileMapAtlas : AtlasNode {
	
	/// info about the map file
	tImageTGA		*tgaInfo;
	
	/// size of the map in pixels
	CGSize			contentSize;
	
	/// numbers of tiles to render
	int				itemsToRender;
}

@property (readonly) CGSize contentSize;

/** creates the TileMap with a tile file (atlas) with a map file and the width and height of each tile */
+(id) tileMapAtlasWithTileFile:(NSString*)tile mapFile:(NSString*)map tileWidth:(int)w tileHeight:(int)h;

/** initializes the TileMap with a tile file (atlas) with a map file and the width and height of each tile */
-(id) initWithTileFile:(NSString*)tile mapFile:(NSString*)map tileWidth:(int)w tileHeight:(int)h;

@end
