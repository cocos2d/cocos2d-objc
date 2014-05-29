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
 CCLabelBMFont displays a bitmap font label. The label is loaded from a fnt-file
 created with an external editor. Each character in the label is represented by a
 CCSprite and can be accessed through the children property.
 
 CCLabelBMFont has the flexibility of CCLabel and all the features and performance of CCSprite.
 
 ### Notes
 
 - All inner characters are using an anchorPoint of (0.5f, 0.5f) and it is not recommend to change it
 because it might affect the rendering.
 
 ### Supported editors
 
 - (Premium) http://www.71squared.com/glyphdesigner
 - (Premium) http://www.bmglyph.com/
 - (Free) http://www.n4te.com/hiero/hiero.jnlp
 - (Free) http://www.angelcode.com/products/bmfont/
 
 */

@interface CCLabelBMFont : CCNode <CCLabelProtocol, CCTextureProtocol>

/// -----------------------------------------------------------------------
/// @name Accessing the Text Attributes
/// -----------------------------------------------------------------------

/** The technique to use for horizontal aligning of the text. */
@property (nonatomic,assign,readonly) CCTextAlignment alignment;

/** The font file of the text. */
@property (nonatomic,strong) NSString* fntFile;

/** The opacity of the text. */
@property (nonatomic,readwrite) CGFloat opacity;

/** The color of the text. */
@property (nonatomic,strong) CCColor* color;


/// -----------------------------------------------------------------------
/// @name Sizing the Label’s Text
/// -----------------------------------------------------------------------

/**
 *  Set the maximum width allowed before a line break will be inserted.
 *
 *  @param width The maximum width.
 */
-(void) setWidth:(float)width;

/**
 *  Set the technique to use for horizontal aligning of the text.
 *
 *  @param alignment Horizontal alignment.
 */
-(void) setAlignment:(CCTextAlignment)alignment;


/// -----------------------------------------------------------------------
/// @name Creating a CCLabelBMFont Object
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
 */
+(id) labelWithString:(NSString*)string fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment imageOffset:(CGPoint)offset;


/// -----------------------------------------------------------------------
/// @name Initializing a CCLabelBMFont Object
/// -----------------------------------------------------------------------

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
 */
-(id) initWithString:(NSString*)string fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment imageOffset:(CGPoint)offset;


/// -----------------------------------------------------------------------
/// @name Memory Management
/// -----------------------------------------------------------------------

/** Removes from memory the cached configurations and the atlas name dictionary. */
+(void) purgeCachedData;

@end



