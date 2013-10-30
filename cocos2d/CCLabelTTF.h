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
 */


#import "CCTexture.h"
#import "CCSprite.h"
#import "Platforms/CCNS.h"

/** CCLabel is a subclass of CCTextureNode that knows how to render text labels
 *
 * All features from CCTextureNode are valid in CCLabel
 *
 * CCLabel objects are slow. Consider using CCLabelAtlas or CCLabelBMFont instead.
 */

@interface CCLabelTTF : CCSprite <CCLabelProtocol>
{
    BOOL _isTextureDirty;
}

#pragma mark String and font

/** Changes the text of the label.
 * @warning Changing the string is as expensive as creating a new CCLabelTTF. To obtain better performance use CCLabelAtlas or CCLabelBMFont.
 */
@property (nonatomic,copy) NSString* string;

/** Changes text of the label, draws the string with given attributes. The attributes used will override the alignment, color and shadow as set by the properties of the label. Attributed strings are only available on Mac and iOS 6 or later.
 * @warning Changing the string is as expensive as creating a new CCLabelTTF. To obtain better performance use CCLabelAtlas or CCLabelBMFont.
 */
@property (nonatomic,copy) NSAttributedString* attributedString;

/** Font name used in the label */
@property (nonatomic,strong) NSString* fontName;

/** Font size used in the label */
@property (nonatomic,assign) float fontSize;

/** Font color. If not using shadow or outline, it is more efficient to use the color property. */
@property (nonatomic,assign) ccColor4B fontColor;

#pragma mark Dimensions

/** Dimensions of the label in Points */
@property (nonatomic,assign) CGSize dimensions;

@property (nonatomic,assign) CCContentSizeType dimensionsType;


#pragma mark Alignment

/** The alignment of the label */
@property (nonatomic,assign) CCTextAlignment horizontalAlignment;

/** The vertical alignment of the label */
@property (nonatomic,assign) CCVerticalTextAlignment verticalAlignment;


#pragma mark Shadow

/** The color of a text shadow. If the color is transparent, no shadow will be used. */
@property (nonatomic,assign) ccColor4B shadowColor;

/** The offset of the shadow (in the type specified by shadowOffsetType), default is (0,0). */
@property (nonatomic,assign) CGPoint shadowOffset;


@property (nonatomic,assign) CCPositionType shadowOffsetType;

/** The blur radius of the shadow, default is 0. */
@property (nonatomic,assign) float shadowBlurRadius;


#pragma mark Outline

/** The color of the label's outline. Default is transparent/no outline. */
@property (nonatomic,assign) ccColor4B outlineColor;

/** The width of the label's outline. Default is 0/no outline. */
@property (nonatomic,assign) float outlineWidth;


#pragma mark Font adjustments

/** If set, the label will be scaled down to fit into the size provided by the dimensions property. Only has an effect if dimensions are set. */
@property (nonatomic,assign) BOOL adjustsFontSizeToFit;

/** Used together with adjustsFontSizeToFit. Fonts will not be scaled down below this size (the label will instead be clipped). */
@property (nonatomic,assign) float minimumFontSize;

/** Adjusts the fonts baseline, the value is set in points. */
@property (nonatomic,assign) float baselineAdjustment;

/** Creates a CCLabelTTF with a font name and font size in points */
+ (id) labelWithString:(NSString *)string fontName:(NSString *)name fontSize:(CGFloat)size;

/** Creates a CCLabelTTF with a font name, font size in points and the desired dimensions. */
+ (id) labelWithString:(NSString *)string fontName:(NSString *)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions;

/** Creates a CCLabelTTF with an attributed string. Only supported on Mac and iOS 6 or later. */
+ (id) labelWithAttributedString:(NSAttributedString *)attrString;

/** Creates a CCLabelTTF with an attributed string and the desired dimensions. Only supported on Mac and iOS 6 or later. */
+ (id) labelWithAttributedString:(NSAttributedString *)attrString dimensions:(CGSize)dimensions;


/** Initializes the CCLabelTTF with a font name and font size in points. */
- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size;

/** Initializes the CCLabelTTF with a font name, font size in points and the desired dimensions. */
- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions;

/** Initializes the CCLabelTTF with an attributed string. Only supported on Mac and iOS 6 or later. */
- (id) initWithAttributedString:(NSAttributedString *)attrString;

/** Initializes the CCLabelTTF with an attributed string and the desired dimensions. Only supported on Mac and iOS 6 or later. */
- (id) initWithAttributedString:(NSAttributedString *)attrString dimensions:(CGSize)dimensions;

#ifdef __CC_PLATFORM_MAC
- (void) setHTML:(NSString*) html;
#endif

+ (void) registerCustomTTF:(NSString*)fontFile;

@end
