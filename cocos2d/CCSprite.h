/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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


#import "CCNode.h"
#import "CCProtocols.h"

@class CCSpriteBatchNode;
@class CCSpriteFrame;
@class CCAnimation;

/// The four CCVertexes of a sprite.
/// Bottom left, bottom right, top right, top left.
typedef struct CCSpriteVertexes {
	CCVertex bl, br, tr, tl;
} CCSpriteVertexes;

#pragma mark CCSprite

#define CCSpriteIndexNotInitialized 0xffffffff 	/// CCSprite invalid index on the CCSpriteBatchode

/** 
 * CCSprite is a 2D image ( http://en.wikipedia.org/wiki/Sprite_(computer_graphics) )
 *
 * CCSprite can be created with an image, or with a sub-rectangle of an image.
 *
 * The default anchorPoint in CCSprite is (0.5, 0.5).
 */
@interface CCSprite : CCNode <CCTextureProtocol, CCShaderProtocol, CCBlendProtocol, CCEffectProtocol>

/** Returns the texture rect of the CCSprite in points. */
@property (nonatomic,readonly) CGRect textureRect;

@property (nonatomic, readonly) const CCSpriteVertexes *vertexes;

/** Returns whether or not the texture rectangle is rotated. */
@property (nonatomic,readonly) BOOL textureRectRotated;

/** The currently displayed spriteFrame. */
@property (nonatomic,strong) CCSpriteFrame* spriteFrame;

/** Whether or not the sprite is flipped horizontally.
 It only flips the texture of the sprite, and not the texture of the sprite's children.
 Also, flipping the texture doesn't alter the anchorPoint.
 If you want to flip the anchorPoint too, and/or to flip the children too use:
 sprite.scaleX *= -1;
 */
@property (nonatomic,readwrite) BOOL flipX;

/** Whether or not the sprite is flipped vertically.
 It only flips the texture of the sprite, and not the texture of the sprite's children.
 Also, flipping the texture doesn't alter the anchorPoint.
 If you want to flip the anchorPoint too, and/or to flip the children too use:
 sprite.scaleY *= -1;
 */
@property (nonatomic,readwrite) BOOL flipY;

/** The offset position in points of the sprite in points. Calculated automatically by sprite sheet editors. */
@property (nonatomic,readonly) CGPoint	offsetPosition;


/// -----------------------------------------------------------------------
/// @name Creating a CCSprite Object
/// -----------------------------------------------------------------------

/**
 *  Creates a sprite with the name of an image. The name can be either a name in a sprite sheet or the name of a file.
 *
 *  @param imageName name of the image to load.
 *
 *  @return The CCSprite Object.
 */
+ (id)spriteWithImageNamed:(NSString*)imageName;

/**
 *  Creates an sprite with a texture.
 *  The rect used will be the size of the texture.
 *  The offset will be (0,0).
 *
 *  @param texture Texture to use.
 *
 *  @return The CCSprite Object.
 */
+ (id)spriteWithTexture:(CCTexture*)texture;

/**
 *  Creates an sprite with a texture.
 *  The offset will be (0,0).
 *
 *  @param texture Texture to use.
 *  @param rect    Rect to use.
 *
 *  @return The CCSprite Object.
 */
+ (id)spriteWithTexture:(CCTexture*)texture rect:(CGRect)rect;

/**
 *  Creates an sprite from a sprite frame.
 *
 *  @param spriteFrame Sprite frame to use.
 *
 *  @return The CCSprite Object.
 */
+ (id)spriteWithSpriteFrame:(CCSpriteFrame*)spriteFrame;

/**
 *  Creates an sprite with a CGImageRef and a key.
 *  The key is used by the CCTextureCache to know if a texture was already created with this CGImage.
 *  For example, a valid key is: @"_spriteframe_01".
 *  If key is nil, then a new texture will be created each time by the CCTextureCache.
 *
 *  @param image Image ref.
 *  @param key   Key description.
 *
 *  @return The CCSprite Object.
 */
+ (id)spriteWithCGImage: (CGImageRef)image key:(NSString*)key;


/// -----------------------------------------------------------------------
/// @name Initializing a CCSprite Object
/// -----------------------------------------------------------------------

/**
 *  Initializes a sprite with the name of an image. The name can be either a name in a sprite sheet or the name of a file.
 *
 *  @param imageName name of the image to load.
 *
 *  @return A newly initialized CCSprite object.
 */
- (id)initWithImageNamed:(NSString*)imageName;

/**
 *  Initializes an sprite with a texture.
 *  The rect used will be the size of the texture.
 *  The offset will be (0,0).
 *
 *  @param texture The texture to use.
 *
 *  @return A newly initialized CCSprite object.
 */
- (id)initWithTexture:(CCTexture*)texture;

/**
 *  Initializes an sprite with a texture and a rect in points (unrotated)
 *  The offset will be (0,0).
 *
 *  @param texture The texture to use.
 *  @param rect    The rect to use.
 *
 *  @return A newly initialized CCSprite object.
 */
- (id)initWithTexture:(CCTexture*)texture rect:(CGRect)rect;

/**
 *  Initializes an sprite with an sprite frame.
 *
 *  @param spriteFrame Sprite frame to use.
 *
 *  @return A newly initialized CCSprite object.
 */
- (id)initWithSpriteFrame:(CCSpriteFrame*)spriteFrame;

/**
 *  Initializes an sprite with a CGImageRef and a key.
 *  The key is used by the CCTextureCache to know if a texture was already created with this CGImage.
 *  For example, a valid key is: @"_spriteframe_01".
 *  If key is nil, then a new texture will be created each time by the CCTextureCache.
 *
 *  @param image Image ref.
 *  @param key   Key description.
 *
 *  @return A newly initialized CCSprite object.
 */
- (id)initWithCGImage:(CGImageRef)image key:(NSString*)key;

/**
 *  Creates a non rendered sprite, the primary use of this type of sprite would be for adding control sprites for more complex animations.
 *
 *  @return A newly initialized CCSprite object.
 */
+ (id)emptySprite;

/**
 *  Designated initializer.
 *  Initializes an sprite with a texture and a rect in points, optionally rotated.
 *  The offset will be (0,0).
 *  IMPORTANT: This is the designated initializer.
 *
 *  @param texture The texture to use.
 *  @param rect    The rect to use.
 *  @param rotated YES if texture is rotated.
 *
 *  @return A newly initialized CCSprite object.
 */
- (id)initWithTexture:(CCTexture *)texture rect:(CGRect)rect rotated:(BOOL)rotated;


/// -----------------------------------------------------------------------
/// @name Textures Methods
/// -----------------------------------------------------------------------

/**
 *  Set the texture rect of the CCSprite in points.
 *  It will call setTextureRect:rotated:untrimmedSize with rotated = NO, and utrimmedSize = rect.size.
 *
 *  @param rect Rect to use.
 */
- (void)setTextureRect:(CGRect) rect;

/**
 *  Set the texture rect, rectRotated and untrimmed size of the CCSprite in points.
 *  It will update the texture coordinates and the vertex rectangle.
 *
 *  @param rect    Rect to use.
 *  @param rotated YES if texture is rotated.
 *  @param size    Untrimmed size.
 */
- (void)setTextureRect:(CGRect)rect rotated:(BOOL)rotated untrimmedSize:(CGSize)size;

@end
