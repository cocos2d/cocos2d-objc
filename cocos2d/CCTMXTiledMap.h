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

#import "CCNode.h"


@class CCTMXLayer;
@class CCTMXObjectGroup;

/** Possible oritentations of the TMX map */
enum
{
	/** Orthogonal orientation */
	CCTMXOrientationOrtho,
	
	/** Hexagonal orientation */
	CCTMXOrientationHex,
	
	/** Isometric orientation */
	CCTMXOrientationIso,
};

/** CCTMXTiledMap knows how to parse and render a TMX map.
 
 It adds support for the TMX tiled map format used by http://www.mapeditor.org
 It supports isometric, hexagonal and orthogonal tiles.
 It also supports object groups, objects, and properties.

 Features:
 - Each tile will be treated as an CCSprite
 - The sprites are created on demand. They will be created only when you call "[layer tileAt:]"
 - Each tile can be rotated / moved / scaled / tinted / "opacitied", since each tile is a CCSprite
 - Tiles can be added/removed in runtime
 - The z-order of the tiles can be modified in runtime
 - Each tile has an anchorPoint of (0,0)
 - The anchorPoint of the TMXTileMap is (0,0)
 - The TMX layers will be added as a child
 - The TMX layers will be aliased by default
 - The tileset image will be loaded using the CCTextureCache
 - Each tile will have a unique tag
 - Each tile will have a unique z value. top-left: z=1, bottom-right: z=max z
 - Each object group will be treated as an NSMutableArray
 - Object class which will contain all the properties in a dictionary
 - Properties can be assigned to the Map, Layer, Object Group, and Object
 
 Limitations:
 - It only supports one tileset per layer.
 - Embeded images are not supported
 - It only supports the XML format (the JSON format is not supported)
 
 Technical description:
   Each layer is created using an CCTMXLayer (subclass of CCSpriteSheet). If you have 5 layers, then 5 CCTMXLayer will be created,
   unless the layer visibility is off. In that case, the layer won't be created at all.
   You can obtain the layers (CCTMXLayer objects) at runtime by:
  - [map getChildByTag: tag_number];  // 0=1st layer, 1=2nd layer, 2=3rd layer, etc...
  - [map layerNamed: name_of_the_layer];

   Each object group is created using a CCTMXObjectGroup which is a subclass of NSMutableArray.
   You can obtain the object groups at runtime by:
   - [map objectGroupNamed: name_of_the_object_group];
  
   Each object is a CCTMXObject.

   Each property is stored as a key-value pair in an NSMutableDictionary.
   You can obtain the properties at runtime by:
 
		[map propertyNamed: name_of_the_property];
		[layer propertyNamed: name_of_the_property];
		[objectGroup propertyNamed: name_of_the_property];
		[object propertyNamed: name_of_the_property];

 @since v0.8.1
 */
@interface CCTMXTiledMap : CCNode
{
	CGSize				mapSize_;
	CGSize				tileSize_;
	int					mapOrientation_;
	NSMutableArray		*objectGroups_;
	NSMutableDictionary	*properties_;
	NSMutableDictionary	*tileProperties_;
}

/** the map's size property measured in tiles */
@property (nonatomic,readonly) CGSize mapSize;
/** the tiles's size property measured in pixels */
@property (nonatomic,readonly) CGSize tileSize;
/** map orientation */
@property (nonatomic,readonly) int mapOrientation;
/** object groups */
@property (nonatomic,readwrite,retain) NSMutableArray *objectGroups;
/** properties */
@property (nonatomic,readwrite,retain) NSMutableDictionary *properties;

/** creates a TMX Tiled Map with a TMX file.*/
+(id) tiledMapWithTMXFile:(NSString*)tmxFile;

/** initializes a TMX Tiled Map with a TMX file */
-(id) initWithTMXFile:(NSString*)tmxFile;

/** return the TMXLayer for the specific layer */
-(CCTMXLayer*) layerNamed:(NSString *)layerName;

/** return the TMXObjectGroup for the secific group */
-(CCTMXObjectGroup*) objectGroupNamed:(NSString *)groupName;

/** return the TMXObjectGroup for the secific group
 @deprecated Use map#objectGroupNamed instead
 */
-(CCTMXObjectGroup*) groupNamed:(NSString *)groupName DEPRECATED_ATTRIBUTE;

/** return the value for the specific property name */
-(id) propertyNamed:(NSString *)propertyName;

/** return properties dictionary for tile GID */
-(NSDictionary*)propertiesForGID:(unsigned int)GID;
@end

