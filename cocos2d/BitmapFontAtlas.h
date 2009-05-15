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

/** Bitmap Font Atlas is a subclass of AtlasSpriteManger.
  
 Features:
 - Treats each character like an AtlasSprite. This means that each individual character can be:
   - rotated
   - scaled
   - translated
   - tinted
   - chage the opacity
 - Supports Hiero format (http://slick.cokeandcode.com/demos/hiero.jnlp)
 
 @since v0.8
 */

enum {
	kBitmapFontAtlasMaxChars = 256,
};

@interface BitmapFontAtlas : AtlasSpriteManager <CocosNodeLabel, CocosNodeRGBA, CocosNodeSize>
{
	// string to render
	NSString		*string_;
	
	// values for kerning
	NSMutableDictionary	*kerningDictionary;

	// Alignmnet
	UITextAlignment	alignment_;
	
	// FNTConfig: Common Height
	NSUInteger		commonHeight;

	// The characters building up the font
	ccBitmapFontDef	bitmapFontArray[kBitmapFontAtlasMaxChars];
	
	// texture color
	GLubyte	r_,g_,b_, opacity_;
	
	// CocosNodeSize protocol
	CGSize	contentSize_;
}

/** conforms to CocosNodeRGBA protocol */
@property (readonly) GLubyte r, g, b, opacity;

/** conforms to CocosNodeSize protocol */
@property (readonly) CGSize contentSize;

/** creates a bitmap font altas with an initial string and the FNT file */
+(id) bitmapFontAtlasWithString:(NSString*)string fntFile:(NSString*)fntFile alignment:(UITextAlignment)alignment;

/** init a bitmap font altas with an initial string and the FNT file */
-(id) initWithString:(NSString*)string fntFile:(NSString*)fntFile alignment:(UITextAlignment)alignment;

/** updates the font chars based on the string to render */
-(void) createFontChars;
@end
