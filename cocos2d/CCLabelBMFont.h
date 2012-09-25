/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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
 * Portions of this code are based and inspired on:
 *   http://www.71squared.co.uk/2009/04/iphone-game-programming-tutorial-4-bitmap-font-class
 *   by Michael Daley
 *
 * Use any of these editors to generate BMFonts:
 *   http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *   http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *   http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *   http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 */

#import "CCSpriteBatchNode.h"
#import "Support/uthash.h"

struct _KerningHashElement;

/** @struct ccBMFontDef
 BMFont definition
 */
typedef struct _BMFontDef {
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
    // Enable Hash Table
    UT_hash_handle hh;
} ccBMFontDef;

/** @struct ccBMFontPadding
 BMFont padding
 @since v0.8.2
 */
typedef struct _BMFontPadding {
	/// padding left
	int	left;
	/// padding top
	int top;
	/// padding right
	int right;
	/// padding bottom
	int bottom;
} ccBMFontPadding;

/** CCBMFontConfiguration has parsed configuration of the the .fnt file
 @since v0.8
 */
@interface CCBMFontConfiguration : NSObject
{
    // XXX: Creating a public interface so that the bitmapFontArray[] is accesible
@public
	// The characters building up the font
	ccBMFontDef *BMFontHash_;

	// FNTConfig: Common Height
	NSUInteger		commonHeight_;

	// Padding
	ccBMFontPadding	padding_;

	// atlas name
	NSString		*atlasName_;

	// values for kerning
	struct _KerningHashElement	*kerningDictionary_;
}

/** allocates a CCBMFontConfiguration with a FNT file */
+(id) configurationWithFNTFile:(NSString*)FNTfile;
/** initializes a CCBMFontConfiguration with a FNT file */
-(id) initWithFNTfile:(NSString*)FNTfile;
@end


/** CCLabelBMFont is a subclass of CCSpriteBatchNode

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

 CCLabelBMFont implements the protocol CCLabelProtocol, like CCLabel and CCLabelAtlas.
 CCLabelBMFont has the flexibility of CCLabel, the speed of CCLabelAtlas and all the features of CCSprite.
 If in doubt, use CCLabelBMFont instead of CCLabelAtlas / CCLabel.

 Supported editors:
 - http://www.n4te.com/hiero/hiero.jnlp
 - http://slick.cokeandcode.com/demos/hiero.jnlp
 - http://www.angelcode.com/products/bmfont/

 @since v0.8
 */

@interface CCLabelBMFont : CCSpriteBatchNode <CCLabelProtocol, CCRGBAProtocol>
{
	// string to render
	NSString		*string_;

    // initial string without line breaks
    NSString *initialString_;
    // max width until a line break is added
    float width_;
    // alignment of all lines
    CCTextAlignment alignment_;

	CCBMFontConfiguration	*configuration_;

	// texture RGBA
	GLubyte		opacity_;
	ccColor3B	color_;
	BOOL opacityModifyRGB_;
}

/** Purges the cached data.
 Removes from memory the cached configurations and the atlas name dictionary.
 @since v0.99.3
 */
+(void) purgeCachedData;

@property (nonatomic,copy,readonly) NSString *initialString;
@property (nonatomic,assign,readonly) float width;
@property (nonatomic,assign,readonly) CCTextAlignment alignment;

/** conforms to CCRGBAProtocol protocol */
@property (nonatomic,readwrite) GLubyte opacity;
/** conforms to CCRGBAProtocol protocol */
@property (nonatomic,readwrite) ccColor3B color;


/** creates a BMFont label with an initial string and the FNT file */
+(id) labelWithString:(NSString*)string fntFile:(NSString*)fntFile;
/** creates a BMFont label with an initial string, the FNT file, width, and alignment option */
+(id) labelWithString:(NSString*)string fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment;

/** init a BMFont label with an initial string and the FNT file */
-(id) initWithString:(NSString*)string fntFile:(NSString*)fntFile;
/** init a BMFont label with an initial string and the FNT file, width, and alignment option*/
-(id) initWithString:(NSString*)string fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment;

/** updates the font chars based on the string to render */
-(void) createFontChars;

- (void)setWidth:(float)width;
- (void)setAlignment:(CCTextAlignment)alignment;
@end

/** Free function that parses a FNT file a place it on the cache
 */
CCBMFontConfiguration * FNTConfigLoadFile( NSString *file );
/** Purges the FNT config cache
 */
void FNTConfigRemoveCache( void );


