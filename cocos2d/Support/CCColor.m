//
//  CCColor.m
//  cocos2d-ios
//
//  Created by Viktor on 12/10/13.
//
//

#import "CCColor.h"

#import "CCDeprecated.h"

@implementation CCColor {
    GLKVector4 _vec4;
    CGColorRef _color;
}

- (void)dealloc
{
    CGColorRelease(_color);
}

+ (CCColor*) colorWithWhite:(float)white alpha:(float)alpha
{
    return [[CCColor alloc] initWithWhite:white alpha:alpha];
}

+ (CCColor*) colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
{
    return [[CCColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

+ (CCColor*) colorWithRed:(float)red green:(float)green blue:(float)blue
{
    return [[CCColor alloc] initWithRed:red green:green blue:blue];
}

+ (CCColor*) colorWithCGColor:(CGColorRef)cgColor
{
    return [[CCColor alloc] initWithCGColor:cgColor];
}

#if __CC_PLATFORM_IOS
+ (CCColor*) colorWithUIColor:(UIColor *)color
{
    return [[CCColor alloc] initWithUIColor:color];
}
#endif

- (CCColor*) colorWithAlphaComponent:(float)alpha
{
    return [CCColor colorWithRed:_vec4.r green:_vec4.g blue:_vec4.b alpha:alpha];
}

- (CCColor*) initWithWhite:(float)white alpha:(float)alpha
{
    self = [super init];
    if (!self) return NULL;
    
    _vec4.r = white;
    _vec4.g = white;
    _vec4.b = white;
    _vec4.a = alpha;
    
    return self;
}

/** Hue in degrees 
 HSV-RGB Conversion adapted from code by Mr. Evil, beyondunreal wiki
 */
- (CCColor*) initWithHue:(float)hue saturation:(float)saturation brightness:(float)brightness alpha:(float)alpha
{
	self = [super init];
	if (!self) return NULL;
	
	float chroma = saturation * brightness;
	float hueSection = hue / 60.0f;
	float X = chroma *  (1.0f - ABS(fmod(hueSection, 2.0f) - 1.0f));
	GLKVector4 rgb = {};

	if(hueSection < 1.0) {
		rgb.r = chroma;
		rgb.g = X;
	} else if(hueSection < 2.0) {
		rgb.r = X;
		rgb.g = chroma;
	} else if(hueSection < 3.0) {
		rgb.g = chroma;
		rgb.b = X;
	} else if(hueSection < 4.0) {
		rgb.g= X;
		rgb.b = chroma;
	} else if(hueSection < 5.0) {
		rgb.r = X;
		rgb.b = chroma;
	} else if(hueSection <= 6.0){
		rgb.r = chroma;
		rgb.b = X;
	}

	float Min = brightness - chroma;

	rgb.r += Min;
	rgb.g += Min;
	rgb.b += Min;
	rgb.a = alpha;

	return [CCColor colorWithGLKVector4:rgb];
}

- (CCColor*) initWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
{
    self = [super init];
    if (!self) return NULL;
    
    _vec4.r = red;
    _vec4.g = green;
    _vec4.b = blue;
    _vec4.a = alpha;
    
    return self;
}

- (CCColor*) initWithRed:(float)red green:(float)green blue:(float)blue
{
    self = [super init];
    if (!self) return NULL;
    
    _vec4.r = red;
    _vec4.g = green;
    _vec4.b = blue;
    _vec4.a = 1;
    
    return self;
}

- (CCColor*) initWithCGColor:(CGColorRef)cgColor
{
    self = [super init];
    if (!self) return NULL;
    
    const CGFloat *components = CGColorGetComponents(cgColor);
    
    _vec4.r = (float) components[0];
    _vec4.g = (float) components[1];
    _vec4.b = (float) components[2];
    _vec4.a = (float) components[3];
    
    return self;
}

#if __CC_PLATFORM_IOS
- (CCColor*) initWithUIColor:(UIColor *)color
{
    self = [super init];
    if (!self) return self;
    
    CGColorRef colorRef = self.CGColor;
    CGColorSpaceModel csModel = CGColorSpaceGetModel(CGColorGetColorSpace(colorRef));
    if (csModel == kCGColorSpaceModelRGB)
    {
		    CGFloat r, g, b, a;
        [color getRed:&r green:&g blue:&b alpha:&a];
				_vec4.r = r, _vec4.g = g, _vec4.b = b, _vec4.a = a;
    }
    else if (csModel == kCGColorSpaceModelMonochrome)
    {
        CGFloat w, a;
        [color getWhite:&w alpha:&a];
        _vec4.r = w, _vec4.g = w, _vec4.b = w, _vec4.a = a;
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
    CGFloat components[4] = {(CGFloat)_vec4.r, (CGFloat)_vec4.g, (CGFloat)_vec4.b, (CGFloat)_vec4.a};
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    _color = CGColorCreate(colorspace, components);
    CGColorSpaceRelease(colorspace);
    return _color;
}

#if __CC_PLATFORM_IOS

- (UIColor*) UIColor
{
    return [UIColor colorWithRed:_vec4.r green:_vec4.g blue:_vec4.b alpha:_vec4.a];
}

#endif

#if __CC_PLATFORM_MAC
- (NSColor*) NSColor
{
	return [NSColor colorWithCalibratedRed:(CGFloat)_vec4.r green:(CGFloat)_vec4.g blue:(CGFloat)_vec4.b alpha:(CGFloat)_vec4.a];
}
#endif

- (BOOL) getRed:(float *)red green:(float *)green blue:(float *)blue alpha:(float *)alpha
{
    *red = _vec4.r;
    *green = _vec4.g;
    *blue = _vec4.b;
    *alpha = _vec4.a;
    
    return YES;
}

- (BOOL) getWhite:(float *)white alpha:(float *)alpha
{
    *white = (_vec4.r + _vec4.g + _vec4.b) / 3.0; // Just use an average of the components
    *alpha = _vec4.a;
    
    return YES;
}

- (CCColor*) interpolateTo:(CCColor *) toColor alpha:(float) t
{
	return [CCColor colorWithGLKVector4:GLKVector4Lerp(_vec4, toColor.glkVector4, t)];
}

static NSDictionary *namedColors() {
    static NSDictionary *namedColors = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        namedColors = @{
            @"black": [CCColor colorWithRed:0 green:0 blue:0 alpha:1],
            @"darkGray": [CCColor colorWithWhite:1.0/3.0 alpha:1],
            @"lightGray": [CCColor colorWithWhite:2.0/3.0 alpha:1],
            @"white": [CCColor colorWithWhite:1 alpha:1],
            @"gray": [CCColor colorWithWhite:0.5 alpha:1],
            @"red": [CCColor colorWithRed:1 green:0 blue:0 alpha:1],
            @"green": [CCColor colorWithRed:0 green:1 blue:0 alpha:1],
            @"blue": [CCColor colorWithRed:0 green:0 blue:1 alpha:1],
            @"cyan": [CCColor colorWithRed:0 green:1 blue:1 alpha:1],
            @"yellow": [CCColor colorWithRed:1 green:1 blue:0 alpha:1],
            @"magenta": [CCColor colorWithRed:1 green:0 blue:1 alpha:1],
            @"orange": [CCColor colorWithRed:1 green:0.5 blue:0 alpha:1],
            @"purple": [CCColor colorWithRed:0.5 green:0 blue:0.5 alpha:1],
            @"brown": [CCColor colorWithRed:0.6 green:0.4 blue:0.2 alpha:1],
            @"clear": [CCColor colorWithRed:0 green:0 blue:0 alpha:0],
        };
    });
    return namedColors;
}

+ (CCColor*) blackColor { return namedColors()[@"black"]; }
+ (CCColor*) darkGrayColor { return namedColors()[@"darkGray"]; }
+ (CCColor*) lightGrayColor { return namedColors()[@"lightGray"]; }
+ (CCColor*) whiteColor { return namedColors()[@"white"]; }
+ (CCColor*) grayColor { return namedColors()[@"gray"]; }
+ (CCColor*) redColor { return namedColors()[@"red"]; }
+ (CCColor*) greenColor { return namedColors()[@"green"]; }
+ (CCColor*) blueColor { return namedColors()[@"blue"]; }
+ (CCColor*) cyanColor { return namedColors()[@"cyan"]; }
+ (CCColor*) yellowColor { return namedColors()[@"yellow"]; }
+ (CCColor*) magentaColor { return namedColors()[@"magenta"]; }
+ (CCColor*) orangeColor { return namedColors()[@"orange"]; }
+ (CCColor*) purpleColor { return namedColors()[@"purple"]; }
+ (CCColor*) brownColor { return namedColors()[@"brown"]; }
+ (CCColor*) clearColor { return namedColors()[@"clear"]; }

@end


@implementation CCColor (OpenGL)

+ (CCColor*) colorWithGLKVector4:(GLKVector4)c
{
    return [[CCColor alloc] initWithGLKVector4:c];
}

- (CCColor*) initWithGLKVector4: (GLKVector4) c
{
    return [self initWithRed:c.r green:c.g blue:c.b alpha:c.a];
}

-(GLKVector4)glkVector4
{
	return GLKVector4Make(_vec4.r, _vec4.g, _vec4.b, _vec4.a);
}

@end

@implementation CCColor (ExtraProperties)

- (float) red
{
    return _vec4.r;
}

- (float) green
{
    return _vec4.g;
}

- (float) blue
{
    return _vec4.b;
}

- (float) alpha
{
    return _vec4.a;
}

- (BOOL) isEqual:(id)color
{
    if (self == color) return YES;
    if (![color isKindOfClass:[CCColor class]]) return NO;
	
		GLKVector4 c = [(CCColor *)color glkVector4];
    return (_vec4.r == c.r && _vec4.g == c.g && _vec4.b == c.b && _vec4.a == c.a);
}

- (BOOL) isEqualToColor:(CCColor*) color
{
    return [self isEqual:color];
}

@end
