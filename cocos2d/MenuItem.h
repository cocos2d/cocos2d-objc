/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <UIKit/UIKit.h>

#import "CocosNode.h"

@class Label;
@class LabelAtlas;
@class Sprite;

#define kItemSize 32

/** Menu Item base class
 */
@interface MenuItem : CocosNode <CocosNodeSize>
{
	NSInvocation *invocation;
	BOOL isEnabled;
}

/** Creates a menu item with a target/selector */
+(id) itemWithTarget:(id) r selector:(SEL) s;

/** Initializes a menu item with a target/selector */
-(id) initWithTarget:(id) r selector:(SEL) s;

/** Returns the outside box */
-(CGRect) rect;

/** Activate the item */
-(void) activate;

/** The item was selected (not activated), similar to "mouse-over" */
-(void) selected;

/** The item was unselected */
-(void) unselected;

/** Enable or disabled the MenuItem */
-(void) setIsEnabled: (BOOL)enabled;
/** Returns whether or not the MenuItem is enabled */
-(BOOL) isEnabled;
@end

/** An abstract class "label" MenuItems */
@interface MenuItemLabel : MenuItem  <CocosNodeRGBA>
{
	id label;
}

/** LabelAtlas that is rendered */
@property (readwrite, retain) id label;

/** Change this menuitem's label's string **/
-(void) setString:(NSString *)string;

/** Enable or disabled the MenuItemFont
 @warning setIsEnabled changes the RGB color of the font
 */
-(void) setIsEnabled: (BOOL)enabled;
@end

/** A MenuItemAtlasFont */
@interface MenuItemAtlasFont : MenuItemLabel
{
}

/** creates a menu item from a string and atlas with a target/selector */
+(id) itemFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap;

/** creates a menu item from a string and atlas. Use it with MenuItemToggle */
+(id) itemFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id) rec selector:(SEL) cb;

/** initializes a menu item from a string and atlas with a target/selector */
-(id) initFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id) rec selector:(SEL) cb;


@end

/** A MenuItemFont */
@interface MenuItemFont : MenuItemLabel
{
}
/** set font size */
+(void) setFontSize: (int) s;

/** get font size */
+(int) fontSize;

/** set the font name */
+(void) setFontName: (NSString*) n;

/** get the font name */
+(NSString*) fontName;

/** creates a menu item from a string. Use it with MenuItemToggle */
+(id) itemFromString: (NSString*) value;

/** creates a menu item from a string with a target/selector */
+(id) itemFromString: (NSString*) value target:(id) r selector:(SEL) s;

/** initializes a menu item from a string with a target/selector */
-(id) initFromString: (NSString*) value target:(id) r selector:(SEL) s;
@end

/** A MenuItemImage */
@interface MenuItemImage : MenuItem <CocosNodeRGBA>
{
	BOOL selected;
	Sprite *normalImage, *selectedImage, *disabledImage;
}

/// Sprite (image) that is displayed when the MenuItem is not selected
@property (readonly) Sprite *normalImage;
/// Sprite (image) that is displayed when the MenuItem is selected
@property (readonly) Sprite *selectedImage;
/// Sprite (image) that is displayed when the MenuItem is disabled
@property (readonly) Sprite *disabledImage;

/** creates a menu item with a normal and selected image*/
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2;
/** creates a menu item with a normal and selected image with target/selector */
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) r selector:(SEL) s;
/** creates a menu item with a normal,selected  and disabled image with target/selector */
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s;
/** initializes a menu item with a normal, selected  and disabled image with target/selector */
-(id) initFromNormalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s;
@end



/** A MenuItemToggle */
@interface MenuItemToggle : MenuItem <CocosNodeRGBA>
{
	NSUInteger selectedIndex_;
	NSMutableArray* subItems_;
	GLubyte opacity_, r_, g_, b_;
}

/** conforms with CocosNodeRGBA protocol */
@property (readonly) GLubyte opacity,r,g,b;

/** returns the selected item */
@property (readwrite) NSUInteger selectedIndex;
/** NSMutableArray that contains the subitems. You can add/remove items in runtime, and you can replace the array with a new one.
 @since v0.7.2
 */
@property (readwrite,retain) NSMutableArray *subItems;

/** creates a menu item from a list of items with a target/selector */
+(id) itemWithTarget:(id)t selector:(SEL)s items:(MenuItem*) item, ... NS_REQUIRES_NIL_TERMINATION;

/** initializes a menu item from a list of items with a target selector */
-(id) initWithTarget:(id)t selector:(SEL)s items:(MenuItem*) item vaList:(va_list) args;

/** return the selected item */
-(MenuItem*) selectedItem;
@end

