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
	atlasIndex_ = index;
}
@end

@interface AtlasSpriteManager (private)
-(void) resizeAtlas;
-(void) updateBlendFunc;
@end

#pragma mark AtlasSpriteManager
@implementation AtlasSpriteManager

@synthesize textureAtlas = textureAtlas_;
@synthesize blendFunc = blendFunc_;

-(void)dealloc
{	
	[textureAtlas_ release];

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
		
		blendFunc_.src = CC_BLEND_SRC;
		blendFunc_.dst = CC_BLEND_DST;
		totalSprites_ = 0;
		textureAtlas_ = [[TextureAtlas alloc] initWithTexture:tex capacity:capacity];
		
		[self updateBlendFunc];
		
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
		
		blendFunc_.src = CC_BLEND_SRC;
		blendFunc_.dst = CC_BLEND_DST;
		totalSprites_ = 0;
		textureAtlas_ = [[TextureAtlas alloc] initWithFile:fileImage capacity:capacity];
		
		[self updateBlendFunc];
		
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

	// CAREFUL:
	// This visit is almost identical to CocosNode#visit
	// with the exception that it doesn't call visit on it's children
	//
	// The alternative is to have a void AtlasSprite#visit, but this
	// although is less mantainable, is faster
	//
	if (!visible)
		return;
	
	glPushMatrix();
	
	if ( grid && grid.active)
		[grid beforeDraw];
	
	[self transform];
	
	[self draw];
	
	if ( grid && grid.active)
		[grid afterDraw:self.camera];
	
	glPopMatrix();
}

-(NSUInteger)indexForNewChildAtZ:(int)z
{
	NSUInteger index = 0;

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
	
	if(totalSprites_ == textureAtlas_.capacity)
		[self resizeAtlas];

	NSUInteger index = [self indexForNewChildAtZ:z];
	[child insertInAtlasAtIndex: index];

	totalSprites_++;
	[super addChild:child z:z tag:aTag];

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

	[textureAtlas_ removeQuadAtIndex:index];

	// update all sprites beyond this one
	NSUInteger count = [children count];
	for(; index < count; index++)
	{
		AtlasSprite *other = (AtlasSprite *)[children objectAtIndex:index];
		NSAssert([other atlasIndex] == index + 1, @"AtlasSpriteManager: index failed");
		[other setIndex:index];
	}	
	totalSprites_--;
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

		[textureAtlas_ insertQuadFromIndex:child.atlasIndex atIndex:newAtlasIndex];
		
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
	
	totalSprites_ = 0;
	[textureAtlas_ removeAllQuads];
}

#pragma mark AtlasSpriteManager - draw
-(void)draw
{
	for( AtlasSprite *child in children )
	{
		if( child.dirty )
			[child updatePosition];
	}

	if(totalSprites_ > 0)
	{
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_COLOR_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glEnable(GL_TEXTURE_2D);
		
		BOOL preMulti = [[textureAtlas_ texture] hasPremultipliedAlpha];
		if( !preMulti )
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
		[textureAtlas_ drawNumberOfQuads:totalSprites_];
		
		if( !preMulti )
			glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
		
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_VERTEX_ARRAY);
	}
}

#pragma mark AtlasSpriteManager - private
-(void) resizeAtlas
{
	// if we're going beyond the current TextureAtlas's capacity,
	// all the previously initialized sprites will need to redo their texture coords
	// this is likely computationally expensive
	NSUInteger quantity = (textureAtlas_.totalQuads + 1) * 4 / 3;

	CCLOG(@"Resizing TextureAtlas capacity, from [%d] to [%d].", textureAtlas_.totalQuads, quantity);


	if( ! [textureAtlas_ resizeCapacity:quantity] ) {
		// serious problems
		CCLOG(@"WARNING: Not enough memory to resize the atlas");
		NSAssert(NO,@"XXX: AltasSpriteManager#resizeAtlas SHALL handle this assert");
	}	
}

#pragma mark AtlasSpriteManager - CocosNodeTexture protocol

-(void) updateBlendFunc
{
	if( ! [textureAtlas_.texture hasPremultipliedAlpha] ) {
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
}

-(void) setTexture:(Texture2D*)texture
{
	textureAtlas_.texture = texture;
	[self updateBlendFunc];
}

-(Texture2D*) texture
{
	return textureAtlas_.texture;
}
@end
