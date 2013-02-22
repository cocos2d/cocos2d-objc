/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2011 Ricardo Quesada
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
 */

#import "CCNode.h"
#import "CCProtocols.h"

@class CCSprite;
@class CCSpriteFrame;

#define kCCItemSize 32

#pragma mark -
#pragma mark CCMenuItem
/** CCMenuItem base class
 *
 *  Subclass CCMenuItem (or any subclass) to create your custom CCMenuItem objects.
 */
@interface CCMenuItem : CCNodeRGBA
{
	// used for menu items using a block
	void (^_block)(id sender);

	BOOL _isEnabled;
	BOOL _isSelected;
	
	BOOL _releaseBlockAtCleanup;
}

/** returns whether or not the item is selected
@since v0.8.2
*/
@property (nonatomic,readonly) BOOL isSelected;

/** If enabled, it releases the block at cleanup time.
 @since v2.1
 */
@property (nonatomic) BOOL releaseBlockAtCleanup;

/** Creates a CCMenuItem with a target/selector.
 target/selector will be implemented using blocks.
 "target" won't be retained.
 */
+(id) itemWithTarget:(id)target selector:(SEL)selector;

/** Creates a CCMenuItem with the specified block.
 The block will be "copied".
 */
+(id) itemWithBlock:(void(^)(id sender))block;

/** Initializes a CCMenuItem with a target/selector */
-(id) initWithTarget:(id)target selector:(SEL)selector;

/** Initializes a CCMenuItem with the specified block.
 The block will be "copied".
*/
-(id) initWithBlock:(void(^)(id sender))block;

/** Returns the outside box in points */
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

/** Sets the block that is called when the item is tapped.
 The block will be "copied".
 */
-(void) setBlock:(void(^)(id sender))block;

/** Sets the target and selector that is called when the item is tapped.
 target/selector will be implemented using blocks.
 "target" won't be retained.
 */
-(void) setTarget:(id)target selector:(SEL)selector;

/** cleanup event. It will release the block and call [super cleanup] */
-(void) cleanup;

@end

#pragma mark -
#pragma mark CCMenuItemLabel

/** An abstract class for "label" CCMenuItemLabel items
 Any CCNode that supports the CCLabelProtocol protocol can be added.
 Supported nodes:
   - CCLabelBMFont
   - CCLabelAtlas
   - CCLabelTTF
 */
@interface CCMenuItemLabel : CCMenuItem
{
	CCNode<CCLabelProtocol, CCRGBAProtocol> *_label;
	ccColor3B	_colorBackup;
	ccColor3B	_disabledColor;
	float		_originalScale;
}

/** the color that will be used to disable the item */
@property (nonatomic,readwrite) ccColor3B disabledColor;

/** Label that is rendered. It can be any CCNode that implements the CCLabelProtocol */
@property (nonatomic,readwrite,assign) CCNode<CCLabelProtocol, CCRGBAProtocol>* label;

/** creates a CCMenuItemLabel with a Label. */
+(id) itemWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label;

/** creates a CCMenuItemLabel with a Label, target and selector.
 The "target" won't be retained.
 */
+(id) itemWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label target:(id)target selector:(SEL)selector;

/** creates a CCMenuItemLabel with a Label and a block to execute.
 The block will be "copied".
 */
+(id) itemWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label block:(void(^)(id sender))block;

/** initializes a CCMenuItemLabel with a Label, target and selector.
 Internally it will create a block that executes the target/selector.
 The "target" won't be retained.
 */
-(id) initWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label target:(id)target selector:(SEL)selector;

/** initializes a CCMenuItemLabel with a Label and a block to execute.
 The block will be "copied".
 This is the designated initializer.
 */
-(id) initWithLabel:(CCNode<CCLabelProtocol,CCRGBAProtocol>*)label block:(void(^)(id sender))block;

/** sets a new string to the inner label */
-(void) setString:(NSString*)label;

/** Enable or disabled the CCMenuItemFont
 @warning setIsEnabled changes the RGB color of the font
 */
-(void) setIsEnabled: (BOOL)enabled;
@end

#pragma mark -
#pragma mark CCMenuItemAtlasFont

/** A CCMenuItemAtlasFont
 Helper class that creates a CCMenuItemLabel class with a CCLabelAtlas
 */
@interface CCMenuItemAtlasFont : CCMenuItemLabel
{
}

/** creates a menu item from a string and atlas with a target/selector */
+(id) itemWithString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap;

/** creates a menu item from a string and atlas. Use it with CCMenuItemToggle.
 The "target" won't be retained.
 */
+(id) itemWithString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id)target selector:(SEL)selector;

/** initializes a menu item from a string and atlas with a target/selector.
  The "target" won't be retained.
 */
-(id) initWithString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap target:(id)target selector:(SEL)selector;

/** creates a menu item from a string and atlas. Use it with CCMenuItemToggle.
 The block will be "copied".
 */
+(id) itemWithString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap block:(void(^)(id sender))block;

/** initializes a menu item from a string and atlas with a  block.
 The block will be "copied".
 */
-(id) initWithString: (NSString*) value charMapFile:(NSString*) charMapFile itemWidth:(int)itemWidth itemHeight:(int)itemHeight startCharMap:(char)startCharMap block:(void(^)(id sender))block;

@end

#pragma mark -
#pragma mark CCMenuItemFont

/** A CCMenuItemFont
 Helper class that creates a CCMenuItemLabel class with a Label
 */
@interface CCMenuItemFont : CCMenuItemLabel
{
	NSUInteger _fontSize;
	NSString *_fontName;
}
/** set default font size */
+(void) setFontSize: (NSUInteger) s;

/** get default font size */
+(NSUInteger) fontSize;

/** set default font name */
+(void) setFontName: (NSString*) n;

/** get default font name */
+(NSString*) fontName;

/** creates a menu item from a string without target/selector. To be used with CCMenuItemToggle */
+(id) itemWithString: (NSString*) value;

/** creates a menu item from a string with a target/selector.
 The "target" won't be retained.
 */
+(id) itemWithString: (NSString*) value target:(id) r selector:(SEL) s;

/** creates a menu item from a string with the specified block.
 The block will be "copied".
 */
+(id) itemWithString: (NSString*) value block:(void(^)(id sender))block;

/** initializes a menu item from a string with a target/selector
  The "target" won't be retained.
 */
-(id) initWithString: (NSString*) value target:(id) r selector:(SEL) s;

/** set font size */
-(void) setFontSize: (NSUInteger) s;

/** get font size */
-(NSUInteger) fontSize;

/** set the font name */
-(void) setFontName: (NSString*) n;

/** get the font name */
-(NSString*) fontName;

/** initializes a menu item from a string with the specified block.
 The block will be "copied".
 */
-(id) initWithString: (NSString*) value block:(void(^)(id sender))block;

@end

#pragma mark -
#pragma mark CCMenuItemSprite

/** CCMenuItemSprite accepts CCNode<CCRGBAProtocol> objects as items.
 The images has 3 different states:
 - unselected image
 - selected image
 - disabled image

 @since v0.8.0
 */
@interface CCMenuItemSprite : CCMenuItem <CCRGBAProtocol>
{
	CCNode<CCRGBAProtocol> *_normalImage, *_selectedImage, *_disabledImage;
}

// weak references

/** the image used when the item is not selected */
@property (nonatomic,readwrite,assign) CCNode<CCRGBAProtocol> *normalImage;
/** the image used when the item is selected */
@property (nonatomic,readwrite,assign) CCNode<CCRGBAProtocol> *selectedImage;
/** the image used when the item is disabled */
@property (nonatomic,readwrite,assign) CCNode<CCRGBAProtocol> *disabledImage;

/** creates a menu item with a normal and selected image*/
+(id) itemWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite;
/** creates a menu item with a normal and selected image with target/selector.
 The "target" won't be retained.
 */
+(id) itemWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite target:(id)target selector:(SEL)selector;

/** creates a menu item with a normal, selected and disabled image with target/selector.
 The "target" won't be retained.
 */
+(id) itemWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector;

/** creates a menu item with a normal and selected image with a block.
 The block will be "copied".
 */
+(id) itemWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite block:(void(^)(id sender))block;

/** creates a menu item with a normal, selected and disabled image with a block.
 The block will be "copied".
 */
+(id) itemWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite block:(void(^)(id sender))block;

/** initializes a menu item with a normal, selected  and disabled image with target/selector.
 The "target" won't be retained.
 */
-(id) initWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite target:(id)target selector:(SEL)selector;

/** initializes a menu item with a normal, selected  and disabled image with a block.
 The block will be "copied".
 */
-(id) initWithNormalSprite:(CCNode<CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode<CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol>*)disabledSprite block:(void(^)(id sender))block;

@end

#pragma mark -
#pragma mark CCMenuItemImage

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
+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2;

/** creates a menu item with a normal, selected and disabled image */
+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage: (NSString*) value3;

/** creates a menu item with a normal and selected image with target/selector */
+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2 target:(id) r selector:(SEL) s;

/** creates a menu item with a normal, selected and disabled image with target/selector.
 The "target" won't be retained.
 */
+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s;

/** creates a menu item with a normal and selected image with a block.
 The block will be "copied".
 */
+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2 block:(void(^)(id sender))block;

/** creates a menu item with a normal, selected and disabled image with a block.
 The block will be "copied".
*/
+(id) itemWithNormalImage: (NSString*)value selectedImage:(NSString*) value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block;

/** initializes a menu item with a normal, selected  and disabled image with target/selector.
 The "target" won't be retained.
 */
-(id) initWithNormalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 target:(id) r selector:(SEL) s;

/** initializes a menu item with a normal, selected  and disabled image with a block.
 The block will be "copied".
*/
-(id) initWithNormalImage: (NSString*) value selectedImage:(NSString*)value2 disabledImage:(NSString*) value3 block:(void(^)(id sender))block;

/** sets the sprite frame for the normal image */
- (void) setNormalSpriteFrame:(CCSpriteFrame*)frame;

/** sets the sprite frame for the selected image */
- (void) setSelectedSpriteFrame:(CCSpriteFrame*)frame;

/** sets the sprite frame for the disabled image */
- (void) setDisabledSpriteFrame:(CCSpriteFrame*)frame;

@end

#pragma mark -
#pragma mark CCMenuItemToggle

/** A CCMenuItemToggle
 A simple container class that "toggles" its inner items
 The inner itmes can be any MenuItem
 */
@interface CCMenuItemToggle : CCMenuItem <CCRGBAProtocol>
{
	NSUInteger	_selectedIndex;
	NSMutableArray* _subItems;
    CCMenuItem*	_currentItem;
}

/** returns the selected item */
@property (nonatomic,readwrite) NSUInteger selectedIndex;
/** NSMutableArray that contains the subitems. You can add/remove items in runtime, and you can replace the array with a new one.
 @since v0.7.2
 */
@property (nonatomic,readwrite,retain) NSMutableArray *subItems;

/** creates a menu item from a list of items with a target/selector */
+(id) itemWithTarget:(id)target selector:(SEL)selector items:(CCMenuItem*) item, ... NS_REQUIRES_NIL_TERMINATION;
+(id) itemWithTarget:(id)target selector:(SEL)selector items:(CCMenuItem*) item vaList:(va_list)args;

/** creates a menu item from a list of items. */
+(id) itemWithItems:(NSArray*)arrayOfItems;

/** creates a menu item from a list of items and executes the given block when the item is selected.
 The block will be "copied".
 */
+(id) itemWithItems:(NSArray*)arrayOfItems block:(void(^)(id sender))block;

/** initializes a menu item from a list of items with a block.
 The block will be "copied".
 */
-(id) initWithItems:(NSArray*)arrayOfItems block:(void (^)(id))block;

/** return the selected item */
-(CCMenuItem*) selectedItem;
@end

