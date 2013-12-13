//
//  CCColor.m
//  cocos2d-ios
//
//  Created by Viktor on 12/10/13.
//
//

#import "CCColor.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation CCColor

+ (CCColor*) colorWithWhite:(CGFloat)white alpha:(CGFloat)alpha
{
    return [[CCColor alloc] initWithWhite:white alpha:alpha];
}

+ (CCColor*) colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [[CCColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

+ (CCColor*) colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    return [[CCColor alloc] initWithRed:red green:green blue:blue];
}

+ (CCColor*) colorWithCGColor:(CGColorRef)cgColor
{
    return [[CCColor alloc] initWithCGColor:cgColor];
}

#ifdef __CC_PLATFORM_IOS
+ (CCColor*) colorWithUIColor:(UIColor *)color
{
    return [[CCColor alloc] initWithUIColor:color];
}
#endif

- (CCColor*) colorWithAlphaComponent:(CGFloat)alpha
{
    return [CCColor colorWithRed:_r green:_g blue:_b alpha:alpha];
}

- (CCColor*) initWithWhite:(CGFloat)white alpha:(CGFloat)alpha
{
    self = [super init];
    if (!self) return NULL;
    
    _r = white;
    _g = white;
    _b = white;
    _a = alpha;
    
    return self;
}

- (CCColor*) initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
    self = [super init];
    if (!self) return NULL;
    
    //NSColor* c = [NSColor colorWithCalibratedHue:hue saturation:saturation brightness:brightness alpha:alpha];
    //[c getRed:&_r green:&_g blue:&_b alpha:&_a];
    
    return self;
}

- (CCColor*) initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    self = [super init];
    if (!self) return NULL;
    
    _r = red;
    _g = green;
    _b = blue;
    _a = alpha;
    
    return self;
}

- (CCColor*) initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    self = [super init];
    if (!self) return NULL;
    
    _r = red;
    _g = green;
    _b = blue;
    _a = 1;
    
    return self;
}

- (CCColor*) initWithCGColor:(CGColorRef)cgColor
{
    self = [super init];
    if (!self) return NULL;
    
    const CGFloat *components = CGColorGetComponents(cgColor);
    
    _r = components[0];
    _g = components[1];
    _b = components[2];
    _a = components[3];
    
    return self;
}

#ifdef __CC_PLATFORM_IOS
- (CCColor*) initWithUIColor:(UIColor *)color
{
    self = [super init];
    if (!self) return NULL;
    
    CGColorSpaceModel csModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    if (csModel == kCGColorSpaceModelRGB)
    {
        [color getRed:&_r green:&_g blue:&_b alpha:&_a];
    }
    else if (csModel == kCGColorSpaceModelMonochrome)
    {
        CGFloat w, a;
        [color getWhite:&w alpha:&a];
        _r = w;
        _g = w;
        _b = w;
        _a = a;
    }
    else
    {
        NSAssert(NO, @"UIColor has unsupported color space model");
    }
    
    return self;
}
#endif

- (CGColorRef) CGColor
{
    CGFloat components[4] = {_r, _g, _b, _a};
    return CGColorCreate(CGColorSpaceCreateDeviceRGB(), components);
}

#ifdef __CC_PLATFORM_IOS

- (UIColor*) UIColor
{
    return [UIColor colorWithRed:_r green:_g blue:_b alpha:_a];
}

#endif

- (BOOL) getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha
{
    *red = _r;
    *green = _g;
    *blue = _b;
    *alpha = _a;
    
    return YES;
}

- (BOOL) getWhite:(CGFloat *)white alpha:(CGFloat *)alpha
{
    *white = (_r + _g + _b) / 3.0; // Just use an average of the components
    *alpha = _a;
    
    return YES;
}

+ (CCColor*) blackColor
{
    return [CCColor colorWithRed:0 green:0 blue:0 alpha:1];
}

+ (CCColor*) darkGrayColor
{
    return [CCColor colorWithWhite:1.0/3.0 alpha:1];
}

+ (CCColor*) lightGrayColor
{
    return [CCColor colorWithWhite:2.0/3.0 alpha:1];
}

+ (CCColor*) whiteColor
{
    return [CCColor colorWithWhite:1 alpha:1];
}

+ (CCColor*) grayColor
{
    return [CCColor colorWithWhite:0.5 alpha:1];
}

+ (CCColor*) redColor
{
    return [CCColor colorWithRed:1 green:0 blue:0 alpha:1];
}

+ (CCColor*) greenColor
{
    return [CCColor colorWithRed:0 green:1 blue:0 alpha:1];
}

+ (CCColor*) blueColor
{
    return [CCColor colorWithRed:0 green:0 blue:1 alpha:1];
}

+ (CCColor*) cyanColor
{
    return [CCColor colorWithRed:0 green:1 blue:1 alpha:1];
}

+ (CCColor*) yellowColor
{
    return [CCColor colorWithRed:1 green:1 blue:0 alpha:1];
}

+ (CCColor*) magentaColor
{
    return [CCColor colorWithRed:1 green:0 blue:1 alpha:1];
}

+ (CCColor*) orangeColor
{
    return [CCColor colorWithRed:1 green:0.5 blue:0 alpha:1];
}

+ (CCColor*) purpleColor
{
    return [CCColor colorWithRed:0.5 green:0 blue:0.5 alpha:1];
}

+ (CCColor*) brownColor
{
    return [CCColor colorWithRed:0.6 green:0.4 blue:0.2 alpha:1];
}

+ (CCColor*) clearColor
{
    return [CCColor colorWithRed:0 green:0 blue:0 alpha:0];
}

@end


@implementation CCColor (OpenGL)

+ (CCColor*) colorWithCcColor3b:(ccColor3B)c
{
    return [[CCColor alloc] initWithCcColor3b:c];
}

+ (CCColor*) colorWithCcColor4b:(ccColor4B)c
{
    return [[CCColor alloc] initWithCcColor4b:c];
}

+ (CCColor*) colorWithCcColor4f:(ccColor4F)c
{
    return [[CCColor alloc] initWithCcColor4f:c];
}

- (CCColor*) initWithCcColor3b: (ccColor3B) c
{
    return [self initWithRed:c.r/255.0 green:c.g/255.0 blue:c.b/255.0 alpha:1];
}

- (CCColor*) initWithCcColor4b: (ccColor4B) c
{
    return [self initWithRed:c.r/255.0 green:c.g/255.0 blue:c.b/255.0 alpha:c.a/255.0];
}

- (CCColor*) initWithCcColor4f: (ccColor4F) c
{
    return [self initWithRed:c.r green:c.g blue:c.b alpha:c.a];
}

- (ccColor3B) ccColor3b
{
    return (ccColor3B){(GLubyte)(_r*255), (GLubyte)(_g*255), (GLubyte)(_b*255)};
}

- (ccColor4B) ccColor4b
{
    return (ccColor4B){(GLubyte)(_r*255), (GLubyte)(_g*255), (GLubyte)(_b*255), (GLubyte)(_a*255)};
}

- (ccColor4F) ccColor4f
{
    return ccc4f(_r, _g, _b, _a);
}

@end

@implementation CCColor (ExtraProperties)

- (CGFloat) red
{
    return _r;
}

- (CGFloat) green
{
    return _g;
}

- (CGFloat) blue
{
    return _b;
}

- (CGFloat) alpha
{
    return _a;
}

- (BOOL) isEqual:(id)color
{
    if (self == color) return YES;
    if (![color isKindOfClass:[CCColor class]]) return NO;
    
    ccColor4F c4f0 = self.ccColor4f;
    ccColor4F c4f1 = ((CCColor*)color).ccColor4f;
    
    return ccc4FEqual(c4f0, c4f1);
}

- (BOOL) isEqualToColor:(CCColor*) color
{
    return [self isEqual:color];
}

@end
