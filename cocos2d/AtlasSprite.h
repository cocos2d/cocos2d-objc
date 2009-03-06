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
@class NSDictionary;

/** AtlasSprite object is an sprite that is rendered using a TextureAtlas object.
 * In particular, the AtlasSpriteManger renders it. It supports all the basic CocosNode transformations like
 * scale, position, rotation, visibility, etc.
 */
@interface AtlasSprite : CocosNode <CocosNodeSize>
{
	// rect point layout:
	//
	// 2---3
	// |	 |
	// |	 |
	// 0---1
	//

@private
	TextureAtlas *mAtlas;
	int mAtlasIndex;

	// texture pixels
	CGRect mRect;

	// texture coords
	// stored as floats in the range [0..1]
	ccQuad2 mTexCoords;

	// screen pixels
	// stored as pixel locations
	ccQuad3 mVertices;

	// because CocosNode::visible doesn't work with this derived class, we have to have this hack
	cpVect mRealPosition;
}

/** returns the altas index of the AtlasSprite */
@property (readonly) int atlasIndex;
/** returns the rect of the AtlasSprite */
@property (readonly) CGRect textureRect;

/** creates an AtlasSprite with an AtlasSpriteManager inidicating the Rect of the Atlas */
+(id)spriteWithSpriteManager:(AtlasSpriteManager *)manager withRect:(CGRect)rect;
/** initializes an AtlasSprite with an AtlasSpriteManager indicating the rect of the Atlas */
-(id)initWithSpriteManager:(AtlasSpriteManager *)manager withRect:(CGRect)rect;

/** updates the Quad in the TextureAtlas with it's new position, scale and rotation */
-(void)updateAtlas;

/** updates the texture rect of the AtlasSprite */
-(void) setTextureRect:(CGRect) rect;

-(void)offsetTextureRect:(cpVect)offset;
-(void)moveTextureRect:(cpVect)pos;
-(id)makeCopyOfSprite:(AtlasSprite *)sprite;

-(cpVect)screenPosition;

-(CGRect)getCGRect;

@end
