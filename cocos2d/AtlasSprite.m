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

#import "AtlasSpriteManager.h"
#import "AtlasSprite.h"

static const cpVect offscreenPosition = { -10000.0f, -10000.0f };

/////////////////////////////////////////////////
/////////////////////////////////////////////////
@interface AtlasSprite ()

-(void)updateTextureCoords;
-(void)updatePosition;
@end

/////////////////////////////////////////////////
/////////////////////////////////////////////////
@implementation AtlasSprite

@synthesize atlasIndex = mAtlasIndex;
@synthesize textureRect = mRect;

/////////////////////////////////////////////////
+(id)spriteWithSpriteManager:(AtlasSpriteManager *)manager withRect:(CGRect)rect
{
	return [manager createNewSpriteWithRect:rect];
}

/////////////////////////////////////////////////
-(id)initWithSpriteManager:(AtlasSpriteManager *)manager withRect:(CGRect)rect
{
	mAtlas = [manager atlas];
	mAtlasIndex = [manager reserveIndexForSprite];
	[manager addSprite:self];

	mRect = rect;

	transformAnchor = cpv( rect.size.width / 2, rect.size.height /2 );

	[self updateTextureCoords];
	[self updatePosition];
	[self updateAtlas];

	return self;
}

/////////////////////////////////////////////////
-(void)setTextureRect:(CGRect) rect
{
	mRect = rect;

	[self updateTextureCoords];
	[self updateAtlas];
}

/////////////////////////////////////////////////
-(void)offsetTextureRect:(cpVect)offset
{
	mRect.origin.x += offset.x;
	mRect.origin.y += offset.y;

	[self updateTextureCoords];
	[self updateAtlas];
}

/////////////////////////////////////////////////
-(void)moveTextureRect:(cpVect)pos
{
	mRect.origin.x = pos.x;
	mRect.origin.y = pos.y;

	[self updateTextureCoords];
	[self updateAtlas];
}

/////////////////////////////////////////////////
-(id)makeCopyOfSprite:(AtlasSprite *)sprite
{	
	mRect = sprite.textureRect;

	[self updateTextureCoords];
	[self updatePosition];
	[self updateAtlas];

	return self;
}

/////////////////////////////////////////////////
-(void)updateTextureCoords
{
	float atlasWidth = mAtlas.texture.pixelsWide;
	float atlasHeight = mAtlas.texture.pixelsHigh;

	float left = mRect.origin.x / atlasWidth;
	float right = (mRect.origin.x + mRect.size.width) / atlasWidth;
	float top = mRect.origin.y / atlasHeight;
	float bottom = (mRect.origin.y + mRect.size.height) / atlasHeight;

	
	ccQuad2 newCoords = {
		left, bottom,
		right, bottom,
		left, top,
		right, top,
	};

	mTexCoords = newCoords;
}

/////////////////////////////////////////////////
-(void)updatePosition
{
	float left = position.x;
	float top = position.y;
	float right = position.x + mRect.size.width;
	float bottom = position.y + mRect.size.height;

	// account for anchor point
	if(relativeTransformAnchor)
	{
		left -= transformAnchor.x;
		right -= transformAnchor.x;
		top -= transformAnchor.y;
		bottom -= transformAnchor.y;
	}

	if(scaleX != 1 || scaleY != 1)
	{
		left += transformAnchor.x;
		right += transformAnchor.x;
		top += transformAnchor.y;
		bottom += transformAnchor.y;

		// account for scale
		if(scaleX != 1)
		{
			float scaleOffset = (mRect.size.width - (mRect.size.width * scaleX)) / 2;
			left += scaleOffset;
			right -= scaleOffset;
		}

		if(scaleY != 1)
		{
			float scaleOffset = (mRect.size.height - (mRect.size.height * scaleY)) / 2;
			top += scaleOffset;
			bottom -= scaleOffset;
		}

		//
		// account for rotation here
		//

		left -= transformAnchor.x;
		right -= transformAnchor.x;
		top -= transformAnchor.y;
		bottom -= transformAnchor.y;
	}

	ccQuad3 newVertices = {
		left,	top,		0,
		right,	top,		0,
		left,	bottom,		0,
		right,	bottom,		0,
	};

	mVertices = newVertices;
}

/////////////////////////////////////////////////
-(void)updateAtlas
{
	[mAtlas updateQuadWithTexture:&mTexCoords vertexQuad:&mVertices atIndex:mAtlasIndex];
}

/////////////////////////////////////////////////
-(cpVect)screenPosition
{
	return cpv(mVertices.bl_x, mVertices.bl_y);
}

/////////////////////////////////////////////////
-(CGRect)getCGRect
{
	return CGRectMake(mVertices.bl_x, mVertices.bl_y, mVertices.br_x - mVertices.bl_x, mVertices.tr_y - mVertices.bl_y);
}

//
// CocosNode property overloads
//
/////////////////////////////////////////////////
-(void)setPosition:(cpVect)pos
{
	[super setPosition:pos];
	
	[self updatePosition];
	[self updateAtlas];
}

/////////////////////////////////////////////////
-(void)setRotation:(float)rotation
{
	NSException *e = [NSException exceptionWithName:@"setRotation" reason:@"AtlasSprite can not be rotated (yet)" userInfo:nil];
	@throw e;
/*
	[super setRotation:rotation];

	[self updatePosition];
	[self updateAtlas];
*/
}

/////////////////////////////////////////////////
-(void)setScaleX:(float) sx
{
	[super setScaleX:sx];

	[self updatePosition];
	[self updateAtlas];
}

/////////////////////////////////////////////////
-(void)setScaleY:(float) sy
{
	[super setScaleY:sy];

	[self updatePosition];
	[self updateAtlas];
}

/////////////////////////////////////////////////
-(void)setScale:(float) s
{
	[super setScale:s];

	[self updatePosition];
	[self updateAtlas];
}

/////////////////////////////////////////////////
-(void)setTransformAnchor:(cpVect)anchor
{
	[super setTransformAnchor:anchor];

	[self updatePosition];
	[self updateAtlas];
}

/////////////////////////////////////////////////
-(void)setRelativeTransformAnchor:(BOOL)relative
{
	[super setRelativeTransformAnchor:relative];

	[self updatePosition];
	[self updateAtlas];
}

/////////////////////////////////////////////////
-(void)setVisible:(BOOL)v
{
	if(v == [super visible])
	{
		return;
	}

	if(!v)
	{
		mRealPosition = [self position];
	}

	[super setVisible:v];

	if(!v)
	{
		[self setPosition:offscreenPosition];
	}
	else
	{
		[self setPosition:mRealPosition];
	}
}

/////////////////////////////////////////////////
-(CGSize)contentSize
{
	return mRect.size;
}
@end
