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

#import "CCNode.h"
#import "CCProtocols.h"

@class CCLabel;
@class CCLabelAtlas;
@class CCSprite;

#define kItemSize 32

/** CCMenuItem base class
 *
 *  Subclass CCMenuItem (or any subclass) to create your custom CCMenuItem objects.
 */
@interface CCMenuItem : CCNode
{
	NSInvocation *invocation;
	BOOL isEnabled_;
	BOOL isSelected_;
}

/** returns whether or not the item is selected
@since v0.8.2
*/
@property (nonatomic,readonly) BOOL isSelected;

/** Creates a CCMenuItem with a target/selector */
+(id) itemWithTarget:(id)target selector:(SEL)selector;

/** Initializes a CCMenuItem with a target/selector */
-(id) initWithTarget:(id)target selector:(SEL)selector;

/** Returns the outside box */
-(CGRect) rect;

/** Activate the item */
-(void) activate;

/** The item was selected (not activated), similar to "mouse-over" */
-(void) selected;

/** The item was unselected */
-(void) unselected;

/** Enable or disabled the CCMenuItem */
-(void) setIsEnabled:(BOOL)enabled;
/** Returns whether or not the CCMenuItem is enabled */
-(BOOL) isEnabled;
@end

/** An abstract class for "label" CCMenuItemLabel items 
 Any CCNode that supports the CCLabelProtocol protocol can be added.
 Supported nodes:
   - CCBitmapFontAtlas
   - CCLabelAtlas
   - CCLabel
 */
@interface CCMenuItemLabel : CCMenuItem  <CCRGBAProtocol>
{
	CCNode<CCLabelProtocol, CCRGBAProtocol> *label_;
	ccColor3B	colorBackup;
	ccColor3B	disabledColor_;
}

/** the color that will be used to disable the item */
@property (nonatomic,readwrite) ccColor3B disabledColor;

/** Label that is rendered. It can be any CCNode that implements the CCLabelProtocol */
@property (nonatomic,readwrite,retain) CCNode<CCLabelProtocol, CCRGBAProtocol>* label;

/** creates a CCMenuItemLabel with a Label, target and selector */
+(id) itemWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label target:(id)target selector:(SEL)selector;

/** initializes a CCMenuItemLabel with a Label, target and selector */
-(id) initWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label target:(id)target selector:(SEL)selector;

/** sets a new string to the inner label */
-(void) setString:(NSString*)label;

/** Enable or disabled the CCMenuItemFont
 @warning setIsEnabled changes the RGB color of the font
 */
-(void) setIsEnabled: (BOOL)enabled;
@end

/** A CCMenuItemAtlasFont
 Helper class that creates a MenuItemLabel class with a LabelAtlas
 */
@interface CCMenuItemAtlasFont : CCMenuItemLabel
{
}

/** creates a menu item from a string and atlas with a target/selector */
+(id) itemFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap;

/** creates a menu item from a string and atlas. Use it with MenuItemToggle */
+(id) itemFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id) rec selector:(SEL) cb;

/** initializes a menu item from a string and atlas with a target/selector */
-(id) initFromString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id) rec selector:(SEL) cb;


@end

/** A CCMenuItemFont
 Helper class that creates a CCMenuItemLabel class with a Label
 */
@interface CCMenuItemFont : CCMenuItemLabel
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

/** creates a menu item from a string without target/selector. To be used with CCMenuItemToggle */
+(id) itemFromString: (NSString*) value;

/** creates a menu item from a string with a target/selector */
+(id) itemFromString: (NSString*) value target:(id) r selector:(SEL) s;

/** initializes a menu item from a string with a target/selector */
-(id) initFromString: (NSString*) value target:(id) r selector:(SEL) s;
@end

/** CCMenuItemSprite accepts CCNode<CCRGBAProtocol> objects as items.
 The images has 3 different states:
 - unselected image
 - selected image
 - disabled image
 
 @since v0.8.0
 */
@interface CCMenuItemSprite : CCMenuItem <CCRGBAProtocol>
{
	CCNode<CCRGBAProtocol> *normalImage_, *selectedImage_, *disabledImage_;
}

/** the image used when the item is not selected */
@property (nonatomic,readwrite,retain) CCNode<CCRGBAProtocol> *normalImage;
/** the image used when the item is selected */
@property (nonatomic,readwrite,retain) CCNode<CCRGBAProtocol> *selectedImage;
/** the image used when the item is disabled */
@property (nonatomic,readwrite,retain) CCNode<CCRGBAProtocol> *disabledImage;

/** creates a menu item with a normal and selected image*/
+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite;
/** creates a menu item with a normal and selected image with target/selector */
+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite target:(id)target selector:(SEL)selector;
/** creates a menu item with a normal,selected  and disabled image with target/selector */
+(id) itemFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector;
/** initializes a menu item with a normal, selected  and disabled image with target/selector */
-(id) initFromNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector;

@end

/** CCMenuItemImage accepts images as items.
 The images has 3 different states:
 - unselected image
 - selected image
 - disabled image
 
 For best results try that all images are of the same size
 */
@interface CCMenuItemImage : CCMenuItemSprite
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



/** A CCMenuItemToggle
 A simple container class that "toggles" it's inner items
 The inner itmes can be any MenuItem
 */
@interface CCMenuItemToggle : CCMenuItem <CCRGBAProtocol>
{
	NSUInteger selectedIndex_;
	NSMutableArray* subItems_;
	GLubyte		opacity_;
	ccColor3B	color_;
}

/** conforms with CCRGBAProtocol protocol */
@property (nonatomic,readonly) GLubyte opacity;
/** conforms with CCRGBAProtocol protocol */
@property (nonatomic,readonly) ccColor3B color;

/** returns the selected item */
@property (nonatomic,readwrite) NSUInteger selectedIndex;
/** NSMutableArray that contains the subitems. You can add/remove items in runtime, and you can replace the array with a new one.
 @since v0.7.2
 */
@property (nonatomic,readwrite,retain) NSMutableArray *subItems;

/** creates a menu item from a list of items with a target/selector */
+(id) itemWithTarget:(id)t selector:(SEL)s items:(CCMenuItem*) item, ... NS_REQUIRES_NIL_TERMINATION;

/** initializes a menu item from a list of items with a target selector */
-(id) initWithTarget:(id)t selector:(SEL)s items:(CCMenuItem*) item vaList:(va_list) args;

/** return the selected item */
-(CCMenuItem*) selectedItem;
@end

