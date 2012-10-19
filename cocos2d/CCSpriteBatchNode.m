/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Matt Oswald
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
#import "CCSpriteBatchNode.h"
#import "CCGrid.h"
#import "CCDrawingPrimitives.h"
#import "CCTextureCache.h"
#import "Support/CGPointExtension.h"

const NSUInteger defaultCapacity = 29;

#pragma mark -
#pragma mark CCSpriteBatchNode

static 	SEL selUpdate = NULL;
static SEL selUpdateAtlasIndex =NULL;
static SEL selSortMethod =NULL;

@interface CCSpriteBatchNode (private)
-(void) updateBlendFunc;
-(void) updateAtlasIndex:(CCSprite*) sprite currentIndex:(NSInteger*) curIndex;
-(void) swap:(NSInteger) oldIndex withNewIndex:(NSInteger) newIndex;

@end

@implementation CCSpriteBatchNode

@synthesize textureAtlas = textureAtlas_;
@synthesize blendFunc = blendFunc_;
@synthesize descendants = descendants_;


+(void) initialize
{
	if ( self == [CCSpriteBatchNode class] ) {
		selUpdate = @selector(updateTransform);
		selUpdateAtlasIndex = @selector(updateAtlasIndex:currentIndex:);
		selSortMethod = @selector(sortAllChildren);
	}
}
/*
 * creation with CCTexture2D
 */
+(id)batchNodeWithTexture:(CCTexture2D *)tex
{
	return [[[self alloc] initWithTexture:tex capacity:defaultCapacity] autorelease];
}

+(id)batchNodeWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity
{
	return [[[self alloc] initWithTexture:tex capacity:capacity] autorelease];
}

/*
 * creation with File Image
 */
+(id)batchNodeWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity
{
	return [[[self alloc] initWithFile:fileImage capacity:capacity] autorelease];
}

+(id)batchNodeWithFile:(NSString*) imageFile
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

		updateAtlasIndexMethod_ = (__typeof__(updateAtlasIndexMethod_)) [self methodForSelector:selUpdateAtlasIndex];
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
#ifdef __LP64__
	return [NSString stringWithFormat:@"<%@ = %p | Tag = %ld>", [self class], self, tag_ ];
#else
	return [NSString stringWithFormat:@"<%@ = %p | Tag = %d>", [self class], self, tag_ ];
#endif
}

-(void)dealloc
{
	[textureAtlas_ release];
	[descendants_ release];

	[super dealloc];
}

#pragma mark CCSpriteBatchNode - composition

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

	[self sortAllChildren];
	[self transform];
	[self draw];

	orderOfArrival_=0;

	if ( grid_ && grid_.active)
		[grid_ afterDraw:self];

	glPopMatrix();
}


// override addChild:
-(void) addChild:(CCSprite*)child z:(NSInteger)z tag:(NSInteger) aTag
{
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( [child isKindOfClass:[CCSprite class]], @"CCSpriteBatchNode only supports CCSprites as children");
	NSAssert( child.texture.name == textureAtlas_.texture.name, @"CCSprite is not using the same texture id");

	[super addChild:child z:z tag:aTag];

	[self appendChild:child];
}

// override reorderChild
-(void) reorderChild:(CCSprite*)child z:(NSInteger)z
{
	NSAssert( child != nil, @"Child must be non-nil");
	NSAssert( [children_ containsObject:child], @"Child doesn't belong to Sprite" );

	if( z == child.zOrder )
		return;

	//set the z-order and sort later
	[super reorderChild:child z:z];
}

// override removeChild:
-(void)removeChild: (CCSprite *)sprite cleanup:(BOOL)doCleanup
{
	// explicit nil handling
	if (sprite == nil)
		return;

	NSAssert([children_ containsObject:sprite], @"CCSpriteBatchNode doesn't contain the sprite. Can't remove it");

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
	// useSelfRender should be performed on all descendants. issue #1216
	[descendants_ makeObjectsPerformSelector:@selector(useSelfRender)];

	[super removeAllChildrenWithCleanup:doCleanup];

	[descendants_ removeAllObjects];
	[textureAtlas_ removeAllQuads];
}

//override sortAllChildren
- (void) sortAllChildren
{
	if (isReorderChildDirty_)
	{
		NSInteger i,j,length=children_->data->num;
		CCNode ** x=children_->data->arr;
		CCNode *tempItem;
		CCSprite *child;

		//insertion sort
		for(i=1; i<length; i++)
		{
			tempItem = x[i];
			j = i-1;

			//continue moving element downwards while zOrder is smaller or when zOrder is the same but orderOfArrival is smaller
			while(j>=0 && ( tempItem.zOrder < x[j].zOrder || ( tempItem.zOrder == x[j].zOrder && tempItem.orderOfArrival < x[j].orderOfArrival ) ) )
			{
				x[j+1] = x[j];
				j--;
			}

			x[j+1] = tempItem;
		}

		//sorted now check all children
		if ([children_ count] > 0)
		{
			//first sort all children recursively based on zOrder
			CCARRAY_FOREACH(children_, child) child->sortMethod(child,selSortMethod);

			NSInteger index=0;

			//fast dispatch, give every child a new atlasIndex based on their relative zOrder (keep parent -> child relations intact) and at the same time reorder descedants and the quads to the right index
			CCARRAY_FOREACH(children_, child) updateAtlasIndexMethod_(self,selUpdateAtlasIndex,child,&index);
		}

		isReorderChildDirty_=NO;
	}
}

-(void) updateAtlasIndex:(CCSprite*) sprite currentIndex:(NSInteger*) curIndex
{
	CCArray *array = [sprite children];
	NSUInteger count = [array count];
	NSInteger oldIndex;

	if( count == 0 )
	{
		oldIndex=sprite.atlasIndex;
		sprite.atlasIndex=*curIndex;
		sprite.orderOfArrival=0;
		if (oldIndex!=*curIndex)
			[self swap:oldIndex withNewIndex:*curIndex];
		(*curIndex)++;
	}
	else
	{
		BOOL needNewIndex=YES;

		if (((CCSprite*) (array->data->arr[0])).zOrder >= 0)
		{//all children are in front of the parent
			oldIndex=sprite.atlasIndex;
			sprite.atlasIndex=*curIndex;
			sprite.orderOfArrival=0;
			if (oldIndex!=*curIndex)
				[self swap:oldIndex withNewIndex:*curIndex];
			(*curIndex)++;

			needNewIndex=NO;
		}

		CCSprite* child;
		CCARRAY_FOREACH(array,child)
		{
			if (needNewIndex && child.zOrder >= 0)
			{
				oldIndex=sprite.atlasIndex;
				sprite.atlasIndex=*curIndex;
				sprite.orderOfArrival=0;
				if (oldIndex!=*curIndex)
					[self swap:oldIndex withNewIndex:*curIndex];
				(*curIndex)++;
				needNewIndex=NO;

			}
			//fast dispatch
			updateAtlasIndexMethod_(self,selUpdateAtlasIndex,child,curIndex);
		}

		if (needNewIndex)
		{//all children have a zOrder < 0)
			oldIndex=sprite.atlasIndex;
			sprite.atlasIndex=*curIndex;
			sprite.orderOfArrival=0;
			if (oldIndex!=*curIndex)
				[self swap:oldIndex withNewIndex:*curIndex];
			(*curIndex)++;
		}
	}
}

- (void) swap:(NSInteger) oldIndex withNewIndex:(NSInteger) newIndex
{
	id* x=descendants_->data->arr;
	ccV3F_C4B_T2F_Quad* quads=textureAtlas_.quads;

	id tempItem=x[oldIndex];
	ccV3F_C4B_T2F_Quad tempItemQuad=quads[oldIndex];

	//update the index of other swapped item
	((CCSprite*) x[newIndex]).atlasIndex=oldIndex;

	x[oldIndex]=x[newIndex];
	quads[oldIndex]=quads[newIndex];
	x[newIndex]=tempItem;
	quads[newIndex]=tempItemQuad;
}

- (void) reorderBatch:(BOOL) reorder
{
	isReorderChildDirty_=reorder;
}

#pragma mark CCSpriteBatchNode - draw
-(void) draw
{
	[super draw];

	// Optimization: Fast Dispatch
	if( textureAtlas_.totalQuads == 0 )
		return;

	CCSprite *child;
	ccArray *array = descendants_->data;

	NSUInteger i = array->num;
	id *arr = array->arr;

	if( i > 0 ) {

		while (i-- > 0) {
			child = *arr++;

			// fast dispatch
			child->updateMethod(child, selUpdate);

#if CC_SPRITEBATCHNODE_DEBUG_DRAW
			//Issue #528, 1069
			ccV3F_C4B_T2F_Quad *quads = [textureAtlas_ quads];
			ccV3F_C4B_T2F_Quad *quad= &(quads[child.atlasIndex]);
			CGPoint vertices[4]={
				ccp(quad->tl.vertices.x,quad->tl.vertices.y),
				ccp(quad->bl.vertices.x,quad->bl.vertices.y),
				ccp(quad->br.vertices.x,quad->br.vertices.y),
				ccp(quad->tr.vertices.x,quad->tr.vertices.y),
			};
			ccDrawPoly(vertices, 4, YES);
#endif // CC_SPRITEBATCHNODE_DEBUG_DRAW
		}
	}

	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: -

	BOOL newBlend = blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST;
	if( newBlend )
		glBlendFunc( blendFunc_.src, blendFunc_.dst );

	[textureAtlas_ drawQuads];
	if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
}

#pragma mark CCSpriteBatchNode - private
-(void) increaseAtlasCapacity
{
	// if we're going beyond the current TextureAtlas's capacity,
	// all the previously initialized sprites will need to redo their texture coords
	// this is likely computationally expensive
	NSUInteger quantity = (textureAtlas_.capacity + 1) * 4 / 3;

	CCLOG(@"cocos2d: CCSpriteBatchNode: resizing TextureAtlas capacity from [%lu] to [%lu].",
		  (long)textureAtlas_.capacity,
		  (long)quantity);


	if( ! [textureAtlas_ resizeCapacity:quantity] ) {
		// serious problems
		CCLOG(@"cocos2d: WARNING: Not enough memory to resize the atlas");
		NSAssert(NO,@"XXX: CCSpriteBatchNode#increaseAtlasCapacity SHALL handle this assert");
	}
}


#pragma mark CCSpriteBatchNode - Atlas Index Stuff

-(NSUInteger) rebuildIndexInOrder:(CCSprite*)node atlasIndex:(NSUInteger)index
{
	CCSprite *sprite;
	CCARRAY_FOREACH(node.children, sprite){
		if( sprite.zOrder < 0 )
			index = [self rebuildIndexInOrder:sprite atlasIndex:index];
	}

	// ignore self (batch node)
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
	NSUInteger count = [array count];
	if( count == 0 )
		return sprite.atlasIndex;
	else
		return [self highestAtlasIndexInChild:[array lastObject]];
}

-(NSUInteger) lowestAtlasIndexInChild:(CCSprite*)sprite
{
	CCArray *array = [sprite children];
	NSUInteger count = [array count];
	if( count == 0 )
		return sprite.atlasIndex;
	else
		return [self lowestAtlasIndexInChild:[array objectAtIndex:0] ];
}


-(NSUInteger)atlasIndexForChild:(CCSprite*)sprite atZ:(NSInteger)z
{
	CCArray *brothers = [[sprite parent] children];
	NSUInteger childIndex = [brothers indexOfObject:sprite];

	// ignore parent Z if parent is batchnode
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
		if( ( previous.zOrder < 0 && z < 0 )|| (previous.zOrder >= 0 && z >= 0) )
			return [self highestAtlasIndexInChild:previous] + 1;

		// else (previous < 0 and sprite >= 0 )
		CCSprite *p = (CCSprite*) sprite.parent;
		return p.atlasIndex + 1;
	}

	NSAssert( NO, @"Should not happen. Error calculating Z on Batch Node");
	return 0;
}

#pragma mark CCSpriteBatchNode - add / remove / reorder helper methods
// add child helper
-(void) insertChild:(CCSprite*)sprite inAtlasAtIndex:(NSUInteger)index
{
	[sprite useBatchNode:self];
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
		NSUInteger idx = [self atlasIndexForChild:child atZ: child.zOrder];
		[self insertChild:child inAtlasAtIndex:idx];
	}
}

// addChild helper, faster than insertChild
-(void) appendChild:(CCSprite*)sprite
{
	isReorderChildDirty_=YES;
	[sprite useBatchNode:self];
	[sprite setDirty: YES];

	if(textureAtlas_.totalQuads == textureAtlas_.capacity)
		[self increaseAtlasCapacity];

	ccArray *descendantsData = descendants_->data;

	ccArrayAppendObjectWithResize(descendantsData, sprite);

	NSUInteger index=descendantsData->num-1;

	sprite.atlasIndex=index;

	ccV3F_C4B_T2F_Quad quad = [sprite quad];
	[textureAtlas_ insertQuad:&quad atIndex:index];

	// add children recursively
	CCSprite* child;
	CCARRAY_FOREACH(sprite.children, child) [self appendChild:child];
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

#pragma mark CCSpriteBatchNode - CocosNodeTexture protocol

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
