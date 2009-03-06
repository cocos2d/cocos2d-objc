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

#import <assert.h>
#import "AtlasSprite.h"
#import "AtlasSpriteManager.h"

const int defaultCapacity = 10;

/////////////////////////////////////////////////
/////////////////////////////////////////////////
@interface AtlasSprite (Remove)

-(void)setIndex:(int)index;
@end

@implementation AtlasSprite (Remove)

/////////////////////////////////////////////////
-(void)setIndex:(int)index
{
	mAtlasIndex = index;
	[self updateAtlas];
}

@end


/////////////////////////////////////////////////
/////////////////////////////////////////////////
@implementation AtlasSpriteManager

@synthesize atlas = mAtlas;

/////////////////////////////////////////////////
-(void)dealloc
{
	[mAtlas release];
	[mSprites release];
	[super dealloc];
}

/*
 * creation with Texture2D
 */
+(id)spriteManagerWithTexture:(Texture2D *)tex
{
	return [[AtlasSpriteManager new] initWithTexture:tex capacity:defaultCapacity];
}

+(id)spriteManagerWithTexture:(Texture2D *)tex capacity:(NSUInteger)capacity
{
	return [[AtlasSpriteManager new] initWithTexture:tex capacity:capacity];
}

/*
 * creation with File Image
 */
+(id)spriteManagerWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity
{
	return [[AtlasSpriteManager new] initWithFile:fileImage capacity:capacity];
}

+(id)spriteManagerWithFile:(NSString*) imageFile
{
	return [[AtlasSpriteManager new] initWithFile:imageFile capacity:defaultCapacity];
}


/*
 * init with Texture2D
 */
-(id)initWithTexture:(Texture2D *)tex capacity:(NSUInteger)capacity
{
	mTotalSprites = 0;
	mAtlas = [[TextureAtlas alloc] initWithTexture:tex capacity:capacity];
	mSprites = [[NSMutableArray alloc] initWithCapacity:mAtlas.totalQuads];

	return self;
}

/*
 * init with FileImage
 */
-(id)initWithFile:(NSString *)fileImage capacity:(NSUInteger)capacity
{
	mTotalSprites = 0;
	mAtlas = [[TextureAtlas alloc] initWithFile:fileImage capacity:capacity];
	mSprites = [[NSMutableArray alloc] initWithCapacity:mAtlas.totalQuads];
	
	return self;
}


/////////////////////////////////////////////////
-(AtlasSprite *)createNewSpriteWithRect:(CGRect)rect
{
	return [[AtlasSprite new] initWithSpriteManager:self withRect:(CGRect)rect];
}

/////////////////////////////////////////////////
-(int)reserveIndexForSprite
{
	// if we're going beyond the current TextureAtlas's capacity,
	// all the previously initialized sprites will need to redo their texture coords
	// this is likely computationally expensive
	if(mTotalSprites == mAtlas.totalQuads)
	{
		CCLOG(@"Resizing TextureAtlas capacity, from [%d] to [%d].", mAtlas.totalQuads, mAtlas.totalQuads * 3 / 2);

		[mAtlas resizeCapacity:mAtlas.totalQuads * 3 / 2];
		
		for(AtlasSprite *sprite in mSprites)
		{
			[sprite updateAtlas];
		}
	}

	return mTotalSprites++;
}

/////////////////////////////////////////////////
-(AtlasSprite *)addSprite:(AtlasSprite *)newSprite
{
	[mSprites insertObject:newSprite atIndex:[newSprite atlasIndex]];
	return newSprite;
}

/////////////////////////////////////////////////
-(void)removeSprite:(AtlasSprite *)sprite
{
	int index = [sprite atlasIndex];
	[mSprites removeObjectAtIndex:index];
	--mTotalSprites;

	assert([sprite retainCount] == 1);
	[sprite release];

	// update all sprites beyond this one
	int count = [mSprites count];
	for(; index != count; ++index)
	{
		AtlasSprite *other = (AtlasSprite *)[mSprites objectAtIndex:index];
		assert([other atlasIndex] == index + 1);
		[other setIndex:index];
	}
}

/////////////////////////////////////////////////
-(void)removeSpriteAtIndex:(int)index
{
	[self removeSprite:(AtlasSprite *)[mSprites objectAtIndex:index]];
}

/////////////////////////////////////////////////
-(void)removeAllSprites
{
	for(AtlasSprite *sprite in mSprites)
	{
		[sprite release];
	}

	[mSprites removeAllObjects];
	mTotalSprites = 0;
}

/////////////////////////////////////////////////
-(void)draw
{
	if(mTotalSprites > 0)
	{
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);

		glEnable(GL_TEXTURE_2D);

		[mAtlas drawNumberOfQuads:mTotalSprites];

		glDisable(GL_TEXTURE_2D);

		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
}


/////////////////////////////////////////////////
-(int)numberOfSprites
{
	return [mSprites count];
}

/////////////////////////////////////////////////
-(AtlasSprite *)spriteAtIndex:(int)index
{
	return [mSprites objectAtIndex:index];
}

@end
