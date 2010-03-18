/*

===== IMPORTANT =====

This is sample code demonstrating API, technology or techniques in development.
Although this sample code has been reviewed for technical accuracy, it is not
final. Apple is supplying this information to help you plan for the adoption of
the technologies and programming interfaces described herein. This information
is subject to change, and software implemented based on this sample code should
be tested with final operating system software and final documentation. Newer
versions of this sample code may be provided with future seeds of the API or
technology. For information about updates to this and other developer
documentation, view the New & Updated sidebars in subsequent documentation
seeds.

=====================

File: Texture2D.m
Abstract: Creates OpenGL 2D textures from images or text.

Version: 1.6

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

/*
 * Support for RGBA_4_4_4_4 and RGBA_5_5_5_1 was copied from:
 * https://devforums.apple.com/message/37855#37855 by a1studmuffin
 */

#import <OpenGLES/ES1/glext.h>

#import "ccConfig.h"
#import "ccMacros.h"
#import "CCTexture2D.h"
#import "CCPVRTexture.h"
#import "CCConfiguration.h"


#if CC_FONT_LABEL_SUPPORT
// FontLabel support
#import "FontManager.h"
#import "FontLabelStringDrawing.h"
#endif// CC_FONT_LABEL_SUPPORT


static unsigned int nextPOT(unsigned int x)
{
    x = x - 1;
    x = x | (x >> 1);
    x = x | (x >> 2);
    x = x | (x >> 4);
    x = x | (x >> 8);
    x = x | (x >>16);
    return x + 1;
}

//CLASS IMPLEMENTATIONS:


// If the image has alpha, you can create RGBA8 (32-bit) or RGBA4 (16-bit) or RGB5A1 (16-bit)
// Default is: RGBA8888 (32-bit textures)
static CCTexture2DPixelFormat defaultAlphaPixelFormat = kCCTexture2DPixelFormat_Default;

@interface CCTexture2D (Private)
-(id) initPremultipliedATextureWithImage:(CGImageRef)image pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height;
-(id) initNonPremultipliedTextureWithImage:(CGImageRef)image pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height;
@end

@implementation CCTexture2D

@synthesize contentSize=_size, pixelFormat=_format, pixelsWide=_width, pixelsHigh=_height, name=_name, maxS=_maxS, maxT=_maxT;
@synthesize hasPremultipliedAlpha=_hasPremultipliedAlpha;
- (id) initWithData:(const void*)data pixelFormat:(CCTexture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSize:(CGSize)size
{
	if((self = [super init])) {
		glGenTextures(1, &_name);
		glBindTexture(GL_TEXTURE_2D, _name);

		[self setAntiAliasTexParameters];
		
		// Specify OpenGL texture image
		
		switch(pixelFormat)
		{
			case kCCTexture2DPixelFormat_RGBA8888:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
				break;
			case kCCTexture2DPixelFormat_RGBA4444:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, data);
				break;
			case kCCTexture2DPixelFormat_RGB5A1:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data);
				break;
			case kCCTexture2DPixelFormat_RGB565:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
				break;
			case kCCTexture2DPixelFormat_A8:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
				break;
			default:
				[NSException raise:NSInternalInconsistencyException format:@""];
				
		}

		_size = size;
		_width = width;
		_height = height;
		_format = pixelFormat;
		_maxS = size.width / (float)width;
		_maxT = size.height / (float)height;

		_hasPremultipliedAlpha = NO;
	}					
	return self;
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	if(_name)
		glDeleteTextures(1, &_name);
	
	[super dealloc];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Name = %i | Dimensions = %ix%i | Coordinates = (%.2f, %.2f)>", [self class], self, _name, _width, _height, _maxS, _maxT];
}

@end

@implementation CCTexture2D (Image)
	
- (id) initWithImage:(UIImage *)uiImage
{
	NSUInteger				POTWide, POTHigh;
	CGImageRef				CGImage;	
	
	CGImage = uiImage.CGImage;
	
	if(CGImage == NULL) {
		CCLOG(@"cocos2d: CCTexture2D. Can't create Texture. UIImage is nil");
		return nil;
	}
	
//	CGImageAlphaInfo alphainfo = CGImageGetAlphaInfo(CGImage);
//	BOOL hasAlpha = ((alphainfo == kCGImageAlphaPremultipliedLast) || (alphainfo == kCGImageAlphaPremultipliedFirst) || (alphainfo == kCGImageAlphaLast) || (alphainfo == kCGImageAlphaFirst) ? YES : NO);
	
//	size_t bpc = CGImageGetBitsPerComponent(CGImage);
//	size_t bpp = CGImageGetBitsPerPixel(CGImage);
//	CGColorSpaceModel colormodel = CGColorSpaceGetModel(CGImageGetColorSpace(CGImage));

	POTWide = nextPOT(CGImageGetWidth(CGImage));
	POTHigh = nextPOT(CGImageGetHeight(CGImage));
		
	unsigned maxTextureSize = [[CCConfiguration sharedConfiguration] maxTextureSize];
	if( POTHigh > maxTextureSize || POTWide > maxTextureSize ) {
		CCLOG(@"cocos2d: WARNING: Image (%d x %d) is bigger than the supported %d x %d", POTWide, POTHigh, maxTextureSize, maxTextureSize);
		return nil;
	}
	
//	if( hasAlpha && bpc==8 && colormodel==kCGColorSpaceModelRGB && bpp==32 )
//		self = [self initNonPremultipliedTextureWithImage:CGImage pixelsWide:POTWide pixelsHigh:POTHigh];
//	else
//		// fallback
//		self = [self initPremultipliedATextureWithImage:CGImage pixelsWide:POTWide pixelsHigh:POTHigh];


	// always load premultiplied images
	self = [self initPremultipliedATextureWithImage:CGImage pixelsWide:POTWide pixelsHigh:POTHigh];

	return self;
}

-(id) initPremultipliedATextureWithImage:(CGImageRef)image pixelsWide:(NSUInteger)POTWide pixelsHigh:(NSUInteger)POTHigh
{
	NSUInteger				i;
	CGContextRef			context = nil;
	void*					data = nil;;
	CGColorSpaceRef			colorSpace;
	void*					tempData;
	unsigned int*			inPixel32;
	unsigned short*			outPixel16;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGAffineTransform		transform;
	CGSize					imageSize;
	CCTexture2DPixelFormat	pixelFormat;
		
	info = CGImageGetAlphaInfo(image);
	hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
	
	size_t bpp = CGImageGetBitsPerComponent(image);
	colorSpace = CGImageGetColorSpace(image);
//	int nrComponents = CGColorSpaceGetNumberOfComponents(colorSpace);
	
	if(colorSpace) {
		if(hasAlpha || bpp >= 8)
			pixelFormat = defaultAlphaPixelFormat;
		else {
			CCLOG(@"cocos2d: CCTexture2D: Using RGB565 texture since image has no alpha");
			pixelFormat = kCCTexture2DPixelFormat_RGB565;
		}
	} else  {
		// NOTE: No colorspace means a mask image
		CCLOG(@"cocos2d: CCTexture2D: Using A8 texture since image is a mask");
		pixelFormat = kCCTexture2DPixelFormat_A8;
	}
	
	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	transform = CGAffineTransformIdentity;
	

	// Create the bitmap graphics context
	
	switch(pixelFormat) {          
		case kCCTexture2DPixelFormat_RGBA8888:
		case kCCTexture2DPixelFormat_RGBA4444:
		case kCCTexture2DPixelFormat_RGB5A1:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(POTHigh * POTWide * 4);
			info = hasAlpha ? kCGImageAlphaPremultipliedLast : kCGImageAlphaNoneSkipLast; 
			context = CGBitmapContextCreate(data, POTWide, POTHigh, 8, 4 * POTWide, colorSpace, info | kCGBitmapByteOrder32Big);				
			CGColorSpaceRelease(colorSpace);
			break;
		case kCCTexture2DPixelFormat_RGB565:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(POTHigh * POTWide * 4);
			info = kCGImageAlphaNoneSkipLast;
			context = CGBitmapContextCreate(data, POTWide, POTHigh, 8, 4 * POTWide, colorSpace, info | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
		case kCCTexture2DPixelFormat_A8:
			data = malloc(POTHigh * POTWide);
			info = kCGImageAlphaOnly; 
			context = CGBitmapContextCreate(data, POTWide, POTHigh, 8, POTWide, NULL, info);
			break;                    
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
	}
	
	
	CGContextClearRect(context, CGRectMake(0, 0, POTWide, POTHigh));
	CGContextTranslateCTM(context, 0, POTHigh - imageSize.height);
	
	if(!CGAffineTransformIsIdentity(transform))
		CGContextConcatCTM(context, transform);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
	
	// Repack the pixel data into the right format
	
	if(pixelFormat == kCCTexture2DPixelFormat_RGB565) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
		tempData = malloc(POTHigh * POTWide * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < POTWide * POTHigh; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		free(data);
		data = tempData;
		
	}
	else if (pixelFormat == kCCTexture2DPixelFormat_RGBA4444) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRGGGGBBBBAAAA"
		tempData = malloc(POTHigh * POTWide * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < POTWide * POTHigh; ++i, ++inPixel32)
			*outPixel16++ = 
			((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | // R
			((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) | // G
			((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | // B
			((((*inPixel32 >> 24) & 0xFF) >> 4) << 0); // A
		
		
		free(data);
		data = tempData;
		
	}
	else if (pixelFormat == kCCTexture2DPixelFormat_RGB5A1) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGBBBBBA"
		tempData = malloc(POTHigh * POTWide * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < POTWide * POTHigh; ++i, ++inPixel32)
			*outPixel16++ = 
			((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | // R
			((((*inPixel32 >> 8) & 0xFF) >> 3) << 6) | // G
			((((*inPixel32 >> 16) & 0xFF) >> 3) << 1) | // B
			((((*inPixel32 >> 24) & 0xFF) >> 7) << 0); // A
		
		
		free(data);
		data = tempData;
	}
	self = [self initWithData:data pixelFormat:pixelFormat pixelsWide:POTWide pixelsHigh:POTHigh contentSize:imageSize];
	
	// should be after calling super init
	_hasPremultipliedAlpha = (info == kCGImageAlphaPremultipliedLast || info == kCGImageAlphaPremultipliedFirst);
	
	CGContextRelease(context);
	free(data);
	
	return self;
}

-(id) initNonPremultipliedTextureWithImage:(CGImageRef)CGImage pixelsWide:(NSUInteger)POTWide pixelsHigh:(NSUInteger)POTHigh
{
    GLuint components, y;
    GLuint imgWide, imgHigh;		// Real image size
    GLuint rowBytes;				// Image size padded by CGImage
    CGBitmapInfo info;				// CGImage component layout info
    CGColorSpaceModel colormodel;	// CGImage colormodel (RGB, CMYK, paletted, etc)
    GLenum	format;
	unsigned int		*inPixel32;
	unsigned short		*outPixel16;
    GLubyte *pixels, *temp = NULL;
    
    // Parse CGImage info
    info       = CGImageGetBitmapInfo(CGImage);        // CGImage may return pixels in RGBA, BGRA, or ARGB order
    colormodel = CGColorSpaceGetModel(CGImageGetColorSpace(CGImage));
    size_t bpp = CGImageGetBitsPerPixel(CGImage);
	
	components = bpp>>3;
    rowBytes   = CGImageGetBytesPerRow(CGImage);    // CGImage may pad rows
	imgWide = CGImageGetWidth(CGImage);
	imgHigh = CGImageGetHeight(CGImage);
	
	
	// Choose OpenGL format
	switch(info & kCGBitmapAlphaInfoMask)
	{
		case kCGImageAlphaPremultipliedFirst:
		case kCGImageAlphaFirst:
		case kCGImageAlphaNoneSkipFirst:
			format = GL_BGRA;
			break;
		default:
			format = GL_RGBA;
	}
	
	// Get a pointer to the uncompressed image data.
    //
    // This allows access to the original (possibly unpremultiplied) data, but any manipulation
    // (such as scaling) has to be done manually. Contrast this with drawing the image
    // into a CGBitmapContext, which allows scaling, but always forces premultiplication.
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(CGImage));
    pixels = (GLubyte *)CFDataGetBytePtr(data);
	
    // If the CGImage component layout isn't compatible with OpenGL, fix it.
    // On the device, CGImage will generally return BGRA or RGBA.
    // On the simulator, CGImage may return ARGB, depending on the file format.
    if (format == GL_BGRA)
    {
        uint32_t *p = (uint32_t *)pixels;
        int i, num = imgWide * imgHigh;
        
        if ((info & kCGBitmapByteOrderMask) != kCGBitmapByteOrder32Host)
        {
            // Convert from ARGB to BGRA
            for (i = 0; i < num; i++)
                p[i] = (p[i] << 24) | ((p[i] & 0xFF00) << 8) | ((p[i] >> 8) & 0xFF00) | (p[i] >> 24);
        }
        
        // All current iPhoneOS devices support BGRA via an extension, but it should check it
//        if (!renderer->extension[IMG_texture_format_BGRA8888])
        {
            format = GL_RGBA;
			
            // Convert from BGRA to RGBA
            for (i = 0; i < num; i++) {
#if __LITTLE_ENDIAN__
                p[i] = ((p[i] >> 16) & 0xFF) | (p[i] & 0xFF00FF00) | ((p[i] & 0xFF) << 16);
#else
				p[i] = ((p[i] & 0xFF00) << 16) | (p[i] & 0xFF00FF) | ((p[i] >> 16) & 0xFF00);
#endif
			}
        }
    }
		
	
	// Determine if we need to pad this image to a power of two.
    // There are multiple ways to deal with NPOT images on renderers that only support POT:
    // 1) scale down the image to POT size. Loses quality.
    // 2) pad up the image to POT size. Wastes memory.
    // 3) slice the image into multiple POT textures. Requires more rendering logic.
    //
    // We are only dealing with a single image here, and pick 2) for simplicity.
    //
    // If you prefer 1), you can use CoreGraphics to scale the image into a CGBitmapContext.
	
	// XXX: Should check GL extentions. Perhaps device supports NPOT textures
    if (imgWide != POTWide || imgHigh != POTHigh)
    {
        GLuint dstBytes = POTWide * components;
        GLubyte *temp = (GLubyte *)malloc(dstBytes * POTHigh);
        
        for (y = 0; y < imgHigh; y++)
            memcpy(&temp[y*dstBytes], &pixels[y*rowBytes], rowBytes);
        
        pixels = temp;
        rowBytes = dstBytes;
    }

	// Repack the pixel data into the right format
	
	defaultAlphaPixelFormat = kCCTexture2DPixelFormat_RGBA8888;

	if(defaultAlphaPixelFormat == kCCTexture2DPixelFormat_RGB565) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
		void *tempData = malloc(POTHigh * POTWide * 2);
		inPixel32 = (unsigned int*)pixels;
		outPixel16 = (unsigned short*)tempData;
		for(UInt32 i = 0; i < POTWide * POTHigh; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) |	// R
			((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) |					// G
			((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);					// B
		
		if( temp )
			free(temp);
		pixels = temp = tempData;		
	}
	else if (defaultAlphaPixelFormat == kCCTexture2DPixelFormat_RGBA4444) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRGGGGBBBBAAAA"
		void *tempData = malloc(POTHigh * POTWide * 2);
		inPixel32 = (unsigned int*)pixels;
		outPixel16 = (unsigned short*)tempData;
		for(UInt32 i = 0; i < POTWide * POTHigh; ++i, ++inPixel32)
			*outPixel16++ = 
			((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) |		// R
			((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) |		// G
			((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) |		// B
			((((*inPixel32 >> 24) & 0xFF) >> 4) << 0);		// A

		if( temp )
			free(temp);
		pixels = temp = tempData;
		
	}
	else if (defaultAlphaPixelFormat == kCCTexture2DPixelFormat_RGB5A1) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGBBBBBA"
		void *tempData = malloc(POTHigh * POTWide * 2);
		inPixel32 = (unsigned int*)pixels;
		outPixel16 = (unsigned short*)tempData;
		for(UInt32 i = 0; i < POTWide * POTHigh; ++i, ++inPixel32)
			*outPixel16++ = 
			((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) |		// R
			((((*inPixel32 >> 8) & 0xFF) >> 3) << 6) |		// G
			((((*inPixel32 >> 16) & 0xFF) >> 3) << 1) |		// B
			((((*inPixel32 >> 24) & 0xFF) >> 7) << 0);		// A
		
		if( temp )
			free(temp);
		pixels = temp = tempData;		
	}	
	
	self = [self initWithData:pixels pixelFormat:defaultAlphaPixelFormat pixelsWide:POTWide pixelsHigh:POTHigh contentSize:CGSizeMake(imgWide,imgHigh)];
	
    if (temp)
		free(temp);
    CFRelease(data);
	
	// should be after calling super init
	CGImageAlphaInfo alphainfo = CGImageGetAlphaInfo(CGImage);

	// It seems that images are already premultiplied on the device!!! WTF!!! WHY ?!?
	_hasPremultipliedAlpha = (alphainfo == kCGImageAlphaPremultipliedLast || alphainfo == kCGImageAlphaPremultipliedFirst);
	
	return self;
}
@end

@implementation CCTexture2D (Text)

- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size
{
    CGSize dim;
	
#if CC_FONT_LABEL_SUPPORT
    ZFont *zFont = [[FontManager sharedManager] zFontWithName:name pointSize:size];
    if (zFont != nil)
        dim = [string sizeWithZFont:zFont];
    else
#endif
        dim = [string sizeWithFont:[UIFont fontWithName:name size:size]];
    
	return [self initWithString:string dimensions:dim alignment:UITextAlignmentCenter fontName:name fontSize:size];
}

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	NSUInteger				width,
							height,
							i;
	CGContextRef			context;
	void*					data;
	CGColorSpaceRef			colorSpace;
	id						uiFont;
    
	width = dimensions.width;
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while(i < width)
			i *= 2;
		width = i;
	}
	height = dimensions.height;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while(i < height)
			i *= 2;
		height = i;
	}
	
	colorSpace = CGColorSpaceCreateDeviceGray();
	data = calloc(height, width);
	context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	
	
	CGContextSetGrayFillColor(context, 1.0f, 1.0f);
	CGContextTranslateCTM(context, 0.0f, height);
	CGContextScaleCTM(context, 1.0f, -1.0f); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
	UIGraphicsPushContext(context);
    

#if CC_FONT_LABEL_SUPPORT
	uiFont = [[FontManager sharedManager] zFontWithName:name pointSize:size];
    if (uiFont != nil)
        [string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withZFont:uiFont lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
    else
#endif // CC_FONT_LABEL_SUPPORT
	{
        uiFont = [UIFont fontWithName:name size:size];
        [string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withFont:uiFont lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
    }
	if( ! uiFont )
		CCLOG(@"cocos2d: Texture2D: Font '%@' not found", name);
	UIGraphicsPopContext();
	
	self = [self initWithData:data pixelFormat:kCCTexture2DPixelFormat_A8 pixelsWide:width pixelsHigh:height contentSize:dimensions];
	
	CGContextRelease(context);
	free(data);
	
	return self;
}

@end

@implementation CCTexture2D (Drawing)

- (void) drawAtPoint:(CGPoint)point 
{
	GLfloat		coordinates[] = { 0.0f,	_maxT,
								_maxS,	_maxT,
								0.0f,	0.0f,
								_maxS,	0.0f };
	GLfloat		width = (GLfloat)_width * _maxS,
				height = (GLfloat)_height * _maxT;

#if 0
	GLfloat		vertices[] = {	-width / 2 + point.x,	-height / 2 + point.y,	0.0f,
								width / 2 + point.x,	-height / 2 + point.y,	0.0f,
								-width / 2 + point.x,	height / 2 + point.y,	0.0f,
								width / 2 + point.x,	height / 2 + point.y,	0.0f };
	
#else // anchor is done by cocos2d automagically
	GLfloat		vertices[] = {	point.x,			point.y,	0.0f,
								width + point.x,	point.y,	0.0f,
								point.x,			height  + point.y,	0.0f,
								width + point.x,	height  + point.y,	0.0f };
#endif
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (void) drawInRect:(CGRect)rect
{
	GLfloat	 coordinates[] = {  0.0f,	_maxT,
								_maxS,	_maxT,
								0.0f,	0.0f,
								_maxS,	0.0f  };
	GLfloat	vertices[] = {	rect.origin.x,							rect.origin.y,							/*0.0f,*/
							rect.origin.x + rect.size.width,		rect.origin.y,							/*0.0f,*/
							rect.origin.x,							rect.origin.y + rect.size.height,		/*0.0f,*/
							rect.origin.x + rect.size.width,		rect.origin.y + rect.size.height,		/*0.0f*/ };
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end

@implementation CCTexture2D (PVRTC)
-(id) initWithPVRTCData: (const void*)data level:(int)level bpp:(int)bpp hasAlpha:(BOOL)hasAlpha length:(int)length
{
//	GLint					saveName;

	if( ! [[CCConfiguration sharedConfiguration] supportsPVRTC] ) {
		CCLOG(@"cocos2d: WARNING: PVRTC images is not supported");
		return nil;
	}

	if((self = [super init])) {
		glGenTextures(1, &_name);
//		glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
		glBindTexture(GL_TEXTURE_2D, _name);

		[self setAntiAliasTexParameters];
		
		GLenum format;
		GLsizei size = length * length * bpp / 8;
		if(hasAlpha) {
			format = (bpp == 4) ? GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG : GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
		} else {
			format = (bpp == 4) ? GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG : GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
		}
		if(size < 32) {
			size = 32;
		}
		glCompressedTexImage2D(GL_TEXTURE_2D, level, format, length, length, 0, size, data);
		
//		glBindTexture(GL_TEXTURE_2D, saveName);
		
		_size = CGSizeMake(length, length);
		_width = length;
		_height = length;
		_maxS = 1.0f;
		_maxT = 1.0f;
	}					
	return self;
}

-(id) initWithPVRTCFile: (NSString*) file
{
	if( ! [[CCConfiguration sharedConfiguration] supportsPVRTC] ) {
		CCLOG(@"cocos2d: WARNING: PVRTC images is not supported");
		return nil;
	}	

	if( (self = [super init]) ) {
		CCPVRTexture *pvr = [[CCPVRTexture alloc] initWithContentsOfFile:file];
		pvr.retainName = YES;	// don't dealloc texture on release
		
		_name = pvr.name;	// texture id
		_maxS = 1.0f;
		_maxT = 1.0f;
		_width = pvr.width;		// width
		_height = pvr.height;	// height
		_size = CGSizeMake(_width, _height);

		[pvr release];

		[self setAntiAliasTexParameters];
	}
	return self;
}
@end

//
// Use to apply MIN/MAG filter
//
@implementation CCTexture2D (GLFilter)

-(void) generateMipmap
{
	glBindTexture( GL_TEXTURE_2D, self.name );
	glGenerateMipmapOES(GL_TEXTURE_2D);
}

-(void) setTexParameters: (ccTexParams*) texParams
{
	glBindTexture( GL_TEXTURE_2D, self.name );
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, texParams->minFilter );
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, texParams->magFilter );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, texParams->wrapS );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, texParams->wrapT );
}

-(void) setAliasTexParameters
{
	ccTexParams texParams = { GL_NEAREST, GL_NEAREST, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
	[self setTexParameters: &texParams];
}

-(void) setAntiAliasTexParameters
{
	ccTexParams texParams = { GL_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
	[self setTexParameters: &texParams];
}
@end

//
// Texture options for images that contains alpha
//
@implementation CCTexture2D (PixelFormat)
+(void) setDefaultAlphaPixelFormat:(CCTexture2DPixelFormat)format
{
	defaultAlphaPixelFormat = format;
}

+(CCTexture2DPixelFormat) defaultAlphaPixelFormat
{
	return defaultAlphaPixelFormat;
}
@end
