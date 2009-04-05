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

#import "AtlasSprite.h"
#import "AtlasSpriteManager.h"
#import "Grid.h"

const int defaultCapacity = 29;

#pragma mark AtlasSprite

@interface AtlasSprite (Remove)
-(void)setIndex:(int)index;
@end

@implementation AtlasSprite (Remove)
-(void)setIndex:(int)index
{
	_atlasIndex = index;
}
@end


#pragma mark AtlasSpriteManager
@implementation AtlasSpriteManager

@synthesize atlas = _textureAtlas;

-(void)dealloc
{	
	[_textureAtlas release];

	[super dealloc];
}

/*
 * creation with Texture2D
 */
+(id)spriteManagerWithTexture:(Texture2D *)tex
{
	return [[[AtlasSpriteManager alloc] initWithTexture:tex capacity:defaultCapacity] autorelease];
}

+(id)spriteManagerWithTexture:(Texture2D *)tex capacity:(NSUInteger)capacity
{
	return [[[AtlasSpriteManager alloc] initWithTexture:tex capacity:capacity] autorelease];
}

/*
 * creation with File Image
 */
+(id)spriteManagerWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity
{
	return [[[AtlasSpriteManager alloc] initWithFile:fileImage capacity:capacity] autorelease];
}

+(id)spriteManagerWithFile:(NSString*) imageFile
{
	return [[[AtlasSpriteManager alloc] initWithFile:imageFile capacity:defaultCapacity] autorelease];
}


/*
 * init with Texture2D
 */
-(id)initWithTexture:(Texture2D *)tex capacity:(NSUInteger)capacity
{
	if( (self=[super init])) {
		_totalSprites = 0;
		_textureAtlas = [[TextureAtlas alloc] initWithTexture:tex capacity:capacity];
		
		// no lazy alloc in this node
		children = [[NSMutableArray alloc] initWithCapacity:capacity];
	}

	return self;
}

/*
 * init with FileImage
 */
-(id)initWithFile:(NSString *)fileImage capacity:(NSUInteger)capacity
{
	if( (self=[super init]) ) {
		_totalSprites = 0;
		_textureAtlas = [[TextureAtlas alloc] initWithFile:fileImage capacity:capacity];
		
		// no lazy alloc in this node
		children = [[NSMutableArray alloc] initWithCapacity:capacity];
	}
	
	return self;
}


#pragma mark AtlasSpriteManager - composition

// override visit.
// Don't call visit on it's children
-(void) visit
{
	// don't iterate over it's children
	// the only valid children are AtlasSprites
	// and are drawn in the atlas
	
	[self draw];
}

-(NSUInteger)indexForNewChildAtZ:(int)z
{
	NSUInteger index = 0;

	// if we're going beyond the current TextureAtlas's capacity,
	// all the previously initialized sprites will need to redo their texture coords
	// this is likely computationally expensive
	if(_totalSprites == _textureAtlas.capacity)
	{
		CCLOG(@"Resizing TextureAtlas capacity, from [%d] to [%d].", _textureAtlas.totalQuads, _textureAtlas.totalQuads * 3 / 2);

		[_textureAtlas resizeCapacity:_textureAtlas.totalQuads * 3 / 2];
		
		for(AtlasSprite *sprite in children)
		{
			[sprite updateAtlas];
		}
	}
	
	for( AtlasSprite *sprite in children) {
		if ( sprite.zOrder > z ) {
			break;
		}
		index++;
	}
		
	return index;
}

-(AtlasSprite*) createSpriteWithRect:(CGRect)rect
{
	return [AtlasSprite spriteWithRect:rect spriteManager:self];
}


// override addChild:
-(id) addChild:(AtlasSprite*)child z:(int)z tag:(int) aTag
{
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( [child isKindOfClass:[AtlasSprite class]], @"AtlasSpriteManager only supports AtlasSprites as children");
	
	NSUInteger index = [self indexForNewChildAtZ:z];
	[child insertInAtlasAtIndex: index];

	if( _textureAtlas.withColorArray )
		[child updateColor];

	_totalSprites++;
	[super addChild:child z:z tag:aTag];

	// XXX: it is not necessary to iterate over all the array.
	NSUInteger count = [children count];
	index++;
	for(; index < count; index++) {
		AtlasSprite *sprite = (AtlasSprite *)[children objectAtIndex:index];
		NSAssert([sprite atlasIndex] == index - 1, @"AtlasSpriteManager: index failed");
		[sprite setIndex:index];		
	}
	
	return self;
}

// override removeChild:
-(void)removeChild: (AtlasSprite *)sprite cleanup:(BOOL)doCleanup
{
	// explicit nil handling
	if (sprite == nil)
		return;
	// ignore non-children 
	if( ![children containsObject:sprite] )
		return;
	
	NSUInteger index= sprite.atlasIndex;
	[super removeChild:sprite cleanup:doCleanup];

	[_textureAtlas removeQuadAtIndex:index];

	// update all sprites beyond this one
	NSUInteger count = [children count];
	for(; index < count; index++)
	{
		AtlasSprite *other = (AtlasSprite *)[children objectAtIndex:index];
		NSAssert([other atlasIndex] == index + 1, @"AtlasSpriteManager: index failed");
		[other setIndex:index];
	}	
	_totalSprites--;
}

// override reorderChild
-(void) reorderChild:(AtlasSprite*)child z:(int)z
{
	// reorder child in the children array
	[super reorderChild:child z:z];

	
	// What's the new atlas index ?
	NSUInteger newAtlasIndex = 0;
	for( AtlasSprite *sprite in children) {
		if( [sprite isEqual:child] )
			break;
		newAtlasIndex++;
	}
	
	if( newAtlasIndex != child.atlasIndex ) {

		[_textureAtlas insertQuadFromIndex:child.atlasIndex atIndex:newAtlasIndex];
		
		// update atlas index
		NSUInteger count = MAX( newAtlasIndex, child.atlasIndex);
		NSUInteger index = MIN( newAtlasIndex, child.atlasIndex);
		for( ; index < count+1 ; index++ ) {
			AtlasSprite *sprite = (AtlasSprite *)[children objectAtIndex:index];
			[sprite setIndex: index];
		}
	}
}

-(void)removeChildAtIndex:(NSUInteger)index cleanup:(BOOL)doCleanup
{
	[self removeChild:(AtlasSprite *)[children objectAtIndex:index] cleanup:doCleanup];
}

-(void)removeAllChildrenWithCleanup:(BOOL)doCleanup
{
	[super removeAllChildrenWithCleanup:doCleanup];
	
	_totalSprites = 0;
	[_textureAtlas removeAllQuads];
}

#pragma mark AtlasSpriteManager - draw
-(void)draw
{
	for( AtlasSprite *child in children )
	{
		if( child.dirtyPosition )
			[child updatePosition];
		if( child.dirtyColor )
			[child updateColor];
	}

	if(_totalSprites > 0)
	{
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		
		if( _textureAtlas.withColorArray )
			glEnableClientState(GL_COLOR_ARRAY);

		glEnable(GL_TEXTURE_2D);

		[_textureAtlas drawQuads];

		glDisable(GL_TEXTURE_2D);

		if( _textureAtlas.withColorArray )
			glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
}

@end
