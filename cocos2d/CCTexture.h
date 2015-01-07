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


#import "ccTypes.h"

#import "Platforms/CCGL.h"


@class CCSpriteFrame;
@class CCFile;
@class CCImage;


/**
 The type of a texture. (2D or cubemap).
 */
typedef NS_ENUM(NSUInteger, CCTextureType){
/**
 A regular rectangular texture.
 */
CCTextureType2D,
/**
 A cubemap texture for use with CCEffects, Cocos3D or custom shaders.
 */
CCTextureTypeCubemap,
};


/**
 Texture filtering types to use with CCTextureOptionMinificationFilter, CCTextureOptionMagnificationFilter, and CCTextureOptionMipmapFilter.
 */
typedef NS_ENUM(NSUInteger, CCTextureFilter){
    /**
     Disable mipmapping. Can only be used with CCTextureOptionMipmapFilter
     */
    CCTextureFilterMipmapNone,
    /**
     "blocky" texture interpolation. Suitable for working with pixel art for instance.
     */
    CCTextureFilterNearest,
    /**
     Smooth texture interpolation. This is the default value.
     */
    CCTextureFilterLinear,
};


/**
 Addressing modes used with CCTextureOptionAddressModeX and CCTextureOptionAddressModeY.
 This mostly affects pixels near the edge of the texture or coordinates outside of the texture's bounds.
 */
typedef NS_ENUM(NSUInteger, CCTextureAddressMode){
    /**
     Clamp colors to the edge pixel values. This will produce a smearing effect when you sample outside of the texture bounds.
     */
    CCTextureAddressModeClampToEdge,
    /**
     Make a texture repeat, or wrap around at the edges.
     */
    CCTextureAddressModeRepeat,
    /**
     Make a texture repeat, but mirror every other copy.
     */
    CCTextureAddressModeRepeatMirrorred,
};


/**
 Generate mipmaps for a texture after loading it.
 This will use more memory, but can have performance and quality benefits for downscaled textures.
 Defaults to NO.
 */
extern NSString * const CCTextureOptionGenerateMipmaps;
/**
 What filtering mode to use when scaling a texture down.
 Defaults to CCTextureFilterLinear.
 */
extern NSString * const CCTextureOptionMinificationFilter;
/**
 What filtering mode to use when scaling a texture up.
 Defaults to CCTextureFilterLinear.
 */
extern NSString * const CCTextureOptionMagnificationFilter;
/**
 What filter mode to apply to blend mipmaps together.
 Defaults to CCTextureFilterMipmapNone.
 */
extern NSString * const CCTextureOptionMipmapFilter;
/**
 What addressing mode to use in the horizontal direction.
 Defaults to CCTextureAddressModeClampToEdge.
 */
extern NSString * const CCTextureOptionAddressModeX;
/**
 What addressing mode to use in the vertical direction.
 Defaults to CCTextureAddressModeClampToEdge.
 */
extern NSString * const CCTextureOptionAddressModeY;


/**
 Textures are image buffers that the GPU reads from when drawing to the screen.
 */
@interface CCTexture : NSObject
{
    @private
    CGSize _sizeInPixels;
    CGSize _contentSize;
    CCTextureType _type;
    
    // Deprecated
	BOOL _premultipliedAlpha;
	BOOL _hasMipmaps;
    BOOL _antialiased;
}

/**
 Create a texture from a CCImage.

 @param image   The image to create the texture from.
 @param options A dictionary using the CCTextureOption* keys to specify how the texture should be set up.

 @return A texture with the contents of the image, or nil if there was an error.
 */
-(instancetype)initWithImage:(CCImage *)image options:(NSDictionary *)options;

/**
 Create a cached texture from an image on disk.
 
 This is the recommended method to load textures for two main reasons. Textures take a long time to load and can use a lot of memory.
 The cache ensures that you don't waste time loading textures multiple times, or waste memory on duplicates.
 The cache is flushed automatically when your app receives a memory warning.
 
 Textures loaded with this method will use the current value of [CCTexture defaultOptions].

 @param file The filename to be loaded. File type is detected automatically. (png, pvr, jpeg, etc)

 @return A texture with the contents of the file, or nil if there was an error.
 */
+(instancetype)textureWithFile:(NSString*)file;

/**
 An options dictionary that will be passed to [CCFileUtils fileNamed:options:], [CCImage initWithfile:options:], and [CCTexture initWithImage:options:].
 @return The current value of the default options dictionary.
 */
+(NSDictionary *)defaultOptions;

/**
 When loading cached textures, several methods take configurable options. [CCFileUtils fileNamed:options:], [CCImage initWithfile:options:], and [CCTexture initWithImage:options:].
 You can configure Cocos2D's default texture loading by overriding this value.
 For instance, you may want to force all textures to use nearest filtering in a pixel art game, or always enable mipmapping.
 
 The default value is normally nil unless set by the user. This means that all methods will fall back on their defaults.

 @param options A dictionary with a set of options that you want to override.
 */
+(void)setDefaultOptions:(NSDictionary *)options;

/**
 A placeholder value used to signal "no texture".
 This texture object will have a size of 0, and will show up as black if you attempt to use it.

 @return An empty texture.
 */
+(instancetype)none;

/**
 Type of the texture. (2D or Cubemap)
 */
@property(nonatomic, readonly) CCTextureType type;

/**
 Size of the texture in pixels.
 */
@property(nonatomic, readonly) CGSize sizeInPixels;

/**
 Content scale of the texture.
 */
@property(nonatomic, readwrite) CGFloat contentScale;

/**
 Content size of the texture.
 This may not be sizeInPixels/contentSize. A texture might be padded to a size that is a power of two on some Android hardware.
 */
@property(nonatomic, readonly) CGSize contentSize;

/**
 Does the texture have power of two dimensions?
 */
@property(nonatomic, readonly) BOOL isPOT;

/**
 A sprite frame that covers the whole texture.
 */
@property(nonatomic, readonly) CCSpriteFrame *spriteFrame;

@end


@interface CCTexture(PVR)

/**
 Load a texture from a PVR file.
 
 PVR files have some advantages. They load very quickly since they have a very simple format and can be loaded directly into video memory.
 They can also save disk space and memory since they support hardware specific formats such as 16 bit per pixel modes, and compressed texture modes.
 They can also load cubemaps from a single file, or contain the full set of mipmaps for a texture without needing to generate them at loading time.
 
 NOTE: Keep in mind that Mac and Android don't support PVR files with a PVRTC format and that Metal currently only supports the RGBA888 format.

 @param file    A PVR file.
 @param options A dictionary using the CCTextureOption* keys to specify how the texture should be set up. The generate mipmaps option is ignored if the PVR file contains mipmaps.

 @return A texture with the contents of the file, or nil if there was an error.
 */
-(instancetype)initPVRWithCCFile:(CCFile *)file options:(NSDictionary *)options;

@end


@interface CCTexture(Cubemap)

/**
 Load a cubemap texture from 6 images for the faces. This is primarily useful for making effect shaders.

 @param posX    An image for the right side of the cube.
 @param negX    An image for the left side of the cube.
 @param posY    An image for the top side of the cube.
 @param negY    An image for the bottom side of the cube.
 @param posZ    An image for the front side of the cube.
 @param negZ    An image for the back side of the cube.
 @param options A dictionary using the CCTextureOption* keys to specify how the texture should be set up. Addressing modes generally do nothing for cubemap textures.

 @return A cubemap texture with the contents of the images, or nil if there was an error.
 */
-(instancetype)initCubemapFromImagesPosX:(CCImage *)posX negX:(CCImage *)negX
                                    posY:(CCImage *)posY negY:(CCImage *)negY
                                    posZ:(CCImage *)posZ negZ:(CCImage *)negZ
                                    options:(NSDictionary *)options;

/**
 Load a cubemap texture from 6 image files for the faces. This is primarily useful for making effect shaders.

 @param posXFilePath An image file for the right side of the cube.
 @param negXFilePath An image file for the left side of the cube.
 @param posYFilePath An image file for the top side of the cube.
 @param negYFilePath An image file for the bottom side of the cube.
 @param posZFilePath An image file for the front side of the cube.
 @param negZFilePath An image file for the back side of the cube.
 @param options A dictionary using the CCTextureOption* keys to specify how the texture should be set up. Addressing modes generally do nothing for cubemap textures.

 @return A cubemap texture with the contents of the image files, or nil if there was an error.
 */
-(instancetype)initCubemapFromFilesPosX:(NSString *)posXFilePath negX:(NSString *)negXFilePath
                                   posY:(NSString *)posYFilePath negY:(NSString *)negYFilePath
                                   posZ:(NSString *)posZFilePath negZ:(NSString *)negZFilePath
                                   options:(NSDictionary *)options;

/**
 Load a cubemap texture from 6 image files for the faces. The filenames are found using a format string.
 
 For instance you would use @"Skybox%@.png" if you had the following files:
 SkyboxPosX.png
 SkyboxNegX.png
 ...
 SkyboxPosZ.png

 @param aFilePathPattern The format string to use as a pattern. %@ will be replaced with "PosX", "NegZ", etc.
 @param options A dictionary using the CCTextureOption* keys to specify how the texture should be set up. Addressing modes generally do nothing for cubemap textures.

 @return A cubemap texture with the contents of the image files, or nil if there was an error.
 */
-(instancetype)initCubemapFromFilePattern:(NSString *)aFilePathPattern options:(NSDictionary *)options;

@end
