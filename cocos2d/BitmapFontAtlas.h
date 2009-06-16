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
 * Portions of this code are based and inspired on:
 *   http://www.71squared.co.uk/2009/04/iphone-game-programming-tutorial-4-bitmap-font-class
 *   by Michael Daley
 *
 */

#import "AtlasNode.h"
#import "AtlasSpriteManager.h"

/** bitmap font definition */
typedef struct _bitmapFontDef {
	//! ID of the character
	unsigned char charID;
	//! origin and size of the font
	CGRect rect;
	//! The X amount the image should be offset when drawing the image (in pixels)
	int xOffset;
	//! The Y amount the image should be offset when drawing the image (in pixels)
	int yOffset;
	//! The amount to move the current position after drawing the character (in pixels)
	int xAdvance;
} ccBitmapFontDef;

/** BitmapFontAtlas is a subclass of AtlasSpriteManger.
  
 Features:
 - Treats each character like an AtlasSprite. This means that each individual character can be:
   - rotated
   - scaled
   - translated
   - tinted
   - chage the opacity
 - It can be used as part of a menu item.
 - anchorPoint can be used to align the "label"
 - Supports Hiero format (http://slick.cokeandcode.com/demos/hiero.jnlp)
 
 Limitations:
  - All inner characters are using an anchorPoint of (0.5f, 0.5f) and it is not recommend to change it
    because it might affect the rendering
 
 BitmapFontAtlas implements the protocol CocosNodeLabel, like Label and LabelAtlas.
 BitmapFontAtlas has the flexibility of Label, the speed of LabelAtlas and all the features of AtlasSprite.
 If in doubt, use BitmapFontAtlas instead of LabelAtlas / Label.
 
 @since v0.8
 */

enum {
	kBitmapFontAtlasMaxChars = 256,
};

@interface BitmapFontAtlas : AtlasSpriteManager <CocosNodeLabel, CocosNodeRGBA>
{
	// string to render
	NSString		*string_;
	
	// values for kerning
	NSMutableDictionary	*kerningDictionary;

	// FNTConfig: Common Height
	NSUInteger		commonHeight;

	// The characters building up the font
	ccBitmapFontDef	bitmapFontArray[kBitmapFontAtlasMaxChars];
	
	// texture RGBA
	GLubyte	r_,g_,b_, opacity_;	
	BOOL opacityModifyRGB_;
}

/** conforms to CocosNodeRGBA protocol */
@property (readonly) GLubyte r, g, b, opacity;

/** creates a bitmap font altas with an initial string and the FNT file */
+(id) bitmapFontAtlasWithString:(NSString*)string fntFile:(NSString*)fntFile;

/** init a bitmap font altas with an initial string and the FNT file */
-(id) initWithString:(NSString*)string fntFile:(NSString*)fntFile;

/** updates the font chars based on the string to render */
-(void) createFontChars;
@end
