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


/** CCLabel is a subclass of CCTextureNode that knows how to render text labels
 *
 * All features from CCTextureNode are valid in CCLabel
 *
 * CCLabel objects are slow. Consider using CCLabelAtlas or CCLabelBMFont instead.
 */

@interface CCLabelTTF : CCSprite <CCLabelProtocol>
{
	CGSize dimensions_;
	CCTextAlignment alignment_;
    CCVerticalAlignment vertAlignment_;
	NSString * fontName_;
	CGFloat fontSize_;
	CCLineBreakMode lineBreakMode_;
	NSString	*string_;
}

/** creates a CCLabel from a fontname, alignment, dimension in points, line break mode, and font size in points.
 Supported lineBreakModes:
 - iOS: all UILineBreakMode supported modes
 - Mac: Only NSLineBreakByWordWrapping is supported.
 @since v1.0
 - verticalAlignment
 @since v1.1RC0
 */
+(id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment vertAlignment:(CCVerticalAlignment)vertAlignment  lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size;
/** creates a CCLabel from a fontname, alignment, dimension in points and font size in points*/
+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
/** creates a CCLabel from a fontname and font size in points*/
+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size;
/** initializes the CCLabel with a font name, alignment, dimension in points, line brea mode and font size in points.
 Supported lineBreakModes:
 - iOS: all UILineBreakMode supported modes
 - Mac: Only NSLineBreakByWordWrapping is supported.
 @since v1.0
 */
- (id) initWithString:(NSString*)str dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment vertAlignment:(CCVerticalAlignment)vertAlignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size;
/** initializes the CCLabel with a font name, alignment, dimension in points and font size in points */
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
/** initializes the CCLabel with a font name and font size in points */
- (id) initWithString:(NSString*)string  fontName:(NSString*)name fontSize:(CGFloat)size;

/** changes the string to render
 * @warning Changing the string is as expensive as creating a new CCLabel. To obtain better performance use CCLabelAtlas
 */
- (void) setString:(NSString*)str;

@end
