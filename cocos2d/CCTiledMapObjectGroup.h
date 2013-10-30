/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Neophit
 *
 * Copyright (c) 2010 Ricardo Quesada
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


@class CCTiledMapObjectGroup;


/** CCTMXObjectGroup represents the TMX object group.
@since v0.99.0
*/
@interface CCTiledMapObjectGroup : NSObject
{
	NSString			*_groupName;
	CGPoint				_positionOffset;
	NSMutableArray		*_objects;
	NSMutableDictionary	*_properties;
}

/** name of the group */
@property (nonatomic,readwrite,strong) NSString *groupName;
/** offset position of child objects */
@property (nonatomic,readwrite,assign) CGPoint positionOffset;
/** array of the objects */
@property (nonatomic,readwrite,strong) NSMutableArray *objects;
/** list of properties stored in a dictionary */
@property (nonatomic,readwrite,strong) NSMutableDictionary *properties;

/** return the value for the specific property name */
-(id) propertyNamed:(NSString *)propertyName;

/** return the dictionary for the specific object name.
 It will return the 1st object found on the array for the given name.
 */
-(NSMutableDictionary*) objectNamed:(NSString *)objectName;

@end
