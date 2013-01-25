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

#import "Platforms/CCGL.h"
#import "Platforms/CCNS.h"

#import "CCTexture2D.h"
#import "ccConfig.h"
#import "ccMacros.h"
#import "CCConfiguration.h"
#import "CCTexturePVR.h"
#import "CCGLProgram.h"
#import "ccGLStateCache.h"
#import "CCShaderCache.h"
#import "CCDirector.h"

#import "Support/ccUtils.h"
#import "Support/CCFileUtils.h"

#import "ccDeprecated.h"



#if CC_USE_LA88_LABELS
#define LABEL_PIXEL_FORMAT kCCTexture2DPixelFormat_AI88
#else
#define LABEL_PIXEL_FORMAT kCCTexture2DPixelFormat_A8
#endif

//CLASS IMPLEMENTATIONS:


// If the image has alpha, you can create RGBA8 (32-bit) or RGBA4 (16-bit) or RGB5A1 (16-bit)
// Default is: RGBA8888 (32-bit textures)
static CCTexture2DPixelFormat defaultAlphaPixel_format = kCCTexture2DPixelFormat_Default;

#pragma mark -
#pragma mark CCTexture2D - Main

@implementation CCTexture2D

@synthesize contentSizeInPixels = _size, pixelFormat = _format, pixelsWide = _width, pixelsHigh = _height, name = _name, maxS = _maxS, maxT = _maxT;
@synthesize hasPremultipliedAlpha = _hasPremultipliedAlpha;
@synthesize shaderProgram = _shaderProgram;
@synthesize resolutionType = _resolutionType;


- (id) initWithData:(const void*)data pixelFormat:(CCTexture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSize:(CGSize)size
{
	if((self = [super init])) {
		
		
		// XXX: 32 bits or POT textures uses UNPACK of 4 (is this correct ??? )
		if( pixelFormat == kCCTexture2DPixelFormat_RGBA8888 || ( ccNextPOT(width)==width && ccNextPOT(height)==height) )
			glPixelStorei(GL_UNPACK_ALIGNMENT,4);
		else
			glPixelStorei(GL_UNPACK_ALIGNMENT,1);

		glGenTextures(1, &_name);
		ccGLBindTexture2D( _name );
		
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );

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
			case kCCTexture2DPixelFormat_RGB888:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, (GLsizei) width, (GLsizei) height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
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

		_size = size;
		_width = width;
		_height = height;
		_format = pixelFormat;
		_maxS = size.width / (float)width;
		_maxT = size.height / (float)height;

		_hasPremultipliedAlpha = NO;

		_hasMipmaps = NO;

		_resolutionType = kCCResolutionUnknown;
		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTexture];
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

	[_shaderProgram release];

	if( _name )
		ccGLDeleteTexture( _name );

	[super dealloc];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Name = %i | Dimensions = %lux%lu | Pixel format = %@ | Coordinates = (%.2f, %.2f)>", [self class], self, _name, (unsigned long)_width, (unsigned long)_height, [self stringForFormat], _maxS, _maxT];
}

-(CGSize) contentSize
{
	CGSize ret;
	ret.width = _size.width / CC_CONTENT_SCALE_FACTOR();
	ret.height = _size.height / CC_CONTENT_SCALE_FACTOR();

	return ret;
}

@end

#pragma mark -
#pragma mark CCTexture2D - Image

@implementation CCTexture2D (Image)

- (id) initWithCGImage:(CGImageRef)cgImage resolutionType:(ccResolutionType)resolution
{
	NSUInteger				textureWidth, textureHeight;
	CGContextRef			context = nil;
	void*					data = nil;
	CGColorSpaceRef			colorSpace;
	void*					tempData;
	unsigned int*			inPixel32;
	unsigned short*			outPixel16;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGSize					imageSize;
	CCTexture2DPixelFormat	pixelFormat;

	if(cgImage == NULL) {
		CCLOG(@"cocos2d: CCTexture2D. Can't create Texture. cgImage is nil");
		[self release];
		return nil;
	}

	CCConfiguration *conf = [CCConfiguration sharedConfiguration];

	info = CGImageGetAlphaInfo(cgImage);

#ifdef __CC_PLATFORM_IOS

	// Bug #886. It is present on iOS 4 only
	unsigned int version = [conf OSVersion];
	if( version >= kCCiOSVersion_4_0 && version < kCCiOSVersion_5_0 )
		hasAlpha = ((info == kCGImageAlphaNoneSkipLast) || (info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
	else
#endif // __CC_PLATFORM_IOS
	
	hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);

	colorSpace = CGImageGetColorSpace(cgImage);

	if(colorSpace) {
		if( hasAlpha ) {
			pixelFormat = defaultAlphaPixel_format;
			info = kCGImageAlphaPremultipliedLast;
		}
		else
		{
			info = kCGImageAlphaNoneSkipLast;

			// Use RGBA8888 if default is RGBA8888, otherwise use RGB565.
			// DO NOT USE RGB888 since it is the same as RGBA8888, but it is more expensive to create it
			if( defaultAlphaPixel_format == kCCTexture2DPixelFormat_RGBA8888 )
				pixelFormat = kCCTexture2DPixelFormat_RGBA8888;
			else
				pixelFormat = kCCTexture2DPixelFormat_RGB565;
			
			CCLOG(@"cocos2d: CCTexture2D: Using RGB565 texture since image has no alpha");
				
		}
	} else {
		// NOTE: No colorspace means a mask image
		CCLOG(@"cocos2d: CCTexture2D: Using A8 texture since image is a mask");
		pixelFormat = kCCTexture2DPixelFormat_A8;
	}

	if( ! [conf supportsNPOT]  )
	{
		textureWidth = ccNextPOT(CGImageGetWidth(cgImage));
		textureHeight = ccNextPOT(CGImageGetHeight(cgImage));
	}
	else
	{
		textureWidth = CGImageGetWidth(cgImage);
		textureHeight = CGImageGetHeight(cgImage);
	}

#ifdef __CC_PLATFORM_IOS

	// iOS 5 BUG:
	// If width is not word aligned, convert it to word aligned.
	// http://www.cocos2d-iphone.org/forum/topic/31092
	if( [conf OSVersion] >= kCCiOSVersion_5_0 )
	{
		
		NSUInteger bpp = [[self class] bitsPerPixelForFormat:pixelFormat];
		NSUInteger bytes = textureWidth * bpp / 8;
		
		// XXX: Should it be 4 or sizeof(int) ??
		NSUInteger mod = bytes % 4;
		
		// Not word aligned ?
		if( mod != 0 ) {
			
			NSUInteger neededBytes = (4 - mod ) / (bpp/8);

			CCLOGWARN(@"cocos2d: WARNING converting size=(%d,%d) to size=(%d,%d) due to iOS 5.x memory BUG. See: http://www.cocos2d-iphone.org/forum/topic/31092", textureWidth, textureHeight, textureWidth + neededBytes, textureHeight );
			textureWidth = textureWidth + neededBytes;
		}
	}   
#endif // IOS
   
   NSUInteger maxTextureSize = [conf maxTextureSize];
   if( textureHeight > maxTextureSize || textureWidth > maxTextureSize ) {
	   CCLOGWARN(@"cocos2d: WARNING: Image (%lu x %lu) is bigger than the supported %ld x %ld",
			 (long)textureWidth, (long)textureHeight,
			 (long)maxTextureSize, (long)maxTextureSize);
	   [self release];
	   return nil;
   }
   
	imageSize = CGSizeMake(CGImageGetWidth(cgImage), CGImageGetHeight(cgImage));

	// Create the bitmap graphics context

	switch(pixelFormat) {
		case kCCTexture2DPixelFormat_RGBA8888:
		case kCCTexture2DPixelFormat_RGBA4444:
		case kCCTexture2DPixelFormat_RGB5A1:
		case kCCTexture2DPixelFormat_RGB565:
		case kCCTexture2DPixelFormat_RGB888:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(textureHeight * textureWidth * 4);
//			info = hasAlpha ? kCGImageAlphaPremultipliedLast : kCGImageAlphaNoneSkipLast;
//			info = kCGImageAlphaPremultipliedLast;  // issue #886. This patch breaks BMP images.
			context = CGBitmapContextCreate(data, textureWidth, textureHeight, 8, 4 * textureWidth, colorSpace, info | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
		case kCCTexture2DPixelFormat_A8:
			data = malloc(textureHeight * textureWidth);
			info = kCGImageAlphaOnly;
			context = CGBitmapContextCreate(data, textureWidth, textureHeight, 8, textureWidth, NULL, info);
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
	}


	CGContextClearRect(context, CGRectMake(0, 0, textureWidth, textureHeight));
	CGContextTranslateCTM(context, 0, textureHeight - imageSize.height);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(cgImage), CGImageGetHeight(cgImage)), cgImage);

	// Repack the pixel data into the right format

	if(pixelFormat == kCCTexture2DPixelFormat_RGB565) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
		tempData = malloc(textureHeight * textureWidth * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(unsigned int i = 0; i < textureWidth * textureHeight; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		free(data);
		data = tempData;

	}

	else if(pixelFormat == kCCTexture2DPixelFormat_RGB888) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRRRRGGGGGGGGBBBBBBB"
		tempData = malloc(textureHeight * textureWidth * 3);
		char *inData = (char*)data;
		char *outData = (char*)tempData;
		int j=0;
		for(unsigned int i = 0; i < textureWidth * textureHeight *4; i++) {
			outData[j++] = inData[i++];
			outData[j++] = inData[i++];
			outData[j++] = inData[i++];
		}
		free(data);
		data = tempData;
		
	}

	else if (pixelFormat == kCCTexture2DPixelFormat_RGBA4444) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRGGGGBBBBAAAA"
		tempData = malloc(textureHeight * textureWidth * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(unsigned int i = 0; i < textureWidth * textureHeight; ++i, ++inPixel32)
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
		/*
		 Here was a bug.
		 When you convert RGBA8888 texture to RGB5A1 texture and then render it on black background, you'll see a "ghost" image as if the texture is still RGBA8888. 
		 On background lighter than the pixel color this effect disappers.
		 This happens because the old convertion function doesn't premultiply old RGB with new A.
		 As Result = sourceRGB + destination*(1-source A), then
		 if Destination = 0000, then Result = source. Here comes the ghost!
		 We need to check new alpha value first (it may be 1 or 0) and depending on it whether convert RGB values or just set pixel to 0 
		 */
		tempData = malloc(textureHeight * textureWidth * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(unsigned int i = 0; i < textureWidth * textureHeight; ++i, ++inPixel32) {
			if ((*inPixel32 >> 31))// A can be 1 or 0
				*outPixel16++ =
				((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | // R
				((((*inPixel32 >> 8) & 0xFF) >> 3) << 6) | // G
				((((*inPixel32 >> 16) & 0xFF) >> 3) << 1) | // B
				1; // A
			else
				*outPixel16++ = 0;
		}
		
		free(data);
		data = tempData;
	}
	self = [self initWithData:data pixelFormat:pixelFormat pixelsWide:textureWidth pixelsHigh:textureHeight contentSize:imageSize];

	// should be after calling super init
	_hasPremultipliedAlpha = (info == kCGImageAlphaPremultipliedLast || info == kCGImageAlphaPremultipliedFirst);

	CGContextRelease(context);
	[self releaseData:data];

	_resolutionType = resolution;

	return self;
}
@end

#pragma mark -
#pragma mark CCTexture2D - Text

@implementation CCTexture2D (Text)

#ifdef __CC_PLATFORM_IOS

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)hAlignment vAlignment:(CCVerticalTextAlignment) vAlignment lineBreakMode:(CCLineBreakMode)lineBreakMode font:(UIFont*)uifont
{
	NSAssert( uifont, @"Invalid font");

	// MUST have the same order declared on ccTypes
	NSInteger linebreaks[] = {UILineBreakModeWordWrap, UILineBreakModeCharacterWrap, UILineBreakModeClip, UILineBreakModeHeadTruncation, UILineBreakModeTailTruncation, UILineBreakModeMiddleTruncation};

	NSUInteger textureWidth = ccNextPOT(dimensions.width);
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
	context = CGBitmapContextCreate(data, textureWidth, textureHeight, 8, textureWidth, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);

	if( ! context ) {
		free(data);
		[self release];
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
	NSUInteger alignments[] = { UITextAlignmentLeft, UITextAlignmentCenter, UITextAlignmentRight };
	
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

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)hAlignment vAlignment:(CCVerticalTextAlignment)vAlignment attributedString:(NSAttributedString*)stringWithAttributes
{
	NSAssert(stringWithAttributes, @"Invalid stringWithAttributes");

    // get nearest power of two
    NSSize POTSize = NSMakeSize(ccNextPOT(dimensions.width), ccNextPOT(dimensions.height));
    
	// Get actual rendered dimensions
    NSRect boundingRect = [stringWithAttributes boundingRectWithSize:NSSizeFromCGSize(dimensions) options:NSStringDrawingUsesLineFragmentOrigin];
    
	// Mac crashes if the width or height is 0
	if( POTSize.width == 0 )
		POTSize.width = 2;

	if( POTSize.height == 0)
		POTSize.height = 2;
        
	CGSize offset = CGSizeMake(0, POTSize.height - dimensions.height);
	
	//Alignment
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
	
	CGRect drawArea = CGRectMake(offset.width, offset.height, boundingRect.size.width, boundingRect.size.height);
	
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
	[bitmap release];
	[image release];

	return self;
}
#endif // __CC_PLATFORM_MAC

- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size
{
    CGSize dim;

#ifdef __CC_PLATFORM_IOS
	UIFont *font = [UIFont fontWithName:name size:size];

	if( ! font ) {
		CCLOGWARN(@"cocos2d: WARNING: Unable to load font %@", name);
		[self release];
		return nil;
	}

	// Is it a multiline ? sizeWithFont: only works with single line.
	CGSize boundingSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
	dim = [string sizeWithFont:font
			 constrainedToSize:boundingSize
				 lineBreakMode:UILineBreakModeWordWrap];
	
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
            [self release];
            return nil;
        }

		NSDictionary *dict = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];

		NSAttributedString *stringWithAttributes = [[[NSAttributedString alloc] initWithString:string attributes:dict] autorelease];

		dim = NSSizeToCGSize( [stringWithAttributes size] );

		return [self initWithString:string dimensions:dim hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentTop attributedString:stringWithAttributes];
	}
#endif // __CC_PLATFORM_MAC

}

- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment vAlignment:(CCVerticalTextAlignment)vAlignment
{
	return [self initWithString:string fontName:name fontSize:size dimensions:dimensions hAlignment:alignment vAlignment:vAlignment lineBreakMode:kCCLineBreakModeWordWrap];
}

- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)hAlignment vAlignment:(CCVerticalTextAlignment)vAlignment lineBreakMode:(CCLineBreakMode)lineBreakMode 
{
#ifdef __CC_PLATFORM_IOS
	UIFont *uifont = [UIFont fontWithName:name size:size];
	if( ! uifont ) {
		CCLOG(@"cocos2d: Texture2d: Invalid Font: %@. Verify the .ttf name", name);
		[self release];
		return nil;
	}

	return [self initWithString:string dimensions:dimensions hAlignment:hAlignment vAlignment:vAlignment lineBreakMode:lineBreakMode font:uifont];

#elif defined(__CC_PLATFORM_MAC)

	// select font
	NSFont *font = [NSFont fontWithName:name size:size];
	if( ! font ) {
		CCLOG(@"cocos2d: Texture2d: Invalid Font: %@. Verify the .ttf name", name);
		[self release];
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

	[pstyle release];

	// create string with attributes
	NSAttributedString *stringWithAttributes = [[[NSAttributedString alloc] initWithString:string attributes:attributes] autorelease];

	return [self initWithString:string dimensions:dimensions hAlignment:hAlignment vAlignment:vAlignment attributedString:stringWithAttributes];

#endif // Mac
}
@end

#pragma mark -
#pragma mark CCTexture2D - PVRSupport

@implementation CCTexture2D (PVRSupport)

// By default PVR images are treated as if they don't have the alpha channel premultiplied
static BOOL _PVRHaveAlphaPremultiplied = NO;

-(id) initWithPVRFile: (NSString*) relPath
{
	ccResolutionType resolution;
	NSString *fullpath = [[CCFileUtils sharedFileUtils] fullPathForFilename:relPath resolutionType:&resolution];

	if( (self = [super init]) ) {
		CCTexturePVR *pvr = [[CCTexturePVR alloc] initWithContentsOfFile:fullpath];
		if( pvr ) {
			pvr.retainName = YES;	// don't dealloc texture on release

			_name = pvr.name;	// texture id
			_maxS = 1;			// only POT texture are supported
			_maxT = 1;
			_width = pvr.width;
			_height = pvr.height;
			_size = CGSizeMake(_width, _height);
			_hasPremultipliedAlpha = (pvr.forcePremultipliedAlpha) ? pvr.hasPremultipliedAlpha : _PVRHaveAlphaPremultiplied;
			_format = pvr.format;

			_hasMipmaps = ( pvr.numberOfMipmaps > 1  );
			[pvr release];

		} else {

			CCLOG(@"cocos2d: Couldn't load PVR image: %@", relPath);
			[self release];
			return nil;
		}
		_resolutionType = resolution;
	}
	return self;
}

+(void) PVRImagesHavePremultipliedAlpha:(BOOL)haveAlphaPremultiplied
{
	_PVRHaveAlphaPremultiplied = haveAlphaPremultiplied;
}
@end

#pragma mark -
#pragma mark CCTexture2D - Drawing

@implementation CCTexture2D (Drawing)

- (void) drawAtPoint:(CGPoint)point
{
	GLfloat		coordinates[] = { 0.0f,	_maxT,
        _maxS,	_maxT,
        0.0f,	0.0f,
        _maxS,	0.0f };
	GLfloat		width = (GLfloat)_width * _maxS,
    height = (GLfloat)_height * _maxT;

	GLfloat		vertices[] = {	point.x,			point.y,
        width + point.x,	point.y,
        point.x,			height  + point.y,
		width + point.x,	height  + point.y };

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords );
	[_shaderProgram use];
	[_shaderProgram setUniformsForBuiltins];

	ccGLBindTexture2D( _name );


	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, coordinates);


	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	CC_INCREMENT_GL_DRAWS(1);
}


- (void) drawInRect:(CGRect)rect
{
	GLfloat	 coordinates[] = {  0.0f,	_maxT,
        _maxS,	_maxT,
        0.0f,	0.0f,
        _maxS,	0.0f  };
	GLfloat	vertices[] = {	rect.origin.x,						rect.origin.y,
        rect.origin.x + rect.size.width,	rect.origin.y,
        rect.origin.x,						rect.origin.y + rect.size.height,
		rect.origin.x + rect.size.width,						rect.origin.y + rect.size.height };


	[_shaderProgram use];
	[_shaderProgram setUniformsForBuiltins];    

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords );

	ccGLBindTexture2D( _name );

	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, coordinates);


	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	CC_INCREMENT_GL_DRAWS(1);
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
	NSAssert( _width == ccNextPOT(_width) && _height == ccNextPOT(_height), @"Mimpap texture only works in POT textures");
	ccGLBindTexture2D( _name );
	glGenerateMipmap(GL_TEXTURE_2D);
	_hasMipmaps = YES;
}

-(void) setTexParameters: (ccTexParams*) texParams
{
	NSAssert( (_width == ccNextPOT(_width) && _height == ccNextPOT(_height)) ||
				(texParams->wrapS == GL_CLAMP_TO_EDGE && texParams->wrapT == GL_CLAMP_TO_EDGE),
			@"GL_CLAMP_TO_EDGE should be used in NPOT dimensions");

	ccGLBindTexture2D( _name );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, texParams->minFilter );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, texParams->magFilter );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, texParams->wrapS );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, texParams->wrapT );
}

-(void) setAliasTexParameters
{
	ccGLBindTexture2D( _name );
	
	if( ! _hasMipmaps )
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	else
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST );

	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );	
}

-(void) setAntiAliasTexParameters
{
	ccGLBindTexture2D( _name );
	
	if( ! _hasMipmaps )
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	else
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST );

	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );	
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
	defaultAlphaPixel_format = format;
}

+(CCTexture2DPixelFormat) defaultAlphaPixelFormat
{
	return defaultAlphaPixel_format;
}

+(NSUInteger) bitsPerPixelForFormat:(CCTexture2DPixelFormat)format
{
	NSUInteger ret=0;
	
	switch (format) {
		case kCCTexture2DPixelFormat_RGBA8888:
			ret = 32;
			break;
		case kCCTexture2DPixelFormat_RGB888:
			// It is 32 and not 24, since its internal representation uses 32 bits.
			ret = 32;
			break;
		case kCCTexture2DPixelFormat_RGB565:
			ret = 16;
			break;
		case kCCTexture2DPixelFormat_RGBA4444:
			ret = 16;
			break;
		case kCCTexture2DPixelFormat_RGB5A1:
			ret = 16;
			break;
		case kCCTexture2DPixelFormat_AI88:
			ret = 16;
			break;
		case kCCTexture2DPixelFormat_A8:
			ret = 8;
			break;
		case kCCTexture2DPixelFormat_I8:
			ret = 8;
			break;
		case kCCTexture2DPixelFormat_PVRTC4:
			ret = 4;
			break;
		case kCCTexture2DPixelFormat_PVRTC2:
			ret = 2;
			break;
		default:
			ret = -1;
			NSAssert1(NO , @"bitsPerPixelForFormat: %ld, unrecognised pixel format", (long)format);
			CCLOG(@"bitsPerPixelForFormat: %ld, cannot give useful result", (long)format);
			break;
	}
	return ret;
}

-(NSUInteger) bitsPerPixelForFormat
{
	return [[self class] bitsPerPixelForFormat:_format];
}

-(NSString*) stringForFormat
{
	
	switch (_format) {
		case kCCTexture2DPixelFormat_RGBA8888:
			return  @"RGBA8888";

		case kCCTexture2DPixelFormat_RGB888:
			return  @"RGB888";

		case kCCTexture2DPixelFormat_RGB565:
			return  @"RGB565";

		case kCCTexture2DPixelFormat_RGBA4444:
			return  @"RGBA4444";

		case kCCTexture2DPixelFormat_RGB5A1:
			return  @"RGB5A1";

		case kCCTexture2DPixelFormat_AI88:
			return  @"AI88";

		case kCCTexture2DPixelFormat_A8:
			return  @"A8";

		case kCCTexture2DPixelFormat_I8:
			return  @"I8";
			
		case kCCTexture2DPixelFormat_PVRTC4:
			return  @"PVRTC4";
			
		case kCCTexture2DPixelFormat_PVRTC2:
			return  @"PVRTC2";

		default:
			NSAssert1(NO , @"stringForFormat: %ld, unrecognised pixel format", (long)_format);
			CCLOG(@"stringForFormat: %ld, cannot give useful result", (long)_format);
			break;
	}
	
	return  nil;
}
@end

