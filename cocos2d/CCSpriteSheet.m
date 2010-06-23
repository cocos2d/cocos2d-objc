/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
 * Copyright (C) 2009 Matt Oswald
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
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
		children_ = [[CCArray alloc] initWithCapacity:capacity];
		descendants_ = [[CCArray alloc] initWithCapacity:capacity];
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
	NSAssert( child != nil, @"Child must be non-nil");
	NSAssert( [children_ containsObject:child], @"Child doesn't belong to Sprite" );
	
	if( z == child.zOrder )
		return;
	
	// XXX: Instead of removing/adding, it is more efficient to reorder manually
	[child retain];
	[self removeChild:child cleanup:NO];
	[self addChild:child z:z];
	[child release];
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
	
	ccArray *array = descendants_->data;
	CCSprite *child;
	
	// is there any child ?. compare with array->num
	// if so, compile the isDirty and update methods
	if( array->num > 0 ) {
		child = array->arr[0];
		dirtyMethod = (DIRTY_IMP) [child methodForSelector:selDirty];
		updateMethod = (UPDATE_IMP) [child methodForSelector:selUpdate];
	}
	
	// itera
	id *arr = array->arr;
	NSUInteger i = array->num;
	while (i-- > 0) {
		child = *arr++;
		
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
	
	CCLOG(@"cocos2d: CCSpriteSheet: resizing TextureAtlas capacity from [%d] to [%d].", textureAtlas_.capacity, quantity);
	
	
	if( ! [textureAtlas_ resizeCapacity:quantity] ) {
		// serious problems
		CCLOG(@"cocos2d: WARNING: Not enough memory to resize the atlas");
		NSAssert(NO,@"XXX: SpriteSheet#increaseAtlasCapacity SHALL handle this assert");
	}	
}


#pragma mark CCSpriteSheet - Atlas Index Stuff

-(NSUInteger) rebuildIndexInOrder:(CCSprite*)node atlasIndex:(NSUInteger)index
{
	CCSprite *sprite;
	CCARRAY_FOREACH(node.children, sprite){
		if( sprite.zOrder < 0 )
			index = [self rebuildIndexInOrder:sprite atlasIndex:index];
	}
	
	// ignore self (spritesheet)
	if( ! [node isEqual:self]) {
		node.atlasIndex = index;
		index++;
	}
	
	CCARRAY_FOREACH(node.children, sprite){
		if( sprite.zOrder >= 0 )
			index = [self rebuildIndexInOrder:sprite atlasIndex:index];
	}
	
	return index;
}

-(NSUInteger) highestAtlasIndexInChild:(CCSprite*)sprite
{
	CCArray *array = [sprite children];
	int count = [array count];
	if( count == 0 )
		return sprite.atlasIndex;
	else
		return [self highestAtlasIndexInChild:[array lastObject]];
}

-(NSUInteger) lowestAtlasIndexInChild:(CCSprite*)sprite
{
	CCArray *array = [sprite children];
	int count = [array count];
	if( count == 0 )
		return sprite.atlasIndex;
	else
		return [self lowestAtlasIndexInChild:[array objectAtIndex:0] ];
}


-(NSUInteger)atlasIndexForChild:(CCSprite*)sprite atZ:(int)z
{
	CCArray *brothers = [[sprite parent] children];
	NSUInteger childIndex = [brothers indexOfObject:sprite];
	
	// ignore parent Z if parent is spriteSheet
	BOOL ignoreParent = ( sprite.parent == self );
	CCSprite *previous = nil;
	if( childIndex > 0 )
		previous = [brothers objectAtIndex:childIndex-1];
	
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
	
	NSAssert( NO, @"Should not happen. Error calculating Z on SpriteSheet");
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
	
	ccArray *descendantsData = descendants_->data;
	
	ccArrayInsertObjectAtIndex(descendantsData, sprite, index);
	
	// update indices
	NSUInteger i = index+1;
	CCSprite *child;
	for(; i<descendantsData->num; i++){
		child = descendantsData->arr[i];
		child.atlasIndex = child.atlasIndex + 1;
	}
	
	// add children recursively
	CCARRAY_FOREACH(sprite.children, child){
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
	
	ccArray *descendantsData = descendants_->data;
	NSUInteger index = ccArrayGetIndexOfObject(descendantsData, sprite);
	if( index != NSNotFound ) {
		ccArrayRemoveObjectAtIndex(descendantsData, index);
		
		// update all sprites beyond this one
		NSUInteger count = descendantsData->num;
		
		for(; index < count; index++)
		{
			CCSprite *s = descendantsData->arr[index];
			s.atlasIndex = s.atlasIndex - 1;
		}
	}
	
	// remove children recursively
	CCSprite *child;
	CCARRAY_FOREACH(sprite.children, child)
		[self removeSpriteFromAtlas:child];
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
