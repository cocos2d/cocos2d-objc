/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCNode.h"
#import "CCProtocols.h"
#import "CCTextureAtlas.h"

@class CCSpriteSheet;
@class CCSpriteFrame;

#pragma mark CCSprite

enum {
	/// CCSprite invalid index on the CCSpriteSheet
	CCSpriteIndexNotInitialized = 0xffffffff,
};

/** CCSprite is a CCNode object that implements the CCFrameProtocol and CCRGBAProtocol protocols.
 *
 * If the parent is a CCSpriteSheet then the following features/limitations are valid
 *	- Features when the parent is a CCSpriteSheet
 *		- It is MUCH faster if you render multiptle sprites at the same time (eg: 50 or more CCSprite nodes)
 *
 *	- Limitations
 *		- They can't have children
 *		- Camera is not supported yet (eg: OrbitCamera action doesn't work)
 *		- GridBase actions are not supported (eg: Lens, Ripple, Twirl)
 *		- The Alias/Antialias property belongs to CCSpriteSheet, so you can't individually set the aliased property.
 *		- The Blending function property belongs to CCSpriteSheet, so you can't individually set the blending function property.
 *		- Parallax scroller is not supported, but can be simulated with a "proxy" sprite.
 *
 *  If the parent is an standard CCNode, then CCSprite behaves like any other CCTextureNode:
 *    - It can have children
 *    - It supports blending functions
 *    - It supports aliasing / antialiasing
 *    - But the rendering will be slower
 *
 * @since v0.7.1
 */
@interface CCSprite : CCNode <CCFrameProtocol, CCRGBAProtocol, CCTextureProtocol>
{
	
	// whether or not it's parent is a CCSpriteSheet
	BOOL	usesSpriteSheet_;

	// Data used when the sprite is rendered using a CCSpriteSheet
	CCTextureAtlas *textureAtlas_;		// Sprite Sheet texture atlas (weak reference)
	NSUInteger atlasIndex_;				// Absolute (real) Index on the SpriteSheet
	BOOL	dirty_;						// Sprite needs to be updated
	CCSpriteSheet	*spriteSheet_;		// Used spritesheet (weak reference)
	
	// Data used when the sprite is self-rendered
	ccBlendFunc	blendFunc_;				// Needed for the texture protocol

	// texture pixels
	CGRect rect_;
	
	// texture
	// used as an optimization
	CCTexture2D		*texture_;

	// vertex coords, texture coors and color info
	ccV3F_C4B_T2F_Quad quad_;
	
	// opacity and RGB protocol
	GLubyte		opacity_;
	ccColor3B	color_;
	BOOL		opacityModifyRGB_;
	
	// image is flipped
	BOOL	flipX_;
	BOOL	flipY_;
	
	
	// Animations that belong to the sprite
	NSMutableDictionary *animations;
}

/** whether or not the Sprite needs to be updated in the Atlas */
@property (nonatomic,readwrite) BOOL dirty;
/** the quad (tex coords, vertex coords and color) information */
@property (nonatomic,readonly) ccV3F_C4B_T2F_Quad quad;
/** The index used on the TextureATlas. Don't modify this value unless you know what you are doing */
@property (nonatomic,readwrite) NSUInteger atlasIndex;
/** returns the rect of the CCSprite */
@property (nonatomic,readonly) CGRect textureRect;
/** whether or not the sprite is flipped horizontally */
@property (nonatomic,readwrite) BOOL flipX;
/** whether or not the sprite is flipped vertically */
@property (nonatomic,readwrite) BOOL flipY;
/** opacity: conforms to CCRGBAProtocol protocol */
@property (nonatomic,readonly) GLubyte opacity;
/** RGB colors: conforms to CCRGBAProtocol protocol */
@property (nonatomic,readonly) ccColor3B color;
/** whether or not the Sprite is rendered using a CCSpriteSheet */
@property (nonatomic,readwrite) BOOL usesSpriteSheet;
/** weak reference of the CCTextureAtlas used when the sprite is rendered using a CCSpriteSheet */
@property (nonatomic,readwrite,assign) CCTextureAtlas *textureAtlas;
/** weak reference to the CCSpriteSheet that renders the CCSprite */
@property (nonatomic,readwrite,assign) CCSpriteSheet *spriteSheet;

/** conforms to CCTextureProtocol protocol */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;

/** Creates an sprite with a texture.
 The rect used will be the size of the texture.
 The offset will be (0,0).
 */
+(id) spriteWithTexture:(CCTexture2D*)texture;

/** Creates an sprite with a texture and a rect.
 The offset will be (0,0).
 */
+(id) spriteWithTexture:(CCTexture2D*)texture rect:(CGRect)rect;

/** Creates an sprite with a texture, a rect and offset.
 */
+(id) spriteWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset;

/** Creates an sprite with an sprite frame.
 */
+(id) spriteWithSpriteFrame:(CCSpriteFrame*)spriteFrame;

/** Creates an sprite with an image filename.
 The rect used will be the size of the image.
 The offset will be (0,0).
 */
+(id) spriteWithFile:(NSString*)filename;

/** Creates an sprite with an image filename and a rect.
 The offset will be (0,0).
 */
+(id) spriteWithFile:(NSString*)filename rect:(CGRect)rect;

/** Creates an sprite with an image filename, a rect and an offset.
 */
+(id) spriteWithFile:(NSString*)filename rect:(CGRect)rect offset:(CGPoint)offset;

/** Creates an sprite with a CGImageRef.
 */
+(id) spriteWithCGImage: (CGImageRef)image;


/** Initializes an sprite with a texture.
 The rect used will be the size of the texture.
 The offset will be (0,0).
 */
-(id) initWithTexture:(CCTexture2D*)texture;

/** Initializes an sprite with a texture and a rect.
 The offset will be (0,0).
 */
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect;

/** Initializes an sprite with a texture, a rect and offset.
 */
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset;

/** Initializes an sprite with a an sprite frame.
 */
-(id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame;

/** Initializes an sprite with an image filename.
 The rect used will be the size of the image.
 The offset will be (0,0).
 */
-(id) initWithFile:(NSString*)filename;

/** Initializes an sprite with an image filename, and a rect.
 The offset will be (0,0).
 */
-(id) initWithFile:(NSString*)filename rect:(CGRect)rect;

/** Initializes an sprite with an image filename, a rect and offset.
 */
-(id) initWithFile:(NSString*)filename rect:(CGRect)rect offset:(CGPoint)offset;

/** Initializes an sprite with a CGImageRef
 */
-(id) initWithCGImage: (CGImageRef)image;


-(void)updatePosition;

/** updates the texture rect of the CCSprite */
-(void) setTextureRect:(CGRect) rect;

@end
