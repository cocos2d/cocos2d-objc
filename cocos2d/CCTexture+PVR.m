#import "CCTexture+PVR.h"
#import "ccMacros.h"
#import "CCDeviceInfo.h"
#import "Support/ccUtils.h"
#import "CCGL.h"
#import "CCRenderDispatch.h"

#import "CCFile_Private.h"
#import "CCTexture_Private.h"

#pragma mark -
#pragma mark CCTexturePVR

#define PVR_TEXTURE_FLAG_TYPE_MASK	0xff

#pragma mark PVR File format - common

typedef struct _ccPVRTexturePixelFormatInfo {
	GLenum internalFormat;
	GLenum format;
	GLenum type;
	uint32_t bpp;
    uint32_t minWidth, minHeight;
	BOOL compressed;
	BOOL alpha;
} ccPVRTexturePixelFormatInfo;

//
// XXX DO NO ALTER THE ORDER IN THIS LIST XXX
//
static const ccPVRTexturePixelFormatInfo PVRTableFormats[] = {

	// 0: RGBA_8888
	{GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE, 32, 1, 1, NO, YES},
	// 1: RGBA_4444
	{GL_RGBA, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, 16, 1, 1, NO, YES},
	// 2: RGBA_5551
	{GL_RGBA, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, 16, 1, 1, NO, YES},
	// 3: RGB_565
	{GL_RGB, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, 16, 1, 1, NO, NO},
	// 4: RGB_888
	{GL_RGB, GL_RGB, GL_UNSIGNED_BYTE, 24, 1, 1, NO, NO},
	// 5: A_8
	{GL_ALPHA, GL_ALPHA, GL_UNSIGNED_BYTE, 8, 1, 1, NO, NO},
	// 6: L_8
	{GL_LUMINANCE, GL_LUMINANCE, GL_UNSIGNED_BYTE, 8, 1, 1, NO, NO},
	// 7: LA_88
	{GL_LUMINANCE_ALPHA, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 16, 1, 1, NO, YES},

	// 8: BGRA_8888
#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
	{GL_RGBA, GL_BGRA, GL_UNSIGNED_BYTE, 32, 1, 1, NO, YES},
#endif

#if __CC_PLATFORM_IOS
	// 9: PVRTC 2BPP RGB
	{GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG, -1, -1, 2, 16, 8, YES, NO},
	// 10: PVRTC 2BPP RGBA
	{GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG, -1, -1, 2, 16, 8, YES, YES},
	// 11: PVRTC 4BPP RGB
	{GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, -1, -1, 4, 8, 8, YES, NO},
	// 12: PVRTC 4BPP RGBA
	{GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG, -1, -1, 4, 8, 8, YES, YES},
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

@implementation CCTexture(PVR)

-(const ccPVRTexturePixelFormatInfo *)readPVRv2Header:(NSInputStream *)stream
{
    struct {
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
        char pvrTag[4];
        uint32_t numSurfs;
    } __attribute__((packed)) header = {};
    
    // Read the header from the stream.
    NSInteger bytesRead = [stream read:(void *)&header maxLength:sizeof(header)];
    NSAssert(bytesRead == sizeof(header), @"Error: Could not read PVR file header.");
    
    // Check the magic number
	if(memcmp(header.pvrTag, "PVR!", 4) != 0){
		return nil;
	}

	uint32_t flags = CFSwapInt32LittleToHost(header.flags);
	uint32_t formatFlags = flags & PVR_TEXTURE_FLAG_TYPE_MASK;

    _sizeInPixels = CGSizeMake(CFSwapInt32LittleToHost(header.width), CFSwapInt32LittleToHost(header.height));
    
	if(![[CCDeviceInfo sharedDeviceInfo] supportsNPOT] && !CCSizeIsPOT(_sizeInPixels)){
		CCLOGWARN(@"cocos2d: ERROR: Loding an NPOT texture (%dx%d) but is not supported on this device", (int)_sizeInPixels.width, (int)_sizeInPixels.height);
		return nil;
	}
    
	for(NSUInteger i=0; i < PVR2_MAX_TABLE_ELEMENTS; i++){
		if(v2_pixel_formathash[i].pixelFormat == formatFlags){
			return v2_pixel_formathash[i].pixelFormatInfo;
		}
	}

	CCLOGWARN(@"cocos2d: WARNING: Unsupported PVR Pixel Format: 0x%2x. Re-encode it with a OpenGL pixel format variant", formatFlags);
	return nil;
}

- (const ccPVRTexturePixelFormatInfo *)readPVRv3Header:(NSInputStream *)stream
{
	struct {
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
    } __attribute__((packed)) header = {};
    NSUInteger bytesRead = [stream read:(void *)&header maxLength:sizeof(header)];
    NSAssert(bytesRead == sizeof(header), @"Error: Could not read PVR file header.");
    
    _sizeInPixels = CGSizeMake(CFSwapInt32LittleToHost(header.width), CFSwapInt32LittleToHost(header.height));
    
    if(header.numberOfFaces == 6){
        _type = CCTextureTypeCube;
    }

	if(![[CCDeviceInfo sharedDeviceInfo] supportsNPOT] && !CCSizeIsPOT(_sizeInPixels)){
		CCLOGWARN(@"cocos2d: ERROR: Loding an NPOT texture (%dx%d) but is not supported on this device", (int)_sizeInPixels.width, (int)_sizeInPixels.height);
		return nil;
	}
    
	uint64_t pixelFormat = header.pixelFormat;
	for(int i = 0; i < PVR3_MAX_TABLE_ELEMENTS; i++) {
		if(v3_pixel_formathash[i].pixelFormat == pixelFormat){
			return v3_pixel_formathash[i].pixelFormatInfo;
		}
	}
    
	CCLOGWARN(@"cocos2d: WARNING: Unsupported PVR Pixel Format: Re-encode it with a OpenGL pixel format variant");
	return nil;
}

// A hack to work around the deprecated .ccz file headers.
static NSInputStream *
OpenPVRStream(CCFile *file)
{
    if([file.url.lastPathComponent hasSuffix:@".ccz"]){
        NSInputStream *stream = [file openInputStream];
        
        // .ccz files are just deflated data with an extra header that we want to skip.
        uint8_t header[16];
        [stream read:header maxLength:sizeof(header)];
        
        // Now wrap the stream in a gzip stream so the rest of the data can be read.
        return [[CCGZippedInputStream alloc]initWithInputStream:stream];
    } else {
        return [file openInputStream];
    }
}

-(NSInputStream *)readPVRHeader:(CCFile *)file format:(const ccPVRTexturePixelFormatInfo **)format
{
    NSInputStream *stream = OpenPVRStream(file);
    
    // Check if the file is a PVRv3 file.
    char magicNumber[4] = {};
    [stream read:(void *)&magicNumber maxLength:4];
    
    if(memcmp(magicNumber, "PVR\x03", 4) == 0){
        *format = [self readPVRv3Header:stream];
    } else {
        CCLOG(@"PVRv2 files are deprecated. You should update to PVRv3 files if possible.");
        
        // PVRv2 files don't use a magic number at the file's beginning so we need to reset the stream.
        [stream close];
        stream = OpenPVRStream(file);
        
        *format = [self readPVRv2Header:stream];
    }
    
    // Close the stream if there was an error.
    if(*format == NULL){
        [stream close];
    }
    
    return stream;
}

// Block invoked after each surface from a PVR file is loaded.
typedef void (^CCPVRSurfaceBlock)(GLenum target, NSUInteger mipmap, NSUInteger width, NSUInteger height, NSData *data);

static NSUInteger
GetDataLength(const ccPVRTexturePixelFormatInfo *format, NSUInteger w, NSUInteger h)
{
    // Size of compressed textures need to be padded.
    if(format->compressed){
        // I grabbed this code from the PVR SDK, but it doesn't really seem correct... It rounds down?
        w += (-w)%format->minWidth;
        h += (-h)%format->minHeight;
    }
    
    return (w*h*format->bpp)/8;
}



-(void)loadFaces
{
//#define GL_TEXTURE_CUBE_MAP_POSITIVE_X                   0x8515
//#define GL_TEXTURE_CUBE_MAP_NEGATIVE_X                   0x8516
//#define GL_TEXTURE_CUBE_MAP_POSITIVE_Y                   0x8517
//#define GL_TEXTURE_CUBE_MAP_NEGATIVE_Y                   0x8518
//#define GL_TEXTURE_CUBE_MAP_POSITIVE_Z                   0x8519
//#define GL_TEXTURE_CUBE_MAP_NEGATIVE_Z                   0x851A
    
}

-(void)readTextureData:(NSInputStream *)stream format:(const ccPVRTexturePixelFormatInfo *)format block:(CCPVRSurfaceBlock)block
{
    CGSize size = self.sizeInPixels;
    NSUInteger width = size.width;
    NSUInteger height = size.height;
    
    NSMutableData *data = [NSMutableData dataWithLength:GetDataLength(format, width, height)];
    
    int miplevel = 0;
    for(;;){
        NSUInteger w = MAX(1, width>>miplevel);
        NSUInteger h = MAX(1, height>>miplevel);
        
        NSUInteger dataLength = GetDataLength(format, w, h);
        NSInteger bytesRead = [stream read:data.mutableBytes maxLength:dataLength];
        data.length = bytesRead;
        
        // Ran out of data.
        // This seems like it might be an error, but the PVR reference implementation handles it this way. (shrug)
        if(bytesRead == 0) break;
        
        switch(self.type){
            case CCTextureType2D:
                block(GL_TEXTURE_2D, miplevel, w, h, data);
                break;
            default: break;
        }
        
        // We've hit the smallest mipmap.
        if(w == 1 && h == 1) break;
        
        miplevel++;
    }
}

-(id)initPVRWithCCFile:(CCFile *)file options:(NSDictionary *)options
{
    options = [CCTexture normalizeOptions:options];
    
    CCDeviceInfo *info = [CCDeviceInfo sharedDeviceInfo];
	NSAssert(info.graphicsAPI != CCGraphicsAPIInvalid, @"Graphics API not configured.");
	
//    NSUInteger maxTextureSize = [info maxTextureSize];
//    CGSize sizeInPixels = image.sizeInPixels;
//    
//    if(sizeInPixels.width > maxTextureSize || sizeInPixels.height > maxTextureSize){
//        CCLOGWARN(@"cocos2d: Error: Image (%d x %d) is bigger than the maximum supported texture size %d",
//            (int)sizeInPixels.width, (int)sizeInPixels.height, (int)maxTextureSize
//        );
//        
//        return nil;
//    }
//    
//    if(!CCSizeIsPOT(sizeInPixels) && !info.supportsNPOT){
//        CCLOGWARN(@"cocos2d: Error: This device requires power of two sized textures.");
//        
//        return nil;
//    }
    
	if((self = [super init])) {
        const ccPVRTexturePixelFormatInfo *format = NULL;
        NSInputStream *stream = [self readPVRHeader:file format:&format];
        
#if __CC_METAL_SUPPORTED_AND_ENABLED
        // TODO
#endif
		CCRenderDispatch(NO, ^{
            CCGL_DEBUG_PUSH_GROUP_MARKER("CCTexture: Init");
            
            [self setupTextureWithSizeInPixels:self.sizeInPixels options:options];
            
            [self readTextureData:stream format:format block:^(GLenum target, NSUInteger mipmap, NSUInteger width, NSUInteger height, NSData *data){
                if(format->compressed){
                    glCompressedTexImage2D(target, (GLint)mipmap, format->internalFormat, (GLint)width, (GLint)height, 0, (GLsizei)data.length, data.bytes);
                } else {
                    glTexImage2D(target, (GLint)mipmap, format->internalFormat, (GLint)width, (GLint)height, 0, format->format, format->type, data.bytes);
                }
            }];
            
            // Generate mipmaps.
            if([options[CCTextureOptionGenerateMipmaps] boolValue]){
                glGenerateMipmap(GL_TEXTURE_2D);
            }
            
            CCGL_DEBUG_POP_GROUP_MARKER();
		});
        
        self.contentScale = file.contentScale;
        _contentSize = CC_SIZE_SCALE(self.sizeInPixels, 1.0/self.contentScale);
    }
    
	return self;
}

@end

