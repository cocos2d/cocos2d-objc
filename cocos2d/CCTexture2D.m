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
 documentation, view the New & Updated sidebars in subsequent documentationd
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

/*
 * Added many additions for cocos2d
 */

#import <Availability.h>

#import "Platforms/CCGL.h"
#import "Platforms/CCNS.h"


#import "CCTexture2D.h"
#import "ccConfig.h"
#import "ccMacros.h"
#import "CCConfiguration.h"
#import "CCTexturePVR.h"
#import "Support/ccUtils.h"
#import "Support/CCFileUtils.h"


#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && CC_FONT_LABEL_SUPPORT
// FontLabel support
#import "FontManager.h"
#import "FontLabelStringDrawing.h"
#endif// CC_FONT_LABEL_SUPPORT


// For Labels use 16-bit textures on iPhone 3GS / iPads since A8 textures are very slow
#if (defined(__ARM_NEON__) || TARGET_IPHONE_SIMULATOR) && CC_USE_LA88_LABELS_ON_NEON_ARCH
#define USE_TEXT_WITH_A8_TEXTURES 0

#else
#define USE_TEXT_WITH_A8_TEXTURES 1
#endif

//CLASS IMPLEMENTATIONS:


// If the image has alpha, you can create RGBA8 (32-bit) or RGBA4 (16-bit) or RGB5A1 (16-bit)
// Default is: RGBA8888 (32-bit textures)
static CCTexture2DPixelFormat defaultAlphaPixelFormat_ = kCCTexture2DPixelFormat_Default;

#pragma mark -
#pragma mark CCTexture2D - Main

@implementation CCTexture2D

@synthesize contentSizeInPixels = size_, pixelFormat = format_, pixelsWide = width_, pixelsHigh = height_, name = name_, maxS = maxS_, maxT = maxT_;
@synthesize hasPremultipliedAlpha = hasPremultipliedAlpha_;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@synthesize resolutionType = resolutionType_;
#endif


- (id) initWithData:(const void*)data pixelFormat:(CCTexture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSize:(CGSize)size
{
	if((self = [super init])) {
		glPixelStorei(GL_UNPACK_ALIGNMENT,1);
		glGenTextures(1, &name_);
		glBindTexture(GL_TEXTURE_2D, name_);
        
		[self setAntiAliasTexParameters];
		
		// Specify OpenGL texture image
		
		switch(pixelFormat)
		{
			case kCCTexture2DPixelFormat_RGBA8888:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei) width, (GLsizei) height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
				break;
			case kCCTexture2DPixelFormat_RGBA4444:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei) width, (GLsizei) height, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, data);
				break;
			case kCCTexture2DPixelFormat_RGB5A1:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei) width, (GLsizei) height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data);
				break;
			case kCCTexture2DPixelFormat_RGB565:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, (GLsizei) width, (GLsizei) height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
				break;
			case kCCTexture2DPixelFormat_AI88:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, (GLsizei) width, (GLsizei) height, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, data);
				break;
			case kCCTexture2DPixelFormat_A8:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, (GLsizei) width, (GLsizei) height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
				break;
			default:
				[NSException raise:NSInternalInconsistencyException format:@""];
				
		}
        
		size_ = size;
		width_ = width;
		height_ = height;
		format_ = pixelFormat;
		maxS_ = size.width / (float)width;
		maxT_ = size.height / (float)height;
        
		hasPremultipliedAlpha_ = NO;
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		resolutionType_ = kCCResolutionUnknown;
#endif
	}
	return self;
}

- (void) releaseData:(void*)data
{
	//Free data
	free(data);
}

- (void*) keepData:(void*)data length:(NSUInteger)length
{
	//The texture data mustn't be saved becuase it isn't a mutable texture.
	return data;
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	if(name_)
		glDeleteTextures(1, &name_);
	
	[super dealloc];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Name = %i | Dimensions = %ix%i | Coordinates = (%.2f, %.2f)>", [self class], self, name_, width_, height_, maxS_, maxT_];
}

-(CGSize) contentSize
{
	CGSize ret;
	ret.width = size_.width / CC_CONTENT_SCALE_FACTOR();
	ret.height = size_.height / CC_CONTENT_SCALE_FACTOR();
	
	return ret;
}

@end

#pragma mark -
#pragma mark CCTexture2D - Image

@implementation CCTexture2D (Image)
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
// XXX deprecated. To be removed in 2.0
- (id) initWithImage:(UIImage *)uiImage
{
	return [self initWithImage:uiImage resolutionType:kCCResolutionUnknown];
}
#endif


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
- (id) initWithImage:(UIImage *)uiImage resolutionType:(ccResolutionType)resolution
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
- (id) initWithImage:(CGImageRef)CGImage
#endif
{
	NSUInteger				POTWide, POTHigh;
	CGContextRef			context = nil;
	void*					data = nil;;
	CGColorSpaceRef			colorSpace;
	void*					tempData;
	unsigned int*			inPixel32;
	unsigned short*			outPixel16;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGSize					imageSize;
	CCTexture2DPixelFormat	pixelFormat;
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	CGImageRef	CGImage = uiImage.CGImage;
#endif
	
	if(CGImage == NULL) {
		CCLOG(@"cocos2d: CCTexture2D. Can't create Texture. UIImage is nil");
		[self release];
		return nil;
	}
	
	CCConfiguration *conf = [CCConfiguration sharedConfiguration];
    
#if CC_TEXTURE_NPOT_SUPPORT
	if( [conf supportsNPOT] ) {
		POTWide = CGImageGetWidth(CGImage);
		POTHigh = CGImageGetHeight(CGImage);
        
	} else 
#endif
	{
		POTWide = ccNextPOT(CGImageGetWidth(CGImage));
		POTHigh = ccNextPOT(CGImageGetHeight(CGImage));
	}
    
	NSUInteger maxTextureSize = [conf maxTextureSize];
	if( POTHigh > maxTextureSize || POTWide > maxTextureSize ) {
		CCLOG(@"cocos2d: WARNING: Image (%lu x %lu) is bigger than the supported %ld x %ld",
			  (long)POTWide, (long)POTHigh,
			  (long)maxTextureSize, (long)maxTextureSize);
		[self release];
		return nil;
	}
	
	info = CGImageGetAlphaInfo(CGImage);
	hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
	
	size_t bpp = CGImageGetBitsPerComponent(CGImage);
	colorSpace = CGImageGetColorSpace(CGImage);
    
	if(colorSpace) {
		if(hasAlpha || bpp >= 8)
			pixelFormat = defaultAlphaPixelFormat_;
		else {
			CCLOG(@"cocos2d: CCTexture2D: Using RGB565 texture since image has no alpha");
			pixelFormat = kCCTexture2DPixelFormat_RGB565;
		}
	} else {
		// NOTE: No colorspace means a mask image
		CCLOG(@"cocos2d: CCTexture2D: Using A8 texture since image is a mask");
		pixelFormat = kCCTexture2DPixelFormat_A8;
	}
	
	imageSize = CGSizeMake(CGImageGetWidth(CGImage), CGImageGetHeight(CGImage));
    
	// Create the bitmap graphics context
	
	switch(pixelFormat) {          
		case kCCTexture2DPixelFormat_RGBA8888:
		case kCCTexture2DPixelFormat_RGBA4444:
		case kCCTexture2DPixelFormat_RGB5A1:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(POTHigh * POTWide * 4);
			info = hasAlpha ? kCGImageAlphaPremultipliedLast : kCGImageAlphaNoneSkipLast; 
            //			info = kCGImageAlphaPremultipliedLast;  // issue #886. This patch breaks BMP images.
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
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(CGImage), CGImageGetHeight(CGImage)), CGImage);
	
	// Repack the pixel data into the right format
	
	if(pixelFormat == kCCTexture2DPixelFormat_RGB565) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
		tempData = malloc(POTHigh * POTWide * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(unsigned int i = 0; i < POTWide * POTHigh; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		free(data);
		data = tempData;
		
	}
	else if (pixelFormat == kCCTexture2DPixelFormat_RGBA4444) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRGGGGBBBBAAAA"
		tempData = malloc(POTHigh * POTWide * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(unsigned int i = 0; i < POTWide * POTHigh; ++i, ++inPixel32)
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
		for(unsigned int i = 0; i < POTWide * POTHigh; ++i, ++inPixel32)
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
	hasPremultipliedAlpha_ = (info == kCGImageAlphaPremultipliedLast || info == kCGImageAlphaPremultipliedFirst);
	
	CGContextRelease(context);
	[self releaseData:data];
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	resolutionType_ = resolution;
#endif
	
	return self;
}
@end

#pragma mark -
#pragma mark CCTexture2D - Text

@implementation CCTexture2D (Text)

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode font:(id)uifont
{
	NSAssert( uifont, @"Invalid font");
	
	NSUInteger POTWide = ccNextPOT(dimensions.width);
	NSUInteger POTHigh = ccNextPOT(dimensions.height);
	unsigned char*			data;
	
	CGContextRef			context;
	CGColorSpaceRef			colorSpace;
    
#if USE_TEXT_WITH_A8_TEXTURES
	data = calloc(POTHigh, POTWide);
#else
	data = calloc(POTHigh, POTWide * 2);
#endif
    
	colorSpace = CGColorSpaceCreateDeviceGray();
	context = CGBitmapContextCreate(data, POTWide, POTHigh, 8, POTWide, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	
	if( ! context ) {
		free(data);
		[self release];
		return nil;
	}
	
	CGContextSetGrayFillColor(context, 1.0f, 1.0f);
	CGContextTranslateCTM(context, 0.0f, POTHigh);
	CGContextScaleCTM(context, 1.0f, -1.0f); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
	
	UIGraphicsPushContext(context);
    
	// normal fonts
	if( [uifont isKindOfClass:[UIFont class] ] )
		[string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withFont:uifont lineBreakMode:lineBreakMode alignment:alignment];
	
#if CC_FONT_LABEL_SUPPORT
	else // ZFont class 
		[string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withZFont:uifont lineBreakMode:lineBreakMode alignment:alignment];
#endif
	
	UIGraphicsPopContext();
	
#if USE_TEXT_WITH_A8_TEXTURES
	self = [self initWithData:data pixelFormat:kCCTexture2DPixelFormat_A8 pixelsWide:POTWide pixelsHigh:POTHigh contentSize:dimensions];
    
#else // ! USE_TEXT_WITH_A8_TEXTURES
	NSUInteger textureSize = POTWide*POTHigh;
	unsigned short *la88_data = (unsigned short*)data;
	for(int i = textureSize-1; i>=0; i--) //Convert A8 to AI88
		la88_data[i] = (data[i] << 8) | 0xff;
	
	self = [self initWithData:data pixelFormat:kCCTexture2DPixelFormat_AI88 pixelsWide:POTWide pixelsHigh:POTHigh contentSize:dimensions];
#endif // ! USE_TEXT_WITH_A8_TEXTURES
    
	CGContextRelease(context);
	[self releaseData:data];
    
	return self;
}



#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment attributedString:(NSAttributedString*)stringWithAttributes
{
	NSAssert(stringWithAttributes, @"Invalid stringWithAttributes");
    
    // get nearest power of two
    NSSize POTSize = NSMakeSize(ccNextPOT(dimensions.width), ccNextPOT(dimensions.height));
	
    // get string dimensions
	NSSize realDimensions = [stringWithAttributes size];
	
	// Mac crashes if the width or height is 0
	if (realDimensions.width > 0 && realDimensions.height > 0)
    {
		// Disable antialias
		[[NSGraphicsContext currentContext] setShouldAntialias:NO];	
		
        NSImage *image = [[NSImage alloc] initWithSize:POTSize];
		[image lockFocus];	

        [stringWithAttributes drawInRect:NSMakeRect(0, POTSize.height - dimensions.height, dimensions.width, dimensions.height)]; //POTSize.width, POTSize.height)];
		
        NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0f, 0.0f, POTSize.width, POTSize.height)];
		[image unlockFocus];
        
		unsigned char *data = (unsigned char *) [bitmap bitmapData];  // Use the same buffer to improve the performance.
		
        NSUInteger textureSize = (NSUInteger)POTSize.width * (NSUInteger)POTSize.height;
        
		for (int i = 0; i < textureSize; i++) //Convert RGBA8888 to A8
			data[i] = data[i * 4 + 3];
		
        self = [self initWithData:data pixelFormat:kCCTexture2DPixelFormat_A8 pixelsWide:POTSize.width pixelsHigh:POTSize.height contentSize:dimensions];
		
		[bitmap release];
		[image release]; 
	}
    else
    {
		[self release];
		return nil;
	}
	
	return self;
}
#endif // __MAC_OS_X_VERSION_MAX_ALLOWED

- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size
{
    CGSize dim;
    
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	id font;
	font = [UIFont fontWithName:name size:size];
	if( font )
		dim = [string sizeWithFont:font];
    
#if CC_FONT_LABEL_SUPPORT
	if( ! font ){
		font = [[FontManager sharedManager] zFontWithName:name pointSize:size];
		if (font)
			dim = [string sizeWithZFont:font];
	}
#endif // CC_FONT_LABEL_SUPPORT
	
	if( ! font ) {
		CCLOG(@"cocos2d: Unable to load font %@", name);
		[self release];
		return nil;
	}
	
	return [self initWithString:string dimensions:dim alignment:CCTextAlignmentCenter lineBreakMode:UILineBreakModeWordWrap font:font];
	
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	{
        
		NSFont *font = [[NSFontManager sharedFontManager]
                        fontWithFamily:name
                        traits:NSUnboldFontMask | NSUnitalicFontMask
                        weight:0
                        size:size];
        
		NSDictionary *dict = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];	
        
		NSAttributedString *stringWithAttributes = [[[NSAttributedString alloc] initWithString:string attributes:dict] autorelease];
        
		dim = NSSizeToCGSize( [stringWithAttributes size] );
        
		return [self initWithString:string dimensions:dim alignment:CCTextAlignmentCenter attributedString:stringWithAttributes];
	}
#endif // __MAC_OS_X_VERSION_MAX_ALLOWED
    
}

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self initWithString:string dimensions:dimensions alignment:alignment lineBreakMode:CCLineBreakModeWordWrap fontName:name fontSize:size];
}

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontName:(NSString*)name fontSize:(CGFloat)size
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	id						uifont = nil;
	
	uifont = [UIFont fontWithName:name size:size];
	
#if CC_FONT_LABEL_SUPPORT
	if( ! uifont )
		uifont = [[FontManager sharedManager] zFontWithName:name pointSize:size];
#endif // CC_FONT_LABEL_SUPPORT
	if( ! uifont ) {
		CCLOG(@"cocos2d: Texture2d: Invalid Font: %@. Verify the .ttf name", name);
		[self release];
		return nil;
	}
	
	return [self initWithString:string dimensions:dimensions alignment:alignment lineBreakMode:lineBreakMode font:uifont];
	
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

    // select font
    NSFont *font = [[NSFontManager sharedFontManager] fontWithFamily:name traits:NSUnboldFontMask | NSUnitalicFontMask weight:0 size:size];

    // create paragraph style
    NSMutableParagraphStyle *pstyle = [[NSMutableParagraphStyle alloc] init];
    [pstyle setAlignment:alignment];
    [pstyle setLineBreakMode:lineBreakMode];
    
    // put attributes into a NSDictionary
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, pstyle, NSParagraphStyleAttributeName, nil];
    
    [pstyle release];
    
    // create string with attributes
    NSAttributedString *stringWithAttributes = [[[NSAttributedString alloc] initWithString:string attributes:attributes] autorelease];
	
	return [self initWithString:string dimensions:dimensions alignment:alignment attributedString:stringWithAttributes];
	
#endif // Mac
}
@end

#pragma mark -
#pragma mark CCTexture2D - PVRSupport

@implementation CCTexture2D (PVRSupport)

// By default PVR images are treated as if they don't have the alpha channel premultiplied
static BOOL PVRHaveAlphaPremultiplied_ = NO;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(id) initWithPVRTCData: (const void*)data level:(int)level bpp:(int)bpp hasAlpha:(BOOL)hasAlpha length:(int)length pixelFormat:(CCTexture2DPixelFormat)pixelFormat
{
	//	GLint					saveName;
	
	if( ! [[CCConfiguration sharedConfiguration] supportsPVRTC] ) {
		CCLOG(@"cocos2d: WARNING: PVRTC images is not supported");
		[self release];
		return nil;
	}
	
	if((self = [super init])) {
		glGenTextures(1, &name_);
		glBindTexture(GL_TEXTURE_2D, name_);
		
		[self setAntiAliasTexParameters];
		
		GLenum format;
		GLsizei size = length * length * bpp / 8;
		if(hasAlpha)
			format = (bpp == 4) ? GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG : GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
		else
			format = (bpp == 4) ? GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG : GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
		
		if(size < 32)
			size = 32;
		
		glCompressedTexImage2D(GL_TEXTURE_2D, level, format, length, length, 0, size, data);
		
		size_ = CGSizeMake(length, length);
		width_ = length;
		height_ = length;
		maxS_ = 1.0f;
		maxT_ = 1.0f;
		hasPremultipliedAlpha_ = PVRHaveAlphaPremultiplied_;
		format_ = pixelFormat;
	}					
	return self;
}
#endif // __IPHONE_OS_VERSION_MAX_ALLOWED

-(id) initWithPVRFile: (NSString*) relPath
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	ccResolutionType resolution;
	NSString *fullpath = [CCFileUtils fullPathFromRelativePath:relPath resolutionType:&resolution];
	
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	NSString *fullpath = [CCFileUtils fullPathFromRelativePath:relPath];
#endif 
	
	if( (self = [super init]) ) {
		CCTexturePVR *pvr = [[CCTexturePVR alloc] initWithContentsOfFile:fullpath];
		if( pvr ) {
			pvr.retainName = YES;	// don't dealloc texture on release
			
			name_ = pvr.name;	// texture id
			maxS_ = 1;			// only POT texture are supported
			maxT_ = 1;
			width_ = pvr.width;
			height_ = pvr.height;
			size_ = CGSizeMake(width_, height_);
			hasPremultipliedAlpha_ = PVRHaveAlphaPremultiplied_;
			format_ = pvr.format;
			
			[pvr release];
			
			[self setAntiAliasTexParameters];
		} else {
			
			CCLOG(@"cocos2d: Couldn't load PVR image: %@", relPath);
			[self release];
			return nil;
		}
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		resolutionType_ = resolution;
#endif
	}
	return self;
}

+(void) PVRImagesHavePremultipliedAlpha:(BOOL)haveAlphaPremultiplied
{
	PVRHaveAlphaPremultiplied_ = haveAlphaPremultiplied;
}
@end

#pragma mark -
#pragma mark CCTexture2D - Drawing

@implementation CCTexture2D (Drawing)

- (void) drawAtPoint:(CGPoint)point 
{
	GLfloat		coordinates[] = { 0.0f,	maxT_,
        maxS_,	maxT_,
        0.0f,	0.0f,
        maxS_,	0.0f };
	GLfloat		width = (GLfloat)width_ * maxS_,
    height = (GLfloat)height_ * maxT_;
    
	GLfloat		vertices[] = {	point.x,			point.y,
        width + point.x,	point.y,
        point.x,			height  + point.y,
		width + point.x,	height  + point.y };
	
	glBindTexture(GL_TEXTURE_2D, name_);
    
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: GL_COLOR_ARRAY
	glDisableClientState(GL_COLOR_ARRAY);
    
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
	// Restore GL state
	glEnableClientState(GL_COLOR_ARRAY);
}


- (void) drawInRect:(CGRect)rect
{
	GLfloat	 coordinates[] = {  0.0f,	maxT_,
        maxS_,	maxT_,
        0.0f,	0.0f,
        maxS_,	0.0f  };
	GLfloat	vertices[] = {	rect.origin.x,						rect.origin.y,
        rect.origin.x + rect.size.width,	rect.origin.y,
        rect.origin.x,						rect.origin.y + rect.size.height,
		rect.origin.x + rect.size.width,						rect.origin.y + rect.size.height };
	
	glBindTexture(GL_TEXTURE_2D, name_);
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: GL_COLOR_ARRAY
	glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	// restore state
	glEnableClientState(GL_COLOR_ARRAY);
}

@end


#pragma mark -
#pragma mark CCTexture2D - GLFilter

//
// Use to apply MIN/MAG filter
//
@implementation CCTexture2D (GLFilter)

-(void) generateMipmap
{
	NSAssert( width_ == ccNextPOT(width_) && height_ == ccNextPOT(height_), @"Mimpap texture only works in POT textures");
	glBindTexture( GL_TEXTURE_2D, name_ );
	ccglGenerateMipmap(GL_TEXTURE_2D);
}

-(void) setTexParameters: (ccTexParams*) texParams
{
	NSAssert( (width_ == ccNextPOT(width_) && height_ == ccNextPOT(height_)) ||
			 (texParams->wrapS == GL_CLAMP_TO_EDGE && texParams->wrapT == GL_CLAMP_TO_EDGE),
			 @"GL_CLAMP_TO_EDGE should be used in NPOT textures");
	glBindTexture( GL_TEXTURE_2D, name_ );
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


#pragma mark -
#pragma mark CCTexture2D - Pixel Format

//
// Texture options for images that contains alpha
//
@implementation CCTexture2D (PixelFormat)
+(void) setDefaultAlphaPixelFormat:(CCTexture2DPixelFormat)format
{
	defaultAlphaPixelFormat_ = format;
}

+(CCTexture2DPixelFormat) defaultAlphaPixelFormat
{
	return defaultAlphaPixelFormat_;
}

-(NSUInteger) bitsPerPixelForFormat
{
	NSUInteger ret=0;
    
	switch (format_) {
		case kCCTexture2DPixelFormat_RGBA8888:
			ret = 32;
			break;
		case kCCTexture2DPixelFormat_RGB565:
			ret = 16;
			break;
		case kCCTexture2DPixelFormat_RGB888:
			ret = 24;
			break;
		case kCCTexture2DPixelFormat_A8:
			ret = 8;
			break;
		case kCCTexture2DPixelFormat_RGBA4444:
			ret = 16;
			break;
		case kCCTexture2DPixelFormat_RGB5A1:
			ret = 16;
			break;
		case kCCTexture2DPixelFormat_PVRTC4:
			ret = 4;
			break;
		case kCCTexture2DPixelFormat_PVRTC2:
			ret = 2;
			break;
		case kCCTexture2DPixelFormat_I8:
			ret = 8;
			break;
		case kCCTexture2DPixelFormat_AI88:
			ret = 16;
			break;
		default:
			ret = -1;
			NSAssert1(NO , @"bitsPerPixelForFormat: %ld, unrecognised pixel format", (long)format_);
			CCLOG(@"bitsPerPixelForFormat: %ld, cannot give useful result", (long)format_);
			break;
	}
	return ret;
}
@end

