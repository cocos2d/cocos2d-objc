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
 *  - RGB888
 *  - RGBA4444
 *  - RGBA5551
 *  - RGB565
 *  - A8
 *  - I8
 *  - AI88
 *
 * Added support for PVR v3 file format
 */

#import <zlib.h>

#import "CCTexturePVR.h"
#import "ccMacros.h"
#import "CCConfiguration.h"
#import "Support/ccUtils.h"
#import "Support/CCFileUtils.h"
#import "Support/ZipUtils.h"
#import "CCGL.h"
#import "CCRenderDispatch.h"

#pragma mark -
#pragma mark CCTexturePVR

#define PVR_TEXTURE_FLAG_TYPE_MASK	0xff

#pragma mark PVR File format - common

//
// XXX DO NO ALTER THE ORDER IN THIS LIST XXX
//
static const ccPVRTexturePixelFormatInfo PVRTableFormats[] = {

	// 0: RGBA_8888
	{GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE, 32, NO, YES, CCTexturePixelFormat_RGBA8888},
	// 1: RGBA_4444
	{GL_RGBA, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, 16, NO, YES, CCTexturePixelFormat_RGBA4444},
	// 2: RGBA_5551
	{GL_RGBA, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, 16, NO, YES, CCTexturePixelFormat_RGB5A1},
	// 3: RGB_565
	{GL_RGB, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, 16, NO, NO, CCTexturePixelFormat_RGB565},
	// 4: RGB_888
	{GL_RGB, GL_RGB, GL_UNSIGNED_BYTE, 24, NO, NO, CCTexturePixelFormat_RGB888},
	// 5: A_8
	{GL_ALPHA, GL_ALPHA, GL_UNSIGNED_BYTE, 8, NO, NO, CCTexturePixelFormat_A8},
	// 6: L_8
	{GL_LUMINANCE, GL_LUMINANCE, GL_UNSIGNED_BYTE, 8, NO, NO, CCTexturePixelFormat_I8},
	// 7: LA_88
	{GL_LUMINANCE_ALPHA, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 16, NO, YES, CCTexturePixelFormat_AI88},

	// 8: BGRA_8888
#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
	{GL_RGBA, GL_BGRA, GL_UNSIGNED_BYTE, 32, NO, YES, CCTexturePixelFormat_RGBA8888},
#endif

#if __CC_PLATFORM_IOS
	// 9: PVRTC 2BPP RGB
	{GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG, -1, -1, 2, YES, NO, CCTexturePixelFormat_PVRTC2},
	// 10: PVRTC 2BPP RGBA
	{GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG, -1, -1, 2, YES, YES, CCTexturePixelFormat_PVRTC2},
	// 11: PVRTC 4BPP RGB
	{GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, -1, -1, 4, YES, NO, CCTexturePixelFormat_PVRTC4},
	// 12: PVRTC 4BPP RGBA
	{GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG, -1, -1, 4, YES, YES, CCTexturePixelFormat_PVRTC4},
#endif // #__CC_PLATFORM_IOS
};

struct _pixel_formathash {
	uint64_t pixelFormat;
	const ccPVRTexturePixelFormatInfo * pixelFormatInfo;
};


#pragma  mark PVR File formats for v2 and v3

// Values taken from PVRTexture.h from http://www.imgtec.com
enum {
	kPVR2TextureFlagMipmap		= (1<<8),		// has mip map levels
	kPVR2TextureFlagTwiddle		= (1<<9),		// is twiddled
	kPVR2TextureFlagBumpmap		= (1<<10),		// has normals encoded for a bump map
	kPVR2TextureFlagTiling		= (1<<11),		// is bordered for tiled pvr
	kPVR2TextureFlagCubemap		= (1<<12),		// is a cubemap/skybox
	kPVR2TextureFlagFalseMipCol	= (1<<13),		// are there false coloured MIP levels
	kPVR2TextureFlagVolume		= (1<<14),		// is this a volume texture
	kPVR2TextureFlagAlpha		= (1<<15),		// v2.1 is there transparency info in the texture
	kPVR2TextureFlagVerticalFlip	= (1<<16),	// v2.1 is the texture vertically flipped
};

enum {
	kPVR3TextureFlagPremultipliedAlpha	= (1<<1)	// has premultiplied alpha
};


static char gPVRTexIdentifier[4] = "PVR!";

// v2
typedef enum
{
	kPVR2TexturePixelFormat_RGBA_4444= 0x10,
	kPVR2TexturePixelFormat_RGBA_5551,
	kPVR2TexturePixelFormat_RGBA_8888,
	kPVR2TexturePixelFormat_RGB_565,
	kPVR2TexturePixelFormat_RGB_555,				// unsupported
	kPVR2TexturePixelFormat_RGB_888,
	kPVR2TexturePixelFormat_I_8,
	kPVR2TexturePixelFormat_AI_88,
	kPVR2TexturePixelFormat_PVRTC_2BPP_RGBA,
	kPVR2TexturePixelFormat_PVRTC_4BPP_RGBA,
	kPVR2TexturePixelFormat_BGRA_8888,
	kPVR2TexturePixelFormat_A_8,
} ccPVR2TexturePixelFormat;

// v3
typedef enum {
	/* supported predefined formats */
	kPVR3TexturePixelFormat_PVRTC_2BPP_RGB = 0,
	kPVR3TexturePixelFormat_PVRTC_2BPP_RGBA = 1,
	kPVR3TexturePixelFormat_PVRTC_4BPP_RGB = 2,
	kPVR3TexturePixelFormat_PVRTC_4BPP_RGBA = 3,
	
	/* supported channel type formats */
	kPVR3TexturePixelFormat_BGRA_8888 = 0x0808080861726762,
	kPVR3TexturePixelFormat_RGBA_8888 = 0x0808080861626772,
	kPVR3TexturePixelFormat_RGBA_4444 = 0x0404040461626772,
	kPVR3TexturePixelFormat_RGBA_5551 = 0x0105050561626772,
	kPVR3TexturePixelFormat_RGB_565 = 0x0005060500626772,
	kPVR3TexturePixelFormat_RGB_888 = 0x0008080800626772,
	kPVR3TexturePixelFormat_A_8 = 0x0000000800000061,
	kPVR3TexturePixelFormat_L_8 = 0x000000080000006c,
	kPVR3TexturePixelFormat_LA_88 = 0x000008080000616c,
} ccPVR3TexturePixelFormat;

// v2
static struct _pixel_formathash v2_pixel_formathash[] = {

	{ kPVR2TexturePixelFormat_RGBA_8888,	&PVRTableFormats[0] },
	{ kPVR2TexturePixelFormat_RGBA_4444,	&PVRTableFormats[1] },
	{ kPVR2TexturePixelFormat_RGBA_5551,	&PVRTableFormats[2] },
	{ kPVR2TexturePixelFormat_RGB_565,		&PVRTableFormats[3] },
	{ kPVR2TexturePixelFormat_RGB_888,		&PVRTableFormats[4] },
	{ kPVR2TexturePixelFormat_A_8,			&PVRTableFormats[5] },
	{ kPVR2TexturePixelFormat_I_8,			&PVRTableFormats[6] },
	{ kPVR2TexturePixelFormat_AI_88,		&PVRTableFormats[7] },

#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
    { kPVR2TexturePixelFormat_BGRA_8888,	&PVRTableFormats[8] },
#endif

#if __CC_PLATFORM_IOS
	{ kPVR2TexturePixelFormat_PVRTC_2BPP_RGBA,	&PVRTableFormats[10] },
	{ kPVR2TexturePixelFormat_PVRTC_4BPP_RGBA,	&PVRTableFormats[12] },
#endif // iphone only
};

#define PVR2_MAX_TABLE_ELEMENTS (sizeof(v2_pixel_formathash) / sizeof(v2_pixel_formathash[0]))

// v3
struct _pixel_formathash v3_pixel_formathash[] = {

	{kPVR3TexturePixelFormat_RGBA_8888,	&PVRTableFormats[0] },
	{kPVR3TexturePixelFormat_RGBA_4444, &PVRTableFormats[1] },
	{kPVR3TexturePixelFormat_RGBA_5551, &PVRTableFormats[2] },
	{kPVR3TexturePixelFormat_RGB_565,	&PVRTableFormats[3] },
	{kPVR3TexturePixelFormat_RGB_888,	&PVRTableFormats[4] },
	{kPVR3TexturePixelFormat_A_8,		&PVRTableFormats[5] },
	{kPVR3TexturePixelFormat_L_8,		&PVRTableFormats[6] },
	{kPVR3TexturePixelFormat_LA_88,		&PVRTableFormats[7] },

#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
    {kPVR3TexturePixelFormat_BGRA_8888,	&PVRTableFormats[8] },
#endif

#if __CC_PLATFORM_IOS
	{kPVR3TexturePixelFormat_PVRTC_2BPP_RGB,	&PVRTableFormats[9] },
	{kPVR3TexturePixelFormat_PVRTC_2BPP_RGBA,	&PVRTableFormats[10] },
	{kPVR3TexturePixelFormat_PVRTC_4BPP_RGB,	&PVRTableFormats[11] },
	{kPVR3TexturePixelFormat_PVRTC_4BPP_RGBA,	&PVRTableFormats[12] },
#endif // #__CC_PLATFORM_IOS
};

#define PVR3_MAX_TABLE_ELEMENTS (sizeof(v3_pixel_formathash) / sizeof(v3_pixel_formathash[0]))

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
} ccPVRv2TexHeader;

typedef struct {
	uint32_t version;
	uint32_t flags;
	uint64_t pixelFormat;
	uint32_t colorSpace;
	uint32_t channelType;
	uint32_t height;
	uint32_t width;
	uint32_t depth;
	uint32_t numberOfSurfaces;
	uint32_t numberOfFaces;
	uint32_t numberOfMipmaps;
	uint32_t metadataLength;
} __attribute__((packed)) ccPVRv3TexHeader ;

@implementation CCTexturePVR
@synthesize name = _name;
@synthesize width = _width;
@synthesize height = _height;
@synthesize hasAlpha = _hasAlpha;
@synthesize hasPremultipliedAlpha = _hasPremultipliedAlpha;
@synthesize forcePremultipliedAlpha = _forcePremultipliedAlpha;
@synthesize numberOfMipmaps = _numberOfMipmaps;

// cocos2d integration
@synthesize retainName = _retainName;
@synthesize format = _format;


- (BOOL)unpackPVRv2Data:(unsigned char*)data PVRLen:(NSUInteger)len
{
	BOOL success = NO;
	ccPVRv2TexHeader *header = NULL;
	uint32_t flags, pvrTag;
	uint32_t dataLength = 0, dataOffset = 0, dataSize = 0;
	uint32_t blockSize = 0, widthBlocks = 0, heightBlocks = 0;
	uint32_t width = 0, height = 0, bpp = 4;
	uint8_t *bytes = NULL;
	uint32_t formatFlags;

	header = (ccPVRv2TexHeader *)data;

	pvrTag = CFSwapInt32LittleToHost(header->pvrTag);

	if ((uint32_t)gPVRTexIdentifier[0] != ((pvrTag >>  0) & 0xff) ||
		(uint32_t)gPVRTexIdentifier[1] != ((pvrTag >>  8) & 0xff) ||
		(uint32_t)gPVRTexIdentifier[2] != ((pvrTag >> 16) & 0xff) ||
		(uint32_t)gPVRTexIdentifier[3] != ((pvrTag >> 24) & 0xff))
	{
		return NO;
	}

	CCConfiguration *configuration = [CCConfiguration sharedConfiguration];

	flags = CFSwapInt32LittleToHost(header->flags);
	formatFlags = flags & PVR_TEXTURE_FLAG_TYPE_MASK;
	BOOL flipped = flags & kPVR2TextureFlagVerticalFlip;
	if( flipped )
		CCLOGWARN(@"cocos2d: WARNING: Image is not flipped. Regenerate it using PVRTexTool");

	if( ! [configuration supportsNPOT] &&
	   ( header->width != CCNextPOT(header->width) || header->height != CCNextPOT(header->height ) ) ) {
		CCLOGWARN(@"cocos2d: ERROR: Loding an NPOT texture (%dx%d) but is not supported on this device", header->width, header->height);
		return NO;
	}

	for( NSUInteger i=0; i < (unsigned int)PVR2_MAX_TABLE_ELEMENTS ; i++) {
		if( v2_pixel_formathash[i].pixelFormat == formatFlags ) {

			_pixelFormatInfo = v2_pixel_formathash[i].pixelFormatInfo;
			_numberOfMipmaps = 0;

			_width = width = CFSwapInt32LittleToHost(header->width);
			_height = height = CFSwapInt32LittleToHost(header->height);

			if (CFSwapInt32LittleToHost(header->bitmaskAlpha))
				_hasAlpha = YES;
			else
				_hasAlpha = NO;

			dataLength = CFSwapInt32LittleToHost(header->dataLength);
			bytes = ((uint8_t *)data) + sizeof(ccPVRv2TexHeader);
			_format = _pixelFormatInfo->ccPixelFormat;
			bpp = _pixelFormatInfo->bpp;

			// Calculate the data size for each texture level and respect the minimum number of blocks
			while (dataOffset < dataLength)
			{
				switch (formatFlags) {
					case kPVR2TexturePixelFormat_PVRTC_2BPP_RGBA:
						blockSize = 8 * 4; // Pixel by pixel block size for 2bpp
						widthBlocks = width / 8;
						heightBlocks = height / 4;
						break;
					case kPVR2TexturePixelFormat_PVRTC_4BPP_RGBA:
						blockSize = 4 * 4; // Pixel by pixel block size for 4bpp
						widthBlocks = width / 4;
						heightBlocks = height / 4;
						break;
					case kPVR2TexturePixelFormat_BGRA_8888:
						if( ! [[CCConfiguration sharedConfiguration] supportsBGRA8888] ) {
							CCLOG(@"cocos2d: TexturePVR. BGRA8888 not supported on this device");
							return NO;
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
				unsigned int packetLength = (dataLength-dataOffset);
				packetLength = packetLength > dataSize ? dataSize : packetLength;

				_mipmaps[_numberOfMipmaps].address = bytes+dataOffset;
				_mipmaps[_numberOfMipmaps].len = packetLength;
				_numberOfMipmaps++;

				NSAssert( _numberOfMipmaps < CC_PVRMIPMAP_MAX, @"TexturePVR: Maximum number of mimpaps reached. Increate the CC_PVRMIPMAP_MAX value");

				dataOffset += packetLength;

				width = MAX(width >> 1, 1);
				height = MAX(height >> 1, 1);
			}

			success = YES;
			break;
		}
	}

	if( ! success )
		CCLOGWARN(@"cocos2d: WARNING: Unsupported PVR Pixel Format: 0x%2x. Re-encode it with a OpenGL pixel format variant", formatFlags);

	return success;
}

- (BOOL)unpackPVRv3Data:(unsigned char*)dataPointer PVRLen:(NSUInteger)dataLength
{
	if(dataLength < sizeof(ccPVRv3TexHeader)) {
		return NO;
	}
	
	ccPVRv3TexHeader *header = (ccPVRv3TexHeader *)dataPointer;
	
	// validate version
	if(CFSwapInt32BigToHost(header->version) != 0x50565203) {
		CCLOG(@"cocos2d: WARNING: pvr file version mismatch");
		return NO;
	}
	
	// parse pixel format
	uint64_t pixelFormat = header->pixelFormat;

	
	BOOL infoValid = NO;
	
	for(int i = 0; i < PVR3_MAX_TABLE_ELEMENTS; i++) {
		if( v3_pixel_formathash[i].pixelFormat == pixelFormat ) {
			_pixelFormatInfo = v3_pixel_formathash[i].pixelFormatInfo;
			_hasAlpha = _pixelFormatInfo->alpha;
			infoValid = YES;
			break;
		}
	}
	
	// unsupported / bad pixel format
	if(!infoValid) {
		CCLOG(@"cocos2d: WARNING: unsupported pvr pixelformat: %llx", pixelFormat );
		return NO;
	}
	
	// flags
	uint32_t flags = CFSwapInt32LittleToHost(header->flags);
	
	// PVRv3 specifies premultiply alpha in a flag -- should always respect this in PVRv3 files
	_forcePremultipliedAlpha = YES;
	if(flags & kPVR3TextureFlagPremultipliedAlpha) {
		_hasPremultipliedAlpha = YES;
	}
	
	// sizing
	uint32_t width = CFSwapInt32LittleToHost(header->width);
	uint32_t height = CFSwapInt32LittleToHost(header->height);
	_width = width;
	_height = height;
	uint32_t dataOffset = 0, dataSize = 0;
	uint32_t blockSize = 0, widthBlocks = 0, heightBlocks = 0;
	uint8_t *bytes = NULL;
	
	dataOffset = (sizeof(ccPVRv3TexHeader) + header->metadataLength);
	bytes = dataPointer;
	
	_numberOfMipmaps = header->numberOfMipmaps;
	NSAssert( _numberOfMipmaps < CC_PVRMIPMAP_MAX, @"TexturePVR: Maximum number of mimpaps reached. Increate the CC_PVRMIPMAP_MAX value");

	for(int i = 0; i < _numberOfMipmaps; i++) {
		
		switch(pixelFormat) {
			case kPVR3TexturePixelFormat_PVRTC_2BPP_RGB :
			case kPVR3TexturePixelFormat_PVRTC_2BPP_RGBA :
				blockSize = 8 * 4; // Pixel by pixel block size for 2bpp
				widthBlocks = width / 8;
				heightBlocks = height / 4;
				break;
			case kPVR3TexturePixelFormat_PVRTC_4BPP_RGB :
			case kPVR3TexturePixelFormat_PVRTC_4BPP_RGBA :
				blockSize = 4 * 4; // Pixel by pixel block size for 4bpp
				widthBlocks = width / 4;
				heightBlocks = height / 4;
				break;
			case kPVR3TexturePixelFormat_BGRA_8888:
				if( ! [[CCConfiguration sharedConfiguration] supportsBGRA8888] ) {
					CCLOG(@"cocos2d: TexturePVR. BGRA8888 not supported on this device");
					return NO;
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
		
		dataSize = widthBlocks * heightBlocks * ((blockSize  * _pixelFormatInfo->bpp) / 8);
		unsigned int packetLength = ((unsigned int)dataLength-dataOffset);
		packetLength = packetLength > dataSize ? dataSize : packetLength;
		
		_mipmaps[i].address = bytes+dataOffset;
		_mipmaps[i].len = packetLength;
		
		dataOffset += packetLength;
		NSAssert( dataOffset <= dataLength, @"CCTexurePVR: Invalid length");
		
		
		width = MAX(width >> 1, 1);
		height = MAX(height >> 1, 1);
	}
	
	return YES;
}


- (BOOL)createGLTexture
{
	NSAssert([CCConfiguration sharedConfiguration].graphicsAPI == CCGraphicsAPIGL, @"PVR textures are not yet supported by Metal.");
	__block BOOL retVal = NO;
	
CCRenderDispatch(NO, ^{
	GLsizei width = _width;
	GLsizei height = _height;
	GLenum err;

	if (_numberOfMipmaps > 0)
	{
		if (_name != 0)
			glDeleteTextures(1, &_name);

		// From PVR sources: "PVR files are never row aligned."
		glPixelStorei(GL_UNPACK_ALIGNMENT,1);

		glGenTextures(1, &_name);
		glBindTexture(GL_TEXTURE_2D, _name);

		// Default: Anti alias.
		if( _numberOfMipmaps == 1 )
			glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
		else
			glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
		
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
	}
	
	CC_CHECK_GL_ERROR_DEBUG(); // clean possible GL error

	GLenum internalFormat = _pixelFormatInfo->internalFormat;
	GLenum format = _pixelFormatInfo->format;
	GLenum type = _pixelFormatInfo->type;
	BOOL compressed = _pixelFormatInfo->compressed;

	// Generate textures with mipmaps
	for (GLint i=0; i < _numberOfMipmaps; i++)
	{
		if( compressed && ! [[CCConfiguration sharedConfiguration] supportsPVRTC] ) {
			CCLOGWARN(@"cocos2d: WARNING: PVRTC images are not supported");
			retVal = NO; return;
		}

		unsigned char *data = _mipmaps[i].address;
		GLsizei datalen = _mipmaps[i].len;

		if( compressed)
			glCompressedTexImage2D(GL_TEXTURE_2D, i, internalFormat, width, height, 0, datalen, data);
		else
			glTexImage2D(GL_TEXTURE_2D, i, internalFormat, width, height, 0, format, type, data);

		if( i > 0 && (width != height || CCNextPOT(width) != width ) )
			CCLOGWARN(@"cocos2d: TexturePVR. WARNING. Mipmap level %u is not squared. Texture won't render correctly. width=%u != height=%u", i, width, height);

		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			CCLOGWARN(@"cocos2d: TexturePVR: Error uploading compressed texture level: %u . glError: 0x%04X", i, err);
			retVal = NO; return;
		}

		width = MAX(width >> 1, 1);
		height = MAX(height >> 1, 1);
	}
	
	retVal = YES; return;
});
	
	return retVal;
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
			return nil;
		}


        _numberOfMipmaps = 0;

		_name = 0;
		_width = _height = 0;
		_hasAlpha = NO;
		_hasPremultipliedAlpha = NO;
		_forcePremultipliedAlpha = NO;
		_pixelFormatInfo = NULL;

		_retainName = NO; // cocos2d integration
		
		
		if( ! (([self unpackPVRv2Data:pvrdata PVRLen:pvrlen] || [self unpackPVRv3Data:pvrdata PVRLen:pvrlen]) &&
		   [self createGLTexture] ) )
		{
			free(pvrdata);
			return nil;
		}
		
#if __CC_PLATFORM_IOS && defined(DEBUG)
		GLenum pixelFormat = _pixelFormatInfo->ccPixelFormat;
		CCConfiguration *conf = [CCConfiguration sharedConfiguration];
		
		if( [conf OSVersion] >= CCSystemVersion_iOS_5_0 )
		{
			
			// iOS 5 BUG:
			// RGB888 textures allocate much more memory than needed on iOS 5
			// http://www.cocos2d-iphone.org/forum/topic/31092
			
			if( pixelFormat == CCTexturePixelFormat_RGB888 ) {
				printf("\n");
				NSLog(@"cocos2d: WARNING. Using RGB888 texture. Convert it to RGB565 or RGBA8888 in order to reduce memory");
				NSLog(@"cocos2d: WARNING: File: %@", [path lastPathComponent] );
				NSLog(@"cocos2d: WARNING: For further info visit: http://www.cocos2d-iphone.org/forum/topic/31092");
				printf("\n");
			}

			
			else if( _width != CCNextPOT(_width) ) {
				
				// XXX: Is this applicable for compressed textures ?
				// Since they are squared and POT (PVRv2) it is not an issue now. Not sure in the future.
				
				// iOS 5 BUG:
				// If width is not word aligned, then log warning.
				// http://www.cocos2d-iphone.org/forum/topic/31092
				

				NSUInteger bpp = [CCTexture bitsPerPixelForFormat:pixelFormat];
				NSUInteger bytes = _width * bpp / 8;

				// XXX: Should it be 4 or sizeof(int) ??
				NSUInteger mod = bytes % 4;
				
				// Not word aligned ?
				if( mod != 0 ) {

					NSUInteger neededBytes = (4 - mod ) / (bpp/8);
					printf("\n");
					NSLog(@"cocos2d: WARNING. Current texture size=(%d,%d). Convert it to size=(%d,%d) in order to save memory", _width, _height, (unsigned int)(_width + neededBytes), _height );
					NSLog(@"cocos2d: WARNING: File: %@", [path lastPathComponent] );
					NSLog(@"cocos2d: WARNING: For further info visit: http://www.cocos2d-iphone.org/forum/topic/31092");
					printf("\n");
				}
			}
		}
#endif // iOS
		


		free(pvrdata);
	}

	return self;
}

- (id)initWithContentsOfURL:(NSURL *)url
{
	if (![url isFileURL])
	{
		CCLOG(@"cocos2d: CCPVRTexture: Only files are supported");
		return nil;
	}

	return [self initWithContentsOfFile:[url path]];
}


+ (id)pvrTextureWithContentsOfFile:(NSString *)path
{
	return [[self alloc] initWithContentsOfFile:path];
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
	
	if(_name != 0 && ! _retainName){
		GLuint name = _name;
		CCRenderDispatch(YES, ^{glDeleteTextures(1, &name);});
	}
}

@end

