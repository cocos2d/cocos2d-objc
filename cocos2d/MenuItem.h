/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */

#import <UIKit/UIKit.h>

#import "CocosNode.h"

@class Label;
@class Sprite;

#define kItemSize 32

/** Menu Item base class
 */
@interface MenuItem : CocosNode
{
	NSInvocation *invocation;
    BOOL isEnabled;
}
/** creates a menu item with a target/selector */
+(id) itemWithTarget:(id) r selector:(SEL) s;

/** initializes a menu item with a target/selector */
-(id) initWithTarget:(id) r selector:(SEL) s;

/** returns the outside box */
-(CGRect) rect;

/** activate the item */
-(void) activate;

/** the item was selected (not activated), similar to "mouse-over" */
-(void) selected;

/** the item was unselected */
-(void) unselected;

/** enable or disabled the MenuItem */
-(void) setIsEnabled: (BOOL)enabled;
/** returns whether or not the MenuItem is enabled */
-(BOOL) isEnabled;

/** returns the height of the item */
-(unsigned int) height;


@end



/** A MenuItemFont */
@interface MenuItemFont : MenuItem
{
	Label *label;
	Action *zoomAction;
}

@property (assign, readwrite) Label* label;

/** set font size */
+(void) setFontSize: (int) s;

/** get font size */
+(int) fontSize;

/** set the font name */
+(void) setFontName: (NSString*) n;

/** get the font name */
+(NSString*) fontName;

/** creates a menu item from a string */
+(id) itemFromString: (NSString*) value target:(id) r selector:(SEL) s;

/** initializes a menu item from a string */
-(id) initFromString: (NSString*) value target:(id) r selector:(SEL) s;
@end



/** A MenuItemImage */
@interface MenuItemImage : MenuItem
{
	BOOL selected;
	Sprite *normalImage, *selectedImage, *disabledImage;
}
/** creates a menu item from a string */
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) r selector:(SEL) s;
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s;

/** initializes a menu item from a string */
-(id) initFromNormalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s;
@end

