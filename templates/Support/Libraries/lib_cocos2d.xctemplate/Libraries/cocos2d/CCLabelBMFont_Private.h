/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013-2014 Cocos2D Authors
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
 */

#import "CCLabelBMFont.h"

enum {
	kCCLabelAutomaticWidth = -1,
};

// ccBMFontDef BMFont definition.
typedef struct _BMFontDef {
    
	// ID of the character.
	unichar charID;
    
	// Origin and size of the font
	CGRect rect;
    
	// The X amount the image should be offset when drawing the image (in pixels)
	short xOffset;
    
	// The Y amount the image should be offset when drawing the image (in pixels)
	short yOffset;
    
	// The amount to move the current position after drawing the character (in pixels)
	short xAdvance;
    
} ccBMFontDef;

// cBMFontPadding BMFont padding.
typedef struct _BMFontPadding {
    
	// Padding left.
	int	left;
    
	// Padding top.
    
	int top;
	// Padding right.
    
	int right;
    
	// Padding bottom.
	int bottom;
    
} ccBMFontPadding;

#pragma mark - Hash Element
// tCCFontDefHashElement.
typedef struct _FontDefHashElement {
    
    // Key. Font Unicode value.
	NSUInteger		key;
    
    // Font definition.
	ccBMFontDef		fontDef;
    
	UT_hash_handle	hh;
    
} tCCFontDefHashElement;

// tCCKerningHashElement.
typedef struct _KerningHashElement {
    
    // Key for the hash. 16-bit for 1st element, 16-bit for 2nd element.
	int				key;
    
    // Kerning value.
	int				amount;
    
    // Had Handle.
	UT_hash_handle	hh;
    
} tCCKerningHashElement;

// CCBMFontConfiguration stores the parsed configuration of the specified .fnt file.
@interface CCBMFontConfiguration : NSObject {
    
	// The character set defines the letters that actually exist in the font.
	NSCharacterSet *_characterSet;
    
	// The atlas name.
	NSString		*_atlasName;
    
@public
    
	// BMFont definitions.
	tCCFontDefHashElement	*_fontDefDictionary;
    
	// FNTConfig: Common Height.
	NSInteger		_commonHeight;
    
	// Padding.
	ccBMFontPadding	_padding;
    
	// Values for kerning.
	tCCKerningHashElement	*_kerningDictionary;
}

/// -----------------------------------------------------------------------
/// @name Accessing the Configuration Attributes
/// -----------------------------------------------------------------------

// The character set defines the letters that actually exist in the font.
@property (nonatomic, strong, readonly) NSCharacterSet *characterSet;

// The atlas name.
@property (nonatomic, readwrite, strong) NSString *atlasName;


/// -----------------------------------------------------------------------
/// @name Creating a CCParticleSystem Object
/// -----------------------------------------------------------------------

// Creates and returns a CCBMFontConfiguration object from a specified font file value.
+(id) configurationWithFNTFile:(NSString*)FNTfile;


/// -----------------------------------------------------------------------
/// @name Initializing a CCLabelBMFont Object
/// -----------------------------------------------------------------------

//  Initializes and returns a CCBMFontConfiguration object from a specified font file value.
-(id) initWithFNTfile:(NSString*)FNTfile;

@end


/// -----------------------------------------------------------------------
/// @name Free Functions
/// -----------------------------------------------------------------------

// Load/Cache font configuration file and return object.
CCBMFontConfiguration* FNTConfigLoadFile(NSString *file);

// Clear font configuration cache.
void FNTConfigRemoveCache(void);
