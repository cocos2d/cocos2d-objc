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
@class CCImage;


@class CCShader;

/**
 Represents a texture, an in-memory representation of an image in a compatible format the graphics processor can process.
 
 Allows to create OpenGL textures from image files, text (font rendering) and raw data.

 @note Be aware that the content of the generated texture will be upside-down! This is an OpenGL oddity.
 */
@interface CCTexture : NSObject

/// -----------------------------------------------------------------------
/// @name Creating a Texture
/// -----------------------------------------------------------------------

-(instancetype)initWithImage:(CCImage *)image options:(NSDictionary *)options;

/**
 *  Creates and returns a new texture, based on the specified image file path.
 *
 *  If the texture has already been loaded, and resides in the internal cache, the previously created texture is returned from the cache.
 *  While this is fast, it still has an overhead compared to manually caching textures in an ivar or property.
 *
 *  @param file File path to load (should not include any suffixes).
 *
 *  @return The CCTexture object.
 */
+(instancetype)textureWithFile:(NSString*)file;

/** A placeholder value for a blank sizeless texture.
 @return An empty texture. */
+(instancetype)none;

/// -------------------------------------------------------
/// @name Creating a Sprite Frame
/// -------------------------------------------------------

-(CCSpriteFrame*)createSpriteFrame;

@property(nonatomic, readonly) CGSize sizeInPixels;
@property(nonatomic, readwrite) CGFloat contentScale;
@property(nonatomic, readonly) CGSize contentSize;

/// -------------------------------------------------------
/// @name Texture Settings
/// -------------------------------------------------------

@end
