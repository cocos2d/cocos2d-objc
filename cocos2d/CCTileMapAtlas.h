/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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

#import "CCTextureAtlas.h"
#import "CCAtlasNode.h"
#import "Support/TGAlib.h"

/** CCTileMapAtlas is a subclass of CCAtlasNode.

 It knows how to render a map based of tiles.
 The tiles must be in a .PNG format while the map must be a .TGA file.

 For more information regarding the format, please see this post:
 http://www.cocos2d-iphone.org/archives/27

 All features from CCAtlasNode are valid in CCTileMapAtlas

 IMPORTANT:
 This class is deprecated. It is maintained for compatibility reasons only.
 You SHOULD not use this class.
 Instead, use the newer TMX file format: CCTMXTiledMap
 */
@interface CCTileMapAtlas : CCAtlasNode
{

	/// info about the map file
	tImageTGA		*tgaInfo;

	/// x,y to altas dicctionary
	NSMutableDictionary	*posToAtlasIndex;

	/// numbers of tiles to render
	int				itemsToRender;
}

/** TileMap info */
@property (nonatomic,readonly) tImageTGA *tgaInfo;

/** creates a CCTileMap with a tile file (atlas) with a map file and the width and height of each tile in points.
 The tile file will be loaded using the TextureMgr.
 */
+(id) tileMapAtlasWithTileFile:(NSString*)tile mapFile:(NSString*)map tileWidth:(int)w tileHeight:(int)h;

/** initializes a CCTileMap with a tile file (atlas) with a map file and the width and height of each tile in points.
 The file will be loaded using the TextureMgr.
 */
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
