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
	BOOL	parentIsSpriteSheet_;

	// Data used when the sprite is rendered using a CCSpriteSheet
	CCTextureAtlas *textureAtlas_;		// Sprite Sheet texture atlas (weak reference)
	NSUInteger atlasIndex_;				// Index on the SpriteSheet
	BOOL	dirty;						// Sprite needs to be updated
	
	// Data used when the sprite is self-rendered
	CCTextureAtlas *selfRenderTextureAtlas_;		// Texture Atlas of 1 element (self)
	ccBlendFunc	blendFunc_;							// Needed for the texture protocol

	// texture pixels
	CGRect rect_;
	
	// texture (weak reference)
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
@property (nonatomic,readonly) BOOL dirty;
/** the quad (tex coords, vertex coords and color) information */
@property (nonatomic,readonly) ccV3F_C4B_T2F_Quad quad;
/** The index used on the TextureATlas. Don't modify this value unless you know what you are doing */
@property (nonatomic,readwrite) NSUInteger atlasIndex;
/** returns the rect of the AtlasSprite */
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
@property (nonatomic,readwrite) BOOL parentIsSpriteSheet;
/** weak reference of the TextureAtlas used when the sprite is rendered using a CCSpriteSheet */
@property (nonatomic,readwrite,assign) CCTextureAtlas *textureAtlas;

/** conforms to CCTextureProtocol protocol */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;

+(id) spriteWithTexture:(CCTexture2D*)texture;
+(id) spriteWithTexture:(CCTexture2D*)texture rect:(CGRect)rect;
+(id) spriteWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset;

+(id) spriteWithSpriteFrame:(CCSpriteFrame*)spriteFrame;

+(id) spriteWithFile:(NSString*)filename;
+(id) spriteWithFile:(NSString*)filename rect:(CGRect)rect;
+(id) spriteWithFile:(NSString*)filename rect:(CGRect)rect offset:(CGPoint)offset;

+(id) spriteWithCGImage: (CGImageRef)image;

-(id) initWithTexture:(CCTexture2D*)texture;
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect;
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset;

-(id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame;

-(id) initWithFile:(NSString*)filename;
-(id) initWithFile:(NSString*)filename rect:(CGRect)rect;
-(id) initWithFile:(NSString*)filename rect:(CGRect)rect offset:(CGPoint)offset;

-(id) initWithCGImage: (CGImageRef)image;


-(void)insertInAtlasAtIndex:(NSUInteger)index;
-(void)updatePosition;

/** updates the texture rect of the CCSprite */
-(void) setTextureRect:(CGRect) rect;

@end
