/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Matt Oswald
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCNode.h"
#import "CCTextureAtlas.h"

@class CCAtlasSpriteManager;
@class CCAtlasSpriteFrame;

#pragma mark AltasSprite

enum {
	/// AtlasSprite invalid index on the AtlasSpriteManager
	CCAtlasSpriteIndexNotInitialized = 0xffffffff,
};

/** CCAtlasSprite is a CCNode object that implements the CCNodeFrames and CCNodeRGBA protocols.
 * 
 * CCAtlasSprite can be used as a replacement of CCSprite.
 *
 * CCAtlasSprite has all the features from CCNode with the following additions and limitations:
 *	- New features
 *		- It is MUCH faster than Sprite
 *		- supports flipX, flipY
 *
 *	- Limitations
 *		- Their parent can only be an AtlasSpriteManager
 *		- They can't have children
 *		- Camera is not supported yet (eg: OrbitCamera action doesn't work)
 *		- GridBase actions are not supported (eg: Lens, Ripple, Twirl)
 *		- The Alias/Antialias property belongs to AtlasSpriteManager, so you can't individually set the aliased property.
 *		- The Blending function property belongs to AtlasSpriteManager, so you can't individually set the blending function property.
 *		- Parallax scroller is not supported, but can be simulated with a "proxy" sprite.
 *
 * @since v0.7.1
 */
@interface CCAtlasSprite : CCNode <CCNodeFrames, CCNodeRGBA, CCNodeTexture>
{
	
	// whether or not it's parent is an Atlas manager
	BOOL	useAtlasRendering_;

	// Data used when the sprite is rendered using the manager
	CCTextureAtlas *textureAtlas_;	// Sprite Manager texture atlas (weak reference)
	NSUInteger atlasIndex_;			// Index on the Sprite Manager
	BOOL	dirty;						// Sprite needs to be updated
	
	// Data used when the sprite is self-rendered
	CCTextureAtlas *selfRenderTextureAtlas_;		// Texture Atlas of 1 element (self)
	ccBlendFunc	blendFunc_;					// Needed for the texture protocol

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
/** opacity: conforms to CCNodeRGBA protocol */
@property (nonatomic,readonly) GLubyte opacity;
/** RGB colors: conforms to CCNodeRGBA protocol */
@property (nonatomic,readonly) ccColor3B color;
/** whether or not the Sprite is rendered using a AtlasSprite manager */
@property (nonatomic,readonly) BOOL useAtlasRendering;

/** conforms to CCNodeTexture protocol */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;

/** creates an AtlasSprite with an AtlasSpriteManager inidicating the Rect of the Atlas */
//+(id)spriteWithRect:(CGRect)rect spriteManager:(CCAtlasSpriteManager*)manager;
/** initializes an AtlasSprite with an AtlasSpriteManager indicating the rect of the Atlas */
//-(id)initWithRect:(CGRect)rect spriteManager:(CCAtlasSpriteManager*)manager;


+(id) spriteWithTexture:(CCTexture2D*)texture;
+(id) spriteWithTexture:(CCTexture2D*)texture rect:(CGRect)rect;
+(id) spriteWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset;

+(id) spriteWithFile:(NSString*)filename;
+(id) spriteWithFile:(NSString*)filename rect:(CGRect)rect;
+(id) spriteWithFile:(NSString*)filename rect:(CGRect)rect offset:(CGPoint)offset;

+(id) spriteWithCGImage: (CGImageRef)image;

-(id) initWithTexture:(CCTexture2D*)texture;
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect;
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset;

-(id) initWithFile:(NSString*)filename;
-(id) initWithFile:(NSString*)filename rect:(CGRect)rect;
-(id) initWithFile:(NSString*)filename rect:(CGRect)rect offset:(CGPoint)offset;

-(id) initWithCGImage: (CGImageRef)image;


-(void)insertInAtlasAtIndex:(NSUInteger)index;
-(void)updatePosition;

/** updates the texture rect of the AtlasSprite */
-(void) setTextureRect:(CGRect) rect;

@end

#pragma mark AtlasAnimation
/** an Animation object used within Sprites to perform animations */
@interface CCAtlasAnimation : NSObject <CCAnimation>
{
	NSString			*name;
	float				delay;
	NSMutableArray		*frames;
}

@property (nonatomic,readwrite,assign) NSString *name;

/** delay between frames in seconds */
@property (nonatomic,readwrite,assign) float delay;
/** array of frames */
@property (nonatomic,readonly) NSMutableArray *frames;

/** creates an AtlasAnimation with an AtlasSpriteManager, a name, delay between frames */
+(id) animationWithName:(NSString*)name delay:(float)delay;

/** creates an AtlasAnimation with an AtlasSpriteManager, a name, delay between frames and the AtlasSpriteFrames */
+(id) animationWithName:(NSString*)name delay:(float)delay frames:frame1,... NS_REQUIRES_NIL_TERMINATION;

/** initializes an Animation with an AtlasSpriteManger, a name and delay between frames */
-(id) initWithName:(NSString*)name delay:(float)delay;

/** initializes an AtlasAnimation with an AtlasSpriteManager, a name, and the AltasSpriteFrames */
-(id) initWithName:(NSString*)name delay:(float)delay firstFrame:(CCAtlasSpriteFrame*)frame vaList:(va_list) args;

/** adds a frame to an Animation */
-(void) addFrameWithRect:(CGRect)rect;
@end

#pragma mark AltasSpriteFrame
/** An AtlasSpriteFrame is an NSObject that encapsulates a CGRect.
 * And a CGRect represents a frame within the AtlasSpriteManager
 */
@interface CCAtlasSpriteFrame : NSObject
{
	CGRect	rect;
}
/** rect of the frame */
@property (nonatomic,readwrite) CGRect rect;

/** create an AtlasSpriteFrame with a CGRect */
+(id) frameWithRect:(CGRect)frame;
/** initializes an AtlasSpriteFrame with a CGRect */
-(id) initWithRect:(CGRect)frame;
@end

