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


#import "CCLabelTTF.h"
#import "Support/CGPointExtension.h"
#import "ccMacros.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "Support/CCFileUtils.h"
#import "ccDeprecated.h"
#import "ccMacros.h"
#import "ccUtils.h"

#ifdef __CC_PLATFORM_IOS
#import "Platforms/iOS/CCDirectorIOS.h"
#import <CoreText/CoreText.h>
#endif

#if CC_USE_LA88_LABELS
#define SHADER_PROGRAM kCCShader_PositionTextureColor
#else
#define SHADER_PROGRAM kCCShader_PositionTextureA8Color
#endif

#if CC_USE_LA88_LABELS
#define LABEL_PIXEL_FORMAT kCCTexture2DPixelFormat_AI88
#else
#define LABEL_PIXEL_FORMAT kCCTexture2DPixelFormat_A8
#endif

#pragma mark -
#pragma mark CCTexture2D - Text

@implementation CCTexture2D (Text)

- (id) initWithAttributedString:(NSAttributedString*)attributedString dimensions:(CGSize)dimensions
{
	NSAssert(attributedString, @"Invalid attributedString");
    
    float xOffset = 0;
    float yOffset = 0;
    
	// Get actual rendered dimensions
    if (dimensions.width == 0 || dimensions.height == 0)
    {
        // Get dimensions for string
#ifdef __CC_PLATFORM_IOS
        dimensions = [attributedString boundingRectWithSize:dimensions options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
#elif defined(__CC_PLATFORM_MAC)
        dimensions = [attributedString boundingRectWithSize:NSSizeFromCGSize(dimensions) options:NSStringDrawingUsesLineFragmentOrigin].size;
#endif
        
        // Outset the dimensions with regards to shadow
        NSShadow* shadow = [attributedString attribute:NSShadowAttributeName atIndex:0 effectiveRange:NULL];
        if (shadow)
        {
            xOffset = (shadow.shadowBlurRadius + fabs(shadow.shadowOffset.width))*2;
            yOffset = (shadow.shadowBlurRadius + fabs(shadow.shadowOffset.height))*2;
            
            dimensions.width += xOffset * 2;
            dimensions.height += yOffset * 2;
        }
    }
    
    // Round dimensions to nearest number that is dividable by 2
    dimensions.width = ceilf(dimensions.width/2)*2;
    dimensions.height = ceilf(dimensions.height/2)*2;
    
    // get nearest power of two
    CGSize POTSize = CGSizeMake(ccNextPOT(dimensions.width), ccNextPOT(dimensions.height));
    
	// Mac crashes if the width or height is 0
	if( POTSize.width == 0 )
		POTSize.width = 2;
    
	if( POTSize.height == 0)
		POTSize.height = 2;
    

#ifdef __CC_PLATFORM_IOS
    yOffset = (POTSize.height - dimensions.height) + yOffset;
	
	CGRect drawArea = CGRectMake(xOffset, yOffset, dimensions.width, dimensions.height);
    
    
    unsigned char* data = calloc(POTSize.width, POTSize.height * 4);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, POTSize.width, POTSize.height, 8, POTSize.width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    if (!context)
    {
        free(data);
        return NULL;
    }
    
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, POTSize.height * 2 - dimensions.height);
    CGContextConcatCTM(context, flipVertical);
    
	UIGraphicsPushContext(context);
    [attributedString drawInRect:drawArea];
    
    UIGraphicsPopContext();

#elif defined(__CC_PLATFORM_MAC)
    yOffset = (POTSize.height - dimensions.height) - yOffset;
	
	CGRect drawArea = CGRectMake(xOffset, yOffset, dimensions.width, dimensions.height);
    
	//Disable antialias
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	
	NSImage *image = [[NSImage alloc] initWithSize:POTSize];
	[image lockFocus];
	[[NSAffineTransform transform] set];
	
	[attributedString drawWithRect:NSRectFromCGRect(drawArea) options:NSStringDrawingUsesLineFragmentOrigin];
	
	NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect (0.0f, 0.0f, POTSize.width, POTSize.height)];
	[image unlockFocus];
    
	unsigned char *data = (unsigned char*) [bitmap bitmapData];  //Use the same buffer to improve the performance.
#endif
    
    self = [self initWithData:data pixelFormat:kCCTexture2DPixelFormat_RGBA8888 pixelsWide:POTSize.width pixelsHigh:POTSize.height contentSize:dimensions];

#ifdef __CC_PLATFORM_IOS
    free(data);
#endif
    
	return self;
}
@end




@implementation CCLabelTTF

+ (id) labelWithString:(NSString *)string fontName:(NSString *)name fontSize:(CGFloat)size
{
    return [[self alloc] initWithString:string fontName:name fontSize:size];
}

+ (id) labelWithString:(NSString *)string fontName:(NSString *)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions
{
    return [[self alloc] initWithString:string fontName:name fontSize:size dimensions:dimensions];
}

+ (id) labelWithAttributedString:(NSAttributedString *)attrString
{
    return [[self alloc] initWithAttributedString:attrString];
}

+ (id) labelWithAttributedString:(NSAttributedString *)attrString dimensions:(CGSize)dimensions
{
    return [[self alloc] initWithAttributedString:attrString dimensions:dimensions];
}

- (id) init
{
    return [self initWithString:@"" fontName:@"Helvetica" fontSize:12];
}


- (id) initWithString:(NSString*)str fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self initWithAttributedString:[[NSAttributedString alloc] initWithString:str] fontName:name fontSize:size dimensions:CGSizeZero];
}

- (id) initWithString:(NSString*)str fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions
{
    return [self initWithAttributedString:[[NSAttributedString alloc] initWithString:str] fontName:name fontSize:size dimensions:dimensions];
}

- (id) initWithAttributedString:(NSAttributedString *)attrString;
{
    return [self initWithAttributedString:attrString fontName:@"Helvetica" fontSize:12 dimensions:CGSizeZero];
}

- (id) initWithWithAttributedString:(NSAttributedString *)attrString dimensions:(CGSize)dimensions
{
    return [self initWithAttributedString:attrString fontName:@"Helvetica" fontSize:12 dimensions:dimensions];
}

- (id) initWithAttributedString:(NSAttributedString *)attrString fontName:(NSString*)fontName fontSize:(float)fontSize dimensions:(CGSize)dimensions
{
    if ( (self = [super init]) )
    {
        if (!fontName) fontName = @"Helvetica";
        if (!fontSize) fontSize = 12;
        
        // shader program
		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:SHADER_PROGRAM];
        
        // other properties
        self.fontName = fontName;
        self.fontSize = fontSize;
        self.dimensions = dimensions;
        self.attributedString = attrString;
    }
    return self;
}

- (void) setAttributedString:(NSAttributedString *)attributedString
{
    NSAssert(attributedString, @"Invalid attributedString");
    
    if ( _attributedString.hash != attributedString.hash)
    {
        _attributedString = [attributedString copy];
        
        [self setTextureDirty];
    }
}

- (void) setString:(NSString*)str
{
	NSAssert( str, @"Invalid string" );
    self.attributedString = [[NSAttributedString alloc] initWithString:str];
}

-(NSString*) string
{
	return [_attributedString string];
}

- (void)setFontName:(NSString*)fontName
{
    
	if( fontName.hash != _fontName.hash ) {
		_fontName = [fontName copy];
		
		// Force update
		[self setTextureDirty];
	}
}

- (NSString*)fontName
{
    return _fontName;
}

- (void) setFontSize:(float)fontSize
{
	if( fontSize != _fontSize ) {
		_fontSize = fontSize;
		
		// Force update
		[self setTextureDirty];
	}
}

- (float) fontSize
{
    return _fontSize;
}

-(void) setDimensions:(CGSize) dim
{
    if( dim.width != _dimensions.width || dim.height != _dimensions.height)
	{
        _dimensions = dim;
        
		// Force update
		[self setTextureDirty];
    }
}

-(CGSize) dimensions
{
    return _dimensions;
}

-(void) setHorizontalAlignment:(CCTextAlignment)alignment
{
    if (alignment != _hAlignment)
    {
        _hAlignment = alignment;
        
        // Force update
		[self setTextureDirty];

    }
}

- (CCTextAlignment) horizontalAlignment
{
    return _hAlignment;
}

-(void) setVerticalAlignment:(CCVerticalTextAlignment)verticalAlignment
{
    if (_vAlignment != verticalAlignment)
    {
        _vAlignment = verticalAlignment;
        
		// Force update
		[self setTextureDirty];
    }
}

- (CCVerticalTextAlignment) verticalAlignment
{
    return _vAlignment;
}

- (void) setShadowColor:(ccColor4B)shadowColor
{
    if (!ccc4BEqual(_shadowColor, shadowColor))
    {
        _shadowColor = shadowColor;
        [self setTextureDirty];
    }
}

- (void) setShadowOffset:(CGPoint)shadowOffset
{
    if (!CGPointEqualToPoint(_shadowOffset, shadowOffset))
    {
        _shadowOffset = shadowOffset;
        [self setTextureDirty];
    }
}

- (void) setShadowBlurRadius:(float)shadowBlurRadius
{
    if (_shadowBlurRadius != shadowBlurRadius)
    {
        _shadowBlurRadius = shadowBlurRadius;
        [self setTextureDirty];
    }
}

- (NSString*) description
{
	// XXX: _string, _fontName can't be displayed here, since they might be already released

	return [NSString stringWithFormat:@"<%@ = %p | FontSize = %.1f>", [self class], self, _fontSize];
}

// Helper
- (void) setTextureDirty
{
    _isTextureDirty = YES;
}

- (BOOL) updateTexture
{
    if (!_attributedString) return NO;
    if (!_isTextureDirty) return NO;
    
    _isTextureDirty = NO;
    
    // Set default values for font attributes if they are not set in the attributed string
    NSDictionary* presetAttributes = [_attributedString attributesAtIndex:0 effectiveRange:NULL];
    
    NSMutableAttributedString* formattedAttributedString = [_attributedString mutableCopy];
    NSRange fullRange = NSMakeRange(0, formattedAttributedString.length);
    
#ifdef __CC_PLATFORM_IOS
    // Font color
    if (![presetAttributes objectForKey:NSForegroundColorAttributeName])
    {
        [formattedAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:fullRange];
    }
    
    // Font
    if (![presetAttributes objectForKey:NSFontAttributeName])
    {
        [formattedAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:_fontName size:_fontSize] range:fullRange];
    }
    
    // Shadow
    if (![presetAttributes objectForKey:NSShadowAttributeName])
    {
        if (_shadowColor.a > 0)
        {
            float r = ((float)_shadowColor.r)/255;
            float g = ((float)_shadowColor.g)/255;
            float b = ((float)_shadowColor.b)/255;
            float a = ((float)_shadowColor.a)/255;
            
            NSShadow* shadow = [[NSShadow alloc] init];
            shadow.shadowOffset = CGSizeMake(_shadowOffset.x, _shadowOffset.y);
            shadow.shadowBlurRadius = _shadowBlurRadius;
            shadow.shadowColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
            
            [formattedAttributedString addAttribute:NSShadowAttributeName value:shadow range:fullRange];
        }
    }
#elif defined(__CC_PLATFORM_MAC)
    // Font color
    if (![presetAttributes objectForKey:NSForegroundColorAttributeName])
    {
        [formattedAttributedString addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:fullRange];
    }
    
    // Font
    if (![presetAttributes objectForKey:NSFontAttributeName])
    {
        [formattedAttributedString addAttribute:NSFontAttributeName value:[NSFont fontWithName:_fontName size:_fontSize] range:fullRange];
    }
    
    // Shadow
    if (![presetAttributes objectForKey:NSShadowAttributeName])
    {
        if (_shadowColor.a > 0)
        {
            float r = ((float)_shadowColor.r)/255;
            float g = ((float)_shadowColor.g)/255;
            float b = ((float)_shadowColor.b)/255;
            float a = ((float)_shadowColor.a)/255;
            
            NSShadow* shadow = [[NSShadow alloc] init];
            shadow.shadowOffset = NSMakeSize(_shadowOffset.x, _shadowOffset.y);
            shadow.shadowBlurRadius = _shadowBlurRadius;
            shadow.shadowColor = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
            
            [formattedAttributedString addAttribute:NSShadowAttributeName value:shadow range:fullRange];
        }
    }
#endif

    // Generate a new texture from the attributed string
	CCTexture2D *tex;
    
    tex = [[CCTexture2D alloc] initWithAttributedString:formattedAttributedString dimensions:_dimensions];

	if( !tex )
		return NO;

#ifdef __CC_PLATFORM_IOS
	// iPad ?
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
		if( CC_CONTENT_SCALE_FACTOR() == 2 )
			[tex setResolutionType:kCCResolutioniPadRetinaDisplay];
		else
			[tex setResolutionType:kCCResolutioniPad];
	}
	// iPhone ?
	else
	{
		if( CC_CONTENT_SCALE_FACTOR() == 2 )
			[tex setResolutionType:kCCResolutioniPhoneRetinaDisplay];
		else
			[tex setResolutionType:kCCResolutioniPhone];
	}
#endif
	
    // Update texture and content size
	[self setTexture:tex];
	
	CGRect rect = CGRectZero;
	rect.size = [_texture contentSize];
	[self setTextureRect: rect];
	
	return YES;
}

- (void) visit
{
    if (_isTextureDirty)
    {
        [self updateTexture];
    }
    
    [super visit];
}

+ (void) registerCustomTTF:(NSString *)fontFile
{
    if ([[fontFile lowercaseString] hasSuffix:@".ttf"])
    {
        // This is a file, register font with font manager
        NSString* fontPath = [[CCFileUtils sharedFileUtils] fullPathForFilename:fontFile];
        NSURL* fontURL = [NSURL fileURLWithPath:fontPath];
        CTFontManagerRegisterFontsForURL((__bridge CFURLRef)fontURL, kCTFontManagerScopeProcess, NULL);
    }
}

@end
