//
//  CCColor.h
//  cocos2d-ios
//
//  Created by Viktor on 12/10/13.
//
//

#import "ccMacros.h"
#import "ccTypes.h"

@interface CCColor : NSObject
{
    CGFloat _r;
    CGFloat _g;
    CGFloat _b;
    CGFloat _a;
}

+ (CCColor *)colorWithWhite:(CGFloat)white alpha:(CGFloat)alpha;
+ (CCColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (CCColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
+ (CCColor *)colorWithCGColor:(CGColorRef)cgColor;
- (CCColor *)colorWithAlphaComponent:(CGFloat)alpha;

#ifdef __CC_PLATFORM_IOS
+ (CCColor *)colorWithUIColor:(UIColor*)color;
#endif

- (CCColor *)initWithWhite:(CGFloat)white alpha:(CGFloat)alpha;
- (CCColor *)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (CCColor *)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
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

- (BOOL)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha;
- (BOOL)getWhite:(CGFloat *)white alpha:(CGFloat *)alpha;

@end

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

@interface CCColor (ExtraProperties)

@property (nonatomic, readonly) CGFloat red;
@property (nonatomic, readonly) CGFloat green;
@property (nonatomic, readonly) CGFloat blue;
@property (nonatomic, readonly) CGFloat alpha;

- (BOOL) isEqualToColor:(CCColor*) color;

@end
