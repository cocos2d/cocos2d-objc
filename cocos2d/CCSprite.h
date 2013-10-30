/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
#import "CCTextureAtlas.h"

@class CCSpriteBatchNode;
@class CCSpriteFrame;
@class CCAnimation;

#pragma mark CCSprite

#define CCSpriteIndexNotInitialized 0xffffffff 	/// CCSprite invalid index on the CCSpriteBatchode


/** CCSprite is a 2d image ( http://en.wikipedia.org/wiki/Sprite_(computer_graphics) )
 *
 * CCSprite can be created with an image, or with a sub-rectangle of an image.
 *
 * If the parent or any of its ancestors is a CCSpriteBatchNode then the following features/limitations are valid
 *	- Features when the parent is a CCBatchNode:
 *		- MUCH faster rendering, specially if the CCSpriteBatchNode has many children. All the children will be drawn in a single batch.
 *
 *	- Limitations
 *		- Camera is not supported yet (eg: CCOrbitCamera action doesn't work)
 *		- GridBase actions are not supported (eg: CCLens, CCRipple, CCTwirl)
 *		- The Alias/Antialias property belongs to CCSpriteBatchNode, so you can't individually set the aliased property.
 *		- The Blending function property belongs to CCSpriteBatchNode, so you can't individually set the blending function property.
 *		- Parallax scroller is not supported, but can be simulated with a "proxy" sprite.
 *
 *  If the parent is an standard CCNode, then CCSprite behaves like any other CCNode:
 *    - It supports blending functions
 *    - It supports aliasing / antialiasing
 *    - But the rendering will be slower: 1 draw per children.
 *
 * The default anchorPoint in CCSprite is (0.5, 0.5).
 */
@interface CCSprite : CCNodeRGBA <CCTextureProtocol>
{

	//
	// Data used when the sprite is rendered using a CCSpriteBatchNode
	//
	CCTextureAtlas			*__unsafe_unretained _textureAtlas;			// Sprite Sheet texture atlas (weak reference)
	NSUInteger				_atlasIndex;			// Absolute (real) Index on the batch node
	CCSpriteBatchNode		*_batchNode;			// Used batch node (weak reference)
	CGAffineTransform		_transformToBatch;		//
	BOOL					_dirty;					// Sprite needs to be updated
	BOOL					_recursiveDirty;		// Subchildren needs to be updated
	BOOL					_hasChildren;			// optimization to check if it contain children
	BOOL					_shouldBeHidden;		// should not be drawn because one of the ancestors is not visible

	//
	// Data used when the sprite is self-rendered
	//
	ccBlendFunc				_blendFunc;				// Needed for the texture protocol
	CCTexture				*_texture;				// Texture used to render the sprite

	//
	// Shared data
	//

	// sprite rectangle
	CGRect	_rect;

	// texture
	BOOL	_rectRotated;

	// Offset Position (used by Zwoptex)
	CGPoint	_offsetPosition;
	CGPoint _unflippedOffsetPositionFromCenter;

	// vertex coords, texture coords and color info
	ccV3F_C4B_T2F_Quad _quad;

	// opacity and RGB protocol
	BOOL		_opacityModifyRGB;

	// image is flipped
	BOOL	_flipX;
	BOOL	_flipY;
}

/** returns the texture rect of the CCSprite in points */
@property (nonatomic,readonly) CGRect textureRect;

/** returns whether or not the texture rectangle is rotated */
@property (nonatomic,readonly) BOOL textureRectRotated;

/** The currently displayed spriteFrame. */
@property (nonatomic,strong) CCSpriteFrame* spriteFrame;

/** whether or not the sprite is flipped horizontally.
 It only flips the texture of the sprite, and not the texture of the sprite's children.
 Also, flipping the texture doesn't alter the anchorPoint.
 If you want to flip the anchorPoint too, and/or to flip the children too use:

	sprite.scaleX *= -1;
 */
@property (nonatomic,readwrite) BOOL flipX;
/** whether or not the sprite is flipped vertically.
 It only flips the texture of the sprite, and not the texture of the sprite's children.
 Also, flipping the texture doesn't alter the anchorPoint.
 If you want to flip the anchorPoint too, and/or to flip the children too use:

	sprite.scaleY *= -1;
 */
@property (nonatomic,readwrite) BOOL flipY;

/** offset position in points of the sprite in points. Calculated automatically by editors like Zwoptex.
 @since v0.99.0
 */
@property (nonatomic,readonly) CGPoint	offsetPosition;

/** conforms to CCTextureProtocol protocol */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;

#pragma mark CCSprite - Initializers

/**
 *  Creates a sprite with the name of an image. The name can be either a name in a sprite sheet or the name of a file.
 *
 *  @param imageName name of the image to load
 *
 *  @return a sprite
 */
+(id)spriteWithImageNamed:(NSString*)imageName;

/** Creates an sprite with a texture.
 The rect used will be the size of the texture.
 The offset will be (0,0).
 */
+(id) spriteWithTexture:(CCTexture*)texture;

/** Creates an sprite with a texture and a rect.
 The offset will be (0,0).
 */
+(id) spriteWithTexture:(CCTexture*)texture rect:(CGRect)rect;

/** Creates an sprite with an sprite frame.
 */
+(id) spriteWithSpriteFrame:(CCSpriteFrame*)spriteFrame;

/** Creates an sprite with a CGImageRef and a key.
 The key is used by the CCTextureCache to know if a texture was already created with this CGImage.
 For example, a valid key is: @"_spriteframe_01".
 If key is nil, then a new texture will be created each time by the CCTextureCache.
 @since v0.99.0
 */
+(id) spriteWithCGImage: (CGImageRef)image key:(NSString*)key;

/**
 *  Initializes a sprite with the name of an image. The name can be either a name in a sprite sheet or the name of a file.
 *
 *  @param imageName name of the image to load
 *
 *  @return a sprite
 */
- (id) initWithImageNamed:(NSString*)imageName;

/** Initializes an sprite with a texture.
 The rect used will be the size of the texture.
 The offset will be (0,0).
 */
-(id) initWithTexture:(CCTexture*)texture;

/** Initializes an sprite with a texture and a rect in points (unrotated)
 The offset will be (0,0).
 */
-(id) initWithTexture:(CCTexture*)texture rect:(CGRect)rect;

/** Initializes an sprite with a texture and a rect in points, optionally rotated.
 The offset will be (0,0).
 IMPORTANT: This is the designated initializer.
 */
- (id)initWithTexture:(CCTexture *)texture rect:(CGRect)rect rotated:(BOOL)rotated;


/** Initializes an sprite with an sprite frame.
 */
-(id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame;

/** Initializes an sprite with a CGImageRef and a key
 The key is used by the CCTextureCache to know if a texture was already created with this CGImage.
 For example, a valid key is: @"_spriteframe_01".
 If key is nil, then a new texture will be created each time by the CCTextureCache.
 @since v0.99.0
 */
-(id) initWithCGImage:(CGImageRef)image key:(NSString*)key;

#pragma mark CCSprite - Texture methods

/** set the texture rect of the CCSprite in points.
 It will call setTextureRect:rotated:untrimmedSize with rotated = NO, and utrimmedSize = rect.size.
 */
-(void) setTextureRect:(CGRect) rect;

/** set the texture rect, rectRotated and untrimmed size of the CCSprite in points.
 It will update the texture coordinates and the vertex rectangle.
 */
-(void) setTextureRect:(CGRect)rect rotated:(BOOL)rotated untrimmedSize:(CGSize)size;

@end
