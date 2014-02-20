/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Matt Oswald
 * Copyright (c) 2009-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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
#import "CCTextureCache.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "ccGLStateCache.h"
#import "CCDirector.h"
#import "Support/CGPointExtension.h"
#import "Support/CCProfiling.h"
#import "CCSprite_Private.h"

#import "CCNode_Private.h"
#import "CCSpriteBatchNode_Private.h"

#import "CCTexture_Private.h"

const NSUInteger defaultCapacity = 0;

#pragma mark -
#pragma mark CCSpriteBatchNode

@interface CCSpriteBatchNode (private)
-(void) updateAtlasIndex:(CCSprite*) sprite currentIndex:(NSInteger*) curIndex;
-(void) swap:(NSInteger) oldIndex withNewIndex:(NSInteger) newIndex;
-(void) updateBlendFunc;
@end

@implementation CCSpriteBatchNode

@synthesize textureAtlas = _textureAtlas;
@synthesize blendFunc = _blendFunc;
@synthesize descendants = _descendants;


/*
 * creation with CCTexture2D
 */
+(id)batchNodeWithTexture:(CCTexture *)tex
{
	return [[self alloc] initWithTexture:tex capacity:defaultCapacity];
}

+(id)batchNodeWithTexture:(CCTexture *)tex capacity:(NSUInteger)capacity
{
	return [[self alloc] initWithTexture:tex capacity:capacity];
}

/*
 * creation with File Image
 */
+(id)batchNodeWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity
{
	return [[self alloc] initWithFile:fileImage capacity:capacity];
}

+(id)batchNodeWithFile:(NSString*) imageFile
{
	return [[self alloc] initWithFile:imageFile capacity:defaultCapacity];
}

-(id)init
{
    return [self initWithTexture:[[CCTexture alloc] init] capacity:0];
}

-(id)initWithFile:(NSString *)fileImage capacity:(NSUInteger)capacity
{
	CCTexture *tex = [[CCTextureCache sharedTextureCache] addImage:fileImage];
	return [self initWithTexture:tex capacity:capacity];
}

// Designated initializer
-(id)initWithTexture:(CCTexture *)tex capacity:(NSUInteger)capacity
{
	if( (self=[super init])) {

		_blendFunc.src = CC_BLEND_SRC;
		_blendFunc.dst = CC_BLEND_DST;
		_textureAtlas = [[CCTextureAtlas alloc] initWithTexture:tex capacity:capacity];

		[self updateBlendFunc];

		// no lazy alloc in this node
		_children = [[NSMutableArray alloc] initWithCapacity:capacity];
		_descendants = [[NSMutableArray alloc] initWithCapacity:capacity];

		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColor];
	}

	return self;
}


- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Tag = %@>", [self class], self, _name ];
}


#pragma mark CCSpriteBatchNode - composition

// override visit.
// Don't call visit on its children
//-(void) visit:(GLKMatrix4)parentTransform
//#warning TODO
//{
//	CC_PROFILER_START_CATEGORY(kCCProfilerCategoryBatchSprite, @"CCSpriteBatchNode - visit");
//
//	NSAssert(_parent != nil, @"CCSpriteBatchNode should NOT be root node");
//    
//	// CAREFUL:
//	// This visit is almost identical to CCNode#visit
//	// with the exception that it doesn't call visit on its children
//	//
//	// The alternative is to have a void CCSprite#visit, but
//	// although this is less mantainable, is faster
//	//
//	if (!_visible)
//		return;
//
//	[self sortAllChildren];
//	GLKMatrix4 transform = [self transform:parentTransform];
//	[self draw:transform];
//
//	_orderOfArrival = 0;
//
//	CC_PROFILER_STOP_CATEGORY(kCCProfilerCategoryBatchSprite, @"CCSpriteBatchNode - visit");
//}

// override addChild:
-(void) addChild:(CCSprite*)child z:(NSInteger)z name:(NSString*) name
{
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( [child isKindOfClass:[CCSprite class]], @"CCSpriteBatchNode only supports CCSprites as children");
    
    if(child.texture) {
        NSAssert( (child.texture.name == _textureAtlas.texture.name), @"CCSprite is not using the same texture id");
    }

	[super addChild:child z:z name:name];

	[self appendChild:child];
}

// override reorderChild
-(void) reorderChild:(CCSprite*)child z:(NSInteger)z
{
	NSAssert( child != nil, @"Child must be non-nil");
	NSAssert( [_children containsObject:child], @"Child doesn't belong to Sprite" );

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

	NSAssert([_children containsObject:sprite], @"CCSpriteBatchNode doesn't contain the sprite. Can't remove it");

	// cleanup before removing
	[self removeSpriteFromAtlas:sprite];

	[super removeChild:sprite cleanup:doCleanup];
}

-(void)removeChildAtIndex:(NSUInteger)index cleanup:(BOOL)doCleanup
{
	[self removeChild:(CCSprite *)[_children objectAtIndex:index] cleanup:doCleanup];
}

-(void)removeAllChildrenWithCleanup:(BOOL)doCleanup
{
	// Invalidate atlas index. issue #569
	// useSelfRender should be performed on all descendants. issue #1216
	[_descendants makeObjectsPerformSelector:@selector(setBatchNode:) withObject:nil];

	[super removeAllChildrenWithCleanup:doCleanup];

	[_descendants removeAllObjects];
	[_textureAtlas removeAllQuads];
}

//override sortAllChildren
- (void) sortAllChildren
{
	if (_isReorderChildDirty)
	{
        [_children sortUsingSelector:@selector(compareZOrderToNode:)];
        
        /*
		NSInteger i,j,length = _children->data->num;
		CCNode ** x = _children->data->arr;
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
		}*/

		//sorted now check all children
		if ([_children count] > 0)
		{
			//first sort all children recursively based on zOrder
			[_children makeObjectsPerformSelector:@selector(sortAllChildren)];

			NSInteger index=0;

			//fast dispatch, give every child a new atlasIndex based on their relative zOrder (keep parent -> child relations intact)
			// and at the same time reorder descedants and the quads to the right index
            for (CCSprite* child in _children)
				[self updateAtlasIndex:child currentIndex:&index];
		}

		_isReorderChildDirty=NO;
	}
}

-(void) updateAtlasIndex:(CCSprite*) sprite currentIndex:(NSInteger*) curIndex{}

- (void) swap:(NSInteger) oldIndex withNewIndex:(NSInteger) newIndex{}

- (void) reorderBatch:(BOOL) reorder
{
	_isReorderChildDirty=reorder;
}

#pragma mark CCSpriteBatchNode - draw
//-(void) draw:(CCRenderer *)renderer transform:(GLKMatrix4)transform
//{
//	CC_PROFILER_START(@"CCSpriteBatchNode - draw");
//
//	// Optimization: Fast Dispatch
//	if( _textureAtlas.totalQuads == 0 )
//		return;
//
//	CC_NODE_DRAW_SETUP(transform);
//
//	[_children makeObjectsPerformSelector:@selector(updateTransform)];
//
//	ccGLBlendFunc( _blendFunc.src, _blendFunc.dst );
//
//	[_textureAtlas drawQuads];
//
//	CC_PROFILER_STOP(@"CCSpriteBatchNode - draw");
//}

#pragma mark CCSpriteBatchNode - private
-(void) increaseAtlasCapacity
{
	// if we're going beyond the current CCTextureAtlas's capacity,
	// all the previously initialized sprites will need to redo their texture coords
	// this is likely computationally expensive
	NSUInteger quantity = (_textureAtlas.capacity + 1) * 4 / 3;

	CCLOG(@"cocos2d: CCSpriteBatchNode: resizing TextureAtlas capacity from [%lu] to [%lu].",
		  (long)_textureAtlas.capacity,
		  (long)quantity);


	if( ! [_textureAtlas resizeCapacity:quantity] ) {
		// serious problems
		CCLOGWARN(@"cocos2d: WARNING: Not enough memory to resize the atlas");
		NSAssert(NO,@"XXX: CCSpriteBatchNode#increaseAtlasCapacity SHALL handle this assert");
	}
}


#pragma mark CCSpriteBatchNode - Atlas Index Stuff

-(NSUInteger) rebuildIndexInOrder:(CCSprite*)node atlasIndex:(NSUInteger)index{}

-(NSUInteger) highestAtlasIndexInChild:(CCSprite*)sprite{}

-(NSUInteger) lowestAtlasIndexInChild:(CCSprite*)sprite{}


-(NSUInteger)atlasIndexForChild:(CCSprite*)sprite atZ:(NSInteger)z{}

#pragma mark CCSpriteBatchNode - add / remove / reorder helper methods
// add child helper
-(void) insertChild:(CCSprite*)sprite inAtlasAtIndex:(NSUInteger)index{}

// addChild helper, faster than insertChild
-(void) appendChild:(CCSprite*)sprite{}


// remove child helper
-(void) removeSpriteFromAtlas:(CCSprite*)sprite{}

#pragma mark CCSpriteBatchNode - CocosNodeTexture protocol

-(void) updateBlendFunc
{
	if( ! [_textureAtlas.texture hasPremultipliedAlpha] ) {
		_blendFunc.src = GL_SRC_ALPHA;
		_blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
}

-(void) setTexture:(CCTexture*)texture
{
	_textureAtlas.texture = texture;
	[self updateBlendFunc];
}

-(CCTexture*) texture
{
	return _textureAtlas.texture;
}
@end

#pragma mark - CCSpriteBatchNode Extension


@implementation CCSpriteBatchNode (QuadExtension)

-(void) insertQuadFromSprite:(CCSprite*)sprite quadIndex:(NSUInteger)index{}

-(void) updateQuadFromSprite:(CCSprite*)sprite quadIndex:(NSUInteger)index{}


-(id) addSpriteWithoutQuad:(CCSprite*)child z:(NSUInteger)z name:(NSString*)name{}
@end

