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
+(id) labelWithString:(NSString*)string fntFile:(NSString*)fntFile;

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
+(id) labelWithString:(NSString*)string fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment;

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
+(id) labelWithString:(NSString*)string fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment imageOffset:(CGPoint)offset;

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

/** The opacity of the text, in the range 0.0 (fully transparent) to 1.0 (fully opaque). */
@property (nonatomic,readwrite) CGFloat opacity;

/** The color of the text.
 @see CCColor */
@property (nonatomic,strong) CCColor* color;


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



