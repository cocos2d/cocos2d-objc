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
	int mLeft;
	int mTop;
	int mRight;
	int mBottom;

	// texture coords
	// stored as floats in the range [0..1]
	ccQuad2 mTexCoords;

	// screen pixels
	// stored as pixel locations
	ccQuad3 mVertices;

	// because CocosNode::visible doesn't work with this derived class, we have to have this hack
	cpVect mRealPosition;
}

@property (readonly) int atlasIndex;

+(id)createWithSpriteManager:(AtlasSpriteManager *)manager withParameters:(NSDictionary *)parameters;
-(id)initWithSpriteManager:(AtlasSpriteManager *)manager withParameters:(NSDictionary *)parameters;

-(void)updateAtlas;
-(void)setTextureRectLeft:(int)left top:(int)top right:(int)right bottom:(int)bottom;
-(void)setTextureRectWithParameters:(NSDictionary *)parameters;
-(void)offsetTextureRect:(cpVect)offset;
-(void)moveTextureRect:(cpVect)pos;
-(id)makeCopyOfSprite:(AtlasSprite *)sprite;

-(cpVect)screenPosition;
-(cpVect)textureTopLeft;
-(cpVect)textureBottomRight;

-(float)height;
-(float)width;
-(float)scaledHeight;
-(float)scaledWidth;
-(float)scaleOffsetX;
-(float)scaleOffsetY;

-(CGRect)getCGRect;

@end
