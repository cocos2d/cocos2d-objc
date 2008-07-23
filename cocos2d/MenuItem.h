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

#define kItemSize 32

/** A MenuItem */
@interface MenuItem : CocosNode
{
	Label *label;
	NSInvocation *invocation;	
}

/** set font size */
+(void) setFontSize: (int) s;

/** get font size */
+(int) fontSize;

/** set the font name */
+(void) setFontName: (NSString*) n;

/** get the font name */
+(NSString*) fontName;

/** creates a menu item from a string */
+(id) itemFromString: (NSString*) value receiver:(id) r selector:(SEL) s;

/** initializes a menu item from a string */
-(id) initFromString: (NSString*) value receiver:(id) r selector:(SEL) s;

/** returns the outside box */
-(CGRect) rect;

/** activate the item */
-(void) activate;

/** the item was selected (not activated), similar to "mouse-over" */
-(void) selected;

/** the item was unselected */
-(void) unselected;

/** returns the height of the item */
-(unsigned int) height;
@end
