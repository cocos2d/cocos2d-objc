/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
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
@class Sprite;

#define kItemSize 32

/** Menu Item base class
 */
@interface MenuItem : CocosNode <CocosNodeSize, CocosNodeOpacity>
{
	NSInvocation *invocation;
	BOOL isEnabled;
	GLubyte opacity;
}

/** Opacity property. Conforms to CocosNodeOpacity protocol */
@property (readwrite,assign) GLubyte opacity;

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

/** Returns the size in pixels of the texture.
 * Conforms to the CocosNodeSize protocol
 */
-(CGSize) contentSize;
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

/** creates a menu item from a string. Use it with MenuItemToggle */
+(id) itemFromString: (NSString*) value;

/** creates a menu item from a string with a target/selector */
+(id) itemFromString: (NSString*) value target:(id) r selector:(SEL) s;

/** initializes a menu item from a string with a target/selector */
-(id) initFromString: (NSString*) value target:(id) r selector:(SEL) s;
@end


/** A MenuItemImage */
@interface MenuItemImage : MenuItem
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
@interface MenuItemToggle : MenuItem
{
	int selectedIndex;
	NSMutableArray* subItems;
}

/** returns the selected item */
@property (readwrite) int selectedIndex;

/** creates a menu item from a list of items with a target/selector */
+(id) itemWithTarget:(id)t selector:(SEL)s items:(MenuItem*) item, ... NS_REQUIRES_NIL_TERMINATION;

/** initializes a menu item from a list of items with a target selector */
-(id) initWithTarget:(id)t selector:(SEL)s items:(MenuItem*) item vaList:(va_list) args;

/** return the selected item */
-(MenuItem*) selectedItem;
@end

