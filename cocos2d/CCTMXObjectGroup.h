/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2010 Neophit
 * Copyright (C) 2010 Ricardo Quesada
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


@class CCTMXObjectGroup;


/** CCTMXObjectGroup represents the TMX object group.
@since v0.99.0
*/
@interface CCTMXObjectGroup : NSObject
{
	NSString			*groupName_;
	CGPoint				positionOffset_;
	NSMutableArray		*objects_;
	NSMutableDictionary	*properties_;
}

/** name of the group */
@property (nonatomic,readwrite,retain) NSString *groupName;
/** offset position of child objects */
@property (nonatomic,readwrite,assign) CGPoint positionOffset;
/** array of the objects */
@property (nonatomic,readwrite,retain) NSMutableArray *objects;
/** list of properties stored in a dictionary */
@property (nonatomic,readwrite,retain) NSMutableDictionary *properties;

/** return the value for the specific property name */
-(id) propertyNamed:(NSString *)propertyName;

/** return the dictionary for the specific object name.
 It will return the 1st object found on the array for the given name.
 */
-(NSMutableDictionary*) objectNamed:(NSString *)objectName;

@end
