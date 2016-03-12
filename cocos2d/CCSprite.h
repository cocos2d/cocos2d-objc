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

#if CC_EFFECTS
@class CCEffectRenderer;
#endif

@class CCSpriteBatchNode;
@class CCSpriteFrame;
@class CCAnimation;

/// The four CCVertexes of a sprite.
/// Bottom left, bottom right, top right, top left.
typedef struct CCSpriteVertexes {
	CCVertex bl, br, tr, tl;
} CCSpriteVertexes;

/// A set of four texture coordinates corresponding to the four
/// vertices of a sprite. 
typedef struct CCSpriteTexCoordSet {
    GLKVector2 bl, br, tr, tl;
} CCSpriteTexCoordSet;

#pragma mark CCSprite

#define CCSpriteIndexNotInitialized 0xffffffff 	/// CCSprite invalid index on the CCSpriteBatchode

/** 
 CCSprite draws a CCTexture on the screen. CCSprite can be created with an image, with a sub-rectangle of an (atlas) image.
 
 The default anchorPoint in CCSprite is (0.5, 0.5).
 */
@interface CCSprite : CCNode <CCTextureProtocol, CCShaderProtocol, CCBlendProtocol
// A bit ugly, will refactor later
#if CC_EFFECTS
, CCEffectProtocol
#endif
> {
@private
    // Vertex coords, texture coords and color info.
    CCSpriteVertexes _verts;
    
    // Center of extents (half width/height) of the sprite for culling purposes.
    GLKVector2 _vertexCenter, _vertexExtents;
#if CC_EFFECTS
    CCEffect *_effect;
    CCEffectRenderer *_effectRenderer;
#endif
}

/// -----------------------------------------------------------------------
/// @name Creating a Sprite with an Image File or Sprite Frame Name
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
 *  Initializes a sprite with the name of an image. The name can be either a name in a sprite sheet or the name of a file.
 *
 *  @param imageName name of the image to load.
 *
 *  @return A newly initialized CCSprite object.
 */
- (id)initWithImageNamed:(NSString*)imageName;

/// -----------------------------------------------------------------------
/// @name Creating a Sprite with a Sprite Frame
/// -----------------------------------------------------------------------

/**
 *  Creates a sprite with an existing CCSpriteFrame.
 *
 *  @param spriteFrame Sprite frame to use.
 *
 *  @return The CCSprite Object.
 *  @see CCSpriteFrame
 */
+ (id)spriteWithSpriteFrame:(CCSpriteFrame*)spriteFrame;

/**
 *  Initializes an sprite with an existing CCSpriteFrame.
 *
 *  @param spriteFrame Sprite frame to use.
 *
 *  @return A newly initialized CCSprite object.
 *  @see CCSpriteFrame
 */
- (id)initWithSpriteFrame:(CCSpriteFrame*)spriteFrame;

/// -----------------------------------------------------------------------
/// @name Creating a Sprite with a Texture
/// -----------------------------------------------------------------------

/**
 *  Creates a sprite with an existing CCTexture.
 *  The rect used will be the size of the texture.
 *  The offset will be (0,0).
 *
 *  @param texture Texture to use.
 *
 *  @return The CCSprite Object.
 *  @see CCTexture
 */
+ (id)spriteWithTexture:(CCTexture*)texture;

/**
 *  Creates a sprite with an existing CCTexture.
 *  The offset will be (0,0).
 *
 *  @param texture Texture to use.
 *  @param rect    Rect to use.
 *
 *  @return The CCSprite Object.
 *  @see CCTexture
 */
+ (id)spriteWithTexture:(CCTexture*)texture rect:(CGRect)rect;

/**
 *  Initializes a sprite with an existing CCTexture.
 *  The rect used will be the size of the texture.
 *  The offset will be (0,0).
 *
 *  @param texture The texture to use.
 *
 *  @return A newly initialized CCSprite object.
 *  @see CCTexture
 */
- (id)initWithTexture:(CCTexture*)texture;

/**
 *  Initializes a sprite with an existing CCTexture and a rect in points (unrotated).
 *  The offset will be (0,0).
 *
 *  @param texture The texture to use.
 *  @param rect    The rect to use.
 *
 *  @return A newly initialized CCSprite object.
 *  @see CCTexture
 */
- (id)initWithTexture:(CCTexture*)texture rect:(CGRect)rect;

/**
 *  Initializes a sprite with an existing CCTexture and a rect in points, optionally rotated.
 *  The offset will be (0,0).
 *  @note This is the designated initializer.
 *
 *  @param texture The texture to use.
 *  @param rect    The rect to use.
 *  @param rotated YES if texture is rotated.
 *
 *  @return A newly initialized CCSprite object.
 *  @see CCTexture
 */
- (id)initWithTexture:(CCTexture *)texture rect:(CGRect)rect rotated:(BOOL)rotated;

/// -----------------------------------------------------------------------
/// @name Creating a Sprite with a CGImage
/// -----------------------------------------------------------------------

/**
 *  Creates an sprite with a CGImageRef and a key.
 *  The key is used to determine if a texture was already created with this CGImage, this ensures proper caching.
 *  For example, a valid key is: @"_spriteframe_01".
 *  
 *  @warning If key is nil, then a new texture will be created each time rather than replacing an existing texture using the same key.
 *  This can waste a lot of memory!
 *
 *  @param image Image ref.
 *  @param key   Key description.
 *
 *  @return The CCSprite Object.
 */
+ (id)spriteWithCGImage: (CGImageRef)image key:(NSString*)key;

/**
 *  Initializes an sprite with a CGImageRef and a key.
 *  The key is used to determine if a texture was already created with this CGImage, this ensures proper caching.
 *  For example, a valid key is: @"_spriteframe_01".
 *
 *  @warning If key is nil, then a new texture will be created each time rather than replacing an existing texture using the same key.
 *  This can waste a lot of memory!
 *
 *  @param image Image ref.
 *  @param key   Key description.
 *
 *  @return A newly initialized CCSprite object.
 */
- (id)initWithCGImage:(CGImageRef)image key:(NSString*)key;

/// -----------------------------------------------------------------------
/// @name Creating an empty Sprite
/// -----------------------------------------------------------------------

/**
 *  Creates an "empty" (invisible) sprite. The primary use of this type of sprite would be for adding control sprites
 *  for more complex animations.
 *
 *  @return A newly initialized CCSprite object.
 */
+ (id)emptySprite;

/// -----------------------------------------------------------------------
/// @name Flipping a Sprite
/// -----------------------------------------------------------------------

/** Whether or not the sprite is flipped horizontally.
 @note Flipping does not flip any of the sprite's child sprites nor does it alter the anchorPoint. 
 If that is what you want, you should try inversing the CCNode scaleX property: `sprite.scaleX *= -1.0;`.
 */
@property (nonatomic,readwrite) BOOL flipX;

/** Whether or not the sprite is flipped vertically.
 @note Flipping does not flip any of the sprite's child sprites nor does it alter the anchorPoint.
 If that is what you want, you should try inversing the CCNode scaleY property: `sprite.scaleY *= -1.0;`.
 */
@property (nonatomic,readwrite) BOOL flipY;

/// -----------------------------------------------------------------------
/// @name Accessing the Sprite Frames
/// -----------------------------------------------------------------------

/** The currently displayed spriteFrame.
 @see CCSpriteFrame */
@property (nonatomic,strong) CCSpriteFrame* spriteFrame;

/** The current normal map spriteFrame.
 @see CCSpriteFrame */
@property (nonatomic,strong) CCSpriteFrame* normalMapSpriteFrame;

/// -----------------------------------------------------------------------
/// @name Working with the Sprite's Texture
/// -----------------------------------------------------------------------

@property (nonatomic, readonly) const CCSpriteVertexes *vertexes;

/** The offset position in points of the sprite in points. Calculated automatically by sprite sheet editors. */
@property (nonatomic,readonly) CGPoint	offsetPosition;

/** Returns the texture rect of the CCSprite in points. */
@property (nonatomic,readonly) CGRect textureRect;

/** Returns whether or not the texture rectangle is rotated. Sprite sheet editors may rotate sprite frames in a texture to fit more sprites in the same atlas. */
@property (nonatomic,readonly) BOOL textureRectRotated;

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

/** Returns the matrix that transforms the sprite's (local) space coordinates into the sprite's texture space coordinates.
 */
- (CGAffineTransform)nodeToTextureTransform;

+ (CCSpriteTexCoordSet)textureCoordsForTexture:(CCTexture *)texture withRect:(CGRect)rect rotated:(BOOL)rotated xFlipped:(BOOL)flipX yFlipped:(BOOL)flipY;

#if CC_EFFECTS
- (void)updateShaderUniformsFromEffect;
#endif
@end


@interface CCSprite(NoARC)

-(void)enqueueTriangles:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform;

@end

