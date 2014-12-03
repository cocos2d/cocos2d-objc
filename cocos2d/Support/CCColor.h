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


#if __CC_PLATFORM_IOS
#import <UIKit/UIColor.h>
#endif


/**
 A CCColor object represents color and sometimes opacity (alpha value) for use with Cocos2D objects.
 
 It is the Cocos2D equivalent of [UIColor](https://developer.apple.com/library/ios/DOCUMENTATION/UIKit/Reference/UIColor_Class/index.html)
 respectively [NSColor](https://developer.apple.com/library/Mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSColor_Class/index.html).
 */
@interface CCColor : NSObject {
    GLfloat _r;
    GLfloat _g;
    GLfloat _b;
    GLfloat _a;
}


#pragma mark - Creating a CCColor Object from Component Values
/// -----------------------------------------------------------------------
/// @name Creating a Color from RGB(A) Components
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a color object using the specified opacity and grayscale values.
 *
 *  @param white The grayscale value of the color object, specified as a value from 0.0 to 1.0.
 *  @param alpha The opacity value of the color object, specified as a value from 0.0 to 1.0.
 *
 *  @return The color object.
 */
+ (CCColor *)colorWithWhite:(float)white alpha:(float)alpha;

/**
 *  Creates and returns a color object using the specified opacity and RGBA component values.
 *
 *  @param red   The red component of the color object, specified as a value from 0.0 to 1.0.
 *  @param green The green component of the color object, specified as a value from 0.0 to 1.0.
 *  @param blue  The blue component of the color object, specified as a value from 0.0 to 1.0.
 *  @param alpha The opacity value of the color object, specified as a value from 0.0 to 1.0.
 *
 *  @return The color object.
 */
+ (CCColor *)colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

/**
 *  Creates and returns a color object using the specified opacity and RGB component values. Alpha will default to 1.0.
 *
 *  @param red   The red component of the color object, specified as a value from 0.0 to 1.0.
 *  @param green The green component of the color object, specified as a value from 0.0 to 1.0.
 *  @param blue  The blue component of the color object, specified as a value from 0.0 to 1.0.
 *
 *  @return The color object.
 */
+ (CCColor *)colorWithRed:(float)red green:(float)green blue:(float)blue;

/**
 *  Creates and returns a color object that has the same color space and component values as the receiver, but has the specified alpha component.
 *
 *  @param alpha The opacity value of the new CCColor object.
 *
 *  @return The color object.
 */
- (CCColor *)colorWithAlphaComponent:(float)alpha;

/**
 *  Initializes and returns a color object using the specified opacity and grayscale values.
 *
 *  @param white The grayscale value of the color object, specified as a value from 0.0 to 1.0.
 *  @param alpha The opacity value of the color object, specified as a value from 0.0 to 1.0.
 *
 *  @return An initialized color object.
 */
- (CCColor *)initWithWhite:(float)white alpha:(float)alpha;

/**
 *  Initializes and returns a color object using the specified opacity and RGBA component values.
 *
 *  @param red   The red component of the color object, specified as a value from 0.0 to 1.0.
 *  @param green The green component of the color object, specified as a value from 0.0 to 1.0.
 *  @param blue  The blue component of the color object, specified as a value from 0.0 to 1.0.
 *  @param alpha The opacity value of the color object, specified as a value from 0.0 to 1.0.
 *
 *  @return An initialized color object.
 */
- (CCColor *)initWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

/**
 *  Initializes and returns a color object using the specified opacity and RGB component values. Alpha will default to 1.0.
 *
 *  @param red   The red component of the color object, specified as a value from 0.0 to 1.0.
 *  @param green The green component of the color object, specified as a value from 0.0 to 1.0.
 *  @param blue  The blue component of the color object, specified as a value from 0.0 to 1.0.
 *
 *  @return An initialized color object.
 */
- (CCColor *)initWithRed:(float)red green:(float)green blue:(float)blue;

/// -----------------------------------------------------------------------
/// @name Creating a Color with CGColor/UIColor
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a color object using the specified Quartz color reference.
 *
 *  @param cgColor A reference to a Quartz color.
 *
 *  @return The color object.
 */
+ (CCColor *)colorWithCGColor:(CGColorRef)cgColor;

#if __CC_PLATFORM_IOS
/**
 *  Converts a UIColor object to its CCColor equivalent.
 *
 *  @param color UIColor object.
 *
 *  @return The color object.
 */
+ (CCColor *)colorWithUIColor:(UIColor*)color;
#endif

/**
 *  Initializes and returns a color object using the specified Quartz color reference.
 *
 *  @param cgColor A reference to a Quartz color.
 *
 *  @return An initialized color object.
 */
- (CCColor *)initWithCGColor:(CGColorRef)cgColor;

#if __CC_PLATFORM_IOS
/**
 *  Initializes and returns a UIColor object to its CCColor equivalent.
 *
 *  @param color UIColor object.
 *
 *  @return An initialized color object.
 */
- (CCColor *)initWithUIColor:(UIColor*)color;
#endif


#pragma mark - Creating a CCColor with Preset Component Values
/// -----------------------------------------------------------------------
/// @name Getting Preset Colors
/// -----------------------------------------------------------------------

/**
 *  Returns a color object whose RGB values are 0.0, 1.0, and 1.0 and whose alpha value is 1.0.
 *
 *  @return The CCColor object.
 */
+ (CCColor *)blackColor;

/**
 *  Returns a color object whose grayscale value is 1/3 and whose alpha value is 1.0.
 *
 *  @return The CCColor object.
 */
+ (CCColor *)darkGrayColor;

/**
 *  Returns a color object whose grayscale value is 2/3 and whose alpha value is 1.0.
 *
 *  @return The CCColor object.
 */
+ (CCColor *)lightGrayColor;

/**
 *  Returns a color object whose grayscale value is 1.0 and whose alpha value is 1.0.
 *
 *  @return The CCColor object.
 */
+ (CCColor *)whiteColor;

/**
 *  Returns a color object whose grayscale value is 0.5 and whose alpha value is 1.0.
 *
 *  @return The CCColor object.
 */
+ (CCColor *)grayColor;

/**
 *  Returns a color object whose RGB values are 1.0, 0.0, and 0.0 and whose alpha value is 1.0.
 *
 *  @return The CCColor object.
 */
+ (CCColor *)redColor;

/**
 *  Returns a color object whose RGB values are 0.0, 1.0, and 0.0 and whose alpha value is 1.0.
 *
 *  @return The CCColor object.
 */
+ (CCColor *)greenColor;

/**
 *  Returns a color object whose RGB values are 0.0, 0.0, and 1.0 and whose alpha value is 1.0.
 *
 *  @return The CCColor object.
 */
+ (CCColor *)blueColor;

/**
 *  Returns a color object whose RGB values are 0.0, 1.0, and 1.0 and whose alpha value is 1.0..
 *
 *  @return The CCColor object.
 */
+ (CCColor *)cyanColor;

/**
 *  Returns a color object whose RGB values are 1.0, 1.0, and 0.0 and whose alpha value is 1.0.
 *
 *  @return The CCColor object.
 */
+ (CCColor *)yellowColor;

/**
 *  Returns a color object whose RGB values are 1.0, 0.0, and 1.0 and whose alpha value is 1.0.
 *
 *  @return The CCColor object.
 */
+ (CCColor *)magentaColor;

/**
 *  Returns a color object whose RGB values are 1.0, 0.5, and 0.0 and whose alpha value is 1.0..
 *
 *  @return The CCColor object.
 */
+ (CCColor *)orangeColor;

/**
 *  Returns a color object whose RGB values are 0.5, 0.0, and 0.5 and whose alpha value is 1.0.
 *
 *  @return The CCColor object.
 */
+ (CCColor *)purpleColor;

/**
 *  Returns a color object whose RGB values are 0.6, 0.4, and 0.2 and whose alpha value is 1.0.
 *
 *  @return The CCColor object.
 */
+ (CCColor *)brownColor;

/**
 *  Returns a color object whose RGB values are 0.0, 0.0, and 0.0 and whose alpha value is 0.0.
 *
 *  @return The CCColor object.
 */
+ (CCColor *)clearColor;

/// -----------------------------------------------------------------------
/// @name Converting Colors
/// -----------------------------------------------------------------------

/** The Quartz color reference that corresponds to the CCColor color. */
@property(nonatomic, readonly) CGColorRef CGColor;

#if __CC_PLATFORM_IOS
/** The UIColor color reference that corresponds to the CCColor color. */
@property (nonatomic, readonly) UIColor* UIColor;
#endif

#if __CC_PLATFORM_MAC
/** The NSColor color reference that corresponds to the CCColor color. */
@property (nonatomic, readonly) NSColor* NSColor;
#endif


#pragma mark - Retrieving Color Information
/// -----------------------------------------------------------------------
/// @name Retrieving RGBA Components
/// -----------------------------------------------------------------------

/** Retrieves the color's RGBA components, storing them in the passed-in parameters.
 
 Usage example, the values will be in the float variables after the method call:
 
    float r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
 
 @param red Red color value.
 @param green Green color value.
 @param blue Blue color value.
 @param alpha Alpha value.
 @returns YES
 */
- (BOOL)getRed:(float *)red green:(float *)green blue:(float *)blue alpha:(float *)alpha;

/** Retrieves the color's brightness and alpha components, storing them in the passed-in parameters.
 
 Usage example, the values will be in the float variables after the method call:
 
    float w, a;
    [color getWhite:&w alpha:&a];
 
 @param white Approximated brightness value (average of R+B+G).
 @param alpha Alpha value.
 @returns YES
 */
- (BOOL)getWhite:(float *)white alpha:(float *)alpha;


#pragma mark - Color Helpers
/// -----------------------------------------------------------------------
/// @name Color Helpers
/// -----------------------------------------------------------------------

/**
 *  Linearly interpolate from this color to 'toColor'. Parameter alpha is normalised
 *
 *  @param toColor Color to interpolate to.
 *  @param alpha   Normalised alpha opacity of toColor.
 *
 *  @return The interpolated color.
 */
- (CCColor*)interpolateTo:(CCColor *) toColor alpha:(float) alpha;

@end


#pragma mark - OpenGL Category
// Helper category for OpenGL compatible color creating/accessing.
@interface CCColor (OpenGL)

+ (CCColor*)colorWithCcColor3b: (ccColor3B) c;
+ (CCColor*)colorWithCcColor4b: (ccColor4B) c;
+ (CCColor*)colorWithCcColor4f: (ccColor4F) c;
+ (CCColor*)colorWithGLKVector4: (GLKVector4) c;

- (CCColor*)initWithCcColor3b: (ccColor3B) c;
- (CCColor*)initWithCcColor4b: (ccColor4B) c;
- (CCColor*)initWithGLKVector4: (GLKVector4) c;

@property (nonatomic, readonly) ccColor3B ccColor3b;
@property (nonatomic, readonly) ccColor4B ccColor4b;
@property (nonatomic, readonly) ccColor4F ccColor4f;
@property (nonatomic, readonly) GLKVector4 glkVector4;

@end


#pragma mark - ExtraProperties Category
// Convenience category for accessing properties.

/** RGBA properties */
@interface CCColor (RGBA_Properties)

/** @name Accessing RGBA Properties */

/** The color's red value. */
@property (nonatomic, readonly) float red;
/** The color's green value. */
@property (nonatomic, readonly) float green;
/** The color's blue value. */
@property (nonatomic, readonly) float blue;
/** The color's alpha value. */
@property (nonatomic, readonly) float alpha;

/** @name Comparing Colors */

/**
 Compares specified color to current color and returns whether they are identical.

 @param color Color to compare.
 @return YES if colors are identical.
*/
- (BOOL)isEqualToColor:(CCColor*) color;

@end
