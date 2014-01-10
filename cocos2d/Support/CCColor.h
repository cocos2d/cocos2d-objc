/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Viktor
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

#import "ccMacros.h"
#import "ccTypes.h"

/**
 *  Defines a CCColor to use with cocos2d.
 */
@interface CCColor : NSObject
{
    GLfloat _r;
    GLfloat _g;
    GLfloat _b;
    GLfloat _a;
}

+ (CCColor *)colorWithWhite:(float)white alpha:(float)alpha;
+ (CCColor *)colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
+ (CCColor *)colorWithRed:(float)red green:(float)green blue:(float)blue;
+ (CCColor *)colorWithCGColor:(CGColorRef)cgColor;
- (CCColor *)colorWithAlphaComponent:(float)alpha;

#ifdef __CC_PLATFORM_IOS
+ (CCColor *)colorWithUIColor:(UIColor*)color;
#endif

- (CCColor *)initWithWhite:(float)white alpha:(float)alpha;
- (CCColor *)initWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
- (CCColor *)initWithRed:(float)red green:(float)green blue:(float)blue;
- (CCColor *)initWithCGColor:(CGColorRef)cgColor;

#ifdef __CC_PLATFORM_IOS
- (CCColor *)initWithUIColor:(UIColor*)color;
#endif

+ (CCColor *)blackColor;
+ (CCColor *)darkGrayColor;
+ (CCColor *)lightGrayColor;
+ (CCColor *)whiteColor;
+ (CCColor *)grayColor;
+ (CCColor *)redColor;
+ (CCColor *)greenColor;
+ (CCColor *)blueColor;
+ (CCColor *)cyanColor;
+ (CCColor *)yellowColor;
+ (CCColor *)magentaColor;
+ (CCColor *)orangeColor;
+ (CCColor *)purpleColor;
+ (CCColor *)brownColor;
+ (CCColor *)clearColor;

@property(nonatomic, readonly) CGColorRef CGColor;

#ifdef __CC_PLATFORM_IOS
@property (nonatomic, readonly) UIColor* UIColor;
#endif

#ifdef __CC_PLATFORM_MAC
@property (nonatomic, readonly) NSColor* NSColor;
#endif

- (BOOL)getRed:(float *)red green:(float *)green blue:(float *)blue alpha:(float *)alpha;
- (BOOL)getWhite:(float *)white alpha:(float *)alpha;

/**
 *  Linearly interpolate from this color to 'toColor'. Parameter t is normalised
 *
 *  @param toColor Color to interpolate to.
 *  @param t       Normalised progress.
 *
 *  @return The interpolated color.
 */
- (CCColor*)interpolateTo:(CCColor *) toColor time:(float) t;

@end

@interface CCColor (OpenGL)

+ (CCColor*)colorWithCcColor3b: (ccColor3B) c;
+ (CCColor*)colorWithCcColor4b: (ccColor4B) c;
+ (CCColor*)colorWithCcColor4f: (ccColor4F) c;

- (CCColor*)initWithCcColor3b: (ccColor3B) c;
- (CCColor*)initWithCcColor4b: (ccColor4B) c;
- (CCColor*)initWithCcColor4f: (ccColor4F) c;

@property (nonatomic, readonly) ccColor3B ccColor3b;
@property (nonatomic, readonly) ccColor4B ccColor4b;
@property (nonatomic, readonly) ccColor4F ccColor4f;

@end

@interface CCColor (ExtraProperties)

@property (nonatomic, readonly) float red;
@property (nonatomic, readonly) float green;
@property (nonatomic, readonly) float blue;
@property (nonatomic, readonly) float alpha;

- (BOOL)isEqualToColor:(CCColor*) color;

@end
