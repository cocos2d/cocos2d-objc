#import "CCTexture_Private.h"

#import "ccMacros.h"
#import "CCDeviceInfo.h"
#import "ccUtils.h"
#import "CCGL.h"
#import "CCRenderDispatch.h"

#import "CCFile_Private.h"
#import "CCMetalSupport_Private.h"


#pragma mark -
#pragma mark CCTexturePVR

#define PVR_TEXTURE_FLAG_TYPE_MASK	0xff

#pragma mark PVR File format - common

struct PVRTexturePixelFormatInfo {
	GLenum internalFormat;
	GLenum format;
	GLenum type;
	uint32_t bpp;
    uint32_t minWidth, minHeight;
	BOOL compressed;
	BOOL alpha;
};

//
// XXX DO NO ALTER THE ORDER IN THIS LIST XXX
//
static const struct PVRTexturePixelFormatInfo PVRTableFormats[] = {
	{GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE, 32, 1, 1, NO, YES},
	{GL_RGBA, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, 16, 1, 1, NO, YES},
	{GL_RGBA, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, 16, 1, 1, NO, YES},
	{GL_RGB, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, 16, 1, 1, NO, NO},
	{GL_RGB, GL_RGB, GL_UNSIGNED_BYTE, 24, 1, 1, NO, NO},
	{GL_ALPHA, GL_ALPHA, GL_UNSIGNED_BYTE, 8, 1, 1, NO, NO},
	{GL_LUMINANCE, GL_LUMINANCE, GL_UNSIGNED_BYTE, 8, 1, 1, NO, NO},
	{GL_LUMINANCE_ALPHA, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 16, 1, 1, NO, YES},

#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
	{GL_RGBA, GL_BGRA, GL_UNSIGNED_BYTE, 32, 1, 1, NO, YES},
#endif

#if __CC_PLATFORM_IOS
	{GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG, -1, -1, 2, 16, 8, YES, NO},
	{GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG, -1, -1, 2, 16, 8, YES, YES},
	{GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, -1, -1, 4, 8, 8, YES, NO},
	{GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG, -1, -1, 4, 8, 8, YES, YES},
#endif
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
    
	kPVR3TextureFlagPremultipliedAlpha	= (1<<1)	// has premultiplied alpha
};

enum
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
    
	kPVR3TexturePixelFormat_BGRA_8888 = 0x0808080861726762,
	kPVR3TexturePixelFormat_RGBA_8888 = 0x0808080861626772,
	kPVR3TexturePixelFormat_RGBA_4444 = 0x0404040461626772,
	kPVR3TexturePixelFormat_RGBA_5551 = 0x0105050561626772,
	kPVR3TexturePixelFormat_RGB_565 = 0x0005060500626772,
	kPVR3TexturePixelFormat_RGB_888 = 0x0008080800626772,
	kPVR3TexturePixelFormat_A_8 = 0x0000000800000061,
	kPVR3TexturePixelFormat_L_8 = 0x000000080000006c,
	kPVR3TexturePixelFormat_LA_88 = 0x000008080000616c,
    
	kPVR3TexturePixelFormat_PVRTC_2BPP_RGB = 0,
	kPVR3TexturePixelFormat_PVRTC_2BPP_RGBA = 1,
	kPVR3TexturePixelFormat_PVRTC_4BPP_RGB = 2,
	kPVR3TexturePixelFormat_PVRTC_4BPP_RGBA = 3,
};

struct PVRFormatEntry {
	uint64_t pixelFormatV2, pixelFormatV3;
	const struct PVRTexturePixelFormatInfo *pixelFormatInfo;
};

static struct PVRFormatEntry PVRFormats[] = {

	{kPVR2TexturePixelFormat_RGBA_8888, kPVR3TexturePixelFormat_RGBA_8888, &PVRTableFormats[0]},
	{kPVR2TexturePixelFormat_RGBA_4444, kPVR3TexturePixelFormat_RGBA_4444, &PVRTableFormats[1]},
	{kPVR2TexturePixelFormat_RGBA_5551, kPVR3TexturePixelFormat_RGBA_5551, &PVRTableFormats[2]},
	{kPVR2TexturePixelFormat_RGB_565,   kPVR3TexturePixelFormat_RGB_565,   &PVRTableFormats[3]},
	{kPVR2TexturePixelFormat_RGB_888,   kPVR3TexturePixelFormat_RGB_888,   &PVRTableFormats[4]},
	{kPVR2TexturePixelFormat_A_8,       kPVR3TexturePixelFormat_A_8,       &PVRTableFormats[5]},
	{kPVR2TexturePixelFormat_I_8,       kPVR3TexturePixelFormat_L_8,       &PVRTableFormats[6]},
	{kPVR2TexturePixelFormat_AI_88,     kPVR3TexturePixelFormat_LA_88,     &PVRTableFormats[7]},

#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
    {kPVR2TexturePixelFormat_BGRA_8888, kPVR3TexturePixelFormat_BGRA_8888, &PVRTableFormats[8]},
#endif

#if __CC_PLATFORM_IOS
	{~(uint64_t)0,                            kPVR3TexturePixelFormat_PVRTC_2BPP_RGB,  &PVRTableFormats[ 9]},
	{kPVR2TexturePixelFormat_PVRTC_2BPP_RGBA, kPVR3TexturePixelFormat_PVRTC_2BPP_RGBA, &PVRTableFormats[10]},
	{~(uint64_t)0,                            kPVR3TexturePixelFormat_PVRTC_4BPP_RGB,  &PVRTableFormats[11]},
	{kPVR2TexturePixelFormat_PVRTC_4BPP_RGBA, kPVR3TexturePixelFormat_PVRTC_4BPP_RGBA, &PVRTableFormats[12]},
#endif
};

#define PVRFormatCount (sizeof(PVRFormats) / sizeof(*PVRFormats))

@implementation CCTexture(PVR)

struct PVRInfo {
    const struct PVRTexturePixelFormatInfo *format;
    CGSize size;
    NSUInteger mipmapCount;
    CCTextureType type;
};

static struct PVRInfo
ReadPVRv2Header(NSInputStream *stream, NSError **error)
{
    struct PVRInfo info = {};
    
    struct {
        uint32_t headerLength;
        uint32_t height;
        uint32_t width;
        uint32_t mipcount;
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
    
    if(bytesRead != sizeof(header)){
        *error = [[NSError alloc] initWithDomain:@"PVR Error" code:-1 userInfo:@{
            NSLocalizedDescriptionKey: @"Could not read PVRv2 file header.",
        }];
        
        return (struct PVRInfo){};
    }
    
    // Check the magic number
	if(memcmp(header.pvrTag, "PVR!", 4) != 0){
        *error = [[NSError alloc] initWithDomain:@"PVR Error" code:-2 userInfo:@{
            NSLocalizedDescriptionKey: @"Not a PVRv2 file.",
        }];
        
        return (struct PVRInfo){};
	}

	uint32_t flags = CFSwapInt32LittleToHost(header.flags);
	uint32_t formatFlags = flags & PVR_TEXTURE_FLAG_TYPE_MASK;

    info.size = CGSizeMake(CFSwapInt32LittleToHost(header.width), CFSwapInt32LittleToHost(header.height));
    info.mipmapCount = header.mipcount + 1;
    
	for(NSUInteger i=0; i < PVRFormatCount; i++){
		if(PVRFormats[i].pixelFormatV2 == formatFlags){
			info.format = PVRFormats[i].pixelFormatInfo;
            return info;
		}
	}
    
    // Failed to find a supported pixel format.
    *error = [[NSError alloc] initWithDomain:@"PVR Error" code:-3 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Unsupported PVR Pixel Format: 0x%04x", (unsigned int)info.format]
    }];
    
    return (struct PVRInfo){};
}

static struct PVRInfo
ReadPVRv3Header(NSInputStream *stream, NSError **error)
{
    struct PVRInfo info = {};
    
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
    
    // Read the header from the stream.
    NSUInteger bytesRead = [stream read:(void *)&header maxLength:sizeof(header)];
    
    if(bytesRead != sizeof(header)){
        *error = [[NSError alloc] initWithDomain:@"PVR Error" code:-1 userInfo:@{
            NSLocalizedDescriptionKey: @"Could not read PVRv3 file header.",
        }];
        
        return (struct PVRInfo){};
    }
    
    info.size = CGSizeMake(CFSwapInt32LittleToHost(header.width), CFSwapInt32LittleToHost(header.height));
    info.mipmapCount = header.numberOfMipmaps;
    
    if(header.numberOfFaces == 6){
        info.type = CCTextureTypeCubemap;
    }

    // Skip past the metadata.
    if(header.metadataLength){
        void *metadata = malloc(header.metadataLength);
        [stream read:metadata maxLength:header.metadataLength];
        free(metadata);
    }
    
	uint64_t pixelFormat = header.pixelFormat;
	for(int i = 0; i < PVRFormatCount; i++) {
		if(PVRFormats[i].pixelFormatV3 == pixelFormat){
			info.format = PVRFormats[i].pixelFormatInfo;
            return info;
		}
	}
    
    // Failed to find a supported pixel format.
    *error = [[NSError alloc] initWithDomain:@"PVR Error" code:-3 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Unsupported PVR Pixel Format: 0x%04x", (unsigned int)info.format]
    }];
    
    return (struct PVRInfo){};
}

// A hack to work around the deprecated .ccz file headers.
static NSInputStream *
OpenPVRStream(CCFile *file)
{
    if([file.url.lastPathComponent hasSuffix:@".ccz"]){
        CCLOGWARN(@".ccz files are deprecated. It's recommended to use gzip for compression instead.");
        
        NSInputStream *stream = [file openInputStream];
        
        // .ccz files are just deflated data with an underutilized header that we want to skip.
        uint8_t header[16];
        [stream read:header maxLength:sizeof(header)];
        
        // Now wrap the stream in a gzip stream so the rest of the data can be read.
        return [[CCGZippedInputStream alloc]initWithInputStream:stream];
    } else {
        return [file openInputStream];
    }
}

-(NSInputStream *)readPVRHeader:(CCFile *)file info:(struct PVRInfo *)info error:(NSError **)error
{
    NSInputStream *stream = OpenPVRStream(file);
    
    // Check if the file is a PVRv3 file.
    char magicNumber[4] = {};
    [stream read:(void *)&magicNumber maxLength:4];
    
    if(memcmp(magicNumber, "PVR\x03", 4) == 0){
        *info = ReadPVRv3Header(stream, error);
    } else {
        CCLOG(@"PVRv2 files are deprecated. You should update to PVRv3 files if possible.");
        
        // PVRv2 files don't use a magic number at the file's beginning so we need to reset the stream.
        [stream close];
        stream = OpenPVRStream(file);
        
        *info = ReadPVRv2Header(stream, error);
    }
    
    if(*error){
        CCLOGWARN(@"PVR Error: %@", *error);
        [stream close];
    }
    
    return stream;
}

// Block invoked after each surface from a PVR file is loaded.
typedef void (^PVRDataBlock)(GLenum target, NSUInteger mipmap, NSUInteger width, NSUInteger height, NSData *data);

static NSUInteger
GetDataLength(const struct PVRTexturePixelFormatInfo *format, NSUInteger w, NSUInteger h)
{
    // I grabbed this code from the PVR SDK.
    // It pads the size of compressed textures to a multiple of their minimum width.
    if(format->compressed){
        w += (-w)%format->minWidth;
        h += (-h)%format->minHeight;
    }
    
    return (w*h*format->bpp)/8;
}

static void
ReadPVRData(NSInputStream *stream, struct PVRInfo info, PVRDataBlock block)
{
    NSUInteger width = info.size.width;
    NSUInteger height = info.size.height;
    
    NSMutableData *data = [NSMutableData dataWithLength:GetDataLength(info.format, width, height)];
    
    for(int miplevel = 0; miplevel < info.mipmapCount; miplevel++){
        NSUInteger w = MAX(1, width>>miplevel);
        NSUInteger h = MAX(1, height>>miplevel);
        
        NSUInteger dataLength = GetDataLength(info.format, w, h);
        
        switch(info.type){
            case CCTextureType2D:
                data.length = [stream read:data.mutableBytes maxLength:dataLength];
                block(GL_TEXTURE_2D, miplevel, w, h, data);
                break;
            case CCTextureTypeCubemap:
                data.length = [stream read:data.mutableBytes maxLength:dataLength];
                block(GL_TEXTURE_CUBE_MAP_POSITIVE_X, miplevel, w, h, data);
                data.length = [stream read:data.mutableBytes maxLength:dataLength];
                block(GL_TEXTURE_CUBE_MAP_NEGATIVE_X, miplevel, w, h, data);
                data.length = [stream read:data.mutableBytes maxLength:dataLength];
                block(GL_TEXTURE_CUBE_MAP_POSITIVE_Y, miplevel, w, h, data);
                data.length = [stream read:data.mutableBytes maxLength:dataLength];
                block(GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, miplevel, w, h, data);
                data.length = [stream read:data.mutableBytes maxLength:dataLength];
                block(GL_TEXTURE_CUBE_MAP_POSITIVE_Z, miplevel, w, h, data);
                data.length = [stream read:data.mutableBytes maxLength:dataLength];
                block(GL_TEXTURE_CUBE_MAP_NEGATIVE_Z, miplevel, w, h, data);
            default: break;
        }
    }
}

-(id)initPVRWithCCFile:(CCFile *)file options:(NSDictionary *)options
{
    options = [CCTexture normalizeOptions:options];
    
    NSError *error = nil;
    struct PVRInfo info = {};
    NSInputStream *stream = [self readPVRHeader:file info:&info error:&error];
    
    CCDeviceInfo *device = [CCDeviceInfo sharedDeviceInfo];
    NSUInteger maxTextureSize = [device maxTextureSize];
    
    if(info.size.width > maxTextureSize || info.size.height > maxTextureSize){
        CCLOGWARN(@"PVR file (%d x %d) is bigger than the maximum supported texture size %d",
            (int)info.size.width, (int)info.size.height, (int)maxTextureSize
        );
        
        [stream close];
        return nil;
    }
    
    if(!CCSizeIsPOT(info.size) && !device.supportsNPOT){
        CCLOGWARN(@"This device does not support NPOT textures.");
        
        [stream close];
        return nil;
    }
    
	if((self = [super init])) {
		CCRenderDispatch(NO, ^{
            [self setupTexture:info.type rendertexture:NO sizeInPixels:info.size options:options];
            
#if __CC_METAL_SUPPORTED_AND_ENABLED
            if([CCDeviceInfo sharedDeviceInfo].graphicsAPI == CCGraphicsAPIMetal){
                // TODO add support for PVRTC
                NSAssert(info.format == &PVRTableFormats[0], @"Metal only supports RGBA8 PVR files.");
                
                ReadPVRData(stream, info, ^(GLenum target, NSUInteger miplevel, NSUInteger width, NSUInteger height, NSData *data){
                    CGSize size = CGSizeMake(width, height);
                    const void *pixelData = data.bytes;
                    
                    if(target == GL_TEXTURE_2D){
                        [self _uploadTexture2D:size miplevel:miplevel pixelData:pixelData];
                    } else {
                        [self _uploadTextureCubeFace:target - GL_TEXTURE_CUBE_MAP_POSITIVE_X sizeInPixels:size miplevel:miplevel pixelData:pixelData];
                    }
                });
                
            } else
#endif
            {
                const struct PVRTexturePixelFormatInfo *format = info.format;
                ReadPVRData(stream, info, ^(GLenum target, NSUInteger mipmap, NSUInteger width, NSUInteger height, NSData *data){
                    if(format->compressed){
                        glCompressedTexImage2D(target, (GLint)mipmap, format->internalFormat, (GLint)width, (GLint)height, 0, (GLsizei)data.length, data.bytes);
                    } else {
                        glTexImage2D(target, (GLint)mipmap, format->internalFormat, (GLint)width, (GLint)height, 0, format->format, format->type, data.bytes);
                    }
                });
            }
            
            // Generate mipmaps only if the file did not contain any.
            if([options[CCTextureOptionGenerateMipmaps] boolValue] && info.mipmapCount == 1){
                [self _generateMipmaps:info.type];
            }
		});
        
        _sizeInPixels = info.size;
        _type = info.type;
        self.contentScale = file.contentScale;
        _contentSize = CC_SIZE_SCALE(info.size, 1.0/file.contentScale);
    }
    
    [stream close];
	return self;
}

@end
