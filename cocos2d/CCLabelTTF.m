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

#ifdef __CC_PLATFORM_IOS

- (id) initWithString:(NSString*)string fontDef:(CCFontDefinition *)definition
{
	// MUST have the same order declared on ccTypes
	NSInteger linebreaks[] = {NSLineBreakByWordWrapping, NSLineBreakByCharWrapping, NSLineBreakByClipping, NSLineBreakByTruncatingHead, NSLineBreakByTruncatingTail, NSLineBreakByTruncatingMiddle};
    
    
    
    UIFont *uifont = [UIFont fontWithName:definition.fontName size:definition.fontSize];
	if( ! uifont )
    {
		CCLOG(@"cocos2d: Texture2d: Invalid Font: %@. Verify the .ttf name", definition.fontName);
		return nil;
	}
    
	// width and height
	NSUInteger textureWidth   = 0;
	NSUInteger textureHeight  = 0;
    
    
    // the final dimension
    CGSize computedDimension;
    
    if (definition.dimensions.width == 0 || definition.dimensions.height == 0)
    {
        CGSize boundingSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        CGSize dim = [string sizeWithFont:uifont
                        constrainedToSize:boundingSize
                            lineBreakMode:NSLineBreakByWordWrapping];
        
        if(dim.width == 0)
            dim.width = 1;
        if(dim.height == 0)
            dim.height = 1;
        
        textureWidth  = dim.width;
        textureHeight = dim.height;
        
        computedDimension = dim;
    }
    else
    {
        textureWidth        = ccNextPOT(definition.dimensions.width);
        textureHeight       = ccNextPOT(definition.dimensions.height);
        computedDimension   = definition.dimensions;
    }
    
	unsigned char*			data;
	CGContextRef			context;
	CGColorSpaceRef			colorSpace;
    
    // check if stroke or shadows are enabled
    bool effectsEnabled = (([definition shadowEnabled]) || ([definition strokeEnabled]));
    
    // compute the padding needed by shadow and stroke
    float shadowStrokePaddingX = 0.0f;
    float shadowStrokePaddingY = 0.0f;
    
    
    if ( [definition strokeEnabled] )
    {
        shadowStrokePaddingY = shadowStrokePaddingX = ceilf([definition strokeSize]);
    }
    
    if ( [definition shadowEnabled] )
    {
        shadowStrokePaddingX = max(shadowStrokePaddingX, (float)abs([definition shadowOffset].width));
        shadowStrokePaddingY = max(shadowStrokePaddingY, (float)abs([definition shadowOffset].height));
    }
    
    // add the padding (this could be 0 if no shadow and no stroke)
    textureWidth  += shadowStrokePaddingX;
    textureHeight += shadowStrokePaddingY;
    
    
    
#if CC_USE_LA88_LABELS
    
	if (effectsEnabled)
	{
		data = calloc(textureHeight, textureWidth * 4);
	}
	else
	{
		data = calloc(textureHeight, textureWidth * 2);
	}
	
#else
    
	data = calloc(textureHeight, textureWidth);
    
#endif
    
    if (effectsEnabled)
    {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        context    = CGBitmapContextCreate(data, textureWidth, textureHeight, 8, textureWidth * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGContextSetRGBFillColor(context, ((float)definition.fontFillColor.r) /255.0, ((float)definition.fontFillColor.g/255.0), ((float)definition.fontFillColor.b/255.0), 1.0);
    }
    else
    {
        colorSpace = CGColorSpaceCreateDeviceGray();
		// XXX ios7
        context = CGBitmapContextCreate(data, textureWidth, textureHeight, 8, textureWidth, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
        CGContextSetGrayFillColor(context, 1.0f, 1.0f);
    }
    
	
	CGColorSpaceRelease(colorSpace);
	
	if( ! context ) {
		free(data);
		return nil;
	}
	
	
	CGContextTranslateCTM(context, 0.0f, textureHeight - shadowStrokePaddingY);
	CGContextScaleCTM(context, 1.0f, -1.0f); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
	UIGraphicsPushContext(context);
    
    // take care of stroke if needed
    if ( [definition strokeEnabled] )
    {
        CGContextSetTextDrawingMode(context, kCGTextFillStroke);
        CGContextSetRGBStrokeColor(context, [definition strokeColor].r, [definition strokeColor].g, [definition strokeColor].b, 1);
        CGContextSetLineWidth(context, [definition strokeSize]);
    }
    
    // take care of shadow if needed
    if ( [definition shadowEnabled] )
    {
        CGSize offset;
        offset.height = [definition shadowOffset].height;
        offset.width  = [definition shadowOffset].width;
        CGContextSetShadow(context, offset, [definition shadowBlur]);
    }
    
    float textOriginX  = 0.0;
    float textOriginY  = 0.0;
    
    if ( [definition shadowOffset].width < 0 )
    {
        textOriginX = shadowStrokePaddingX;
    }
    
    if ( [definition shadowOffset].height < 0 )
    {
        textOriginY = (-shadowStrokePaddingY);
    }
    
    CGRect drawArea;
    
    if(definition.vertAlignment == kCCVerticalTextAlignmentTop)
    {
        drawArea = CGRectMake(textOriginX, textOriginY, computedDimension.width, computedDimension.height);
    }
    else
    {
        CGSize drawSize = [string sizeWithFont:uifont constrainedToSize:computedDimension lineBreakMode:linebreaks[definition.lineBreakMode] ];
        
        if(definition.vertAlignment == kCCVerticalTextAlignmentBottom)
        {
            drawArea = CGRectMake(textOriginX, (computedDimension.height - drawSize.height) + textOriginY, computedDimension.width, drawSize.height);
        }
        else // kCCVerticalTextAlignmentCenter
        {
            drawArea = CGRectMake(textOriginX, ((computedDimension.height - drawSize.height) / 2) + textOriginY, computedDimension.width, drawSize.height);
        }
    }
    
	// must follow the same order of CCTextureAligment
	NSUInteger alignments[] = { NSTextAlignmentLeft, NSTextAlignmentCenter, NSTextAlignmentRight };
	
	[string drawInRect:drawArea withFont:uifont lineBreakMode:linebreaks[definition.lineBreakMode] alignment:alignments[definition.alignment]];
    
    
	UIGraphicsPopContext();
	
	if (effectsEnabled)
	{
		CGSize finalSize;
		finalSize.width  = textureWidth;
		finalSize.height = textureHeight;
		self = [self initWithData:data pixelFormat:kCCTexture2DPixelFormat_RGBA8888 pixelsWide:textureWidth pixelsHigh:textureHeight contentSize:finalSize];
	}
	else
	{
#if CC_USE_LA88_LABELS
		NSUInteger textureSize = textureWidth*textureHeight;
		unsigned short *la88_data = (unsigned short*)data;
		for(int i = textureSize-1; i>=0; i--) //Convert A8 to AI88
            la88_data[i] = (data[i] << 8) | 0xff;
#endif
        self = [self initWithData:data pixelFormat:LABEL_PIXEL_FORMAT pixelsWide:textureWidth pixelsHigh:textureHeight contentSize:computedDimension];
	}
	
	CGContextRelease(context);
	[self releaseData:data];
	
	return self;
    
}

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)hAlignment vAlignment:(CCVerticalTextAlignment) vAlignment lineBreakMode:(CCLineBreakMode)lineBreakMode font:(UIFont*)uifont
{
	NSAssert( uifont, @"Invalid font");
    
	// MUST have the same order declared on ccTypes
	NSInteger linebreaks[] = {NSLineBreakByWordWrapping, NSLineBreakByCharWrapping, NSLineBreakByClipping, NSLineBreakByTruncatingHead, NSLineBreakByTruncatingTail, NSLineBreakByTruncatingMiddle};
    
	NSUInteger textureWidth  = ccNextPOT(dimensions.width);
	NSUInteger textureHeight = ccNextPOT(dimensions.height);
	unsigned char*			data;
    
	CGContextRef			context;
	CGColorSpaceRef			colorSpace;
    
#if CC_USE_LA88_LABELS
	data = calloc(textureHeight, textureWidth * 2);
#else
	data = calloc(textureHeight, textureWidth);
#endif
    
	colorSpace = CGColorSpaceCreateDeviceGray();
	context = CGBitmapContextCreate(data, textureWidth, textureHeight, 8, textureWidth, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
    
	if( ! context ) {
		free(data);
		return nil;
	}
    
	CGContextSetGrayFillColor(context, 1.0f, 1.0f);
	CGContextTranslateCTM(context, 0.0f, textureHeight);
	CGContextScaleCTM(context, 1.0f, -1.0f); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
    
	UIGraphicsPushContext(context);
    
	CGRect drawArea;
	if(vAlignment == kCCVerticalTextAlignmentTop)
	{
		drawArea = CGRectMake(0, 0, dimensions.width, dimensions.height);
	}
	else
	{
		CGSize drawSize = [string sizeWithFont:uifont constrainedToSize:dimensions lineBreakMode:linebreaks[lineBreakMode] ];
		
		if(vAlignment == kCCVerticalTextAlignmentBottom)
		{
			drawArea = CGRectMake(0, dimensions.height - drawSize.height, dimensions.width, drawSize.height);
		}
		else // kCCVerticalTextAlignmentCenter
		{
			drawArea = CGRectMake(0, (dimensions.height - drawSize.height) / 2, dimensions.width, drawSize.height);
		}
	}
    
	// must follow the same order of CCTextureAligment
	NSUInteger alignments[] = { NSTextAlignmentLeft, NSTextAlignmentCenter, NSTextAlignmentRight };
	
	[string drawInRect:drawArea withFont:uifont lineBreakMode:linebreaks[lineBreakMode] alignment:alignments[hAlignment]];
    
	UIGraphicsPopContext();
    
#if CC_USE_LA88_LABELS
	NSUInteger textureSize = textureWidth*textureHeight;
	unsigned short *la88_data = (unsigned short*)data;
	for(int i = textureSize-1; i>=0; i--) //Convert A8 to AI88
		la88_data[i] = (data[i] << 8) | 0xff;
    
#endif
    
	self = [self initWithData:data pixelFormat:LABEL_PIXEL_FORMAT pixelsWide:textureWidth pixelsHigh:textureHeight contentSize:dimensions];
    
	CGContextRelease(context);
	[self releaseData:data];
    
	return self;
}


#elif defined(__CC_PLATFORM_MAC)

- (id) initWithAttributedString:(NSAttributedString*)attributedString dimensions:(CGSize)dimensions

//- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)hAlignment vAlignment:(CCVerticalTextAlignment)vAlignment attributedString:(NSAttributedString*)stringWithAttributes
{
	NSAssert(attributedString, @"Invalid attributedString");
    
    float xOffset = 0;
    float yOffset = 0;
    
	// Get actual rendered dimensions
    if (dimensions.width == 0 || dimensions.height == 0)
    {
        // Get dimensions for string
        dimensions = [attributedString boundingRectWithSize:NSSizeFromCGSize(dimensions) options:NSStringDrawingUsesLineFragmentOrigin].size;
        
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
    NSSize POTSize = NSMakeSize(ccNextPOT(dimensions.width), ccNextPOT(dimensions.height));
    
	// Mac crashes if the width or height is 0
	if( POTSize.width == 0 )
		POTSize.width = 2;
    
	if( POTSize.height == 0)
		POTSize.height = 2;
    
    yOffset = (POTSize.height - dimensions.height) - yOffset;
	
	//Alignment
    /*
     switch (hAlignment) {
     case kCCTextAlignmentLeft: break;
     case kCCTextAlignmentCenter: offset.width = (dimensions.width-boundingRect.size.width)/2.0f; break;
     case kCCTextAlignmentRight: offset.width = dimensions.width-boundingRect.size.width; break;
     default: break;
     }
     switch (vAlignment) {
     case kCCVerticalTextAlignmentTop: offset.height += dimensions.height - boundingRect.size.height; break;
     case kCCVerticalTextAlignmentCenter: offset.height += (dimensions.height - boundingRect.size.height) / 2; break;
     case kCCVerticalTextAlignmentBottom: break;
     default: break;
     }
     */
	
	CGRect drawArea = CGRectMake(xOffset, yOffset, dimensions.width, dimensions.height);
	
	//Disable antialias
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	
	NSImage *image = [[NSImage alloc] initWithSize:POTSize];
	[image lockFocus];
	[[NSAffineTransform transform] set];
	
	[attributedString drawWithRect:NSRectFromCGRect(drawArea) options:NSStringDrawingUsesLineFragmentOrigin];
	
	NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect (0.0f, 0.0f, POTSize.width, POTSize.height)];
	[image unlockFocus];
    
	unsigned char *data = (unsigned char*) [bitmap bitmapData];  //Use the same buffer to improve the performance.
    
	//NSUInteger textureSize = POTSize.width * POTSize.height;
    
    /*
#if CC_USE_LA88_LABELS
	unsigned short *dst = (unsigned short*)data;
	for(int i = 0; i<textureSize; i++)
		dst[i] = (data[i*4+3] << 8) | 0xff;		//Convert RGBA8888 to LA88
#else
	unsigned char *dst = (unsigned char*)data;
	for(int i = 0; i<textureSize; i++)
		dst[i] = data[i*4+3];					//Convert RGBA8888 to A8
#endif // ! CC_USE_LA88_LABELS
    
	data = [self keepData:dst length:textureSize];
    
	self = [self initWithData:data pixelFormat:LABEL_PIXEL_FORMAT pixelsWide:POTSize.width pixelsHigh:POTSize.height contentSize:dimensions];
     */
    self = [self initWithData:data pixelFormat:kCCTexture2DPixelFormat_RGBA8888 pixelsWide:POTSize.width pixelsHigh:POTSize.height contentSize:dimensions];
    
	return self;
}
/*
 - (id) initWithString:(NSString*)string fontDef:(CCFontDefinition *)definition
 {
 bool useAdvancedAttributes  = false;
 bool mustAllign             = true;
 
 NSFont* font = [NSFont fontWithName:definition.fontName size:definition.fontSize];
 if( ! font ) {
 CCLOGWARN(@"cocos2d: WARNING: Unable to load font %@", definition.fontName);
 return nil;
 }
 
 NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
 
 
 if ([definition shadowEnabled])
 {
 CGFloat shadowC[4]          = {0.5, 0.5, 0.5, 0.5};
 NSShadow *textShadow        = [[NSShadow alloc] init];
 
 NSColorSpace *colorSpace = [NSColorSpace sRGBColorSpace];
 NSColor *shadowColor     = [NSColor colorWithColorSpace:colorSpace components:shadowC count:4];
 
 textShadow.shadowColor      = shadowColor;
 textShadow.shadowBlurRadius = [definition shadowBlur];
 
 NSSize tempSize;
 tempSize.width  = [definition shadowOffset].width;
 tempSize.height = [definition shadowOffset].height;
 textShadow.shadowOffset     = tempSize;
 
 [dict setObject:textShadow forKey:NSShadowAttributeName];
 
 // need rgba
 useAdvancedAttributes = true;
 
 // release it
 }
 
 if ([definition strokeEnabled])
 {
 static const int COLOR_COMPONENTS = 4;
 CGFloat strokeC[COLOR_COMPONENTS];
 strokeC[0] = ((float)[definition strokeColor].r)/255.0f;
 strokeC[1] = ((float)[definition strokeColor].g)/255.0f;
 strokeC[2] = ((float)[definition strokeColor].b)/255.0f;
 strokeC[3] = 1.0f;
 
 NSColorSpace *colorSpace = [NSColorSpace sRGBColorSpace];
 NSColor *strokeColor     = [NSColor colorWithColorSpace:colorSpace components:strokeC count:COLOR_COMPONENTS];
 
 [dict setObject:strokeColor forKey:NSStrokeColorAttributeName];
 NSNumber *strokeSize = [NSNumber numberWithFloat:(-[definition strokeSize] * 3)];
 [dict setObject:strokeSize forKey:NSStrokeWidthAttributeName];
 
 // need rgba
 useAdvancedAttributes = true;
 }
 
 if (useAdvancedAttributes)
 {
 static const int COLOR_COMPONENTS = 4;
 CGFloat fillC[COLOR_COMPONENTS];
 fillC[0] = ((float)definition.fontFillColor.r)/255.0f;
 fillC[1] = ((float)definition.fontFillColor.g)/255.0f;
 fillC[2] = ((float)definition.fontFillColor.b)/255.0f;
 fillC[3] = 1.0f;
 
 NSColorSpace *colorSpace    = [NSColorSpace sRGBColorSpace];
 NSColor *fillColor          = [NSColor colorWithColorSpace:colorSpace components:fillC count:COLOR_COMPONENTS];
 [dict setObject:fillColor forKey:NSForegroundColorAttributeName];
 }
 
 
 
 
 NSAttributedString *stringWithAttributes = [[NSAttributedString alloc] initWithString:string attributes:dict];
 
 CGSize dim;
 if (definition.dimensions.width == 0 || definition.dimensions.height == 0)
 {
 dim         = NSSizeToCGSize( [stringWithAttributes size] );
 mustAllign  = false;
 }
 else
 {
 dim = definition.dimensions;
 mustAllign = true;
 }
 
 // compute the padding needed by shadow and stroke
 float shadowStrokePaddingX = 0.0f;
 float shadowStrokePaddingY = 0.0f;
 float translationX = 0.0;
 float translationY = 0.0;
 
 if ([definition strokeEnabled])
 {
 shadowStrokePaddingY = shadowStrokePaddingX = ceilf([definition strokeSize]);
 }
 
 if ( [definition shadowEnabled] )
 {
 shadowStrokePaddingX = max(shadowStrokePaddingX, (float)abs([definition shadowOffset].width));
 shadowStrokePaddingY = max(shadowStrokePaddingY, (float)abs([definition shadowOffset].height));
 
 if ([definition shadowOffset].width != 0 )
 {
 if (mustAllign)
 {
 switch ( definition.alignment )
 {
 case kCCTextAlignmentLeft:
 if ([definition shadowOffset].width < 0 )
 translationX = shadowStrokePaddingX;
 break;
 case kCCTextAlignmentCenter:
 break;
 case kCCTextAlignmentRight:
 if ([definition shadowOffset].width > 0 )
 translationX = -shadowStrokePaddingX;
 break;
 default:
 break;
 }
 }
 else
 {
 if ([definition shadowOffset].width < 0 )
 translationX = shadowStrokePaddingX;
 }
 }
 
 if ([definition shadowOffset].height != 0 )
 {
 if (mustAllign)
 {
 switch (definition.vertAlignment)
 {
 case kCCVerticalTextAlignmentTop:
 if ([definition shadowOffset].height > 0 )
 translationY = (-shadowStrokePaddingY);
 break;
 
 case kCCVerticalTextAlignmentCenter:
 break;
 
 case kCCVerticalTextAlignmentBottom:
 if ([definition shadowOffset].height < 0 )
 translationY = shadowStrokePaddingY;
 break;
 
 default:
 break;
 }
 
 }
 else
 {
 if ([definition shadowOffset].height < 0 )
 translationY = shadowStrokePaddingY;
 }
 }
 }
 
 dim.height +=shadowStrokePaddingY;
 dim.width  +=shadowStrokePaddingX;
 
 
 NSAssert(stringWithAttributes, @"Invalid stringWithAttributes");
 
 // get nearest power of two
 NSSize POTSize = NSMakeSize(ccNextPOT(dim.width), ccNextPOT(dim.height));
 
 
 // Get actual rendered dimensions
 NSRect boundingRect = [stringWithAttributes boundingRectWithSize:NSSizeFromCGSize(dim) options:NSStringDrawingUsesLineFragmentOrigin];
 
 // Mac crashes if the width or height is 0
 if( POTSize.width == 0 )
 POTSize.width = 2;
 
 if( POTSize.height == 0)
 POTSize.height = 2;
 
 CGSize offset = CGSizeMake(0, POTSize.height - dim.height);
 
 //Alignment
 if (mustAllign)
 {
 switch (definition.alignment) {
 case kCCTextAlignmentLeft: break;
 case kCCTextAlignmentCenter: offset.width = (dim.width-boundingRect.size.width)/2.0f; break;
 case kCCTextAlignmentRight: offset.width  = dim.width-boundingRect.size.width; break;
 default: break;
 }
 switch (definition.vertAlignment) {
 case kCCVerticalTextAlignmentTop: offset.height += dim.height  - boundingRect.size.height; break;
 case kCCVerticalTextAlignmentCenter: offset.height += (dim.height - boundingRect.size.height) / 2; break;
 case kCCVerticalTextAlignmentBottom: break;
 default: break;
 }
 }
 
 
 CGRect drawArea = CGRectMake((offset.width + translationX), (offset.height + translationY), boundingRect.size.width, boundingRect.size.height);
 
 //Disable antialias
 [[NSGraphicsContext currentContext] setShouldAntialias:NO];
 
 NSImage *image = [[NSImage alloc] initWithSize:POTSize];
 [image lockFocus];
 [[NSAffineTransform transform] set];
 
 [stringWithAttributes drawWithRect:NSRectFromCGRect(drawArea) options:NSStringDrawingUsesLineFragmentOrigin];
 
 NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect (0.0f, 0.0f, POTSize.width, POTSize.height)];
 [image unlockFocus];
 
 unsigned char *data = (unsigned char*) [bitmap bitmapData];  //Use the same buffer to improve the performance.
 
 NSUInteger textureSize = POTSize.width * POTSize.height;
 
 
 if (useAdvancedAttributes)
 {
 self = [self initWithData:data pixelFormat:kCCTexture2DPixelFormat_RGBA8888 pixelsWide:POTSize.width pixelsHigh:POTSize.height contentSize:dim];
 }
 else
 {
 #if CC_USE_LA88_LABELS
 unsigned short *dst = (unsigned short*)data;
 for(int i = 0; i<textureSize; i++)
 dst[i] = (data[i*4+3] << 8) | 0xff;		//Convert RGBA8888 to LA88
 #else
 unsigned char *dst = (unsigned char*)data;
 for(int i = 0; i<textureSize; i++)
 dst[i] = data[i*4+3];					//Convert RGBA8888 to A8
 #endif // ! CC_USE_LA88_LABELS
 data = [self keepData:dst length:textureSize];
 self = [self initWithData:data pixelFormat:LABEL_PIXEL_FORMAT pixelsWide:POTSize.width pixelsHigh:POTSize.height contentSize:dim];
 }
 
 
 return self;
 
 }
 */


#endif // __CC_PLATFORM_MAC
/*
 - (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size
 {
 CGSize dim;
 
 #ifdef __CC_PLATFORM_IOS
 UIFont *font = [UIFont fontWithName:name size:size];
 
 if( ! font ) {
 CCLOGWARN(@"cocos2d: WARNING: Unable to load font %@", name);
 return nil;
 }
 
 // Is it a multiline ? sizeWithFont: only works with single line.
 CGSize boundingSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
 dim = [string sizeWithFont:font
 constrainedToSize:boundingSize
 lineBreakMode:NSLineBreakByWordWrapping];
 
 if(dim.width == 0)
 dim.width = 1;
 if(dim.height == 0)
 dim.height = 1;
 
 return [self initWithString:string dimensions:dim hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentTop lineBreakMode:kCCLineBreakModeWordWrap font:font];
 
 #elif defined(__CC_PLATFORM_MAC)
 {
 NSFont* font = [NSFont fontWithName:name size:size];
 if( ! font ) {
 CCLOGWARN(@"cocos2d: WARNING: Unable to load font %@", name);
 return nil;
 }
 
 NSDictionary *dict = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
 
 NSAttributedString *stringWithAttributes = [[NSAttributedString alloc] initWithString:string attributes:dict];
 
 dim = NSSizeToCGSize( [stringWithAttributes size] );
 
 return [self initWithString:string dimensions:dim hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentTop attributedString:stringWithAttributes];
 }
 #endif // __CC_PLATFORM_MAC
 
 }
 */

/*
 - (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment vAlignment:(CCVerticalTextAlignment)vAlignment
 {
 return [self initWithString:string fontName:name fontSize:size dimensions:dimensions hAlignment:alignment vAlignment:vAlignment lineBreakMode:kCCLineBreakModeWordWrap];
 }
 */

/*
 - (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)hAlignment vAlignment:(CCVerticalTextAlignment)vAlignment lineBreakMode:(CCLineBreakMode)lineBreakMode
 {
 #ifdef __CC_PLATFORM_IOS
 UIFont *uifont = [UIFont fontWithName:name size:size];
 if( ! uifont ) {
 CCLOG(@"cocos2d: Texture2d: Invalid Font: %@. Verify the .ttf name", name);
 return nil;
 }
 
 return [self initWithString:string dimensions:dimensions hAlignment:hAlignment vAlignment:vAlignment lineBreakMode:lineBreakMode font:uifont];
 
 #elif defined(__CC_PLATFORM_MAC)
 
 // select font
 NSFont *font = [NSFont fontWithName:name size:size];
 if( ! font ) {
 CCLOG(@"cocos2d: Texture2d: Invalid Font: %@. Verify the .ttf name", name);
 return nil;
 }
 
 // create paragraph style
 NSInteger linebreaks[] = {NSLineBreakByWordWrapping, -1, -1, -1, -1, -1};
 NSUInteger alignments[] = { NSLeftTextAlignment, NSCenterTextAlignment, NSRightTextAlignment };
 
 NSMutableParagraphStyle *pstyle = [[NSMutableParagraphStyle alloc] init];
 [pstyle setAlignment: alignments[hAlignment] ];
 [pstyle setLineBreakMode: linebreaks[lineBreakMode] ];
 
 // put attributes into a NSDictionary
 NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, pstyle, NSParagraphStyleAttributeName, nil];
 
 
 // create string with attributes
 NSAttributedString *stringWithAttributes = [[NSAttributedString alloc] initWithString:string attributes:attributes];
 
 return [self initWithString:string dimensions:dimensions hAlignment:hAlignment vAlignment:vAlignment attributedString:stringWithAttributes];
 
 #endif // Mac
 }
 */
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
        
        [self updateTexture];
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
		[self updateTexture];
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
		[self updateTexture];
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
		[self updateTexture];
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
		[self updateTexture];

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
		[self updateTexture];
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
        [self updateTexture];
    }
}

- (void) setShadowOffset:(CGPoint)shadowOffset
{
    if (!CGPointEqualToPoint(_shadowOffset, shadowOffset))
    {
        _shadowOffset = shadowOffset;
        [self updateTexture];
    }
}

- (void) setShadowBlurRadius:(float)shadowBlurRadius
{
    if (_shadowBlurRadius != shadowBlurRadius)
    {
        _shadowBlurRadius = shadowBlurRadius;
        [self updateTexture];
    }
}

- (NSString*) description
{
	// XXX: _string, _fontName can't be displayed here, since they might be already released

	return [NSString stringWithFormat:@"<%@ = %p | FontSize = %.1f>", [self class], self, _fontSize];
}

// Helper
- (BOOL) updateTexture
{
    if (!_attributedString) return NO;
    
    // Set default values for font attributes if they are not set in the attributed string
    NSDictionary* presetAttributes = [_attributedString attributesAtIndex:0 effectiveRange:NULL];
    
    NSMutableAttributedString* formattedAttributedString = [_attributedString mutableCopy];
    NSRange fullRange = NSMakeRange(0, formattedAttributedString.length);
    
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

/** init the label with string and text definition*/
/*
- (id) initWithString:(NSString *) string fontDefinition:(CCFontDefinition *)definition
{
    if( (self=[super init]) ) {
        
		// shader program
		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:SHADER_PROGRAM];
        
		_dimensions     = definition.dimensions;
		_hAlignment     = definition.alignment;
		_vAlignment     = definition.vertAlignment;
		_fontName       = [definition.fontName copy];
		_fontSize       = definition.fontSize;
		_lineBreakMode  = definition.lineBreakMode;
        
        // take care of shadow
        if ([definition shadowEnabled])
        {
            [self enableShadowWithOffset:[definition shadowOffset] opacity:0.5 blur:[definition shadowBlur] updateImage: false];
        }
        else
        {
            [self disableShadowAndUpdateImage:false];
        }
        
        // take care of stroke
        if ([definition strokeEnabled])
        {
            [self enableStrokeWithColor:[definition strokeColor] size:[definition strokeSize] updateImage:false];
        }
        else
        {
            [self disableStrokeAndUpdateImage:false];
        }
        
        
        [self setFontFillColor: definition.fontFillColor updateImage:false];
        
        
        // actually update the string
        [self setString:string];
	}
    
    return self;
}
 */


/** enable or disable shadow for the label */
/*
- (void) enableShadowWithOffset:(CGSize)shadowOffset opacity:(float)shadowOpacity blur:(float)shadowBlur updateImage:(Boolean) mustUpdate
{
    bool valueChanged = false;
    
    if (false == _shadowEnabled)
    {
        _shadowEnabled = true;
        valueChanged    = true;
    }
    
    if ( (_shadowOffset.width != shadowOffset.width) || (_shadowOffset.height!=shadowOffset.height) )
    {
        _shadowOffset.width  = shadowOffset.width;
        _shadowOffset.height = shadowOffset.height;
        
        valueChanged = true;
    }
    
    if (_shadowOpacity != shadowOpacity )
    {
        _shadowOpacity = shadowOpacity;
        valueChanged = true;
    }
    
    if (_shadowBlur    != shadowBlur)
    {
        _shadowBlur = shadowBlur;
        valueChanged = true;
    }
    
    if ( valueChanged && mustUpdate )
    {
        [self updateTexture];
    }
}
*/
 
/** disable shadow rendering */
/*
- (void) disableShadowAndUpdateImage:(Boolean)mustUpdate
{
    if (_shadowEnabled)
    {
        _shadowEnabled = false;
        
        if ( mustUpdate )
        {
            [self updateTexture];
        }
    }
}
 */

/** enable or disable stroke */
/*
- (void) enableStrokeWithColor:(ccColor3B)strokeColor size:(float)strokeSize updateImage:(Boolean) mustUpdate
{
    bool valueChanged = false;
    
    if(_strokeEnabled == false)
    {
        _strokeEnabled = true;
        valueChanged = true;
    }
    
    if ( (_strokeColor.r != strokeColor.r) || (_strokeColor.g != strokeColor.g) || (_strokeColor.b != strokeColor.b) )
    {
        _strokeColor = strokeColor;
        valueChanged = true;
    }
    
    if (_strokeSize!=strokeSize)
    {
        _strokeSize = strokeSize;
        valueChanged = true;
    }
    
    if ( valueChanged && mustUpdate )
    {
        [self updateTexture];
    }

}
 */

/** disable stroke */
/*
- (void) disableStrokeAndUpdateImage:(Boolean) mustUpdate
{
    
    if ( _strokeEnabled )
    {
        _strokeEnabled = false;
        
        if ( mustUpdate )
        {
            [self updateTexture];
        }
    }
}
 */

/** set fill color */
/*
- (void) setFontFillColor:(ccColor3B) tintColor updateImage:(Boolean) mustUpdate
{
    if (_textFillColor.r != tintColor.r || _textFillColor.g != tintColor.g || _textFillColor.b != tintColor.b)
    {
        _textFillColor = tintColor;
        
        if (mustUpdate)
        {
            [self updateTexture];
        }
    }
}
 */

/*
- (CCFontDefinition*) prepareFontDefinitionAndAdjustForResolution:(Boolean) resAdjust
{
    int tempFontSize = 0;
    
    if (resAdjust)
       tempFontSize       =  _fontSize * CC_CONTENT_SCALE_FACTOR();
    else
       tempFontSize       =  _fontSize;
    
    CCFontDefinition *retDefinition = [[CCFontDefinition alloc]initWithFontName:_fontName fontSize:tempFontSize];
    
    if (retDefinition)
    {
        retDefinition.lineBreakMode  = _lineBreakMode;
        retDefinition.alignment      = _hAlignment;
        retDefinition.vertAlignment  = _vAlignment;
        retDefinition.lineBreakMode  = _lineBreakMode;
        retDefinition.fontFillColor  = _textFillColor;
    
    
        // stroke
        if ( _strokeEnabled )
        {
            [retDefinition enableStroke: true];
            [retDefinition setStrokeColor: _strokeColor];
            
            if (resAdjust)
                [retDefinition setStrokeSize: _strokeSize * CC_CONTENT_SCALE_FACTOR()];
            else
                [retDefinition setStrokeSize: _strokeSize];
        }
        else
        {
            [retDefinition enableStroke: false];
        }
        
        
        // shadow
        if ( _shadowEnabled )
        {
            [retDefinition enableShadow:true];
            [retDefinition setShadowBlur:_shadowBlur];
            
            if (resAdjust)
            {
                [retDefinition setShadowOffset: CC_SIZE_POINTS_TO_PIXELS(_shadowOffset)];
            }
            else
            {
                [retDefinition setShadowOffset: _shadowOffset];
            }
        }
        else
        {
            [retDefinition enableShadow:false];
        }
    }
    
    return retDefinition;
}
 */

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
