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

#import "CCNode.h"

@class CCTiledMapLayer;
@class CCTiledMapObjectGroup;

/** Supported orientations of the TMX map. Used by CCTiledMap, CCTiledMapLayer and their various "info" classes. */
typedef NS_ENUM(NSUInteger, CCTiledMapOrientation)
{
	/** Orthogonal orientation. */
	CCTiledMapOrientationOrtho,
	
	/** Isometric orientation. */
	CCTiledMapOrientationIso,
};

/** CCTiledMap parses and renders a tile map in the TMX format.

 The Tiled map's layers create CCTiledMapLayer instances which are added as a child nodes of CCTiledMap
 
 ### Limitations:
 
 - Only supports one tileset image per layer.
 - Image layers are not supported.
 - It only supports the Base64 format.
 - Hexagonal and staggered isometric tilemaps are not currently supported.

 ### Tips:
 
 You can obtain the map's layers at runtime by:
 
    [map getChildByTag: tag_number];
    [map layerNamed: name_of_the_layer];
 
 ### Supported editors
 
 - [Tiled Map Editor](http://www.mapeditor.org/)
 - [iTileMaps](https://itunes.apple.com/app/itilemaps/id432784227)
 - And others ...

 */

@interface CCTiledMap : CCNode {
    
    // Map size measured in tiles.
	CGSize				_mapSize;
    
    // Map Tile size measured in pixels.
	CGSize				_tileSize;
    
    // Map Orientation method.
	CCTiledMapOrientation _mapOrientation;
    
    // Object Groups.
	NSMutableArray		*_objectGroups;
    
    // Properties.
	NSMutableDictionary	*_properties;
    
    // Tile Properties.
	NSMutableDictionary	*_tileProperties;
}

/// -----------------------------------------------------------------------
/// @name Creating a Tiled Map
/// -----------------------------------------------------------------------

/**
 *  Creates a returns a Tile Map object using the specified TMX file.
 *
 *  @param tmxFile TMX file to use.
 *
 *  @return The CCTiledMap Object.
 */
+(instancetype) tiledMapWithFile:(NSString*)tmxFile;

/**
 *  Creates a returns a Tile Map object using the specified TMX XML and path to TMX resources.
 *
 *  @param tmxString    TMX XML to use.
 *  @param resourcePath TMX resource path.
 *
 *  @return The CCTiledMap Object.
 */
+(instancetype) tiledMapWithXML:(NSString*)tmxString resourcePath:(NSString*)resourcePath;

/**
 *  Initializes and returns a Tile Map object using the specified TMX file.
 *
 *  @param tmxFile TMX file to use.
 *
 *  @return An initialized CCTiledMap Object.
 */
-(id) initWithFile:(NSString*)tmxFile;

/**
 *  Initializes and returns a Tile Map object using the specified TMX XML and path to TMX resources.
 *
 *  @param tmxString    TMX XML to use.
 *  @param resourcePath TMX resource path.
 *
 *  @return The CCTiledMap Object.
 */
-(id) initWithXML:(NSString*)tmxString resourcePath:(NSString*)resourcePath;


/// -----------------------------------------------------------------------
/// @name Map Attributes
/// -----------------------------------------------------------------------

/** Map size measured in tiles.*/
@property (nonatomic,readonly) CGSize mapSize;

/** Map Tile size measured in pixels. */
@property (nonatomic,readonly) CGSize tileSize;

/** Map Orientation method.
 @see CCTiledMapOrientation */
@property (nonatomic,readonly) CCTiledMapOrientation mapOrientation;

/// -----------------------------------------------------------------------
/// @name Tilemap Objects and Properties
/// -----------------------------------------------------------------------

/** Object Groups contain the objects in a tilemap. */
@property (nonatomic,readwrite,strong) NSMutableArray *objectGroups;

/** Tile Properties. */
@property (nonatomic,readwrite,strong) NSMutableDictionary *properties;


/// -----------------------------------------------------------------------
/// @name Getting specific Layers, Objects and Properties
/// -----------------------------------------------------------------------

/**
 *  Return the Tiled Map Layer specified by the layer name.
 *
 *  @param layerName Name of layer to lookup.
 *
 *  @return The CCTiledMapLayer object.
 *  @see CCTiledMapLayer
 */
-(CCTiledMapLayer*) layerNamed:(NSString *)layerName;

/** return the TMXObjectGroup for the specific group */

/**
 *  Return the Tiled Map Object Group specified by the object group name.
 *
 *  @param groupName Object group name to lookup.
 *
 *  @return The CCTiledMapObjectGroup object.
 *  @see CCTiledMapObjectGroup
 */
-(CCTiledMapObjectGroup*) objectGroupNamed:(NSString *)groupName;

/**
 *  Return the value held by the specified property name.
 *
 *  @param propertyName Property name to lookup.
 *
 *  @return The property value object.
 */
-(id) propertyNamed:(NSString *)propertyName;

/** return properties dictionary for tile GID */

/**
 *  Return the properties dictionary for the specified tile GID.
 *
 *  @param GID GID to lookup.
 *
 *  @return The properties NSDictionary.
 */
-(NSDictionary*)propertiesForGID:(unsigned int)GID;

@end

