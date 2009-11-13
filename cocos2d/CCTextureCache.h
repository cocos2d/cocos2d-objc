/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <Foundation/Foundation.h>

#import "CCTexture2D.h"

/** Singleton that handles the loading of textures
 * Once the texture is loaded, the next time it will return
 * a reference of the previously loaded texture reducing GPU & CPU memory
 */
@interface CCTextureCache : NSObject
{
	NSMutableDictionary *textures;
	NSLock				*dictLock;
	NSLock				*contextLock;
}

/** Retruns ths shared instance of the cache */
+ (CCTextureCache *) sharedTextureCache;

/** purges the cache. It releases the retained instance.
 @since v0.9.0
 */
+(void)purgeSharedTextureCache;


/** Returns a Texture2D object given an file image
 * If the file image was not previously loaded, it will create a new Texture2D
 *  object and it will return it.
 * Otherwise it will return a reference of a previosly loaded image.
 * Supported image extensions: .png, .bmp, .tiff, .jpeg, .pvr, .gif
 */
-(CCTexture2D*) addImage: (NSString*) fileimage;

/** Returns a Texture2D object given an file image
 * If the file image was not previously loaded, it will create a new Texture2D object and it will return it.
 * Otherwise it will load a texture in a new thread, and when the image is loaded, the callback will be called with the Texture2D as a parameter.
 * The callback will be called from the main thread, so it is safe to create any cocos2d object from the callback.
 * Supported image extensions: .png, .bmp, .tiff, .jpeg, .pvr, .gif
 * @since v0.8
 */
-(void) addImageAsync:(NSString*) filename target:(id)target selector:(SEL)selector;

/** Returns a Texture2D object given an PVRTC RAW filename
 * If the file image was not previously loaded, it will create a new Texture2D
 *  object and it will return it. Otherwise it will return a reference of a previosly loaded image
 *
 * It can only load square images: width == height, and it must be a power of 2 (128,256,512...)
 * bpp can only be 2 or 4. 2 means more compression but lower quality.
 * hasAlpha: whether or not the image contains alpha channel
 */
-(CCTexture2D*) addPVRTCImage: (NSString*) fileimage bpp:(int)bpp hasAlpha:(BOOL)alpha width:(int)w;

/** Returns a Texture2D object given an PVRTC filename
 * If the file image was not previously loaded, it will create a new Texture2D
 *  object and it will return it. Otherwise it will return a reference of a previosly loaded image
 */
-(CCTexture2D*) addPVRTCImage: (NSString*) filename;

/** Returns a Texture2D object given an CGImageRef image
 * If the image was not previously loaded, it will create a new Texture2D object and it will return it.
 * Otherwise it will return a reference of a previously loaded image
 * The "key" parameter will be used as the "key" for the cache.
 * @since v0.8
 */
-(CCTexture2D*) addCGImage: (CGImageRef) image forKey: (NSString *)key;

/** Purges the dictionary of loaded textures.
 * Call this method if you receive the "Memory Warning"
 * In the short term: it will free some resources preventing your app from being killed
 * In the medium term: it will allocate more resources
 * In the long term: it will be the same
 */
-(void) removeAllTextures;

/** Removes unused textures
 * Textures that have a retain count of 1 will be deleted
 * It is convinient to call this method after when starting a new Scene
 * @since v0.8
 */
-(void) removeUnusedTextures;

/** Deletes a texture from the cache
 */
-(void) removeTexture: (CCTexture2D*) tex;
@end
