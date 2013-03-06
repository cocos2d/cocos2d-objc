/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
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


#import <Foundation/Foundation.h>

#import "ccMacros.h"

enum {
	TMXLayerAttribNone = 1 << 0,
	TMXLayerAttribBase64 = 1 << 1,
	TMXLayerAttribGzip = 1 << 2,
	TMXLayerAttribZlib = 1 << 3,
};

enum {
	TMXPropertyNone,
	TMXPropertyMap,
	TMXPropertyLayer,
	TMXPropertyObjectGroup,
	TMXPropertyObject,
	TMXPropertyTile
};

typedef enum ccTMXTileFlags_ {
	kCCTMXTileHorizontalFlag		= 0x80000000,
	kCCTMXTileVerticalFlag			= 0x40000000,
	kCCTMXTileDiagonalFlag			= 0x20000000,

	kCCFlipedAll					= (kCCTMXTileHorizontalFlag|kCCTMXTileVerticalFlag|kCCTMXTileDiagonalFlag),
	kCCFlippedMask					= ~(kCCFlipedAll),
} ccTMXTileFlags;

// Bits on the far end of the 32-bit global tile ID (GID's) are used for tile flags

/* CCTMXLayerInfo contains the information about the layers like:
 - Layer name
 - Layer size
 - Layer opacity at creation time (it can be modified at runtime)
 - Whether the layer is visible (if it is not visible, then the CCNode won't be created)

 This information is obtained from the TMX file.
 */
@interface CCTMXLayerInfo : NSObject
{
	NSString			*_name;
	CGSize				_layerSize;
	unsigned int		*_tiles;
	BOOL				_visible;
	unsigned char		_opacity;
	BOOL				_ownTiles;
	unsigned int		_minGID;
	unsigned int		_maxGID;
	NSMutableDictionary	*_properties;
	CGPoint				_offset;
}

@property (nonatomic,readwrite,retain)	NSString *name;
@property (nonatomic,readwrite)			CGSize layerSize;
@property (nonatomic,readwrite)			unsigned int *tiles;
@property (nonatomic,readwrite)			BOOL visible;
@property (nonatomic,readwrite)			unsigned char opacity;
@property (nonatomic,readwrite)			BOOL ownTiles;
@property (nonatomic,readwrite)			unsigned int minGID;
@property (nonatomic,readwrite)			unsigned int maxGID;
@property (nonatomic,readwrite,retain) NSMutableDictionary *properties;
@property (nonatomic,readwrite)			CGPoint offset;
@end

/* CCTMXTilesetInfo contains the information about the tilesets like:
 - Tileset name
 - Tilset spacing
 - Tileset margin
 - size of the tiles
 - Image used for the tiles
 - Image size

 This information is obtained from the TMX file.
 */
@interface CCTMXTilesetInfo : NSObject
{
	NSString		*_name;
	unsigned int	_firstGid;
	CGSize			_tileSize;
	unsigned int	_spacing;
	unsigned int	_margin;

	// filename containing the tiles (should be spritesheet / texture atlas)
	NSString	*_sourceImage;

	// size in pixels of the image
	CGSize		_imageSize;
}
@property (nonatomic,readwrite,retain) NSString *name;
@property (nonatomic,readwrite,assign) unsigned int firstGid;
@property (nonatomic,readwrite,assign) CGSize tileSize;
@property (nonatomic,readwrite,assign) unsigned int spacing;
@property (nonatomic,readwrite,assign) unsigned int margin;
@property (nonatomic,readwrite,retain) NSString *sourceImage;
@property (nonatomic,readwrite,assign) CGSize imageSize;

-(CGRect) rectForGID:(unsigned int)gid;
@end

/* CCTMXMapInfo contains the information about the map like:
 - Map orientation (hexagonal, isometric or orthogonal)
 - Tile size
 - Map size

 And it also contains:
 - Layers (an array of TMXLayerInfo objects)
 - Tilesets (an array of TMXTilesetInfo objects)
 - ObjectGroups (an array of TMXObjectGroupInfo objects)

 This information is obtained from the TMX file.

 */
@interface CCTMXMapInfo : NSObject <NSXMLParserDelegate>
{
	NSMutableString		*_currentString;
    BOOL				_storingCharacters;
	int					_layerAttribs;
	int					_parentElement;
	unsigned int		_parentGID;
	unsigned int		_currentFirstGID;

	// tmx filename
	NSString *_filename;

	// tmx resource path
	NSString *_resources;

	// map orientation
	int		_orientation;

	// map width & height
	CGSize	_mapSize;

	// tiles width & height
	CGSize	_tileSize;

	// Layers
	NSMutableArray *_layers;

	// tilesets
	NSMutableArray *_tilesets;

	// ObjectGroups
	NSMutableArray *_objectGroups;

	// properties
	NSMutableDictionary *_properties;

	// tile properties
	NSMutableDictionary *_tileProperties;
}

@property (nonatomic,readwrite,assign) int orientation;
@property (nonatomic,readwrite,assign) CGSize mapSize;
@property (nonatomic,readwrite,assign) CGSize tileSize;
@property (nonatomic,readwrite,retain) NSMutableArray *layers;
@property (nonatomic,readwrite,retain) NSMutableArray *tilesets;
@property (nonatomic,readwrite,retain) NSString *filename;
@property (nonatomic,readwrite,retain) NSString *resources;
@property (nonatomic,readwrite,retain) NSMutableArray *objectGroups;
@property (nonatomic,readwrite,retain) NSMutableDictionary *properties;
@property (nonatomic,readwrite,retain) NSMutableDictionary *tileProperties;

/** creates a TMX Format with a tmx file */
+(id) formatWithTMXFile:(NSString*)tmxFile;

/** creates a TMX Format with an XML string and a TMX resource path */
+(id) formatWithXML:(NSString*)tmxString resourcePath:(NSString*)resourcePath;

/** initializes a TMX format with a tmx file */
-(id) initWithTMXFile:(NSString*)tmxFile;

/** initializes a TMX format with an XML string and a TMX resource path */
-(id) initWithXML:(NSString*)tmxString resourcePath:(NSString*)resourcePath;

@end

