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

#import "CCAtlasNode.h"
#import "CCSpriteSheet.h"

/** bitmap font definition */
typedef struct _bitmapFontDef {
	//! ID of the character
	unsigned int charID;
	//! origin and size of the font
	CGRect rect;
	//! The X amount the image should be offset when drawing the image (in pixels)
	int xOffset;
	//! The Y amount the image should be offset when drawing the image (in pixels)
	int yOffset;
	//! The amount to move the current position after drawing the character (in pixels)
	int xAdvance;
} ccBitmapFontDef;

/** bitmap font padding
 @since v0.8.2
 */
typedef struct _bitmapFontPadding {
	/// padding left
	int	left;
	/// padding top
	int top;
	/// padding right
	int right;
	/// padding bottom
	int bottom;
} ccBitmapFontPadding;

enum {
	// how many characters are supported
	kBitmapFontAtlasMaxChars = 2048, //256,
};

/** CCBitmapFontConfiguration has parsed configuration of the the .fnt file
 @since v0.8
 */
@interface CCBitmapFontConfiguration : NSObject
{
// XXX: Creating a public interface so that the bitmapFontArray[] is accesible
@public
	// The characters building up the font
	ccBitmapFontDef	bitmapFontArray[kBitmapFontAtlasMaxChars];
	
	// FNTConfig: Common Height
	NSUInteger		commonHeight;
	
	// Padding
	ccBitmapFontPadding	padding;

	// values for kerning
	NSMutableDictionary	*kerningDictionary;
}

/** allocates a CCBitmapFontConfiguration with a FNT file */
+(id) configurationWithFNTFile:(NSString*)FNTfile;
/** initializes a BitmapFontConfiguration with a FNT file */
-(id) initWithFNTfile:(NSString*)FNTfile;
@end


/** CCBitmapFontAtlas is a subclass of CCSpriteSheet.
  
 Features:
 - Treats each character like a CCSprite. This means that each individual character can be:
   - rotated
   - scaled
   - translated
   - tinted
   - chage the opacity
 - It can be used as part of a menu item.
 - anchorPoint can be used to align the "label"
 - Supports AngelCode text format
 
 Limitations:
  - All inner characters are using an anchorPoint of (0.5f, 0.5f) and it is not recommend to change it
    because it might affect the rendering
 
 CCBitmapFontAtlas implements the protocol CCLabelProtocol, like CCLabel and CCLabelAtlas.
 CCBitmapFontAtlas has the flexibility of CCLabel, the speed of CCLabelAtlas and all the features of CCSprite.
 If in doubt, use CCBitmapFontAtlas instead of CCLabelAtlas / CCLabel.
 
 Supported editors:
  - http://www.n4te.com/hiero/hiero.jnlp
  - http://slick.cokeandcode.com/demos/hiero.jnlp
  - http://www.angelcode.com/products/bmfont/
 
 @since v0.8
 */

@interface CCBitmapFontAtlas : CCSpriteSheet <CCLabelProtocol, CCRGBAProtocol>
{
	// string to render
	NSString		*string_;
	
	CCBitmapFontConfiguration	*configuration;

	// texture RGBA
	GLubyte		opacity_;
	ccColor3B	color_;
	BOOL opacityModifyRGB_;
}

/** conforms to CCRGBAProtocol protocol */
@property (nonatomic,readonly) GLubyte opacity;
/** conforms to CCRGBAProtocol protocol */
@property (nonatomic,readonly) ccColor3B color;


/** creates a bitmap font altas with an initial string and the FNT file */
+(id) bitmapFontAtlasWithString:(NSString*)string fntFile:(NSString*)fntFile;

/** init a bitmap font altas with an initial string and the FNT file */
-(id) initWithString:(NSString*)string fntFile:(NSString*)fntFile;

/** updates the font chars based on the string to render */
-(void) createFontChars;
@end

/** Free function that parses a FNT file a place it on the cache
*/
CCBitmapFontConfiguration * FNTConfigLoadFile( NSString *file );
/** Purges the FNT config cache
 */
void FNTConfigRemoveCache( void );
