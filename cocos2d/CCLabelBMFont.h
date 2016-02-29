/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
 *
 */

#import "CCSpriteBatchNode.h"
#import "Support/uthash.h"

@class CCBMFontConfiguration;

/**
 CCLabelBMFont is a label whose characters are drawn from a bitmap image.
 
 The label is loaded from a fnt file created with an external editor with support for Cocos2D. For example [Glyph Designer](https://71squared.com/glyphdesigner)
 or [bmGlyph](http://www.bmglyph.com/).
 
 Each character is internally represented by a CCSprite instance. You can access and modify the label's sprites via the [CCNode children] property.

 ### Drawbacks/Advantages
 
 **Advantages:**
 
 - No penalty when label text changes.
 - Individual characters are sprites, can be modified individually (ie individual character animations).
 - Even using few labels may provide a memory usage advantage over CCLabelTTF, depending on size of bitmap font texture atlas and how many different fonts are used.
 
 **Drawbacks:**
 
 - Visual quality suffers when scaling (aliasing, blurring).
 - Limited to characters in bitmap font atlas. Foreign language support means potentially having lots of additional Unicode characters, thus increasing the font texture size.

 See the [Developer Guide](https://www.makegameswith.us/docs/) (Concepts: Nodes) for more details.

 ### Usage Notes
 
 The character sprites' anchorPoint is (0.5, 0.5) and should not be changed. It might affect the rendering.
 */

@interface CCLabelBMFont : CCNode <CCLabelProtocol, CCTextureProtocol>


/// -----------------------------------------------------------------------
/// @name Creating a Bitmap Font Label
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a label object using the specified text and font file values.
 *
 *  @param string  Label text.
 *  @param fntFile Label font file.
 *
 *  @return The CCLabelBMFont Object.
 */
+(instancetype) labelWithString:(NSString*)string fntFile:(NSString*)fntFile;

/**
 *  Creates and returns a label object using the specified text, font file and alignment values.
 *
 *  @param string  Label text.
 *  @param fntFile Label font file.
 *  @param width   Label maximum width.
 *  @param alignment Horizontal text alignment.
 *
 *  @return The CCLabelBMFont Object.
 *  @see CCTextAlignment
 */
+(instancetype) labelWithString:(NSString*)string fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment;

/**
 *  Creates and returns a label object using the specified text, font file, alignment and image offset values.
 *
 *  @param string  Label text.
 *  @param fntFile Label font file.
 *  @param width   Label maximum width.
 *  @param alignment Horizontal text alignment.
 *  @param offset Glyph offset on the font texture
 *
 *  @return The CCLabelBMFont Object.
 *  @see CCTextAlignment
 */
+(instancetype) labelWithString:(NSString*)string fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment imageOffset:(CGPoint)offset;

/**
 *  Initializes and returns a label object using the specified text and font file values.
 *
 *  @param string  Label text.
 *  @param fntFile Label font file.
 *
 *  @return An initialized CCLabelBMFont Object.
 */
-(id) initWithString:(NSString*)string fntFile:(NSString*)fntFile;

/**
 *  Initializes and returns a label object using the specified text, font file and alignment values.
 *
 *  @param string  Label text.
 *  @param fntFile Label font file.
 *  @param width   Label maximum width.
 *  @param alignment Horizontal text alignment.
 *
 *  @return An initialized CCLabelBMFont Object.
 *  @see CCTextAlignment
 */
-(id) initWithString:(NSString*)string fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment;

/**
 *  Initializes and returns a label object using the specified text, font file, alignment and image offset values.
 *
 *  @param string  Label text.
 *  @param fntFile Label font file.
 *  @param width   Label maximum width.
 *  @param alignment Horizontal text alignment.
 *  @param offset Glyph offset on the font texture.
 *
 *  @return An initialized CCLabelBMFont Object.
 *  @see CCTextAlignment
 */
-(id) initWithString:(NSString*)string fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment imageOffset:(CGPoint)offset;


/// -----------------------------------------------------------------------
/// @name Accessing Text Attributes
/// -----------------------------------------------------------------------

// purposefully undocumented: the fntFile is known to the user, this property doesn't seem very useful other than for debugging purposes
/* The font file name used by the label. */
@property (nonatomic,strong) NSString* fntFile;

/** The technique to use for horizontal aligning of the text.
 @see CCTextAlignment */
@property (nonatomic,assign,readonly) CCTextAlignment alignment;

/// -----------------------------------------------------------------------
/// @name Size and Alignment
/// -----------------------------------------------------------------------

/**
 *  Set the maximum width allowed before a line break will be inserted.
 *
 *  @param width The maximum width of a line.
 */
-(void) setWidth:(float)width;

/**
 *  Set the horizontal alignment of the text.
 *
 *  @param alignment Horizontal alignment.
 */
-(void) setAlignment:(CCTextAlignment)alignment;


/// -----------------------------------------------------------------------
/// @name Memory Management
/// -----------------------------------------------------------------------

/** Uncaches bitmap font configuration data and the atlas dictionary. 
 
 @note The bulk of the cached memory will not be released instantly but rather after
 the last instance of CCLabelBMFont using a specific set of cached data has been deallocated. */
+(void) purgeCachedData;

@end

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

// Creates and returns a CCBMFontConfiguration object from a specified font file value.
+(instancetype) configurationWithFNTFile:(NSString*)FNTfile;


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

