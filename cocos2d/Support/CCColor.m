//
//  CCColor.m
//  cocos2d-ios
//
//  Created by Viktor on 12/10/13.
//
//

#import "CCColor.h"

#ifdef __CC_PLATFORM_MAC

@implementation CCColor

+ (CCColor*) colorWithWhite:(CGFloat)white alpha:(CGFloat)alpha
{
    return [[CCColor alloc] initWithWhite:white alpha:alpha];
}

+ (CCColor*) colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
    return [[CCColor alloc] initWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

+ (CCColor*) colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [[CCColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

+ (CCColor*) colorWithCGColor:(CGColorRef)cgColor
{
    return [[CCColor alloc] initWithCGColor:cgColor];
}

+ (CCColor*) colorWithCIColor:(CIColor *)ciColor
{
    return [[CCColor alloc] initWithCIColor:ciColor];
}

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
    
    NSColor* c = [NSColor colorWithCalibratedHue:hue saturation:saturation brightness:brightness alpha:alpha];
    [c getRed:&_r green:&_g blue:&_b alpha:&_a];
    
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

- (CCColor*) initWithCIColor:(CIColor *)ciColor
{
    self = [super init];
    if (!self) return NULL;
    
    _r = ciColor.red;
    _g = ciColor.green;
    _b = ciColor.blue;
    _a = ciColor.alpha;
    
    return self;
}

- (CGColorRef) CGColor
{
    return CGColorCreateGenericRGB(_r, _g, _b, _a);
}

- (CIColor*) CIColor
{
    return [CIColor colorWithRed:_r green:_g blue:_b alpha:_a];
}

- (BOOL) getHue:(CGFloat *)hue saturation:(CGFloat *)saturation brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha
{
    NSColor* c = [NSColor colorWithCalibratedRed:_r green:_g blue:_b alpha:_a];
    *hue = c.hueComponent;
    *saturation = c.saturationComponent;
    *brightness = c.saturationComponent;
    *alpha = _a;
    
    return YES;
}

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

#endif

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
    CGColorSpaceModel csModel = [self colorSpaceModel];
    if (csModel == kCGColorSpaceModelRGB)
    {
        CGFloat r, g, b, a;
        [self getRed:&r green:&g blue:&b alpha:&a];
        
        return (ccColor3B){(GLubyte)(r*255), (GLubyte)(g*255), (GLubyte)(b*255)};
    }
    else if (csModel == kCGColorSpaceModelMonochrome)
    {
        CGFloat w, a;
        [self getWhite:&w alpha:&a];
        return ccc3(w*255, w*255, w*255);
    }
    else
    {
        return ccc3(255, 255, 255);
    }
}

- (ccColor4B) ccColor4b
{
    CGColorSpaceModel csModel = [self colorSpaceModel];
    if (csModel == kCGColorSpaceModelRGB)
    {
        CGFloat r, g, b, a;
        [self getRed:&r green:&g blue:&b alpha:&a];
        
        return (ccColor4B){(GLubyte)(r*255), (GLubyte)(g*255), (GLubyte)(b*255), (GLubyte)(a*255)};
    }
    else if (csModel == kCGColorSpaceModelMonochrome)
    {
        CGFloat w, a;
        [self getWhite:&w alpha:&a];
        return ccc4(w*255, w*255, w*255, a*255);
    }
    else
    {
        return ccc4(255, 255, 255, 255);
    }
}

- (ccColor4F) ccColor4f
{
    CGColorSpaceModel csModel = [self colorSpaceModel];
    if (csModel == kCGColorSpaceModelRGB)
    {
        CGFloat r, g, b, a;
        [self getRed:&r green:&g blue:&b alpha:&a];
        
        return ccc4f(r, g, b, a);
    }
    else if (csModel == kCGColorSpaceModelMonochrome)
    {
        CGFloat w, a;
        [self getWhite:&w alpha:&a];
        return ccc4f(w, w, w, a);
    }
    else
    {
        return ccc4f(1, 1, 1, 1);
    }
}

- (CGColorSpaceModel) colorSpaceModel
{
	return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

@end

@implementation CCColor (ExtraProperties)

- (CGFloat) red
{
    CGColorSpaceModel csModel = [self colorSpaceModel];
    if (csModel == kCGColorSpaceModelRGB)
    {
        CGFloat r, g, b, a;
        [self getRed:&r green:&g blue:&b alpha:&a];
        return r;
    }
    else if (csModel == kCGColorSpaceModelMonochrome)
    {
        CGFloat w, a;
        [self getWhite:&w alpha:&a];
        return w;
    }
    else
    {
        return 1;
    }
}

- (CGFloat) green
{
    CGColorSpaceModel csModel = [self colorSpaceModel];
    if (csModel == kCGColorSpaceModelRGB)
    {
        CGFloat r, g, b, a;
        [self getRed:&r green:&g blue:&b alpha:&a];
        return g;
    }
    else if (csModel == kCGColorSpaceModelMonochrome)
    {
        CGFloat w, a;
        [self getWhite:&w alpha:&a];
        return w;
    }
    else
    {
        return 1;
    }
}

- (CGFloat) blue
{
    CGColorSpaceModel csModel = [self colorSpaceModel];
    if (csModel == kCGColorSpaceModelRGB)
    {
        CGFloat r, g, b, a;
        [self getRed:&r green:&g blue:&b alpha:&a];
        return b;
    }
    else if (csModel == kCGColorSpaceModelMonochrome)
    {
        CGFloat w, a;
        [self getWhite:&w alpha:&a];
        return w;
    }
    else
    {
        return 1;
    }
}

- (CGFloat) alpha
{
    CGColorSpaceModel csModel = [self colorSpaceModel];
    if (csModel == kCGColorSpaceModelRGB)
    {
        CGFloat r, g, b, a;
        [self getRed:&r green:&g blue:&b alpha:&a];
        return a;
    }
    else if (csModel == kCGColorSpaceModelMonochrome)
    {
        CGFloat w, a;
        [self getWhite:&w alpha:&a];
        return a;
    }
    else
    {
        return 1;
    }
}

- (BOOL) isEqualToColor:(CCColor*) color
{
    if (self == color) return YES;
    if (![color isKindOfClass:[CCColor class]]) return NO;
    
    ccColor4F c4f0 = self.ccColor4f;
    ccColor4F c4f1 = ((CCColor*)color).ccColor4f;
    
    return ccc4FEqual(c4f0, c4f1);
}

@end
