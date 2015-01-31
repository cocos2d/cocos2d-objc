/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2014 Cocos2D Authors
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
 */


#import "Platforms/CCNS.h"

#import "CCTexture.h"
#import "ccConfig.h"
#import "ccMacros.h"
#import "CCDeviceInfo.h"
#import "CCShader.h"
#import "CCDirector.h"
#import "CCRenderDispatch.h"
#import "CCImage_Private.h"

#import "Support/ccUtils.h"
#import "Support/CCFileUtils.h"

#import "CCTexture_Private.h"
#import "CCTextureCache.h"
#import "CCSpriteFrame.h"
#import "CCDeprecated.h"

#if __CC_METAL_SUPPORTED_AND_ENABLED
#import "CCMetalSupport_Private.h"
#endif


NSString * const CCTextureOptionGenerateMipmaps = @"CCTextureOptionGenerateMipmaps";
NSString * const CCTextureOptionMinificationFilter = @"CCTextureOptionMinificationFilter";
NSString * const CCTextureOptionMagnificationFilter = @"CCTextureOptionMagnificationFilter";
NSString * const CCTextureOptionMipmapFilter = @"CCTextureOptionMipmapFilter";
NSString * const CCTextureOptionAddressModeX = @"CCTextureOptionAddressModeX";
NSString * const CCTextureOptionAddressModeY = @"CCTextureOptionAddressModeY";


//CLASS IMPLEMENTATIONS:

// This class implements what will hopefully be a temporary replacement
// for the retainCount trick used to figure out which cached objects are safe to purge.
@implementation CCProxy
{
    id _target;
}

- (id)initWithTarget:(id)target
{
    if ((self = [super init]))
    {
        _target = target;
    }
    
    return(self);
}

// Forward class checks for assertions.
-(BOOL)isKindOfClass:(Class)aClass {return [_target isKindOfClass:aClass];}

// Make concrete implementations for CCTexture methods commonly called at runtime.
-(GLuint)name {return [(CCTextureGL *)_target name];}
-(CGFloat)contentScale {return [(CCTexture *)_target contentScale];}
-(CGSize)contentSize {return [_target contentSize];}
-(NSUInteger)pixelWidth {return [_target pixelWidth];}
-(NSUInteger)pixelHeight {return [_target pixelHeight];}
-(BOOL)hasPremultipliedAlpha {return [_target hasPremultipliedAlpha];}
-(CCSpriteFrame *)spriteFrame {return [_target spriteFrame];}

// Make concrete implementations for CCSpriteFrame methods commonly called at runtime.
-(CGRect)rect {return [_target rect];}
-(CGPoint)offset {return [(CCSpriteFrame *)_target offset];}
-(BOOL)rotated {return [_target rotated];}
-(CGSize)originalSize {return [_target originalSize];}
-(CCTexture *)texture {return [_target texture];}

// Let the rest fall back to a slow forwarded path.
- (id)forwardingTargetForSelector:(SEL)aSelector
{
//    CCLOGINFO(@"Forwarding selector [%@ %@]", NSStringFromClass([_target class]), NSStringFromSelector(aSelector));
//		CCLOGINFO(@"If there are many of these calls, we should add concrete forwarding methods. (TODO remove logging before release)");
    return(_target);
}

- (void)dealloc
{
		CCLOGINFO(@"Proxy for %p deallocated.", _target);
}

@end


#pragma mark -
#pragma mark CCTexture2D - Main

@implementation CCTexture
{
	CCProxy __weak *_proxy;
}

static NSDictionary *NORMALIZED_OPTIONS = nil;

static CCTexture *CCTextureNone = nil;

+(void)initialize
{
	// +initialize may be called due to loading a subclass.
	if(self != [CCTexture class]) return;
    
    NORMALIZED_OPTIONS = @{
        CCTextureOptionGenerateMipmaps: @(NO),
        CCTextureOptionMinificationFilter: @(CCTextureFilterLinear),
        CCTextureOptionMagnificationFilter: @(CCTextureFilterLinear),
        CCTextureOptionMipmapFilter: @(CCTextureFilterMipmapNone),
        CCTextureOptionAddressModeX: @(CCTextureAddressModeClampToEdge),
        CCTextureOptionAddressModeY: @(CCTextureAddressModeClampToEdge),
    };
	
	CCTextureNone = [self alloc];
	CCTextureNone->_contentScale = 1.0;
	
#if __CC_METAL_SUPPORTED_AND_ENABLED
	if([CCDeviceInfo sharedDeviceInfo].graphicsAPI == CCGraphicsAPIMetal){
		CCMetalContext *context = [CCMetalContext currentContext];
		NSAssert(context, @"Metal context is nil.");
		
		((CCTextureMetal *)CCTextureNone)->_metalSampler = [context.device newSamplerStateWithDescriptor:[MTLSamplerDescriptor new]];
		
		MTLTextureDescriptor *textureDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm width:1 height:1 mipmapped:NO];
		((CCTextureMetal *)CCTextureNone)->_metalTexture = [context.device newTextureWithDescriptor:textureDesc];
	}
#endif
}

+(instancetype)none
{
	return CCTextureNone;
}

static NSDictionary *_DEFAULT_OPTIONS = nil;

+ (id) textureWithFile:(NSString*)file
{
    return [[CCTextureCache sharedTextureCache] addImage:file];
}

+(NSDictionary *)defaultOptions
{
    return _DEFAULT_OPTIONS;
}

+(void)setDefaultOptions:(NSDictionary *)options
{
    _DEFAULT_OPTIONS = options;
}

+(NSDictionary *)normalizeOptions:(NSDictionary *)options
{
    if(options == nil || options == NORMALIZED_OPTIONS){
        return NORMALIZED_OPTIONS;
    } else {
        // Merge the default values with the user values.
        NSMutableDictionary *opts = [NORMALIZED_OPTIONS mutableCopy];
        [opts addEntriesFromDictionary:options];
        
        return opts;
    }
}

//MARK: Abstract methods.
static void Abstract(){NSCAssert(NO, @"Abstract method. Must be overridden by subclasses.");}

-(void)_setupTexture:(CCTextureType)type rendertexture:(BOOL)renderTexture sizeInPixels:(CGSize)sizeInPixels mipmapped:(BOOL)mipmapped;
{
    Abstract();
}

-(void)_setupSampler:(CCTextureType)type
    minFilter:(CCTextureFilter)minFilter magFilter:(CCTextureFilter)magFilter mipFilter:(CCTextureFilter)mipFilter
    addressX:(CCTextureAddressMode)addressX addressY:(CCTextureAddressMode)addressY
{
    Abstract();
}

-(void)_uploadTexture2D:(CGSize)sizeInPixels miplevel:(NSUInteger)miplevel pixelData:(const void *)pixelData
{
    Abstract();
}

// Faces are in the same order as GL/Metal (+x, -x, +y, -y, +z, -z)
-(void)_uploadTextureCubeFace:(NSUInteger)face sizeInPixels:(CGSize)sizeInPixels miplevel:(NSUInteger)miplevel pixelData:(const void *)pixelData
{
    Abstract();
}

-(void)_generateMipmaps:(CCTextureType)type
{
    Abstract();
}

//MARK: Setup/Init methods.

-(void)setupTexture:(CCTextureType)type rendertexture:(BOOL)rendertexture sizeInPixels:(CGSize)sizeInPixels options:(NSDictionary *)options;
{
    BOOL genMipmaps = [options[CCTextureOptionGenerateMipmaps] boolValue];
    
    CCTextureFilter minFilter = [options[CCTextureOptionMinificationFilter] unsignedIntegerValue];
    CCTextureFilter magFilter = [options[CCTextureOptionMagnificationFilter] unsignedIntegerValue];
    CCTextureFilter mipFilter = [options[CCTextureOptionMipmapFilter] unsignedIntegerValue];
    
    NSAssert(minFilter != CCTextureFilterMipmapNone, @"CCTextureFilterMipmapNone can only be used with CCTextureOptionMipmapFilter.");
    NSAssert(magFilter != CCTextureFilterMipmapNone, @"CCTextureFilterMipmapNone can only be used with CCTextureOptionMipmapFilter.");
    NSAssert(mipFilter == CCTextureFilterMipmapNone || genMipmaps, @"CCTextureOptionMipmapFilter must be CCTextureFilterMipmapNone unless CCTextureOptionGenerateMipmaps is YES");
    
    CCTextureAddressMode addressX = [options[CCTextureOptionAddressModeX] unsignedIntegerValue];
    CCTextureAddressMode addressY = [options[CCTextureOptionAddressModeY] unsignedIntegerValue];
    
    BOOL isPOT = CCSizeIsPOT(sizeInPixels);
    NSAssert(addressX == CCTextureAddressModeClampToEdge || isPOT, @"Only CCTextureAddressModeClampToEdge can be used with non power of two sized textures.");
    NSAssert(addressY == CCTextureAddressModeClampToEdge || isPOT, @"Only CCTextureAddressModeClampToEdge can be used with non power of two sized textures.");
    
    [self _setupTexture:type rendertexture:rendertexture sizeInPixels:sizeInPixels mipmapped:genMipmaps];
    [self _setupSampler:type minFilter:minFilter magFilter:magFilter mipFilter:mipFilter addressX:addressX addressY:addressY];
}

-(instancetype)initWithImage:(CCImage *)image options:(NSDictionary *)options;
{
    return [self initWithImage:image options:options rendertexture:NO];
}

-(instancetype)initWithImage:(CCImage *)image options:(NSDictionary *)options rendertexture:(BOOL)rendertexture;
{
    options = [CCTexture normalizeOptions:options];
    
    CCDeviceInfo *info = [CCDeviceInfo sharedDeviceInfo];
	NSAssert(info.graphicsAPI != CCGraphicsAPIInvalid, @"Graphics API not configured.");
	
    NSUInteger maxTextureSize = [info maxTextureSize];
    CGSize sizeInPixels = image.sizeInPixels;
    
    if(sizeInPixels.width > maxTextureSize || sizeInPixels.height > maxTextureSize){
        CCLOGWARN(@"cocos2d: Error: Image (%d x %d) is bigger than the maximum supported texture size %d",
            (int)sizeInPixels.width, (int)sizeInPixels.height, (int)maxTextureSize
        );
        
        return nil;
    }
    
    if(!CCSizeIsPOT(sizeInPixels) && !info.supportsNPOT){
        CCLOGWARN(@"cocos2d: Error: This device requires power of two sized textures.");
        
        return nil;
    }
    
	if((self = [super init])) {
		CCRenderDispatch(NO, ^{
            [self setupTexture:CCTextureType2D rendertexture:rendertexture sizeInPixels:sizeInPixels options:options];
            
            [self _uploadTexture2D:sizeInPixels miplevel:0 pixelData:image.pixelData.bytes];
            
            if([options[CCTextureOptionGenerateMipmaps] boolValue]){
                [self _generateMipmaps:CCTextureType2D];
            }
		});
        
        _sizeInPixels = sizeInPixels;
        _contentScale = image.contentScale;
        _contentSize = image.contentSize;
    }
    
	return self;
}

// -------------------------------------------------------------

- (BOOL)hasProxy
{
    @synchronized(self)
    {
        // NSLog(@"hasProxy: %p", self);
        return(_proxy != nil);
    }
}

- (CCProxy *)proxy
{
    @synchronized(self)
    {
        __strong CCProxy *proxy = _proxy;

        if (_proxy == nil)
        {
            proxy = [[CCProxy alloc] initWithTarget:self];
            _proxy = proxy;
        }
    
        return(proxy);
    }
}

// -------------------------------------------------------------

// TODO should move this to the Metal/GL impls.
- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Dimensions = %lux%lu pixels >",
        [self class], self, (unsigned long)_sizeInPixels.width, (unsigned long)_sizeInPixels.height];
}

-(CCSpriteFrame*)spriteFrame
{
	CGRect rectInPixels = {CGPointZero, _sizeInPixels};
	return [CCSpriteFrame frameWithTexture:(CCTexture *)self.proxy rectInPixels:rectInPixels rotated:NO offset:CGPointZero originalSize:_sizeInPixels];
}

@end


@implementation CCTexture(Cubemap)

-(instancetype)initCubemapFromImagesPosX:(CCImage *)posX negX:(CCImage *)negX
                                    posY:(CCImage *)posY negY:(CCImage *)negY
                                    posZ:(CCImage *)posZ negZ:(CCImage *)negZ
                                    options:(NSDictionary *)options;
{
    options = [CCTexture normalizeOptions:options];
    
    CCDeviceInfo *info = [CCDeviceInfo sharedDeviceInfo];
	NSAssert(info.graphicsAPI != CCGraphicsAPIInvalid, @"Graphics API not configured.");
	
    NSUInteger maxTextureSize = [info maxTextureSize];
    CGSize sizeInPixels = posX.sizeInPixels;
    
    if(sizeInPixels.width > maxTextureSize || sizeInPixels.height > maxTextureSize){
        CCLOGWARN(@"cocos2d: Error: Image (%d x %d) is bigger than the maximum supported texture size %d",
            (int)sizeInPixels.width, (int)sizeInPixels.height, (int)maxTextureSize
        );
        
        return nil;
    }
    
    if(!CCSizeIsPOT(sizeInPixels) && !info.supportsNPOT){
        CCLOGWARN(@"cocos2d: Error: This device requires power of two sized textures.");
        
        return nil;
    }
    
	if((self = [super init])) {
		CCRenderDispatch(NO, ^{
            [self setupTexture:CCTextureTypeCubemap rendertexture:NO sizeInPixels:sizeInPixels options:options];
            
            [self _uploadTextureCubeFace:0 sizeInPixels:sizeInPixels miplevel:0 pixelData:posX.pixelData.bytes];
            [self _uploadTextureCubeFace:1 sizeInPixels:sizeInPixels miplevel:0 pixelData:negX.pixelData.bytes];
            [self _uploadTextureCubeFace:2 sizeInPixels:sizeInPixels miplevel:0 pixelData:posY.pixelData.bytes];
            [self _uploadTextureCubeFace:3 sizeInPixels:sizeInPixels miplevel:0 pixelData:negY.pixelData.bytes];
            [self _uploadTextureCubeFace:4 sizeInPixels:sizeInPixels miplevel:0 pixelData:posZ.pixelData.bytes];
            [self _uploadTextureCubeFace:5 sizeInPixels:sizeInPixels miplevel:0 pixelData:negZ.pixelData.bytes];
            
            // Generate mipmaps.
            if([options[CCTextureOptionGenerateMipmaps] boolValue]){
                [self _generateMipmaps:CCTextureTypeCubemap];
            }
		});
        
        _type = CCTextureTypeCubemap;
        _sizeInPixels = sizeInPixels;
        _contentScale = posX.contentScale;
        _contentSize = posX.contentSize;
    }
    
	return self;
}

-(instancetype)initCubemapFromFilesPosX:(NSString *)posXFilePath negX:(NSString *)negXFilePath
                                   posY:(NSString *)posYFilePath negY:(NSString *)negYFilePath
                                   posZ:(NSString *)posZFilePath negZ:(NSString *)negZFilePath
                                   options:(NSDictionary *)options;
{
    NSMutableDictionary *opts = [options mutableCopy];
    opts[CCImageOptionFlipVertical] = @(YES);
    
    return [self initCubemapFromImagesPosX:[[CCImage alloc] initWithCCFile:[CCFileUtils fileNamed:posXFilePath] options:opts]
        negX:[[CCImage alloc] initWithCCFile:[CCFileUtils fileNamed:negXFilePath] options:opts]
        posY:[[CCImage alloc] initWithCCFile:[CCFileUtils fileNamed:posYFilePath] options:opts]
        negY:[[CCImage alloc] initWithCCFile:[CCFileUtils fileNamed:negYFilePath] options:opts]
        posZ:[[CCImage alloc] initWithCCFile:[CCFileUtils fileNamed:posZFilePath] options:opts]
        negZ:[[CCImage alloc] initWithCCFile:[CCFileUtils fileNamed:negZFilePath] options:opts]
        options:opts
    ];
}

-(instancetype)initCubemapFromFilePattern:(NSString *)aFilePathPattern options:(NSDictionary *)options;
{
	return [self initCubemapFromFilesPosX:[NSString stringWithFormat: aFilePathPattern, @"PosX"]
        negX:[NSString stringWithFormat:aFilePathPattern, @"NegX"]
        posY:[NSString stringWithFormat:aFilePathPattern, @"PosY"]
        negY:[NSString stringWithFormat:aFilePathPattern, @"NegY"]
        posZ:[NSString stringWithFormat:aFilePathPattern, @"PosZ"]
        negZ:[NSString stringWithFormat:aFilePathPattern, @"NegZ"]
        options:options
    ];
}

@end
