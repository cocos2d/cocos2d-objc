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
 * TMX Tiled Map support:
 * http://www.mapeditor.org
 *
 */

#import "CCAtlasNode.h"
#import "CCSpriteSheet.h"
#import "Support/ccArray.h"


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
 - Each tile can be rotated / moved / scaled / tinted / "opacitied"
 - Tiles can be added/removed in runtime
 - The z-order of the tiles can be modified in runtime.
 - Each tile has an anchorPoint of (0,0)
 - The anchorPoint of the TMXTileMap is (0,0)
 - The TMX layers will be added as a child
 - The TMX layers will be aliased by default
 - The tileset image will be loaded using the TextureMgr
 - Each tile will have a unique tag
 - Each tile will have a unique z value. top-left: z=1, bottom-right: z=max z
 - Each object group will be treated as an NSMutableArray
 - Objects can be created using your own classes or a generic object class which will contain all the properties in a dictionary
 - Properties can be assigned to the Map, Layer, Object Group, and Object
 
 Limitations:
 - It only supports one tileset per layer.
 - Embeded images are not supported
 - It only supports the XML format (the JSON format is not supported)
 
 Technical description:
   Each layer is created using an TMXLayer (subclass of CCSpriteSheet). If you have 5 layers, then 5 TMXLayer will be created,
   unless the layer visibility is off. In that case, the layer won't be created at all.
   You can obtain the layers (TMXLayer objects) at runtime by:
  - [map getChildByTag: tag_number];  // 0=1st layer, 1=2nd layer, 2=3rd layer, etc...
  - [map layerNamed: name_of_the_layer];

   Each object group is created using a TMXObjectGroup which is a subclass of NSMutableArray.
   You can obtain the object groups at runtime by:
   - [map groupNamed: name_of_the_object_group];
  
   Each object is created using the "type" property set in Tiled for the class. If "type" is not a valid class or is blank, then
   the generic TMXObject class will be used. If a valid class is specified, each parsed property value will be assigned to
   the object's property matching the parsed property name, if it exists.
   The parser will attempt to convert the property values to the appropriate data types by checking the object's property type
   encoding string. If you want to use CGPoint, CGSize, or CGRect, you need to enclose your values in braces {} within Tiled.
   - {3,2} instead of 3,2
   You can obtain the object at runtime by:
   - [objectGroup objectNamed: name_of_the_object];
  
   Each property is stored as a key-value pair in an NSMutableDictionary.
   You can obtain the properties at runtime by:
   - [map propertyNamed: name_of_the_property];
   - [layer propertyNamed: name_of_the_property];
   - [objectGroup propertyNamed: name_of_the_property];
   - [object propertyNamed: name_of_the_property];

 @since v0.8.1
 */
@interface CCTMXTiledMap : CCNode
{
	CGSize				mapSize_;
	CGSize				tileSize_;
	int					mapOrientation_;
	NSMutableArray		*objectGroups_;
	NSMutableDictionary	*properties_;}

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
-(CCTMXObjectGroup*) groupNamed:(NSString *)groupName;

/** return the value for the specific property name */
-(id) propertyNamed:(NSString *)propertyName;
@end

