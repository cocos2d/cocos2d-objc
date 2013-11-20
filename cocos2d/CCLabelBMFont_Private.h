/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Apportable Inc.
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

#import "CCLabelBMFont.h"

enum {
	kCCLabelAutomaticWidth = -1,
};

/** @struct ccBMFontDef BMFont definition. */
typedef struct _BMFontDef {
	//! ID of the character
	unichar charID;
    
	//! origin and size of the font
	CGRect rect;
    
	//! The X amount the image should be offset when drawing the image (in pixels)
	short xOffset;
    
	//! The Y amount the image should be offset when drawing the image (in pixels)
	short yOffset;
    
	//! The amount to move the current position after drawing the character (in pixels)
	short xAdvance;
    
} ccBMFontDef;

/** @struct cBMFontPadding BMFont padding. */
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

#pragma mark - Hash Element
/** @struct tCCFontDefHashElement. */
typedef struct _FontDefHashElement {
    // key. Font Unicode value.
	NSUInteger		key;
    
    // font definition.
	ccBMFontDef		fontDef;
    
	UT_hash_handle	hh;
} tCCFontDefHashElement;

/** @struct tCCKerningHashElement. */
typedef struct _KerningHashElement {
    // key for the hash. 16-bit for 1st element, 16-bit for 2nd element.
	int				key;
    
	int				amount;
	UT_hash_handle	hh;
} tCCKerningHashElement;

/** CCBMFontConfiguration stores the parsed configuration of the specified .fnt file. */
@interface CCBMFontConfiguration : NSObject {
    
	// The character set defines the letters that actually exist in the font.
	NSCharacterSet *_characterSet;
    
	// The atlas name.
	NSString		*_atlasName;
    
@public
    
	// BMFont definitions
	tCCFontDefHashElement	*_fontDefDictionary;
    
	// FNTConfig: Common Height
	NSInteger		_commonHeight;
    
	// Padding
	ccBMFontPadding	_padding;
    
	// values for kerning
	tCCKerningHashElement	*_kerningDictionary;
}

/// -----------------------------------------------------------------------
/// @name Accessing the Configuration Attributes
/// -----------------------------------------------------------------------

/** The character set defines the letters that actually exist in the font. */
@property (nonatomic, strong, readonly) NSCharacterSet *characterSet;

/** The atlas name. */
@property (nonatomic, readwrite, strong) NSString *atlasName;


/// -----------------------------------------------------------------------
/// @name Initializing a CCLabelBMFont Object
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a CCBMFontConfiguration object from a specified font file value.
 *
 *  @param FNTfile Font configuration file.
 *
 *  @return The CCBMFontConfiguration Object.
 */
+(id) configurationWithFNTFile:(NSString*)FNTfile;

/**
 *  Initializes and returns a CCBMFontConfiguration object from a specified font file value.
 *
 *  @param FNTfile FNTfile Font configuration file.
 *
 *  @return An initialized CCBMFontConfiguration Object.
 */
-(id) initWithFNTfile:(NSString*)FNTfile;

@end


/// -----------------------------------------------------------------------
/// @name Free Functions
/// -----------------------------------------------------------------------

/** Load/Cache font configuration file and return object. */
CCBMFontConfiguration* FNTConfigLoadFile(NSString *file);

/** Clear font configuration cache. */
void FNTConfigRemoveCache(void);
