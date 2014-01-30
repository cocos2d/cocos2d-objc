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

/** Possible oritentations of the TMX map. */
typedef NS_ENUM(NSUInteger, CCTiledMapOrientation)
{
	/** Orthogonal orientation. */
	CCTiledMapOrientationOrtho,

	/** Hexagonal orientation. */
	CCTiledMapOrientationHex,

	/** Isometric orientation. */
	CCTiledMapOrientationIso,
};

/** 
 
 CCTiledMap knows how to parse and render a TMX map.

 ### Features:
 
 - Each tile will be treated as an CCSprite
 - The sprites are created on demand. They will be created only when you call "[layer tileAt:]"
 - Each tile can be rotated / moved / scaled / tinted / "opacitied", since each tile is a CCSprite
 - Tiles can be added/removed in runtime
 - The z-order of the tiles can be modified in runtime
 - Each tile has an anchorPoint of (0,0)
 - The anchorPoint of the TMXTileMap is (0,0)
 - The Tiled layers will be added as a child
 - The Tiled layers will be aliased by default
 - The tileset image will be loaded using the CCTextureCache
 - Each tile will have a unique tag
 - Each tile will have a unique z value. top-left: z=1, bottom-right: z=max z
 - Each object group will be treated as an NSMutableArray
 - Object class which will contain all the properties in a dictionary
 - Properties can be assigned to the Map, Layer, Object Group, and Object

 ### Limitations:
 - It only supports one tileset per layer.
 - Embedded images are not supported
 - It only supports the XML format (the JSON format is not supported)

 ### Notes:
 - Each layer is created using an CCTileMapLayer
 - You can obtain the layers at runtime by:
 - [map getChildByTag: tag_number];
 - [map layerNamed: name_of_the_layer];
 
 ### Supported editors
 
 - Tiled http://www.mapeditor.org/

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
/// @name Accessing the Tile Map Attributes
/// -----------------------------------------------------------------------

/** Map size measured in tiles.*/
@property (nonatomic,readonly) CGSize mapSize;

/** Map Tile size measured in pixels. */
@property (nonatomic,readonly) CGSize tileSize;

/** Map Orientation method. */
@property (nonatomic,readonly) CCTiledMapOrientation mapOrientation;

/** Object Groups. */
@property (nonatomic,readwrite,strong) NSMutableArray *objectGroups;

/** Tile Properties. */
@property (nonatomic,readwrite,strong) NSMutableDictionary *properties;


/// -----------------------------------------------------------------------
/// @name Creating a CCTiledMap Object
/// -----------------------------------------------------------------------

/**
 *  Creates a returns a Tile Map object using the specified TMX file.
 *
 *  @param tmxFile TMX file to use.
 *
 *  @return The CCTiledMap Object.
 */
+(id) tiledMapWithFile:(NSString*)tmxFile;

/**
 *  Creates a returns a Tile Map object using the specified TMX XML and path to TMX resources.
 *
 *  @param tmxString    TMX XML to use.
 *  @param resourcePath TMX resource path.
 *
 *  @return The CCTiledMap Object.
 */
+(id) tiledMapWithXML:(NSString*)tmxString resourcePath:(NSString*)resourcePath;


/// -----------------------------------------------------------------------
/// @name Initializing a CCTiledMap Object
/// -----------------------------------------------------------------------

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
/// @name Tiled Map Helpers
/// -----------------------------------------------------------------------

/**
 *  Return the Tiled Map Layer specified by the layer name.
 *
 *  @param layerName Name of layer to lookup.
 *
 *  @return The CCTiledMapLayer object.
 */
-(CCTiledMapLayer*) layerNamed:(NSString *)layerName;

/** return the TMXObjectGroup for the specific group */

/**
 *  Return the Tiled Map Object Group specified by the object group name.
 *
 *  @param groupName Object group name to lookup.
 *
 *  @return The CCTiledMapObjectGroup object.
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

