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

/////////////////////////////////////////////////
+(id)createWithSpriteManager:(AtlasSpriteManager *)manager withParameters:(NSDictionary *)parameters
{
	return [manager createNewSpriteWithParameters:parameters];
}

/////////////////////////////////////////////////
-(id)initWithSpriteManager:(AtlasSpriteManager *)manager withParameters:(NSDictionary *)parameters
{
	mAtlas = [manager atlas];
	mAtlasIndex = [manager reserveIndexForSprite];
	[manager addSprite:self];

	mLeft = [[parameters objectForKey:@"left"] intValue];
	mTop = [[parameters objectForKey:@"top"] intValue];
	mRight = [[parameters objectForKey:@"right"] intValue];
	mBottom = [[parameters objectForKey:@"bottom"] intValue];

	transformAnchor = cpv(0, 0);

	[self updateTextureCoords];
	[self updatePosition];
	[self updateAtlas];

	return self;
}

/////////////////////////////////////////////////
-(void)setTextureRectLeft:(int)left top:(int)top right:(int)right bottom:(int)bottom
{
	mLeft = left;
	mTop = top;
	mRight = right;
	mBottom = bottom;

	[self updateTextureCoords];
	[self updateAtlas];
}

/////////////////////////////////////////////////
-(void)setTextureRectWithParameters:(NSDictionary *)parameters
{
	mLeft = [[parameters objectForKey:@"left"] intValue];
	mTop = [[parameters objectForKey:@"top"] intValue];
	mRight = [[parameters objectForKey:@"right"] intValue];
	mBottom = [[parameters objectForKey:@"bottom"] intValue];

	[self updateTextureCoords];
	[self updateAtlas];
}

/////////////////////////////////////////////////
-(void)offsetTextureRect:(cpVect)offset
{
	mLeft += offset.x;
	mTop += offset.y;
	mRight += offset.x;
	mBottom += offset.y;

	[self updateTextureCoords];
	[self updateAtlas];
}

/////////////////////////////////////////////////
-(void)moveTextureRect:(cpVect)pos
{
	mRight = pos.x + (mRight - mLeft);
	mBottom = pos.y + (mBottom - mTop);
	mLeft = pos.x;
	mTop = pos.y;

	[self updateTextureCoords];
	[self updateAtlas];
}

/////////////////////////////////////////////////
-(id)makeCopyOfSprite:(AtlasSprite *)sprite
{
	mLeft = sprite->mLeft;
	mTop = sprite->mTop;
	mRight = sprite->mRight;
	mBottom = sprite->mBottom;

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
	
	ccQuad2 newCoords = {
		mLeft / atlasWidth, mBottom / atlasHeight,
		mRight / atlasWidth, mBottom / atlasHeight,
		mLeft / atlasWidth, mTop / atlasHeight,
		mRight / atlasWidth, mTop / atlasHeight,
	};

	mTexCoords = newCoords;
}

/////////////////////////////////////////////////
-(void)updatePosition
{
	int myWidth = mRight - mLeft;
	int myHeight = mBottom - mTop;

	float left = position.x;
	float top = position.y;
	float right = position.x + myWidth;
	float bottom = position.y + myHeight;

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
			float scaleOffset = (myWidth - (myWidth * scaleX)) / 2;
			left += scaleOffset;
			right -= scaleOffset;
		}

		if(scaleY != 1)
		{
			float scaleOffset = (myHeight - (myHeight * scaleY)) / 2;
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
-(cpVect)textureTopLeft
{
	return cpv(mLeft, mTop);
}

/////////////////////////////////////////////////
-(cpVect)textureBottomRight
{
	return cpv(mRight, mBottom);
}

/////////////////////////////////////////////////
-(float)height
{
	return mBottom - mTop;
}

/////////////////////////////////////////////////
-(float)width
{
	return mRight - mLeft;
}

/////////////////////////////////////////////////
-(float)scaledHeight
{
	return (mBottom - mTop) * scaleY;
}

/////////////////////////////////////////////////
-(float)scaledWidth
{
	return (mRight - mLeft) * scaleX;
}

/////////////////////////////////////////////////
-(float)scaleOffsetX
{
	float width = mRight - mLeft;
	return (width - (width * scaleX)) / 2;
}

/////////////////////////////////////////////////
-(float)scaleOffsetY
{
	float height = mBottom - mTop;
	return (height - (height * scaleY)) / 2;
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
	return CGSizeMake([self scaledWidth], [self scaledHeight]);
}

/////////////////////////////////////////////////
//-(void)setZOrder:(int)z
//{
//	[super setZOrder:z];
//
//	[self UpdatePosition];
//	[self UpdateAtlas];
//}

@end
