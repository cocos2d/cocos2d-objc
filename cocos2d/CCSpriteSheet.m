/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Matt Oswald
 * Copyright (C) 2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "ccConfig.h"
#import "CCSprite.h"
#import "CCSpriteSheet.h"
#import "CCGrid.h"
#import "CCDrawingPrimitives.h"
#import "CCTextureCache.h"
#import "Support/CGPointExtension.h"

const int defaultCapacity = 29;

#pragma mark -
#pragma mark CCSpriteSheet

@interface CCSpriteSheet (private)
-(void) updateBlendFunc;
@end

@implementation CCSpriteSheet

@synthesize textureAtlas = textureAtlas_;
@synthesize blendFunc = blendFunc_;
@synthesize descendants = descendants_;

/*
 * creation with CCTexture2D
 */
+(id)spriteSheetWithTexture:(CCTexture2D *)tex
{
	return [[[self alloc] initWithTexture:tex capacity:defaultCapacity] autorelease];
}

+(id)spriteSheetWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity
{
	return [[[self alloc] initWithTexture:tex capacity:capacity] autorelease];
}

/*
 * creation with File Image
 */
+(id)spriteSheetWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity
{
	return [[[self alloc] initWithFile:fileImage capacity:capacity] autorelease];
}

+(id)spriteSheetWithFile:(NSString*) imageFile
{
	return [[[self alloc] initWithFile:imageFile capacity:defaultCapacity] autorelease];
}


/*
 * init with CCTexture2D
 */
-(id)initWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity
{
	if( (self=[super init])) {
		
		blendFunc_.src = CC_BLEND_SRC;
		blendFunc_.dst = CC_BLEND_DST;
		textureAtlas_ = [[CCTextureAtlas alloc] initWithTexture:tex capacity:capacity];

		[self updateBlendFunc];

		// no lazy alloc in this node
		children_ = [[NSMutableArray alloc] initWithCapacity:capacity];
		descendants_ = [[NSMutableArray alloc] initWithCapacity:capacity];
	}

	return self;
}

/*
 * init with FileImage
 */
-(id)initWithFile:(NSString *)fileImage capacity:(NSUInteger)capacity
{
	CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:fileImage];
	return [self initWithTexture:tex capacity:capacity];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Tag = %i>", [self class], self, tag_ ];
}

-(void)dealloc
{	
	[textureAtlas_ release];
	[descendants_ release];
	
	[super dealloc];
}

#pragma mark CCSpriteSheet - composition

// override visit.
// Don't call visit on it's children
-(void) visit
{

	// CAREFUL:
	// This visit is almost identical to CocosNode#visit
	// with the exception that it doesn't call visit on it's children
	//
	// The alternative is to have a void CCSprite#visit, but
	// although this is less mantainable, is faster
	//
	if (!visible_)
		return;
	
	glPushMatrix();
	
	if ( grid_ && grid_.active) {
		[grid_ beforeDraw];
		[self transformAncestors];
	}
	
	[self transform];
	
	[self draw];
	
	if ( grid_ && grid_.active)
		[grid_ afterDraw:self];
	
	glPopMatrix();
}

// XXX deprecated
-(CCSprite*) createSpriteWithRect:(CGRect)rect
{
	CCSprite *sprite = [CCSprite spriteWithTexture:textureAtlas_.texture rect:rect];
	[sprite useSpriteSheetRender:self];

	return sprite;
}

// XXX deprecated
-(void) initSprite:(CCSprite*)sprite rect:(CGRect)rect
{
	[sprite initWithTexture:textureAtlas_.texture rect:rect];
	[sprite useSpriteSheetRender:self];
}

// override addChild:
-(id) addChild:(CCSprite*)child z:(int)z tag:(int) aTag
{
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( [child isKindOfClass:[CCSprite class]], @"CCSpriteSheet only supports CCSprites as children");
	NSAssert( child.texture.name == textureAtlas_.texture.name, @"CCSprite is not using the same texture id");

	id ret = [super addChild:child z:z tag:aTag];

	NSUInteger index = [self atlasIndexForChild:child atZ:z];
	[self insertChild:child inAtlasAtIndex:index];

	return ret;
}

// override reorderChild
-(void) reorderChild:(CCSprite*)child z:(int)z
{
	// reorder child in the children array
	[super reorderChild:child z:z];
	
	
	// What's the new atlas index ?
	NSUInteger newAtlasIndex = 0;
	for( CCSprite *sprite in children_) {
		if( [sprite isEqual:child] )
			break;
		newAtlasIndex++;
	}
	
	if( newAtlasIndex != child.atlasIndex ) {
		
		[textureAtlas_ insertQuadFromIndex:child.atlasIndex atIndex:newAtlasIndex];
		
		// update descendats (issue #708)
		[child retain];
		[descendants_ removeObjectAtIndex: child.atlasIndex];
		[descendants_ insertObject:child atIndex:newAtlasIndex];
		[child release];
		
		// update atlas index
		NSUInteger count = MAX( newAtlasIndex, child.atlasIndex);
		NSUInteger index = MIN( newAtlasIndex, child.atlasIndex);
		for( ; index < count+1 ; index++ ) {
			CCSprite *sprite = (CCSprite *)[children_ objectAtIndex:index];
			[sprite setAtlasIndex: index];
		}
	}
}

// override removeChild:
-(void)removeChild: (CCSprite *)sprite cleanup:(BOOL)doCleanup
{
	// explicit nil handling
	if (sprite == nil)
		return;

	NSAssert([children_ containsObject:sprite], @"CCSpriteSheet doesn't contain the sprite. Can't remove it");

	// cleanup before removing
	[self removeSpriteFromAtlas:sprite];
	
	[super removeChild:sprite cleanup:doCleanup];
}

-(void)removeChildAtIndex:(NSUInteger)index cleanup:(BOOL)doCleanup
{
	[self removeChild:(CCSprite *)[children_ objectAtIndex:index] cleanup:doCleanup];
}

-(void)removeAllChildrenWithCleanup:(BOOL)doCleanup
{
	// Invalidate atlas index. issue #569
	[children_ makeObjectsPerformSelector:@selector(useSelfRender)];
	
	[super removeAllChildrenWithCleanup:doCleanup];
	
	[descendants_ removeAllObjects];
	[textureAtlas_ removeAllQuads];
}

#pragma mark CCSpriteSheet - draw
-(void) draw
{
	if( textureAtlas_.totalQuads == 0 )
		return;

	// Optimization: Fast Dispatch
	typedef BOOL (*DIRTY_IMP)(id, SEL);
	typedef BOOL (*UPDATE_IMP)(id, SEL);
	SEL selDirty = @selector(dirty);
	SEL selUpdate = @selector(updateTransform);
	DIRTY_IMP dirtyMethod = nil;
	UPDATE_IMP updateMethod = nil;
	
	for( CCSprite *child in descendants_ )
	{
		if( ! dirtyMethod ) {
			// Optimization: Fast Dispatch
			dirtyMethod = (DIRTY_IMP) [child methodForSelector:selDirty];
			updateMethod = (UPDATE_IMP) [child methodForSelector:selUpdate];
		}
		
		// fast dispatch
		if( dirtyMethod(child, selDirty) )
			updateMethod(child, selUpdate);
		
#if CC_SPRITESHEET_DEBUG_DRAW
		CGRect rect = [child boundingBox]; //Issue #528
		CGPoint vertices[4]={
			ccp(rect.origin.x,rect.origin.y),
			ccp(rect.origin.x+rect.size.width,rect.origin.y),
			ccp(rect.origin.x+rect.size.width,rect.origin.y+rect.size.height),
			ccp(rect.origin.x,rect.origin.y+rect.size.height),
		};
		ccDrawPoly(vertices, 4, YES);
#endif // CC_SPRITESHEET_DEBUG_DRAW		
	}


	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: -
	
	
	
	BOOL newBlend = NO;
	if( blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST ) {
		newBlend = YES;
		glBlendFunc( blendFunc_.src, blendFunc_.dst );
	}
	
	[textureAtlas_ drawQuads];
	if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);		
}

#pragma mark CCSpriteSheet - private
-(void) increaseAtlasCapacity
{
	// if we're going beyond the current TextureAtlas's capacity,
	// all the previously initialized sprites will need to redo their texture coords
	// this is likely computationally expensive
	NSUInteger quantity = (textureAtlas_.capacity + 1) * 4 / 3;

	CCLOG(@"cocos2d: Resizing TextureAtlas capacity, from [%d] to [%d].", textureAtlas_.capacity, quantity);


	if( ! [textureAtlas_ resizeCapacity:quantity] ) {
		// serious problems
		CCLOG(@"cocos2d: WARNING: Not enough memory to resize the atlas");
		NSAssert(NO,@"XXX: SpriteSheet#increateAtlasCapacity SHALL handle this assert");
	}	
}


#pragma mark CCSpriteSheet - Atlas Index Stuff

-(NSUInteger) rebuildIndexInOrder:(CCSprite*)node atlasIndex:(NSUInteger)index
{
	for( CCSprite *sprite in node.children ) {
		if( sprite.zOrder < 0 )
			index = [self rebuildIndexInOrder:sprite atlasIndex:index];
	}
	
	// ignore self (spritesheet)
	if( ! [node isEqual:self]) {
		node.atlasIndex = index;
		index++;
	}
	
	for( CCSprite *sprite in node.children ) {
		if( sprite.zOrder >= 0 )
			index = [self rebuildIndexInOrder:sprite atlasIndex:index];
	}
	
	return index;
}

-(NSUInteger) highestAtlasIndexInChild:(CCSprite*)sprite
{
	if( [[sprite children] count] == 0 )
		return sprite.atlasIndex;
	else
		return [self highestAtlasIndexInChild:[sprite.children lastObject]];
}

-(NSUInteger) lowestAtlasIndexInChild:(CCSprite*)sprite
{
	if( [[sprite children] count] == 0 )
		return sprite.atlasIndex;
	else
		return [self lowestAtlasIndexInChild:[sprite.children objectAtIndex:0] ];
}


-(NSUInteger)atlasIndexForChild:(CCSprite*)sprite atZ:(int)z
{
	NSArray *brothers = [[sprite parent] children];
	NSUInteger childIndex = [brothers indexOfObject:sprite];
	
	// ignore parent Z if parent is spriteSheet
	BOOL ignoreParent = ( sprite.parent == self );
	CCSprite *previous = nil;
	if( childIndex > 0 )
		previous = [brothers objectAtIndex:childIndex-1];
	
//	if( childIndex < [brothers count] -1 )
//		next = [brothers objectAtIndex:childIndex+1];

	// first child of the sprite sheet
	if( ignoreParent ) {
		if( childIndex == 0 )
			return 0;
		// else
		return [self highestAtlasIndexInChild: previous] + 1;
	}
	
	// parent is a CCSprite, so, it must be taken into account
	
	// first child of an CCSprite ?
	if( childIndex == 0 )
	{
		CCSprite *p = (CCSprite*) sprite.parent;

		// less than parent and brothers
		if( z < 0 )
			return p.atlasIndex;
		else
			return p.atlasIndex+1;
	} else {
		// previous & sprite belong to the same branch
		if( ( previous.zOrder < 0 && z < 0 )|| (previous.zOrder >= 0 && z >= 0) ) {
			return [self highestAtlasIndexInChild:previous] + 1;
		}
		// else (previous < 0 and sprite >= 0 )
		CCSprite *p = (CCSprite*) sprite.parent;
		return p.atlasIndex + 1;
	}
	
	NSAssert( YES, @"Should not happen. Error calculating Z on SpriteSheet");
	return 0;
}

#pragma mark CCSpriteSheet - add / remove / reorder helper methods
// add child helper
-(void) insertChild:(CCSprite*)sprite inAtlasAtIndex:(NSUInteger)index
{
	[sprite useSpriteSheetRender:self];
	[sprite setAtlasIndex:index];
	[sprite setDirty: YES];
	
	if(textureAtlas_.totalQuads == textureAtlas_.capacity)
		[self increaseAtlasCapacity];
	
	ccV3F_C4B_T2F_Quad quad = [sprite quad];
	[textureAtlas_ insertQuad:&quad atIndex:index];
	
	[descendants_ insertObject:sprite atIndex:index];
	
	// update indices
	NSUInteger i=0;
	for( CCSprite *child in descendants_ ) {
		if( i > index )
			child.atlasIndex = child.atlasIndex + 1;
		
		i++;
	}
	
	// add children recursively
	for( CCSprite *child in sprite.children ) {
		NSUInteger index = [self atlasIndexForChild:child atZ: child.zOrder];
		[self insertChild:child inAtlasAtIndex:index];
	}
}

// remove child helper
-(void) removeSpriteFromAtlas:(CCSprite*)sprite
{
	// remove from TextureAtlas
	[textureAtlas_ removeQuadAtIndex:sprite.atlasIndex];
	
	// Cleanup sprite. It might be reused (issue #569)
	[sprite useSelfRender];

	NSUInteger index = [descendants_ indexOfObject:sprite];
	if( index != NSNotFound ) {
		[descendants_ removeObjectAtIndex:index];
		
		// update all sprites beyond this one
		NSUInteger count = [descendants_ count];
		
		for(; index < count; index++)
		{
			CCSprite *s = [descendants_ objectAtIndex:index];
			s.atlasIndex = s.atlasIndex - 1;
		}
	}
	
	// remove children recursively
	for( CCSprite *child in sprite.children ) {
		[self removeSpriteFromAtlas:child];
	}	
}

#pragma mark CCSpriteSheet - CocosNodeTexture protocol

-(void) updateBlendFunc
{
	if( ! [textureAtlas_.texture hasPremultipliedAlpha] ) {
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
}

-(void) setTexture:(CCTexture2D*)texture
{
	textureAtlas_.texture = texture;
	[self updateBlendFunc];
}

-(CCTexture2D*) texture
{
	return textureAtlas_.texture;
}
@end
