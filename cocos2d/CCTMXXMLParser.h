/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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
@property (nonatomic,readwrite)			float opacity;

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


/**
 *  CCTiledMapTilesetInfo contains information about the Tile Map's Tileset. This information is obtained from the supplied Tile Map File (TMX).
 */
@interface CCTiledMapTilesetInfo : NSObject


/// -----------------------------------------------------------------------
/// @name Accessing the Tile Map Tileset Info Attributes
/// -----------------------------------------------------------------------

/** Tileset name. */
@property (nonatomic,readwrite,strong) NSString *name;

/** First GID. */
@property (nonatomic,readwrite,assign) unsigned int firstGid;

/** Tileset size. */
@property (nonatomic,readwrite,assign) CGSize tileSize;

/** Tileset spacing. */
@property (nonatomic,readwrite,assign) unsigned int spacing;

/** Tileset margin. */
@property (nonatomic,readwrite,assign) unsigned int margin;

/** Tileset source texture, should be spritesheet. */
@property (nonatomic,readwrite,strong) NSString *sourceImage;

/** Size of image in pixels. */
@property (nonatomic,readwrite,assign) CGSize imageSize;

/** Tileset offset in pixels. */
@property (nonatomic,readwrite,assign) CGPoint tileOffset;

/** Auto set when tileOffset is modified. */
@property (nonatomic,readonly,assign) CGPoint tileAnchorPoint;

/** Content scale of the TMX file. Mostly for backwords compatibility. */
@property (nonatomic,readwrite) CGFloat contentScale;

/// -----------------------------------------------------------------------
/// @name Accessing the Tile Map Tileset Info Helpers
/// -----------------------------------------------------------------------

/**
 *  Return rectange for GID value.
 *
 *  @param gid GID value to use.
 *
 *  @return CGRect.
 */
-(CGRect) rectForGID:(unsigned int)gid;

@end


/**
 *  CCTiledMapInfo contains information regarding the Tile Map. This information is obtained from the supplied Tile Map File (TMX).
 */
@interface CCTiledMapInfo : NSObject <NSXMLParserDelegate> {
    
	NSMutableString		*_currentString;
    BOOL				_storingCharacters;
	int					_layerAttribs;
	int					_parentElement;
	unsigned int		_parentGID;
	unsigned int		_currentFirstGID;
    
}


/// -----------------------------------------------------------------------
/// @name Accessing the Tile Map Info Attributes
/// -----------------------------------------------------------------------

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

/** Content scale of the TMX file. Mostly for backwords compatibility. */
@property (nonatomic,readwrite) CGFloat contentScale;

/// -----------------------------------------------------------------------
/// @name Creating a CCTiledMapInfo Object
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a CCTiledMapInfo object using the TMX format file specified.
 *
 *  @param tmxFile CCTiledMapInfo.
 *
 *  @return The CCTiledMapInfo Object.
 */
+(id) formatWithTMXFile:(NSString*)tmxFile;

/**
 *  Creates and returns a CCTiledMapInfo object using the TMX XML and resource file path.
 *
 *  @param tmxString    TMX XML.
 *  @param resourcePath Resource file path.
 *
 *  @return The CCTiledMapInfo Object.
 */
+(id) formatWithXML:(NSString*)tmxString resourcePath:(NSString*)resourcePath;


/// -----------------------------------------------------------------------
/// @name Initializing a CCTiledMapInfo Object
/// -----------------------------------------------------------------------

/**
 *  Initializes and returns a CCTiledMapInfo object using the TMX format file specified.
 *
 *  @param tmxFile CCTiledMapInfo.
 *
 *  @return An initialized CCTiledMapInfo Object.
 */
-(id) initWithFile:(NSString*)tmxFile;

/**
 *   Initializes and returns a  CCTiledMapInfo object using the TMX XML and resource file path.
 *
 *  @param tmxString    TMX XML.
 *  @param resourcePath Resource file path.
 *
 *  @return An initialized CCTiledMapInfo Object.
 */
-(id) initWithXML:(NSString*)tmxString resourcePath:(NSString*)resourcePath;

@end

