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
 CCLabelTTF displays a rendered TTF font texture. The label is created from a platform font.
 Attributed strings are supported on Mac and iOS6+ which allows for greater text formatting control.
 
 ### Notes
 
 Each time you modify the label text you are effectivley creating a new CCLabelTTF so there may be a performance hit if you need to frequently update the label.  In this scenario you should also look at CCLabelBMFont which does not have this overhead.
 
 ### Resources
 
 - http://iosfonts.com/ (Please use Safari for accurate font rendering)
 
 */

@interface CCLabelTTF : CCSprite <CCLabelProtocol> {
    
    // True if the label needs to be updated.
    BOOL _isTextureDirty;
}


/// -----------------------------------------------------------------------
/// @name Accessing the Text Attributes
/// -----------------------------------------------------------------------

/** The label text. */
@property (nonatomic,copy) NSString* string;

/** The label attributed text. */
@property (nonatomic,copy) NSAttributedString* attributedString;

/** The platform font to use for the text. */
@property (nonatomic,strong) NSString* fontName;

/** The font size of the text. */
@property (nonatomic,assign) float fontSize;

/** The color of the text (If not using shadow or outline). */
@property (nonatomic,strong) CCColor* fontColor;

/** The horizontal alignment technique of the text. */
@property (nonatomic,assign) CCTextAlignment horizontalAlignment;

/** The vertical alignment technique of the text. */
@property (nonatomic,assign) CCVerticalTextAlignment verticalAlignment;


/// -----------------------------------------------------------------------
/// @name Sizing the Label
/// -----------------------------------------------------------------------

/** Dimensions of the label in Points. */
@property (nonatomic,assign) CGSize dimensions;

/** Dimension type of the label. */
@property (nonatomic,assign) CCSizeType dimensionsType;

/** If true, the label will be scaled down to fit into the size provided by the dimensions property. Only has an effect if dimensions are set. */
@property (nonatomic,assign) BOOL adjustsFontSizeToFit;

/** Used together with adjustsFontSizeToFit. Fonts will not be scaled down below this size (the label will instead be clipped). */
@property (nonatomic,assign) float minimumFontSize;

/** Adjusts the fonts baseline, the value is set in points. */
@property (nonatomic,assign) float baselineAdjustment;


/// -----------------------------------------------------------------------
/// @name Drawing a Shadow
/// -----------------------------------------------------------------------

/** The color of the text shadow. If the color is transparent, no shadow will be used. */
@property (nonatomic,strong) CCColor* shadowColor;

/** The offset of the shadow. */
@property (nonatomic,assign) CGPoint shadowOffset;

/** The offset of the shadow in points */
@property(nonatomic,readonly) CGPoint shadowOffsetInPoints;

/** The position type to be used for the shadow offset. */
@property (nonatomic,assign) CCPositionType shadowOffsetType;

/** The blur radius of the shadow. */
@property (nonatomic,assign) float shadowBlurRadius;


/// -----------------------------------------------------------------------
/// @name Drawing an Outline
/// -----------------------------------------------------------------------

/** The color of the text's outline. */
@property (nonatomic,strong) CCColor* outlineColor;

/** The width of the text's outline. */
@property (nonatomic,assign) float outlineWidth;


/// -----------------------------------------------------------------------
/// @name Creating a CCLabelTTF Object
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
+(id) labelWithString:(NSString *)string fontName:(NSString *)name fontSize:(CGFloat)size;

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
+(id) labelWithString:(NSString *)string fontName:(NSString *)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions;

/**
 *  Creates and returns a label object using the specified attributed text.
 *
 *  @param attrString Label Attributed text.
 *
 *  @since Available in iOS 6.0+ and OS X.
 *
 *  @return The CCLabelTTF Object.
 */
+(id) labelWithAttributedString:(NSAttributedString *)attrString;

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
+(id) labelWithAttributedString:(NSAttributedString *)attrString dimensions:(CGSize)dimensions;


/// -----------------------------------------------------------------------
/// @name Initializing a CCLabelTTF Object
/// -----------------------------------------------------------------------

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
/// @name OS X
/// -----------------------------------------------------------------------

#ifdef __CC_PLATFORM_MAC
/**
 *  (OS X) HTML Label
 *
 *  @param html HTML Description.
 */
- (void) setHTML:(NSString*) html;
#endif


/// -----------------------------------------------------------------------
/// @name TTF Management
/// -----------------------------------------------------------------------

/**
 *  Register a TTF font resource.
 *
 *  @param fontFile Font file path.
 */
+(void) registerCustomTTF:(NSString*)fontFile;


@end
