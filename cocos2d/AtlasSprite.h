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

#import "CocosNode.h"
#import "TextureAtlas.h"

@class AtlasSpriteManager;
@class AtlasSpriteFrame;

#pragma mark AltasSprite

/** AtlasSprite is a CocosNode object that implements the CocosNodeFrames and CocosNodeRGBA protocols.
 * 
 * AtlasSprite can be used as a replacement of Sprite.
 *
 * AtlasSprite has all the features from CocosNode with the following additions and limitations:
 *	- New features
 *		- It is MUCH faster than Sprite
 *      - supports flipX, flipY
 *
 *	- Limitations
 *		- Their parent can only be an AtlasSpriteManager
 *		- They can't have children
 *		- Camera is not supported yet (eg: OrbitCamera action doesn't work)
 *		- GridBase actions are not supported (eg: Lens, Ripple, Twirl)
 *		- The Alias/Antialias property belongs to AtlasSpriteManager, so you can't individually set the aliased property.
 *      - The Blending function property belongs to AtlasSpriteManager, so you can't individually set the blending function property.
 *		- Parallax scroller is not supported, but can be simulated with a "proxy" sprite.
 *
 * @since v0.7.1
 */
@interface AtlasSprite : CocosNode <CocosNodeFrames, CocosNodeRGBA>
{
	// weak reference
	TextureAtlas *textureAtlas_;
	NSUInteger atlasIndex_;

	// texture pixels
	CGRect rect_;

	// texture, vertex and color info
	ccV3F_C4B_T2F_Quad quad_;
	
	// whether or not this Sprite needs to be updated in the Atlas
	BOOL	dirty;
	
	// opacity and RGB protocol
	GLubyte r_, g_, b_, opacity_;
	BOOL opacityModifyRGB_;
	
	// Animations that belong to the sprite
	NSMutableDictionary *animations;
	
	// image is flipped
	BOOL	flipX_;
	BOOL	flipY_;
}

/** whether or not the Sprite needs to be updated in the Atlas */
@property (readonly) BOOL dirty;
/** the quad (tex coords, vertex coords and color) information */
@property (readonly) ccV3F_C4B_T2F_Quad quad;
/** returns the altas index of the AtlasSprite */
@property (readonly) NSUInteger atlasIndex;
/** returns the rect of the AtlasSprite */
@property (readonly) CGRect textureRect;
/** whether or not the sprite is flipped horizontally */
@property (readwrite) BOOL flipX;
/** whether or not the sprite is flipped vertically */
@property (readwrite) BOOL flipY;
/** opacity and RGB colors. conforms to CocosNodeRGBA protocol */
@property (readonly) GLubyte opacity, r, g, b;

/** creates an AtlasSprite with an AtlasSpriteManager inidicating the Rect of the Atlas */
+(id)spriteWithRect:(CGRect)rect spriteManager:(AtlasSpriteManager*)manager;
/** initializes an AtlasSprite with an AtlasSpriteManager indicating the rect of the Atlas */
-(id)initWithRect:(CGRect)rect spriteManager:(AtlasSpriteManager*)manager;

-(void)insertInAtlasAtIndex:(NSUInteger)index;
-(void)updatePosition;

/** updates the texture rect of the AtlasSprite */
-(void) setTextureRect:(CGRect) rect;

@end

#pragma mark AtlasAnimation
/** an Animation object used within Sprites to perform animations */
@interface AtlasAnimation : NSObject <CocosAnimation>
{
	NSString			*name;
	float				delay;
	NSMutableArray		*frames;
}

@property (readwrite,assign) NSString *name;

/** delay between frames in seconds */
@property (readwrite,assign) float delay;
/** array of frames */
@property (readonly) NSMutableArray *frames;

/** creates an AtlasAnimation with an AtlasSpriteManager, a name, delay between frames */
+(id) animationWithName:(NSString*)name delay:(float)delay;

/** creates an AtlasAnimation with an AtlasSpriteManager, a name, delay between frames and the AtlasSpriteFrames */
+(id) animationWithName:(NSString*)name delay:(float)delay frames:frame1,... NS_REQUIRES_NIL_TERMINATION;

/** initializes an Animation with an AtlasSpriteManger, a name and delay between frames */
-(id) initWithName:(NSString*)name delay:(float)delay;

/** initializes an AtlasAnimation with an AtlasSpriteManager, a name, and the AltasSpriteFrames */
-(id) initWithName:(NSString*)name delay:(float)delay firstFrame:(AtlasSpriteFrame*)frame vaList:(va_list) args;

/** adds a frame to an Animation */
-(void) addFrameWithRect:(CGRect)rect;
@end

#pragma mark AltasSpriteFrame
/** An AtlasSpriteFrame is an NSObject that encapsulates a CGRect.
 * And a CGRect represents a frame within the AtlasSpriteManager
 */
@interface AtlasSpriteFrame : NSObject
{
	CGRect	rect;
}
/** rect of the frame */
@property (readwrite) CGRect rect;

/** create an AtlasSpriteFrame with a CGRect */
+(id) frameWithRect:(CGRect)frame;
/** initializes an AtlasSpriteFrame with a CGRect */
-(id) initWithRect:(CGRect)frame;
@end

