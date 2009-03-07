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
+(id)spriteWithRect:(CGRect)rect spriteManager:(AtlasSpriteManager*)manager
{
	return [[[self alloc] initWithRect:rect spriteManager:manager] autorelease];
}

/////////////////////////////////////////////////
-(id)initWithRect:(CGRect)rect spriteManager:(AtlasSpriteManager*)manager
{
	if( (self = [super init])) {
		mAtlas = [manager atlas];	// XXX: shall be retained
		mAtlasIndex = [manager reserveIndexForSprite];
		[manager addSprite:self];

		mRect = rect;

		transformAnchor = cpv( rect.size.width / 2, rect.size.height /2 );

		[self updateTextureCoords];
		[self updatePosition];
		[self updateAtlas];
	}

	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Rect = (%i,%i,%i,%i) | Tag = %i>", [self class], self, (int) mRect.origin.x, (int) mRect.origin.y, (int) mRect.size.width, (int) mRect.size.height, tag];
}

- (void) dealloc
{
	[super dealloc];
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
	// algorithm from pyglet ( http://www.pyglet.org ) 

	// if not visible
	// then everything is 0
	if( ! visible ) {		
		ccQuad3 newVertices = {
			0,0,0,
			0,0,0,
			0,0,0,
			0,0,0,			
		};
		
		mVertices = newVertices;
		return;
	}
	
	// rotation ? -> update: rotation, scale, position
	if( rotation ) {
		float x1 = -transformAnchor.x * scaleX;
		float y1 = -transformAnchor.y * scaleY;

		float x2 = x1 + mRect.size.width * scaleX;
		float y2 = y1 + mRect.size.height * scaleY;
		float x = position.x;
		float y = position.y;
//		if (relativeTransformAnchor) {
//			x -= transformAnchor.x;
//			y -= transformAnchor.y;
//		}
		
		float r = (float)-CC_DEGREES_TO_RADIANS(rotation);
		float cr = cosf(r);
		float sr = sinf(r);
		float ax = x1 * cr - y1 * sr + x;
		float ay = x1 * sr + y1 * cr + y;
		float bx = x2 * cr - y1 * sr + x;
		float by = x2 * sr + y1 * cr + y;
		float cx = x2 * cr - y2 * sr + x;
		float cy = x2 * sr + y2 * cr + y;
		float dx = x1 * cr - y2 * sr + x;
		float dy = x1 * sr + y2 * cr + y;
		
		ccQuad3 newVertices = 
					{ax, ay, 0, 
					bx, by, 0,
					dx, dy, 0,
					cx, cy, 0};
		mVertices = newVertices;
		
		return;
	}
	
	// scale ? -> update: scale, position
	if(scaleX != 1 || scaleY != 1)
	{
		float x = position.x;
		float y = position.y;
//		if (relativeTransformAnchor) {
//			x -= transformAnchor.x;
//			y -= transformAnchor.y;
//		}
		
		float x1 = (x- transformAnchor.x * scaleX);
		float y1 = (y- transformAnchor.y * scaleY);
		float x2 = (x1 + mRect.size.width * scaleX);
		float y2 = (y1 + mRect.size.height * scaleY);
		ccQuad3 newVertices = {
			x1,y1,0,
			x2,y1,0,
			x1,y2,0,
			x2,y2,0,
		};

		mVertices = newVertices;
	
		return;
	}
	
	// update position
	{
		float x = position.x;
		float y = position.y;
//		if (relativeTransformAnchor) {
//			x -= transformAnchor.x;
//			y -= transformAnchor.y;
//		}
		
		float x1 = (x-transformAnchor.x);
		float y1 = (y-transformAnchor.y);
		float x2 = (x1 + mRect.size.width);
		float y2 = (y1 + mRect.size.height);
		ccQuad3 newVertices = {
			x1,y1,0,
			x2,y1,0,
			x1,y2,0,
			x2,y2,0,
		};
		
		mVertices = newVertices;
	}
	
	return;
}

/////////////////////////////////////////////////
-(void)updateAtlas
{
	[mAtlas updateQuadWithTexture:&mTexCoords vertexQuad:&mVertices atIndex:mAtlasIndex];
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
-(void)setRotation:(float)rot
{
	[super setRotation:rot];

	[self updatePosition];
	[self updateAtlas];
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
	CCLOG(@"relativeTransformAnchor is ignored in AtlasSprite");
}

/////////////////////////////////////////////////
-(void)setVisible:(BOOL)v
{
	[super setVisible:v];
	[self updatePosition];
	[self updateAtlas];
}

/////////////////////////////////////////////////
-(CGSize)contentSize
{
	return mRect.size;
}
@end
