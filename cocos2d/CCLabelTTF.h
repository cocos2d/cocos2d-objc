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


#import "CCTexture2D.h"
#import "CCSprite.h"
#import "Platforms/CCNS.h"

/**
 Extensions to make it easy to create a CCTexture2D object from a string of text.
 Note that the generated textures are of type A8 - use the blending mode (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA).
 */
@interface CCTexture2D (Text)
/** Initializes a texture from a string with dimensions, alignment, line break mode, font name and font size
 Supported lineBreakModes:
 - iOS: all UILineBreakMode supported modes
 - Mac: Only NSLineBreakByWordWrapping is supported.
 @since v1.0
 */
- (id) initWithAttributedString:(NSAttributedString*)attributedString dimensions:(CGSize)dimensions;

@end


/** CCLabel is a subclass of CCTextureNode that knows how to render text labels
 *
 * All features from CCTextureNode are valid in CCLabel
 *
 * CCLabel objects are slow. Consider using CCLabelAtlas or CCLabelBMFont instead.
 */

@interface CCLabelTTF : CCSprite <CCLabelProtocol>
{
	CGSize                       _dimensions;
	CCTextAlignment              _hAlignment;
    CCVerticalTextAlignment      _vAlignment;
	NSString                    *_fontName;
	CGFloat                      _fontSize;
	CCLineBreakMode              _lineBreakMode;
    
    /** font fill color */
    ccColor3B   _textFillColor;
}
/** changes the string to render
 * @warning Changing the string is as expensive as creating a new CCLabelTTF. To obtain better performance use CCLabelAtlas or CCLabelBMFont.
 */
@property (nonatomic,copy) NSString* string;

@property (nonatomic,copy) NSAttributedString* attributedString;
/** Font name used in the label */
@property (nonatomic,strong) NSString* fontName;
/** Font size used in the label */
@property (nonatomic,assign) float fontSize;
/** Dimensions of the label in Points */
@property (nonatomic,assign) CGSize dimensions;
/** The alignment of the label */
@property (nonatomic,assign) CCTextAlignment horizontalAlignment;
/** The vertical alignment of the label */
@property (nonatomic,assign) CCVerticalTextAlignment verticalAlignment;

@property (nonatomic,assign) ccColor4B shadowColor;
@property (nonatomic,assign) CGPoint shadowOffset;
@property (nonatomic,assign) float shadowBlurRadius;

@property (nonatomic,assign) BOOL adjustsFontSizeToFitWidth;
@property (nonatomic,assign) BOOL adjustsLetterSpacingToFitWidth;
@property (nonatomic,assign) float baselineAdjustment;
@property (nonatomic,assign) float minimumFontSize;

/** creates a CCLabelTTF with a font name and font size in points*/
+ (id) labelWithString:(NSString *)string fontName:(NSString *)name fontSize:(CGFloat)size;

+ (id) labelWithString:(NSString *)string fontName:(NSString *)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions;

+ (id) labelWithAttributedString:(NSAttributedString *)attrString;

+ (id) labelWithAttributedString:(NSAttributedString *)attrString dimensions:(CGSize)dimensions;


/** initializes the CCLabelTTF with a font name and font size in points */
- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size;

- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions;

- (id) initWithAttributedString:(NSAttributedString *)attrString;

- (id) initWithWithAttributedString:(NSAttributedString *)attrString dimensions:(CGSize)dimensions;

- (id) initWithAttributedString:(NSAttributedString *)attrString fontName:(NSString*)fontName fontSize:(float)fontSize dimensions:(CGSize)dimensions;

+ (void) registerCustomTTF:(NSString*)fontFile;

@end
