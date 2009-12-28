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


@class CCTMXObject;
@class CCTMXObjectGroup;


/** CCTMXObjectGroup represents the TMX object group.
@since v0.9.0
*/
@interface CCTMXObjectGroup : NSObject
{
	NSString			*groupName_;
	NSMutableArray		*objects_;
	NSMutableDictionary	*properties_;
}

/** name of the group */
@property (nonatomic,readwrite,retain) NSString *groupName;
/** array of the objects */
@property (nonatomic,readwrite,retain) NSMutableArray *objects;
/** list of properties stored in a dictionary */
@property (nonatomic,readwrite,retain) NSMutableDictionary *properties;

/** return the value for the specific property name */
-(id) propertyNamed:(NSString *)propertyName;
@end

/** CCTMXObject represents the TMX object.
@since v0.9.0
*/
@interface CCTMXObject : NSObject
{
	NSString			*name_;
	NSMutableDictionary	*properties_;
}

/** name of the group */
@property (nonatomic,readwrite,retain) NSString *name;
/** list of properties stored in a dictionary */
@property (nonatomic,readwrite,retain) NSMutableDictionary *properties;

/** return the value for the specific property name */
-(id) propertyNamed:(NSString *)propertyName;
@end
