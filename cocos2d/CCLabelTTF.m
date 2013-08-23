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
#import "NSAttributedString+CCAdditions.h"

#ifdef __CC_PLATFORM_IOS
#import "Platforms/iOS/CCDirectorIOS.h"
#import <CoreText/CoreText.h>
#endif


#pragma mark CCLabelTTF


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

- (id) initWithAttributedString:(NSAttributedString *)attrString dimensions:(CGSize)dimensions
{
    return [self initWithAttributedString:attrString fontName:@"Helvetica" fontSize:12 dimensions:dimensions];
}

- (id) initWithAttributedString:(NSAttributedString *)attrString fontName:(NSString*)fontName fontSize:(float)fontSize dimensions:(CGSize)dimensions
{
    if ( (self = [super init]) )
    {
        if (!fontName) fontName = @"Helvetica";
        if (!fontSize) fontSize = 12;
        
        _blendFunc.src = GL_ONE;
        _blendFunc.dst = GL_ONE;
        
        // other properties
        self.fontName = fontName;
        self.fontSize = fontSize;
        self.dimensions = dimensions;
        self.attributedString = attrString;
    }
    return self;
}



#pragma mark Properties

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

- (void) setFontSize:(float)fontSize
{
	if( fontSize != _fontSize ) {
		_fontSize = fontSize;
		
		// Force update
		[self setTextureDirty];
	}
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

- (CGSize) contentSize
{
    [self updateTexture];
    return _contentSize;
}

-(void) setHorizontalAlignment:(CCTextAlignment)alignment
{
    if (alignment != _horizontalAlignment)
    {
        _horizontalAlignment = alignment;
        
        // Force update
		[self setTextureDirty];

    }
}

-(void) setVerticalAlignment:(CCVerticalTextAlignment)verticalAlignment
{
    if (_verticalAlignment != verticalAlignment)
    {
        _verticalAlignment = verticalAlignment;
        
		// Force update
		[self setTextureDirty];
    }
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



#pragma mark Helpers

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
    
    NSMutableAttributedString* formattedAttributedString = [_attributedString mutableCopy];
    NSRange fullRange = NSMakeRange(0, formattedAttributedString.length);
    
    BOOL useFullColor = NO;
    //CGSize dimensions = _dimensions;
    
#ifdef __CC_PLATFORM_IOS
    // Font color
    if (![formattedAttributedString hasAttribute:NSForegroundColorAttributeName])
    {
        [formattedAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:fullRange];
    }
    else
    {
        useFullColor = YES;
    }
    
    // Font
    if (![formattedAttributedString hasAttribute:NSFontAttributeName])
    {
        UIFont* font = [UIFont fontWithName:_fontName size:_fontSize];
        if (!font) font = [UIFont fontWithName:@"Helvetica" size:_fontSize];
        [formattedAttributedString addAttribute:NSFontAttributeName value:font range:fullRange];
    }
    
    // Shadow
    if (![formattedAttributedString hasAttribute:NSShadowAttributeName])
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
            
            useFullColor = YES;
        }
    }
    else
    {
        useFullColor = YES;
    }
    
    // Text alignment
    if (![formattedAttributedString hasAttribute:NSParagraphStyleAttributeName])
    {
        NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
        
        if (_horizontalAlignment == kCCTextAlignmentLeft) style.alignment = NSTextAlignmentLeft;
        else if (_horizontalAlignment == kCCTextAlignmentCenter) style.alignment = NSTextAlignmentCenter;
        else if (_horizontalAlignment == kCCTextAlignmentRight) style.alignment = NSTextAlignmentRight;
        
        [formattedAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:fullRange];
    }
    
    // Dimensions adjusted for content scale
    dimensions.width *= CC_CONTENT_SCALE_FACTOR();
    dimensions.height *= CC_CONTENT_SCALE_FACTOR();
    
#elif defined(__CC_PLATFORM_MAC)
    // Font color
    if (![formattedAttributedString hasAttribute:NSForegroundColorAttributeName])
    {
        [formattedAttributedString addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:fullRange];
    }
    else
    {
        useFullColor = YES;
    }
    
    // Font
    if (![formattedAttributedString hasAttribute:NSFontAttributeName])
    {
        [formattedAttributedString addAttribute:NSFontAttributeName value:[NSFont fontWithName:_fontName size:_fontSize] range:fullRange];
    }
    
    // Shadow
    if (![formattedAttributedString hasAttribute:NSShadowAttributeName])
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
            
            useFullColor = YES;
        }
    }
    else
    {
        useFullColor = YES;
    }
    
    // Text alignment
    if (![formattedAttributedString hasAttribute:NSParagraphStyleAttributeName])
    {
        NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
        
        if (_horizontalAlignment == kCCTextAlignmentLeft) style.alignment = NSLeftTextAlignment;
        else if (_horizontalAlignment == kCCTextAlignmentCenter) style.alignment = NSCenterTextAlignment;
        else if (_horizontalAlignment == kCCTextAlignmentRight) style.alignment = NSRightTextAlignment;
        
        [formattedAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:fullRange];
    }
#endif
    

    // Generate a new texture from the attributed string
	CCTexture2D *tex;
    
    tex = [self createTextureWithAttributedString:[formattedAttributedString copyAdjustedForContentScaleFactor] useFullColor:useFullColor];

	if( !tex )
		return NO;
    
    if (!useFullColor)
    {
        self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureA8Color];
    }

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

- (CCTexture2D*) createTextureWithAttributedString:(NSAttributedString*)attributedString useFullColor:(BOOL) fullColor
{
	NSAssert(attributedString, @"Invalid attributedString");
    
    CGSize originalDimensions = _dimensions;
    
#ifdef __CC_PLATFORM_IOS
    originalDimensions.width *= CC_CONTENT_SCALE_FACTOR();
    originalDimensions.height *= CC_CONTENT_SCALE_FACTOR();
#endif
    
    CGSize dimensions = originalDimensions;
    
    float xOffset = 0;
    float yOffset = 0;
    
	// Get actual rendered dimensions
    if (dimensions.height == 0)
    {
        // Get dimensions for string without dimensions of string with variable height
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
    else if (dimensions.width > 0 && dimensions.height > 0)
    {
        // Handle strings with fixed dimensions
        if (_adjustsFontSizeToFit)
        {
            float fontSize = [attributedString singleFontSize];
            if (fontSize)
            {
                // This is a string that can be resized (it only uses one font and size)
#ifdef __CC_PLATFORM_IOS
                CGSize wantedSize = [attributedString boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
#elif defined(__CC_PLATFORM_MAC)
                CGSize wantedSize = [attributedString boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin].size;
#endif
                
                float wScaleFactor = 1;
                float hScaleFactor = 1;
                if (wantedSize.width > dimensions.width)
                {
                    wScaleFactor = dimensions.width/wantedSize.width;
                }
                if (wantedSize.height > dimensions.height)
                {
                    hScaleFactor = dimensions.height/wantedSize.height;
                }
                
                float scaleFactor = 1;
                if (wScaleFactor < hScaleFactor) scaleFactor = wScaleFactor;
                else scaleFactor = hScaleFactor;
            
                if (scaleFactor != 1)
                {
                    float newFontSize = fontSize * scaleFactor;
                    float minFontSize = _minimumFontSize * CC_CONTENT_SCALE_FACTOR();
                    if (minFontSize && newFontSize < minFontSize) newFontSize = minFontSize;
                    attributedString = [attributedString copyWithNewFontSize:newFontSize];
                }
            }
        }

        // Handle vertical alignment
#ifdef __CC_PLATFORM_IOS
        CGSize actualSize = [attributedString boundingRectWithSize:CGSizeMake(originalDimensions.width, 0) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
#elif defined(__CC_PLATFORM_MAC)
        CGSize actualSize = NSSizeToCGSize([attributedString boundingRectWithSize:NSMakeSize(originalDimensions.width, 0) options:NSStringDrawingUsesLineFragmentOrigin].size);
#endif
        if (_verticalAlignment == kCCVerticalTextAlignmentBottom)
        {
            yOffset = originalDimensions.height - actualSize.height;
        }
        else if (_verticalAlignment == kCCVerticalTextAlignmentCenter)
        {
            yOffset = (originalDimensions.height - actualSize.height)/2;
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
    
    // Render the label - different code for Mac / iOS
    
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
    
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	
	NSImage *image = [[NSImage alloc] initWithSize:POTSize];
	[image lockFocus];
	[[NSAffineTransform transform] set];
	
	[attributedString drawWithRect:NSRectFromCGRect(drawArea) options:NSStringDrawingUsesLineFragmentOrigin];
	
	NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect (0.0f, 0.0f, POTSize.width, POTSize.height)];
	[image unlockFocus];
    
	unsigned char *data = (unsigned char*) [bitmap bitmapData];  //Use the same buffer to improve the performance.
#endif
    
    CCTexture2D* texture = NULL;
    
    // Initialize the texture
    if (fullColor)
    {
        // RGBA8888 format
        texture = [[CCTexture2D alloc] initWithData:data pixelFormat:kCCTexture2DPixelFormat_RGBA8888 pixelsWide:POTSize.width pixelsHigh:POTSize.height contentSize:dimensions];
#warning FIX!
        //texture.hasPremultipliedAlpha = YES;
    }
    else
    {
        NSUInteger textureSize = POTSize.width * POTSize.height;
        
        // A8 format (alpha channel only)
        unsigned char* dst = data;
        for(int i = 0; i<textureSize; i++)
            dst[i] = data[i*4+3];
        
        texture = [[CCTexture2D alloc] initWithData:data pixelFormat:kCCTexture2DPixelFormat_A8 pixelsWide:POTSize.width pixelsHigh:POTSize.height contentSize:dimensions];
        self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureA8Color];
    }
    
#ifdef __CC_PLATFORM_IOS
    free(data); // On Mac data is freed by NSBitmapImageRep
#endif
    
	return texture;
}

- (void) visit
{
    if (_isTextureDirty)
    {
        [self updateTexture];
    }
    
    [super visit];
}



#pragma mark Handle HTML

#ifdef __CC_PLATFORM_MAC
- (void) setHTML:(NSString *)html
{
    NSData* data = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    self.attributedString = [[NSAttributedString alloc] initWithHTML:data documentAttributes:NULL];
}
#endif



#pragma mark Class functions

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
