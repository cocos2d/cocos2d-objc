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
 */

#import <UIKit/UIKit.h>

#import "CocosNode.h"

@class Label;
@class LabelAtlas;
@class Sprite;

#define kItemSize 32

/** Menu Item base class
 *
 *  Subclass MenuItem (or any subclass) to create your custom MenuItem
 */
@interface MenuItem : CocosNode
{
	NSInvocation *invocation;
	BOOL isEnabled;
}

/** Creates a menu item with a target/selector */
+(id) itemWithTarget:(id)target selector:(SEL)selector;

/** Initializes a menu item with a target/selector */
-(id) initWithTarget:(id)target selector:(SEL)selector;

/** Returns the outside box */
-(CGRect) rect;

/** Activate the item */
-(void) activate;

/** The item was selected (not activated), similar to "mouse-over" */
-(void) selected;

/** The item was unselected */
-(void) unselected;

/** Enable or disabled the MenuItem */
-(void) setIsEnabled:(BOOL)enabled;
/** Returns whether or not the MenuItem is enabled */
-(BOOL) isEnabled;
@end

/** An abstract class for "label" MenuItems 
 Any CocosNode that supports the CocosNodeLabel protocol can be added.
 Supported nodes:
   - BitmapFontAtlas
   - LabelAtlas
   - Label
 */
@interface MenuItemLabel : MenuItem  <CocosNodeRGBA>
{
	CocosNode<CocosNodeLabel, CocosNodeRGBA> *label_;
}

/** Label that is rendered. It can be any CocosNode that implements the CocosNodeLabel */
@property (readwrite,retain) CocosNode<CocosNodeLabel, CocosNodeRGBA>* label;

/** creates a MenuItemLabel with a Label, target and selector */
+(id) itemWithLabel:(CocosNode<CocosNodeLabel,CocosNodeRGBA>*)label target:(id)target selector:(SEL)selector;

/** initializes a MenuItemLabel with a Label, target and selector */
-(id) initWithLabel:(CocosNode<CocosNodeLabel,CocosNodeRGBA>*)label target:(id)target selector:(SEL)selector;

/** sets a new string to the inner label */
-(void) setString:(NSString*)label;

/** Enable or disabled the MenuItemFont
 @warning setIsEnabled changes the RGB color of the font
 */
-(void) setIsEnabled: (BOOL)enabled;
@end

/** A MenuItemAtlasFont
 Helper class that creates a MenuItemLabel class with a LabelAtlas
 */
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

/** A MenuItemFont
 Helper class that creates a MenuItemLabel class with a Label
 */
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

/** MenuItemSprite accepts CocosNode<CocosNodeRGBA> objects as items.
 The images has 3 different states:
 - unselected image
 - selected image
 - disabled image
 
 @since v0.8.0
 */
@interface MenuItemSprite : MenuItem <CocosNodeRGBA>
{
	BOOL selected;
	CocosNode<CocosNodeRGBA> *normalImage_, *selectedImage_, *disabledImage_;
}

/** the image used when the item is not selected */
@property (readwrite,retain) CocosNode<CocosNodeRGBA> *normalImage;
/** the image used when the item is selected */
@property (readwrite,retain) CocosNode<CocosNodeRGBA> *selectedImage;
/** the image used when the item is disabled */
@property (readwrite,retain) CocosNode<CocosNodeRGBA> *disabledImage;

/** creates a menu item with a normal and selected image*/
+(id) itemFromNormalSprite:(CocosNode<CocosNodeRGBA>*)normalSprite selectedSprite:(CocosNode<CocosNodeRGBA>*)selectedSprite;
/** creates a menu item with a normal and selected image with target/selector */
+(id) itemFromNormalSprite:(CocosNode<CocosNodeRGBA>*)normalSprite selectedSprite:(CocosNode<CocosNodeRGBA>*)selectedSprite target:(id)target selector:(SEL)selector;
/** creates a menu item with a normal,selected  and disabled image with target/selector */
+(id) itemFromNormalSprite:(CocosNode<CocosNodeRGBA>*)normalSprite selectedSprite:(CocosNode<CocosNodeRGBA>*)selectedSprite disabledSprite:(CocosNode<CocosNodeRGBA>*)disabledSprite target:(id)target selector:(SEL)selector;
/** initializes a menu item with a normal, selected  and disabled image with target/selector */
-(id) initFromNormalSprite:(CocosNode<CocosNodeRGBA>*)normalSprite selectedSprite:(CocosNode<CocosNodeRGBA>*)selectedSprite disabledSprite:(CocosNode<CocosNodeRGBA>*)disabledSprite target:(id)target selector:(SEL)selector;

@end

/** MenuItemAtlasCocosNode<CocosNodeRGBA> accepts AtlasCocosNode<CocosNodeRGBA> objects as items.
 The images has 3 different states:
 - unselected image
 - selected image
 - disabled image
 
 Limitations:
  - AtlasSprite objects can only have as a parent an AltasSpriteManager
  - So they need to be added twice:
    - To the Menu
	- And to the AtlasSpriteManager
  - To respect the menu aligments, the AtlasSpriteManager should have the same coordinates as the Menu
 @since v0.8.0
 */
@interface MenuItemAtlasSprite : MenuItemSprite
{
}
@end

/** MenuItemImage accepts images as items.
 The images has 3 different states:
 - unselected image
 - selected image
 - disabled image
 
 For best results try that all images are of the same size
 */
@interface MenuItemImage : MenuItemSprite
{
}

/** creates a menu item with a normal and selected image*/
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2;
/** creates a menu item with a normal and selected image with target/selector */
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) r selector:(SEL) s;
/** creates a menu item with a normal,selected  and disabled image with target/selector */
+(id) itemFromNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s;
/** initializes a menu item with a normal, selected  and disabled image with target/selector */
-(id) initFromNormalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s;
@end



/** A MenuItemToggle
 A simple container class that "toggles" it's inner items
 The inner itmes can be any MenuItem
 */
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

