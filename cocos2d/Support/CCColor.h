//
//  CCColor.h
//  cocos2d-ios
//
//  Created by Viktor on 12/10/13.
//
//

#import "ccMacros.h"
#import "ccTypes.h"

#ifdef __CC_PLATFORM_IOS

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define CCColor UIColor

#elif defined (__CC_PLATFORM_MAC)

@interface CCColor : NSObject
{
    CGFloat _r;
    CGFloat _g;
    CGFloat _b;
    CGFloat _a;
}

+ (CCColor *)colorWithWhite:(CGFloat)white alpha:(CGFloat)alpha;
+ (CCColor *)colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
+ (CCColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (CCColor *)colorWithCGColor:(CGColorRef)cgColor;
+ (CCColor *)colorWithCIColor:(CIColor *)ciColor;
- (CCColor *)colorWithAlphaComponent:(CGFloat)alpha;

- (CCColor *)initWithWhite:(CGFloat)white alpha:(CGFloat)alpha;
- (CCColor *)initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
- (CCColor *)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (CCColor *)initWithCGColor:(CGColorRef)cgColor;
- (CCColor *)initWithCIColor:(CIColor *)ciColor;

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
@property(nonatomic, readonly) CIColor *CIColor;

- (BOOL)getHue:(CGFloat *)hue saturation:(CGFloat *)saturation brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha;
- (BOOL)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha;
- (BOOL)getWhite:(CGFloat *)white alpha:(CGFloat *)alpha;

@end

#endif

@interface CCColor (OpenGL)

+ (CCColor*) colorWithCcColor3b: (ccColor3B) c;
+ (CCColor*) colorWithCcColor4b: (ccColor4B) c;
+ (CCColor*) colorWithCcColor4f: (ccColor4F) c;

- (CCColor*) initWithCcColor3b: (ccColor3B) c;
- (CCColor*) initWithCcColor4b: (ccColor4B) c;
- (CCColor*) initWithCcColor4f: (ccColor4F) c;


@property (nonatomic, readonly) ccColor3B ccColor3b;
@property (nonatomic, readonly) ccColor4B ccColor4b;
@property (nonatomic, readonly) ccColor4F ccColor4f;

@end
