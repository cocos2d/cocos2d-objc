/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
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

#import <Foundation/Foundation.h>
#import "CCNode.h"
#import "CCProtocols.h"

/** 
 A CCSpriteFrame contains the texture and rectangle of the texture to be used by a CCSprite.

 You can easily modify the sprite frame of a CCSprite using the following handy method:

 CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:@"jump.png"];
 [sprite setSpriteFrame:frame];
 */

@class CCProxy;

@interface CCSpriteFrame : NSObject <NSCopying>

/// -----------------------------------------------------------------------
/// @name Accessing Sprite Frame Attributes
/// -----------------------------------------------------------------------

/** Rectangle of the frame in points. If it is updated, then rectInPixels will also be updated. */
@property (nonatomic, readonly) CGRect rect;

/** Is the frame rectangle is rotated. */
@property (nonatomic, readonly) BOOL rotated;

/** Offset of the frame in points.  If it is updated, then offsetInPixels will also be updated. */
@property (nonatomic, readonly) CGPoint offset;

/** Original size of the trimmed image in points. */
@property (nonatomic, readonly) CGSize originalSize;

/** Texture of the frame. */
@property (nonatomic, strong, readonly) CCTexture *texture;

/** Texture image file name, when created from a texture image. */
@property (nonatomic, strong, readonly) NSString *textureFilename;


/// -----------------------------------------------------------------------
/// @name Creating a CCSpriteFrame Object
/// -----------------------------------------------------------------------

/**
 *  Create and return a sprite frame object from the specified image name.  On first attempt it will check CCSpriteFrameCache and if not available will then try and create from an image file of the same name.
 *
 *  @param imageName Image name.
 *
 *  @return The CCSpriteFrame Object.
 */
+(id) frameWithImageNamed:(NSString*)imageName;

/**
 *  Create and return a sprite frame object from the specified texture, texture rectangle, rotation status, offset and originalSize values.
 *
 *  @param texture      Texture to use.
 *  @param rect         Texture rectangle (in pixels) to use.
 *  @param rotated      Is rectangle rotated?
 *  @param offset       Offset (in pixels) to use.
 *  @param originalSize Original size (in pixels) before being trimmed.
 *
 *  @return The CCSpriteFrame Object.
 */
+(id) frameWithTexture:(CCTexture*)texture rectInPixels:(CGRect)rect rotated:(BOOL)rotated offset:(CGPoint)offset originalSize:(CGSize)originalSize;

/**
 *  Create and return a sprite frame object from the specified texture file name, texture rectangle, rotation status, offset and originalSize values.
 *
 *  @param filename     Image file name to use.
 *  @param rect         Texture rectangle (in pixels) to use.
 *  @param rotated      Is rectangle rotated?
 *  @param offset       Offset (in pixels) to use.
 *  @param originalSize Original size (in pixels) before being trimmed.
 *
 *  @return The CCSpriteFrame Object.
 */
+(id) frameWithTextureFilename:(NSString*)filename rectInPixels:(CGRect)rect rotated:(BOOL)rotated offset:(CGPoint)offset originalSize:(CGSize)originalSize;


/// -----------------------------------------------------------------------
/// @name Initializing a CCSpriteFrame Object
/// -----------------------------------------------------------------------

/**
 *  Initializes and returns a sprite frame object from the specified texture, texture rectangle, rotation status, offset and originalSize values.
 *
 *  @param texture      Texture to use.
 *  @param rect         Texture rectangle (in pixels) to use.
 *  @param rotated      Is rectangle rotated?
 *  @param offset       Offset (in pixels) to use.
 *  @param originalSize Original size (in pixels) before being trimmed.
 *
 *  @return An initialized CCSpriteFrame Object.
 */
-(id) initWithTexture:(CCTexture*)texture rectInPixels:(CGRect)rect rotated:(BOOL)rotated offset:(CGPoint)offset originalSize:(CGSize)originalSize;

/**
 *  Initializes and returns a sprite frame object from the specified texture file name, texture rectangle, rotation status, offset and originalSize values.
 *
 *  @param filename     Image file name to use.
 *  @param rect         Texture rectangle (in pixels) to use.
 *  @param rotated      Is rectangle rotated?
 *  @param offset       Offset (in pixels) to use.
 *  @param originalSize Original size (in pixels) before being trimmed.
 *
 *  @return An initialized CCSpriteFrame Object.
 */
-(id) initWithTextureFilename:(NSString*)filename rectInPixels:(CGRect)rect rotated:(BOOL)rotated offset:(CGPoint)offset originalSize:(CGSize)originalSize;

@end

