/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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

/** AtlasSprite is a CocosNode object that implements the CocosNodeSize, CocosNodeFrames, CocosNodeOpacity and
 * CocosNodeRGB protocols.
 * 
 * AtlasSprite can be used as a replacement of Sprite.
 *
 * AtlasSprite has all the features from CocosNode with the following additions and limitations:
 *	- New features
 *		- It is MUCH faster than Sprite
 *
 *	- Limitations
 *		- Their parent can only be an AtlasSpriteManager
 *		- They can't have children
 *		- Camera is not supported yet (eg: OrbitCamera action doesn't work)
 *		- GridBase actions are supported (eg: Lens, Ripple, Twirl)
 *		- They can't Aliased or AntiAliased (but AtlasSpriteManager can)
 *		- They can't be "parallaxed" (but AtlasSpriteManager can)
 *
 * @since v0.7.1
 */
@interface AtlasSprite : CocosNode <CocosNodeSize, CocosNodeFrames, CocosNodeOpacity, CocosNodeRGB>
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
	GLubyte opacity_;
	GLubyte r_, g_, b_;
	
	// Animations that belong to the sprite
	NSMutableDictionary *animations;
	
	// image is flipped
	BOOL	flipX_;
	BOOL	flipY_;

	// cocosNodeProtcol
	BOOL	autoCenterFrames_;
}

/** whether or not the Sprite needs to be updated in the Atlas */
@property (readonly) BOOL dirty;
/** the quad (tex coords, vertex coords and color) information */
@property (readonly) ccV3F_C4B_T2F_Quad quad;
/** returns the altas index of the AtlasSprite */
@property (readonly) NSUInteger atlasIndex;
/** returns the rect of the AtlasSprite */
@property (readonly) CGRect textureRect;
/** whether or not the new frames will be auto centered */
@property (readwrite) BOOL autoCenterFrames;
/** whether or not the sprite is flipped horizontally */
@property (readwrite) BOOL flipX;
/** whether or not the sprite is flipped vertically */
@property (readwrite) BOOL flipY;


/** creates an AtlasSprite with an AtlasSpriteManager inidicating the Rect of the Atlas */
+(id)spriteWithRect:(CGRect)rect spriteManager:(AtlasSpriteManager*)manager;
/** initializes an AtlasSprite with an AtlasSpriteManager indicating the rect of the Atlas */
-(id)initWithRect:(CGRect)rect spriteManager:(AtlasSpriteManager*)manager;

/** updates the Quad in the TextureAtlas with it's new position, scale and rotation */
-(void)updateAtlas;

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

/* cocos animation */
@property (readwrite,assign) float delay;
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

