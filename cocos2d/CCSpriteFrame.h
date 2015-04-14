/*
 * Cocos2D-SpriteBuilder: http://cocos2d.spritebuilder.com
 *
 * Copyright (c) 2008-2011 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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
 *
 */


#import "ccTypes.h"


@class CCTexture;


/** 
 A CCSpriteFrame contains the texture and rectangle of the texture to be used by a CCSprite.

 You can easily modify the sprite frame of a CCSprite using the following handy method:

    CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:@"jump.png"];
    [sprite setSpriteFrame:frame];
 */

@class CCProxy;

@interface CCSpriteFrame : NSObject <NSCopying>

/// -----------------------------------------------------------------------
/// @name Creating a Sprite Frame
/// -----------------------------------------------------------------------

/**
 *  Create and return a sprite frame object from the specified image name.  On first attempt it will check the internal texture/frame cache
 *  and if not available will then try and create the frame from an image file of the same name.
 *
 *  @param imageName Image name.
 *
 *  @return The CCSpriteFrame Object.
 */
+(instancetype) frameWithImageNamed:(NSString*)imageName;

/**
 *  Initializes and returns a sprite frame object from the specified texture, texture rectangle, rotation status, offset and originalSize values.
 *
 *  @param texture Texture to use.
 *  @param rectInPixels Texture rectangle (in pixels) to use.
 *  @param rotated Is rectangle rotated?
 *  @param trimOffsetInPixels Offset (in pixels) to use.
 *  @param untrimmedSizeInPixels Original size (in pixels) before being trimmed.
 *
 *  @return An initialized CCSpriteFrame Object.
 *  @see CCTexture
 */
-(instancetype)initWithTexture:(CCTexture*)texture rectInPixels:(CGRect)rectInPixels rotated:(BOOL)rotated trimOffsetInPixels:(CGPoint)trimOffsetInPixels untrimmedSizeInPixels:(CGSize)untrimmedSizeInPixels;

/**
 *  Initializes and returns a sprite frame object from the specified texture file name, texture rectangle, rotation status, offset and originalSize values.
 *
 *  @param filename Image file name to use.
 *  @param rectInPixels Texture rectangle (in pixels) to use.
 *  @param rotated Is rectangle rotated?
 *  @param trimOffsetInPixels Offset (in pixels) to use.
 *  @param untrimmedSizeInPixels Original size (in pixels) before being trimmed.
 *
 *  @return An initialized CCSpriteFrame Object.
 */
-(instancetype)initWithTextureFilename:(NSString*)filename rectInPixels:(CGRect)rectInPixels rotated:(BOOL)rotated trimOffsetInPixels:(CGPoint)trimOffsetInPixels untrimmedSizeInPixels:(CGSize)untrimmedSizeInPixels;

/// -----------------------------------------------------------------------
/// @name Sprite Frame Properties
/// -----------------------------------------------------------------------

/** Rectangle of the frame within the texture, in points. */
@property (nonatomic, readonly) CGRect rect;

/** If YES, the frame rectangle is rotated. */
@property (nonatomic, readonly) BOOL rotated;

/** To save space in a spritesheet, the transparent edges of a frame may be trimmed. This is the original size in points of a frame before it was trimmed. */
@property (nonatomic, readonly) CGSize untrimmedSize;

/** To save space in a spritesheet, the transparent edges of a frame may be trimmed. This is offset of the sprite caused by trimming in points. */
@property (nonatomic, readonly) CGPoint trimOffset;

/// -----------------------------------------------------------------------
/// @name Texture Properties
/// -----------------------------------------------------------------------

/** Texture used by the frame.
 @see CCTexture */
@property (nonatomic, strong, readonly) CCTexture *texture;

/** Texture image file name used to create the texture. */
@property (nonatomic, strong, readonly) NSString *textureFilename;

/**
 Purge all unused spriteframes from the cache.

 @since 4.0.0
 */
+(void)purgeCache;

@end

