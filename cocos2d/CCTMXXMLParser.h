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

// Bits on the far end of the 32-bit global tile ID (GID's) are used for tile flags.
typedef enum ccTMXTileFlags_ {
	kCCTMXTileHorizontalFlag		= 0x80000000,
	kCCTMXTileVerticalFlag			= 0x40000000,
	kCCTMXTileDiagonalFlag			= 0x20000000,

	kCCFlipedAll					= (kCCTMXTileHorizontalFlag|kCCTMXTileVerticalFlag|kCCTMXTileDiagonalFlag),
	kCCFlippedMask					= ~(kCCFlipedAll),
} ccTMXTileFlags;


/**
 *  CCTiledMapLayerInfo contains information about the Tile Map Layer. This information is obtained from the supplied Tile Map File (TMX).
 */
@interface CCTiledMapLayerInfo : NSObject

/// -----------------------------------------------------------------------
/// @name Accessing the Tile Map Layer Info Attributes
/// -----------------------------------------------------------------------

/** Layer name. */
@property (nonatomic,readwrite,strong)	NSString *name;

/** Layer size in tiles. */
@property (nonatomic,readwrite)			CGSize layerSize;

/** Layer tile array. */
@property (nonatomic,readwrite)			unsigned int *tiles;

/** Layer visibility. */
@property (nonatomic,readwrite)			BOOL visible;

/** Layer Opacity. */
@property (nonatomic,readwrite)			unsigned char opacity;

/** True to release ownership of layer tiles. */
@property (nonatomic,readwrite)			BOOL ownTiles;

/** Minimum GID. */
@property (nonatomic,readwrite)			unsigned int minGID;

/** Maximum GID. */
@property (nonatomic,readwrite)			unsigned int maxGID;

/** Properties dictionary. */
@property (nonatomic,readwrite,strong) NSMutableDictionary *properties;

/** Layer offset position. */
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
@interface CCTiledMapTilesetInfo : NSObject {
    
	NSString		*_name;
	unsigned int	_firstGid;
	CGSize			_tileSize;
	unsigned int	_spacing;
	unsigned int	_margin;
	
	//	Offset of tiles. New TMX XML node introduced here: https://github.com/bjorn/tiled/issues/16 .
	//	Node structure:
	//	(...) <tileset firstgid="1" name="mytileset-ipad" tilewidth="40" tileheight="40" spacing="1" margin="1">
	//			  <tileoffset x="0" y="10"/>
	//			  <image source="mytileset-ipad.png" width="256" height="256"/>
	//	(...)
	CGPoint         _tileOffset;
	CGPoint			_tileAnchorPoint; //normalized anchor point	

	// filename containing the tiles (should be spritesheet / texture atlas)
	NSString	*_sourceImage;

	// size in pixels of the image
	CGSize		_imageSize;
}

@property (nonatomic,readwrite,strong) NSString *name;
@property (nonatomic,readwrite,assign) unsigned int firstGid;
@property (nonatomic,readwrite,assign) CGSize tileSize;
@property (nonatomic,readwrite,assign) unsigned int spacing;
@property (nonatomic,readwrite,assign) unsigned int margin;
@property (nonatomic,readwrite,strong) NSString *sourceImage;
@property (nonatomic,readwrite,assign) CGSize imageSize;
@property (nonatomic,readwrite,assign) CGPoint tileOffset; //setter has a custom implementation
@property (nonatomic,readonly,assign) CGPoint tileAnchorPoint; //set automatically when tileOffset changes

/**
 *  Return rectange for GID value.
 *
 *  @param gid GID value to use.
 *
 *  @return CGRect.
 */
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
@interface CCTiledMapInfo : NSObject <NSXMLParserDelegate> {
    
	NSMutableString		*_currentString;
    BOOL				_storingCharacters;
	int					_layerAttribs;
	int					_parentElement;
	unsigned int		_parentGID;
	unsigned int		_currentFirstGID;
}

/** Map orienatation method. */
@property (nonatomic,readwrite,assign) int orientation;

/** Map size. */
@property (nonatomic,readwrite,assign) CGSize mapSize;

/** Map tile size. */
@property (nonatomic,readwrite,assign) CGSize tileSize;

/** Map layers array. */
@property (nonatomic,readwrite,strong) NSMutableArray *layers;

/** Map tileset array. */
@property (nonatomic,readwrite,strong) NSMutableArray *tilesets;

/** Tile Map file path. */
@property (nonatomic,readwrite,strong) NSString *filename;

/** Tile Map resource file path. */
@property (nonatomic,readwrite,strong) NSString *resources;

/** Object groups. */
@property (nonatomic,readwrite,strong) NSMutableArray *objectGroups;

/** Properties dictionary. */
@property (nonatomic,readwrite,strong) NSMutableDictionary *properties;

// Tile properties dictionary. */
@property (nonatomic,readwrite,strong) NSMutableDictionary *tileProperties;

/** creates a TMX Format with a tmx file */
+(id) formatWithTMXFile:(NSString*)tmxFile;

/** creates a TMX Format with an XML string and a TMX resource path */
+(id) formatWithXML:(NSString*)tmxString resourcePath:(NSString*)resourcePath;

/** initializes a TMX format with a tmx file */
-(id) initWithFile:(NSString*)tmxFile;

/** initializes a TMX format with an XML string and a TMX resource path */
-(id) initWithXML:(NSString*)tmxString resourcePath:(NSString*)resourcePath;

@end

