/*

File: PVRTexture.m
Abstract: The PVRTexture class is responsible for loading .pvr files.

Version: 1.0

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
 * Extended PVR formats for cocos2d project ( http://www.cocos2d-iphone.org )
 *	- RGBA8888
 *	- BGRA8888
 *  - RGBA4444
 *  - RGBA5551
 *  - RGB565
 *  - A8
 *  - I8
 *  - AI88
 */

#import <zlib.h>

#import "CCTexturePVR.h"
#import "ccMacros.h"
#import "CCConfiguration.h"
#import "ccGLStateCache.h"
#import "Support/ccUtils.h"
#import "Support/CCFileUtils.h"
#import "Support/ZipUtils.h"
#import "Support/OpenGL_Internal.h"

#pragma mark -
#pragma mark CCTexturePVR

#define PVR_TEXTURE_FLAG_TYPE_MASK	0xff

// Values taken from PVRTexture.h from http://www.imgtec.com
enum {
	kPVRTextureFlagMipmap		= (1<<8),		// has mip map levels
	kPVRTextureFlagTwiddle		= (1<<9),		// is twiddled
	kPVRTextureFlagBumpmap		= (1<<10),		// has normals encoded for a bump map
	kPVRTextureFlagTiling		= (1<<11),		// is bordered for tiled pvr
	kPVRTextureFlagCubemap		= (1<<12),		// is a cubemap/skybox
	kPVRTextureFlagFalseMipCol	= (1<<13),		// are there false coloured MIP levels
	kPVRTextureFlagVolume		= (1<<14),		// is this a volume texture
	kPVRTextureFlagAlpha		= (1<<15),		// v2.1 is there transparency info in the texture
	kPVRTextureFlagVerticalFlip	= (1<<16),		// v2.1 is the texture vertically flipped
};


static char gPVRTexIdentifier[4] = "PVR!";

enum
{
	kPVRTexturePixelTypeRGBA_4444= 0x10,
	kPVRTexturePixelTypeRGBA_5551,
	kPVRTexturePixelTypeRGBA_8888,
	kPVRTexturePixelTypeRGB_565,
	kPVRTexturePixelTypeRGB_555,				// unsupported
	kPVRTexturePixelTypeRGB_888,
	kPVRTexturePixelTypeI_8,
	kPVRTexturePixelTypeAI_88,
	kPVRTexturePixelTypePVRTC_2,
	kPVRTexturePixelTypePVRTC_4,
	kPVRTexturePixelTypeBGRA_8888,
	kPVRTexturePixelTypeA_8,
};

static const uint32_t tableFormats[][7] = {

	// - PVR texture format
	// - OpenGL internal format
	// - OpenGL format
	// - OpenGL type
	// - bpp
	// - compressed
	// - Cocos2d texture format constant
	{ kPVRTexturePixelTypeRGBA_4444,	GL_RGBA,	GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4,				16, NO, kCCTexture2DPixelFormat_RGBA4444	},
	{ kPVRTexturePixelTypeRGBA_5551,	GL_RGBA,	GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1,				16, NO, kCCTexture2DPixelFormat_RGB5A1		},
	{ kPVRTexturePixelTypeRGBA_8888,	GL_RGBA,	GL_RGBA, GL_UNSIGNED_BYTE,						32, NO, kCCTexture2DPixelFormat_RGBA8888	},
	{ kPVRTexturePixelTypeRGB_565,		GL_RGB,		GL_RGB,	 GL_UNSIGNED_SHORT_5_6_5,				16, NO, kCCTexture2DPixelFormat_RGB565		},
	{ kPVRTexturePixelTypeRGB_888,		GL_RGB,		GL_RGB,	 GL_UNSIGNED_BYTE,						24, NO,	kCCTexture2DPixelFormat_RGB888		},
	{ kPVRTexturePixelTypeA_8,			GL_ALPHA,	GL_ALPHA,	GL_UNSIGNED_BYTE,					8,	NO, kCCTexture2DPixelFormat_A8			},
	{ kPVRTexturePixelTypeI_8,			GL_LUMINANCE,	GL_LUMINANCE,	GL_UNSIGNED_BYTE,			8,	NO, kCCTexture2DPixelFormat_I8			},
	{ kPVRTexturePixelTypeAI_88,		GL_LUMINANCE_ALPHA,	GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE,	16,	NO, kCCTexture2DPixelFormat_AI88		},
#ifdef __CC_PLATFORM_IOS
	{ kPVRTexturePixelTypePVRTC_2,		GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG, -1, -1,				2,	YES, kCCTexture2DPixelFormat_PVRTC2		},
	{ kPVRTexturePixelTypePVRTC_4,		GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG, -1, -1,				4,	YES, kCCTexture2DPixelFormat_PVRTC4		},
#endif // iphone only
	{ kPVRTexturePixelTypeBGRA_8888,	GL_RGBA,	GL_BGRA, GL_UNSIGNED_BYTE,						32,	NO, kCCTexture2DPixelFormat_RGBA8888	},
};
#define MAX_TABLE_ELEMENTS (sizeof(tableFormats) / sizeof(tableFormats[0]))

enum {
	kCCInternalPVRTextureFormat,
	kCCInternalOpenGLInternalFormat,
	kCCInternalOpenGLFormat,
	kCCInternalOpenGLType,
	kCCInternalBPP,
	kCCInternalCompressedImage,
	kCCInternalCCTexture2DPixelFormat,
};

typedef struct _PVRTexHeader
{
	uint32_t headerLength;
	uint32_t height;
	uint32_t width;
	uint32_t numMipmaps;
	uint32_t flags;
	uint32_t dataLength;
	uint32_t bpp;
	uint32_t bitmaskRed;
	uint32_t bitmaskGreen;
	uint32_t bitmaskBlue;
	uint32_t bitmaskAlpha;
	uint32_t pvrTag;
	uint32_t numSurfs;
} PVRTexHeader;


@implementation CCTexturePVR

@synthesize name = name_;
@synthesize width = width_;
@synthesize height = height_;
@synthesize hasAlpha = hasAlpha_;

// cocos2d integration
@synthesize retainName = retainName_;
@synthesize format = format_;


- (BOOL)unpackPVRData:(unsigned char*)data PVRLen:(NSUInteger)len
{
	BOOL success = FALSE;
	PVRTexHeader *header = NULL;
	uint32_t flags, pvrTag;
	uint32_t dataLength = 0, dataOffset = 0, dataSize = 0;
	uint32_t blockSize = 0, widthBlocks = 0, heightBlocks = 0;
	uint32_t width = 0, height = 0, bpp = 4;
	uint8_t *bytes = NULL;
	uint32_t formatFlags;

	header = (PVRTexHeader *)data;

	pvrTag = CFSwapInt32LittleToHost(header->pvrTag);

	if ((uint32_t)gPVRTexIdentifier[0] != ((pvrTag >>  0) & 0xff) ||
		(uint32_t)gPVRTexIdentifier[1] != ((pvrTag >>  8) & 0xff) ||
		(uint32_t)gPVRTexIdentifier[2] != ((pvrTag >> 16) & 0xff) ||
		(uint32_t)gPVRTexIdentifier[3] != ((pvrTag >> 24) & 0xff))
	{
		return FALSE;
	}

	CCConfiguration *configuration = [CCConfiguration sharedConfiguration];

	flags = CFSwapInt32LittleToHost(header->flags);
	formatFlags = flags & PVR_TEXTURE_FLAG_TYPE_MASK;
	BOOL flipped = flags & kPVRTextureFlagVerticalFlip;
	if( flipped )
		CCLOG(@"cocos2d: WARNING: Image is flipped. Regenerate it using PVRTexTool");

	if( ! [configuration supportsNPOT] &&
	   ( header->width != ccNextPOT(header->width) || header->height != ccNextPOT(header->height ) ) ) {
		CCLOG(@"cocos2d: ERROR: Loding an NPOT texture (%dx%d) but is not supported on this device", header->width, header->height);
		return FALSE;
	}

	for( tableFormatIndex_=0; tableFormatIndex_ < (unsigned int)MAX_TABLE_ELEMENTS ; tableFormatIndex_++) {
		if( tableFormats[tableFormatIndex_][kCCInternalPVRTextureFormat] == formatFlags ) {

			numberOfMipmaps_ = 0;

			width_ = width = CFSwapInt32LittleToHost(header->width);
			height_ = height = CFSwapInt32LittleToHost(header->height);

			if (CFSwapInt32LittleToHost(header->bitmaskAlpha))
				hasAlpha_ = TRUE;
			else
				hasAlpha_ = FALSE;

			dataLength = CFSwapInt32LittleToHost(header->dataLength);
			bytes = ((uint8_t *)data) + sizeof(PVRTexHeader);
			format_ = tableFormats[tableFormatIndex_][kCCInternalCCTexture2DPixelFormat];
			bpp = tableFormats[tableFormatIndex_][kCCInternalBPP];

			// Calculate the data size for each texture level and respect the minimum number of blocks
			while (dataOffset < dataLength)
			{
				switch (formatFlags) {
					case kPVRTexturePixelTypePVRTC_2:
						blockSize = 8 * 4; // Pixel by pixel block size for 2bpp
						widthBlocks = width / 8;
						heightBlocks = height / 4;
						break;
					case kPVRTexturePixelTypePVRTC_4:
						blockSize = 4 * 4; // Pixel by pixel block size for 4bpp
						widthBlocks = width / 4;
						heightBlocks = height / 4;
						break;
					case kPVRTexturePixelTypeBGRA_8888:
						if( ! [[CCConfiguration sharedConfiguration] supportsBGRA8888] ) {
							CCLOG(@"cocos2d: TexturePVR. BGRA8888 not supported on this device");
							return FALSE;
						}
					default:
						blockSize = 1;
						widthBlocks = width;
						heightBlocks = height;
						break;
				}

				// Clamp to minimum number of blocks
				if (widthBlocks < 2)
					widthBlocks = 2;
				if (heightBlocks < 2)
					heightBlocks = 2;

				dataSize = widthBlocks * heightBlocks * ((blockSize  * bpp) / 8);
				float packetLength = (dataLength-dataOffset);
				packetLength = packetLength > dataSize ? dataSize : packetLength;

				mipmaps_[numberOfMipmaps_].address = bytes+dataOffset;
				mipmaps_[numberOfMipmaps_].len = packetLength;
				numberOfMipmaps_++;

				NSAssert( numberOfMipmaps_ < CC_PVRMIPMAP_MAX, @"TexturePVR: Maximum number of mimpaps reached. Increate the CC_PVRMIPMAP_MAX value");

				dataOffset += packetLength;

				width = MAX(width >> 1, 1);
				height = MAX(height >> 1, 1);
			}

			success = TRUE;
			break;
		}
	}

	if( ! success )
		CCLOG(@"cocos2d: WARNING: Unsupported PVR Pixel Format: 0x%2x. Re-encode it with a OpenGL pixel format variant", formatFlags);

	return success;
}


- (BOOL)createGLTexture
{
	GLsizei width = width_;
	GLsizei height = height_;
	GLenum err;

	if (numberOfMipmaps_ > 0)
	{
		if (name_ != 0)
			ccGLDeleteTexture( name_ );

		glPixelStorei(GL_UNPACK_ALIGNMENT,1);
		glGenTextures(1, &name_);
		ccGLBindTexture2D( name_ );

	}

	CHECK_GL_ERROR(); // clean possible GL error

	// Generate textures with mipmaps
	for (GLint i=0; i < numberOfMipmaps_; i++)
	{
		GLenum internalFormat = tableFormats[tableFormatIndex_][kCCInternalOpenGLInternalFormat];
		GLenum format = tableFormats[tableFormatIndex_][kCCInternalOpenGLFormat];
		GLenum type = tableFormats[tableFormatIndex_][kCCInternalOpenGLType];
		BOOL compressed = tableFormats[tableFormatIndex_][kCCInternalCompressedImage];

		if( compressed && ! [[CCConfiguration sharedConfiguration] supportsPVRTC] ) {
			CCLOG(@"cocos2d: WARNING: PVRTC images are not supported");
			return FALSE;
		}

		unsigned char *data = mipmaps_[i].address;
		unsigned int datalen = mipmaps_[i].len;

		if( compressed)
			glCompressedTexImage2D(GL_TEXTURE_2D, i, internalFormat, width, height, 0, datalen, data);
		else
			glTexImage2D(GL_TEXTURE_2D, i, internalFormat, width, height, 0, format, type, data);

		if( i > 0 && (width != height || ccNextPOT(width) != width ) )
			CCLOG(@"cocos2d: TexturePVR. WARNING. Mipmap level %u is not squared. Texture won't render correctly. width=%u != height=%u", i, width, height);

		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			CCLOG(@"cocos2d: TexturePVR: Error uploading compressed texture level: %u . glError: 0x%04X", i, err);
			return FALSE;
		}

		width = MAX(width >> 1, 1);
		height = MAX(height >> 1, 1);
	}

	return TRUE;
}


- (id)initWithContentsOfFile:(NSString *)path
{
	if((self = [super init]))
	{
		unsigned char *pvrdata = NULL;
		NSInteger pvrlen = 0;
		NSString *lowerCase = [path lowercaseString];

        if ( [lowerCase hasSuffix:@".ccz"])
			pvrlen = ccInflateCCZFile( [path UTF8String], &pvrdata );

		else if( [lowerCase hasSuffix:@".gz"] )
			pvrlen = ccInflateGZipFile( [path UTF8String], &pvrdata );

		else
			pvrlen = ccLoadFileIntoMemory( [path UTF8String], &pvrdata );

		if( pvrlen < 0 ) {
			[self release];
			return nil;
		}


        numberOfMipmaps_ = 0;

		name_ = 0;
		width_ = height_ = 0;
		tableFormatIndex_ = -1;
		hasAlpha_ = FALSE;

		retainName_ = NO; // cocos2d integration

		if( ! [self unpackPVRData:pvrdata PVRLen:pvrlen] || ![self createGLTexture]  ) {
			free(pvrdata);
			[self release];
			return nil;
		}

		free(pvrdata);
	}

	return self;
}

- (id)initWithContentsOfURL:(NSURL *)url
{
	if (![url isFileURL])
	{
		CCLOG(@"cocos2d: CCPVRTexture: Only files are supported");
		[self release];
		return nil;
	}

	return [self initWithContentsOfFile:[url path]];
}


+ (id)pvrTextureWithContentsOfFile:(NSString *)path
{
	return [[[self alloc] initWithContentsOfFile:path] autorelease];
}


+ (id)pvrTextureWithContentsOfURL:(NSURL *)url
{
	if (![url isFileURL])
		return nil;

	return [CCTexturePVR pvrTextureWithContentsOfFile:[url path]];
}


- (void)dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);

	if (name_ != 0 && ! retainName_ )
		ccGLDeleteTexture( name_ );

	[super dealloc];
}

@end

