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

#import "CCTexture.h"
#import "CCSprite.h"
#import "Platforms/CCNS.h"

/**
 CCLabelTTF displays text rendered using a TrueType (TTF, OTF) font.
 
 Attributed strings are supported on Mac and iOS6+ which allow for greater text formatting control.
 
 ### Performance Note
 
 Each time the label's string property changes a new CCLabelTTF texture is created and rendered, and the previous one discarded.
 This adds a **huge performance penalty on every text change**. If you need to frequently update a label's text, you have two options:

 - Use CCLabelBMFont which does not incur such a penalty. Requires creating a font with an external bitmap font editing tool.
 - Create and cache all possible string variants as individual CCLabelTTF. Only suitable if the number of possible string
    permutations is low and all strings are known beforehand. For example, assuming you use a fixed-width font you could use
    label nodes with digits 0 through 9 and create your own digit counter node using n times ten label nodes, where n stands
    for the total number of digits you expect to display at most. However consider the next paragraph.
 
 ### Memory Usage Note
 
 Each label, even when using the same string and font and all other properties being identical, will still create its own texture.
 
 So if you have 100 label nodes with a "Hello" string you will have 100 "Hello" textures in memory. This behavior is unlike other
 nodes, for instace sprites created from the same image file load and share identical textures.
 
 If you use many labels in the same scene you should look into bitmap fonts and CCLabelBMFont.
 
 ### iOS Fonts List
 
 Here's a [list of fonts built into iOS](http://iosfonts.com) and their font names. Fonts not in this list will have iOS 
 automatically pick the font that closely resembles the desired font, or a default font.
 
 ### Custom Fonts
 
 It is possible to add custom truetype fonts to an iOS application and use the font with CCLabelTTF.
 For instructions and troubleshooting carefully [read this Q&A post](http://stackoverflow.com/questions/360751/can-i-embed-a-custom-font-in-an-iphone-application).
 
 Note that a very common mistake is to assume the font filename or family name as the fontName property. Assuming you have
 a font named "Avenir Condensed" then you need to find out the actual font identifier, which may be labelled `AvenirNextCondensed-HeavyItalic`.
 That's the identifier you need to use. A typical giveaway that you got the wrong identifier is if the string contains a space character.
 */

@interface CCLabelTTF : CCSprite <CCLabelProtocol> {
    
    // True if the label needs to be updated.
    BOOL _isTextureDirty;
}

/// -----------------------------------------------------------------------
/// @name Creating a Truetype Font Label
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a label object using the specified text, font name and font size.
 *
 *  @param string   Label text.
 *  @param name     Label font name.
 *  @param size     Label font size (in points).
 *
 *  @return The CCLabelTTF Object.
 */
+(instancetype) labelWithString:(NSString *)string fontName:(NSString *)name fontSize:(CGFloat)size;

/**
 *  Creates and returns a label object using the specified text, font name, font size and dimensions.
 *
 *  @param string     Label text.
 *  @param name       Label font name.
 *  @param size       Label font size (in points).
 *  @param dimensions Label dimensions.
 *
 *  @return The CCLabelTTF Object.
 */
+(instancetype) labelWithString:(NSString *)string fontName:(NSString *)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions;

/**
 *  Initializes and returns a label object using the specified text, font name and font size.
 *
 *  @param string   Label text.
 *  @param name     Label font name.
 *  @param size     Label font size (in points).
 *
 *  @return An initialized CCLabelTTF Object.
 */
-(id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size;

/**
 *  Initializes and returns a label object using the specified text, font name, font size and dimensions.
 *
 *  @param string     Label text.
 *  @param name       Label font name.
 *  @param size       Label font size (in points).
 *  @param dimensions Label dimensions.
 *
 *  @return An initialized CCLabelTTF Object.
 */
-(id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions;

/// -----------------------------------------------------------------------
/// @name Creating an Attributed Truetype Font Label
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a label object using the specified attributed text.
 *
 *  @param attrString Label Attributed text.
 *
 *  @since Available in iOS 6.0+ and OS X.
 *
 *  @return The CCLabelTTF Object.
 */
+(instancetype) labelWithAttributedString:(NSAttributedString *)attrString;

/**
 *  Creates and returns a label object using the specified attributed text and dimensions.
 *
 *  @param attrString Label Attributed text.
 *  @param dimensions Label dimensions.
 *
 *  @since Available in iOS 6.0+ and OS X.
 *
 *  @return The CCLabelTTF Object.
 */
+(instancetype) labelWithAttributedString:(NSAttributedString *)attrString dimensions:(CGSize)dimensions;

/**
 *  Initializes and returns a label object using the specified attributed text.
 *
 *  @param attrString Label Attributed text.
 *
 *  @since Available in iOS 6.0+ and OS X.
 *
 *  @return An initialized CCLabelTTF Object.
 */
-(id) initWithAttributedString:(NSAttributedString *)attrString;

/**
 *  Initializes and returns a label object using the specified attributed text and dimensions.
 *
 *  @param attrString Label Attributed text.
 *  @param dimensions Label dimensions.
 *
 *  @since Available in iOS 6.0+ and OS X.
 *
 *  @return An initialized CCLabelTTF Object.
 */
-(id) initWithAttributedString:(NSAttributedString *)attrString dimensions:(CGSize)dimensions;


/// -----------------------------------------------------------------------
/// @name Text Attributes
/// -----------------------------------------------------------------------

/** The label text. */
@property (nonatomic,copy) NSString* string;

/** The label's attributed text. */
@property (nonatomic,copy) NSAttributedString* attributedString;

/** The platform font name to use for the text. */
@property (nonatomic,strong) NSString* fontName;

/** The font size of the text. */
@property (nonatomic,assign) CGFloat fontSize;

/** The color of the text. Does not apply if you are using shadow or outline effects.
 @see CCColor */
@property (nonatomic,strong) CCColor* fontColor;

/** The horizontal alignment of the text.
 @see CCTextAlignment */
@property (nonatomic,assign) CCTextAlignment horizontalAlignment;

/** The vertical alignment of the text.
  @see CCVerticalTextAlignment */
@property (nonatomic,assign) CCVerticalTextAlignment verticalAlignment;


/// -----------------------------------------------------------------------
/// @name Sizing the Label
/// -----------------------------------------------------------------------

/** Dimensions of the label in Points, including padding. */
@property (nonatomic,assign) CGSize dimensions;

/** Dimension type of the label.
 @see CCSizeType, CCSizeUnit */
@property (nonatomic,assign) CCSizeType dimensionsType;

/** If YES, the label will be scaled down to fit into the size provided by the dimensions property. Only has an effect if dimensions are set. */
@property (nonatomic,assign) BOOL adjustsFontSizeToFit;

/** Used together with adjustsFontSizeToFit. Fonts will not be scaled down below this size (the label will instead be clipped). */
@property (nonatomic,assign) CGFloat minimumFontSize;

/** Adjusts the font's baseline, the value is in points. */
@property (nonatomic,assign) CGFloat baselineAdjustment;


/// -----------------------------------------------------------------------
/// @name Drawing a Shadow
/// -----------------------------------------------------------------------

/** The color of the text shadow. If the color is fully transparent, no shadow will be used. */
@property (nonatomic,strong) CCColor* shadowColor;

/** The offset of the shadow. */
@property (nonatomic,assign) CGPoint shadowOffset;

/** The offset of the shadow in points */
@property(nonatomic,readonly) CGPoint shadowOffsetInPoints;

/** The position type to be used for the shadow offset.
 @see CCPositionType, CCPositionUnit, CCPositionReferenceCorner */
@property (nonatomic,assign) CCPositionType shadowOffsetType;

/** The blur radius of the shadow. */
@property (nonatomic,assign) CGFloat shadowBlurRadius;


/// -----------------------------------------------------------------------
/// @name Drawing an Outline
/// -----------------------------------------------------------------------

/** The color of the text's outline.
 @see CCColor */
@property (nonatomic,strong) CCColor* outlineColor;

/** The width of the text's outline. */
@property (nonatomic,assign) CGFloat outlineWidth;

#if __CC_PLATFORM_MAC
/// -----------------------------------------------------------------------
/// @name HTML String (OS X only)
/// -----------------------------------------------------------------------

/**
 *  Creates an attributed string from HTML text.
 *
 *  @param html HTML string.
 *  @since Only available on OS X.
 */
- (void) setHTML:(NSString*) html;
#endif


/// -----------------------------------------------------------------------
/// @name Register a Custom Truetype Font
/// -----------------------------------------------------------------------

/**
 *  Register a TTF font resource added to the project/bundle.
 *
 *  @param fontFile Full or relative path to font file.
 *
 *  @return Registered font name. Returns nil if the font file failed to register.
 */
+(NSString *) registerCustomTTF:(NSString*)fontFile;


@end
