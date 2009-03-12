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

#pragma mark AltasSprite

/** AtlasSprite object is an sprite that is rendered using a TextureAtlas object.
 * In particular, the AtlasSpriteManger renders it. It supports all the basic CocosNode transformations like
 * scale, position, rotation, visibility, etc.
 */
@interface AtlasSprite : CocosNode <CocosNodeSize, CocosNodeFrames>
{
	// weak reference
	TextureAtlas *mAtlas;
	int mAtlasIndex;
	
	// spriteManager. weak ref
	AtlasSpriteManager *spriteManager;
	
	// texture pixels
	CGRect mRect;

	// texture coords
	// stored as floats in the range [0..1]
	ccQuad2 mTexCoords;

	// screen pixels
	// stored as pixel locations
	ccQuad3 mVertices;
	
	// whether or not this Sprite needs to be updated in the Atlas
	BOOL	dirty;
}

/** whether or not the Sprite needs to be updated in the Atlas */
@property (readonly) BOOL dirty;
/** returns the altas index of the AtlasSprite */
@property (readonly) int atlasIndex;
/** returns the rect of the AtlasSprite */
@property (readonly) CGRect textureRect;

/** creates an AtlasSprite with an AtlasSpriteManager inidicating the Rect of the Atlas */
+(id)spriteWithRect:(CGRect)rect spriteManager:(AtlasSpriteManager*)manager;
/** initializes an AtlasSprite with an AtlasSpriteManager indicating the rect of the Atlas */
-(id)initWithRect:(CGRect)rect spriteManager:(AtlasSpriteManager*)manager;

/** updates the Quad in the TextureAtlas with it's new position, scale and rotation */
-(void)updateAtlas;

-(void)updatePosition;

/** updates the texture rect of the AtlasSprite */
-(void) setTextureRect:(CGRect) rect;

@end

#pragma mark AtlasAnimation
/** an Animation object used within Sprites to perform animations */
@interface AtlasAnimation : NSObject <CocosAnimation>
{
	int					tag;
	float				delay;
	NSMutableArray		*frames;
	AtlasSpriteManager	*spriteManager;
}

@property (readwrite) int tag;

/* cocos animation */
@property (readwrite,assign) float delay;
@property (readwrite,retain) NSMutableArray *frames;

/** creates an AtlasAnimation with an AtlasSpriteManager, a tag, delay between frames */
+(id) animationWithSpriteManager:(AtlasSpriteManager*)atlasSpriteManager tag:(int)tag delay:(float)delay;

/** creates an AtlasAnimation with an AtlasSpriteManager, a tag, delay between frames and the frames from altas rects */
+(id) animationWithSpriteManager:(AtlasSpriteManager*)atlasSpriteManager tag:(int)tag delay:(float)delay rects:rect1,... NS_REQUIRES_NIL_TERMINATION;

/** initializes an Animation with an AtlasSpriteManger, a tag and delay between frames */
-(id) initWithSpriteManager:(AtlasSpriteManager*)atlasSpriteManager tag:(int)tag delay:(float)delay;

/** initializes an AtlasAnimation with an AtlasSpriteManager, a tag, and the frames from altas rects */
-(id) initWithSpriteManager:(AtlasSpriteManager*)atlasSpriteManager tag:(int)tag delay:(float)delay firstRect:(void*)rect vaList:(va_list) args;

/** adds a frame to an Animation */
-(void) addFrameWithRect:(CGRect)rect;
@end
