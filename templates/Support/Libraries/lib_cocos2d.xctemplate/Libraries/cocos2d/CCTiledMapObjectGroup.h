/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Neophit
 * Copyright (c) 2010 Ricardo Quesada
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

@class CCTiledMapObjectGroup;

/**
 *  CCTiledMapObjectGroup represents the tile map object group.
 */
@interface CCTiledMapObjectGroup : NSObject {

	NSString			*_groupName;
    
	CGPoint				_positionOffset;
    
	NSMutableArray		*_objects;
    
	NSMutableDictionary	*_properties;
}


/// -----------------------------------------------------------------------
/// @name Accessing the Tile Map Object Group Attributes
/// -----------------------------------------------------------------------

/** Name of the object group. */
@property (nonatomic,readwrite,strong) NSString *groupName;

/** Offset position of child objects, */
@property (nonatomic,readwrite,assign) CGPoint positionOffset;

/** Array of the objects. */
@property (nonatomic,readwrite,strong) NSMutableArray *objects;

/** List of properties stored in the dictionary. */
@property (nonatomic,readwrite,strong) NSMutableDictionary *properties;

/**
 *  Return the value for the specified property name value.
 *
 *  @param propertyName Propery name to lookup.
 *
 *  @return Property name value.
 */
-(id) propertyNamed:(NSString *)propertyName;

/**
 *  Return the dictionary for the first entry of specified object namee.
 *
 *  @param objectName Object name to use.
 *
 *  @return Object dictionary.
 */
-(NSMutableDictionary*) objectNamed:(NSString *)objectName;

@end
