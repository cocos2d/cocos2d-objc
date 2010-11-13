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


#import <Availability.h>

#import "Platforms/CCGL.h"
#import "Platforms/CCNS.h"


#import "CCTexture2D.h"
#import "ccConfig.h"
#import "ccMacros.h"
#import "CCConfiguration.h"
#import "Support/ccUtils.h"
#import "CCTexturePVR.h"

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && CC_FONT_LABEL_SUPPORT
// FontLabel support
#import "FontManager.h"
#import "FontLabelStringDrawing.h"
#endif// CC_FONT_LABEL_SUPPORT


// For Labels use 32-bit textures on iPhone 3GS / iPads since A8 textures are very slow
#if defined(__ARM_NEON__) && CC_USE_RGBA32_LABELS_ON_NEON_ARCH
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

@synthesize contentSizeInPixels=size_, pixelFormat=format_, pixelsWide=width_, pixelsHigh=height_, name=name_, maxS=maxS_, maxT=maxT_;
@synthesize hasPremultipliedAlpha=hasPremultipliedAlpha_;
- (id) initWithData:(const void*)data pixelFormat:(CCTexture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSize:(CGSize)size
{
	if((self = [super init])) {
		glGenTextures(1, &name_);
		glBindTexture(GL_TEXTURE_2D, name_);

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

		size_ = size;
		width_ = width;
		height_ = height;
		format_ = pixelFormat;
		maxS_ = size.width / (float)width;
		maxT_ = size.height / (float)height;

		hasPremultipliedAlpha_ = NO;
	}					
	return self;
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
- (id) initWithImage:(UIImage *)uiImage
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
		CCLOG(@"cocos2d: WARNING: Image (%d x %d) is bigger than the supported %d x %d",
			  (unsigned int)POTWide, (unsigned int)POTHigh,
			  (unsigned int)maxTextureSize, (unsigned int)maxTextureSize);
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
	} else  {
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
	free(data);
	
	return self;
}
@end

#pragma mark -
#pragma mark CCTexture2D - Text

@implementation CCTexture2D (Text)

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment font:(id)uifont
{
	NSAssert( uifont, @"Invalid font");
	
	NSUInteger POTWide = ccNextPOT(dimensions.width);
	NSUInteger POTHigh = ccNextPOT(dimensions.height);
	unsigned char*			data;
	
	CGContextRef			context;
	CGColorSpaceRef			colorSpace;
	
#if USE_TEXT_WITH_A8_TEXTURES
	colorSpace = CGColorSpaceCreateDeviceGray();
	data = calloc(POTHigh, POTWide);
	context = CGBitmapContextCreate(data, POTWide, POTHigh, 8, POTWide, colorSpace, kCGImageAlphaNone);
#else
	colorSpace = CGColorSpaceCreateDeviceRGB();
	data = calloc(POTHigh, POTWide * 4);
	context = CGBitmapContextCreate(data, POTWide, POTHigh, 8, 4 * POTWide, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);				
#endif

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
		[string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withFont:uifont lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
	
#if CC_FONT_LABEL_SUPPORT
	else // ZFont class 
		[string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withZFont:uifont lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
#endif
	
	UIGraphicsPopContext();
	
#if USE_TEXT_WITH_A8_TEXTURES
	self = [self initWithData:data pixelFormat:kCCTexture2DPixelFormat_A8 pixelsWide:POTWide pixelsHigh:POTHigh contentSize:dimensions];
#else
	self = [self initWithData:data pixelFormat:kCCTexture2DPixelFormat_RGBA8888 pixelsWide:POTWide pixelsHigh:POTHigh contentSize:dimensions];
#endif
	CGContextRelease(context);
	free(data);
			
	return self;
}
				 
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment attributedString:(NSAttributedString*)stringWithAttributes
{				
	NSAssert( stringWithAttributes, @"Invalid stringWithAttributes");

	NSUInteger POTWide = ccNextPOT(dimensions.width);
	NSUInteger POTHigh = ccNextPOT(dimensions.height);
	unsigned char*			data;
	
	NSSize realDimensions = [stringWithAttributes size];

	//Alignment
	float xPadding = 0;
	
	// Mac crashes if the width or height is 0
	if( realDimensions.width > 0 && realDimensions.height > 0 ) {
		switch (alignment) {
			case CCTextAlignmentLeft: xPadding = 0; break;
			case CCTextAlignmentCenter: xPadding = (dimensions.width-realDimensions.width)/2.0f; break;
			case CCTextAlignmentRight: xPadding = dimensions.width-realDimensions.width; break;
			default: break;
		}
		
		//Disable antialias
		[[NSGraphicsContext currentContext] setShouldAntialias:NO];	
		
		NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(POTWide, POTHigh)];
		[image lockFocus];	
		
		[stringWithAttributes drawAtPoint:NSMakePoint(xPadding, POTHigh-dimensions.height)]; // draw at offset position	
		
		NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect (0.0f, 0.0f, POTWide, POTHigh)];
		[image unlockFocus];
		
		data = (unsigned char*) [bitmap bitmapData];  //Use the same buffer to improve the performance.
		
		for(int i = 0; i<(POTWide*POTHigh); i++) //Convert RGBA8888 to A8
			data[i] = data[i*4+3];
		
		self = [self initWithData:data pixelFormat:kCCTexture2DPixelFormat_A8 pixelsWide:POTWide pixelsHigh:POTHigh contentSize:dimensions];
		
		[bitmap release];
		[image release]; 
			
	} else {
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
	
	return [self initWithString:string dimensions:dim alignment:CCTextAlignmentCenter font:font];
	
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	{

		NSAttributedString *stringWithAttributes =
		[[[NSAttributedString alloc] initWithString:string
										 attributes:[NSDictionary dictionaryWithObject:[[NSFontManager sharedFontManager]
																						fontWithFamily:name
																						traits:NSUnboldFontMask | NSUnitalicFontMask
																						weight:0
																						size:size]
																				forKey:NSFontAttributeName]
		  ]
		 autorelease];
	
		dim = NSSizeToCGSize( [stringWithAttributes size] );
				
		return [self initWithString:string dimensions:dim alignment:CCTextAlignmentCenter attributedString:stringWithAttributes];
	}
#endif // __MAC_OS_X_VERSION_MAX_ALLOWED
    
}

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
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
	
	return [self initWithString:string dimensions:dimensions alignment:alignment font:uifont];
	
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	
	//String with attributes
	NSAttributedString *stringWithAttributes =
	[[[NSAttributedString alloc] initWithString:string
									 attributes:[NSDictionary dictionaryWithObject:[[NSFontManager sharedFontManager]
																					fontWithFamily:name
																					traits:NSUnboldFontMask | NSUnitalicFontMask
																					weight:0
																					size:size]
																			forKey:NSFontAttributeName]
	  ]
	 autorelease];
	
	return [self initWithString:string dimensions:dimensions alignment:CCTextAlignmentCenter attributedString:stringWithAttributes];
		
#endif // Mac
}
@end

#pragma mark -
#pragma mark CCTexture2D - PVRSupport

@implementation CCTexture2D (PVRSupport)

// By default PVR images are treated as if they don't have the alpha channel premultiplied
static BOOL PVRHaveAlphaPremultiplied_ = NO;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(id) initWithPVRTCData: (const void*)data level:(int)level bpp:(int)bpp hasAlpha:(BOOL)hasAlpha length:(int)length
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
		if(hasAlpha) {
			format = (bpp == 4) ? GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG : GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
		} else {
			format = (bpp == 4) ? GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG : GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
		}
		if(size < 32) {
			size = 32;
		}
		glCompressedTexImage2D(GL_TEXTURE_2D, level, format, length, length, 0, size, data);
		
		size_ = CGSizeMake(length, length);
		width_ = length;
		height_ = length;
		maxS_ = 1.0f;
		maxT_ = 1.0f;
		hasPremultipliedAlpha_ = PVRHaveAlphaPremultiplied_;
	}					
	return self;
}
#endif // __IPHONE_OS_VERSION_MAX_ALLOWED

-(id) initWithPVRFile: (NSString*) file
{
	if( (self = [super init]) ) {
		CCTexturePVR *pvr = [[CCTexturePVR alloc] initWithContentsOfFile:file];
		if( pvr ) {
			pvr.retainName = YES;	// don't dealloc texture on release
			
			name_ = pvr.name;	// texture id
			maxS_ = 1;			// only POT texture are supported
			maxT_ = 1;
			width_ = pvr.width;
			height_ = pvr.height;
			size_ = CGSizeMake(width_, height_);
			hasPremultipliedAlpha_ = PVRHaveAlphaPremultiplied_;
			
			[pvr release];
			
			[self setAntiAliasTexParameters];
		} else {
			
			CCLOG(@"cocos2d: Couldn't load PVR image");
			[self release];
			return nil;
		}
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

	GLfloat		vertices[] = {	point.x,			point.y,	0.0f,
								width + point.x,	point.y,	0.0f,
								point.x,			height  + point.y,	0.0f,
								width + point.x,	height  + point.y,	0.0f };
	
	glBindTexture(GL_TEXTURE_2D, name_);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (void) drawInRect:(CGRect)rect
{
	GLfloat	 coordinates[] = {  0.0f,	maxT_,
								maxS_,	maxT_,
								0.0f,	0.0f,
								maxS_,	0.0f  };
	GLfloat	vertices[] = {	rect.origin.x,							rect.origin.y,							/*0.0f,*/
							rect.origin.x + rect.size.width,		rect.origin.y,							/*0.0f,*/
							rect.origin.x,							rect.origin.y + rect.size.height,		/*0.0f,*/
							rect.origin.x + rect.size.width,		rect.origin.y + rect.size.height,		/*0.0f*/ };
	
	glBindTexture(GL_TEXTURE_2D, name_);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
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
@end

