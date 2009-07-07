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

enum {
	kBitmapFontAtlasMaxChars = 256,
};

/** BitmapFontConfiguration has parsed configuration of the the .fnt file
 @since v0.8
 */
@interface BitmapFontConfiguration : NSObject
{
// XXX: Creating a public interface so that the bitmapFontArray[] is accesible
@public
	// The characters building up the font
	ccBitmapFontDef	bitmapFontArray[kBitmapFontAtlasMaxChars];
	
	// FNTConfig: Common Height
	NSUInteger		commonHeight;

	// values for kerning
	NSMutableDictionary	*kerningDictionary;
}

/** allocates a BitmapFontConfiguration with a FNT file */
+(id) configurationWithFNTFile:(NSString*)FNTfile;
/** initializes a BitmapFontConfiguration with a FNT file */
-(id) initWithFNTfile:(NSString*)FNTfile;
@end


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

@interface BitmapFontAtlas : AtlasSpriteManager <CocosNodeLabel, CocosNodeRGBA>
{
	// string to render
	NSString		*string_;
	
	BitmapFontConfiguration	*configuration;

	// texture RGBA
	GLubyte		opacity_;
	ccColor3B	color_;
	BOOL opacityModifyRGB_;
}

/** conforms to CocosNodeRGBA protocol */
@property (readonly) GLubyte opacity;
/** conforms to CocosNodeRGBA protocol */
@property (readonly) ccColor3B color;


/** creates a bitmap font altas with an initial string and the FNT file */
+(id) bitmapFontAtlasWithString:(NSString*)string fntFile:(NSString*)fntFile;

/** init a bitmap font altas with an initial string and the FNT file */
-(id) initWithString:(NSString*)string fntFile:(NSString*)fntFile;

/** updates the font chars based on the string to render */
-(void) createFontChars;
@end

/** Free function that parses a FNT file a place it on the cache
*/
BitmapFontConfiguration * FNTConfigLoadFile( NSString *file );
/** Purges the FNT config cache
 */
void FNTConfigRemoveCache( void );



