/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Matt Oswald
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Copyright (c) 2011 Marco Tillemans
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

#import "CCParticleBatchNode.h"
#import "CCTextureCache.h"
#import "CCTextureAtlas.h"
#import "ccConfig.h"
#import "ccMacros.h"
#import "Support/CGPointExtension.h"
#import "CCParticleSystem.h"
#import "CCParticleSystem.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "ccGLStateCache.h"

#import "Support/base64.h"
#import "Support/ZipUtils.h"
#import "Support/CCFileUtils.h"

#import "kazmath/GL/matrix.h"

#import "CCNode_Private.h"
#import "CCParticleSystem_Private.h"

#import "CCTexture_Private.h"

#define kCCParticleDefaultCapacity 500

@interface CCNode()
-(void) _setZOrder:(NSInteger)z;
@end

@interface CCParticleBatchNode (private)
-(void) updateAllAtlasIndexes;
-(void) increaseAtlasCapacityTo:(NSUInteger) quantity;
-(NSUInteger) searchNewPositionInChildrenForZ:(NSInteger)z;
-(void) getCurrentIndex:(NSUInteger*)oldIndex newIndex:(NSUInteger*)newIndex forChild:(CCNode*)child z:(NSInteger)z;
-(NSUInteger) addChildHelper: (CCNode*) child z:(NSInteger)z tag:(NSInteger) aTag;
@end

@implementation CCParticleBatchNode

@synthesize textureAtlas = _textureAtlas;
@synthesize blendFunc = _blendFunc;

/*
 * creation with CCTexture2D
 */
+(id)batchNodeWithTexture:(CCTexture *)tex
{
	return [[self alloc] initWithTexture:tex capacity:kCCParticleDefaultCapacity];
}

+(id)batchNodeWithTexture:(CCTexture *)tex capacity:(NSUInteger) capacity
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
	return [[self alloc] initWithFile:imageFile capacity:kCCParticleDefaultCapacity];
}

/*
 * init with CCTexture2D
 */
-(id)initWithTexture:(CCTexture *)tex capacity:(NSUInteger)capacity
{
	if (self = [super init])
	{
		_textureAtlas = [[CCTextureAtlas alloc] initWithTexture:tex capacity:capacity];

		// no lazy alloc in this node
		_children = [[NSMutableArray alloc] initWithCapacity:capacity];

		_blendFunc.src = CC_BLEND_SRC;
		_blendFunc.dst = CC_BLEND_DST;

		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColor];
	}

	return self;
}

/*
 * init with FileImage
 */
-(id)initWithFile:(NSString *)fileImage capacity:(NSUInteger)capacity
{
	CCTexture *tex = [[CCTextureCache sharedTextureCache] addImage:fileImage];
	return [self initWithTexture:tex capacity:capacity];
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Tag = %@>", [self class], self, _name ];
}


#pragma mark CCParticleBatchNode - composition

// override visit.
// Don't call visit on it's children
-(void) visit
{
	// CAREFUL:
	// This visit is almost identical to CCNode#visit
	// with the exception that it doesn't call visit on it's children
	//
	// The alternative is to have a void CCSprite#visit, but
	// although this is less mantainable, is faster
	//
	if (!_visible)
		return;

	kmGLPushMatrix();

	[self transform];

	[self draw];

	kmGLPopMatrix();
}

// override addChild:
-(void) addChild:(CCParticleSystem*)child z:(NSInteger)z tag:(NSInteger) aTag
{
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( [child isKindOfClass:[CCParticleSystem class]], @"CCParticleBatchNode only supports CCQuadParticleSystems as children");
	NSAssert( child.texture.name == _textureAtlas.texture.name, @"CCParticleSystem is not using the same texture id");

	// If this is the 1st children, then copy blending function
	if( [_children count] == 0 )
		_blendFunc = [child blendFunc];

	NSAssert( _blendFunc.src  == child.blendFunc.src && _blendFunc.dst  == child.blendFunc.dst, @"Can't add a PaticleSystem that uses a differnt blending function");

	//no lazy sorting, so don't call super addChild, call helper instead
	NSUInteger pos = [self addChildHelper:child z:z tag:aTag];

	//get new atlasIndex
	NSUInteger atlasIndex;

	if (pos != 0)
		atlasIndex = [[_children objectAtIndex:pos-1] atlasIndex] + [[_children objectAtIndex:pos-1] totalParticles];
	else
		atlasIndex = 0;

	[self insertChild:child inAtlasAtIndex:atlasIndex];

	// update quad info
	[child setBatchNode:self];
}

// don't use lazy sorting, reordering the particle systems quads afterwards would be too complex
// XXX research whether lazy sorting + freeing current quads and calloc a new block with size of capacity would be faster
// XXX or possibly using vertexZ for reordering, that would be fastest
// this helper is almost equivalent to CCNode's addChild, but doesn't make use of the lazy sorting
-(NSUInteger) addChildHelper: (CCNode*) child z:(NSInteger)z name:(NSString*) name
{
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( child.parent == nil, @"child already added. It can't be added again");

	if( ! _children )
		_children = [[NSMutableArray alloc] initWithCapacity:4];

	//don't use a lazy insert
	NSUInteger pos = [self searchNewPositionInChildrenForZ:z];

	[_children insertObject:child atIndex:pos];

	child.name = name;
	[child _setZOrder:z];

	[child setParent: self];

	if( _isInActiveScene ) {
		[child onEnter];
		[child onEnterTransitionDidFinish];
	}
	return pos;
}

// Reorder will be done in this function, no "lazy" reorder to particles
-(void) reorderChild:(CCParticleSystem*)child z:(NSInteger)z
{
	NSAssert( child != nil, @"Child must be non-nil");
	NSAssert( [_children containsObject:child], @"Child doesn't belong to batch" );

	if( z == child.zOrder )
		return;

	// no reordering if only 1 child
	if( [_children count] > 1)
	{
		NSUInteger newIndex = 0;
        NSUInteger oldIndex = 0;

		[self getCurrentIndex:&oldIndex newIndex:&newIndex forChild:child z:z];

		if( oldIndex != newIndex ) {

			// reorder _children array
			[_children removeObjectAtIndex:oldIndex];
			[_children insertObject:child atIndex:newIndex];

			// save old altasIndex
			NSUInteger oldAtlasIndex = child.atlasIndex;

			// update atlas index
			[self updateAllAtlasIndexes];

			// Find new AtlasIndex
			NSUInteger newAtlasIndex = 0;
			for( NSUInteger i=0;i < [_children count];i++) {
				CCParticleSystem *node = [_children objectAtIndex:i];
				if( node == child ) {
					newAtlasIndex = [child atlasIndex];
					break;
				}
			}

			// reorder textureAtlas quads
			[_textureAtlas moveQuadsFromIndex:oldAtlasIndex  amount:child.totalParticles atIndex:newAtlasIndex];

			[child updateWithNoTime];
		}
	}

	[child _setZOrder:z];
}

-(void) getCurrentIndex:(NSUInteger*)oldIndex newIndex:(NSUInteger*)newIndex forChild:(CCNode*)child z:(NSInteger)z
{
	BOOL foundCurrentIdx = NO;
	BOOL foundNewIdx = NO;

	NSInteger  minusOne = 0;
	NSUInteger count = [_children count];

	for( NSUInteger i=0; i < count; i++ ) {

		CCNode *node = [_children objectAtIndex:i];

		// new index
		if( node.zOrder > z &&  ! foundNewIdx ) {
			*newIndex = i;
			foundNewIdx = YES;

			if( foundCurrentIdx && foundNewIdx )
				break;
		}

		// current index
		if( child == node ) {
			*oldIndex = i;
			foundCurrentIdx = YES;

			if( ! foundNewIdx )
				minusOne = -1;

			if( foundCurrentIdx && foundNewIdx )
				break;

		}

	}

	if( ! foundNewIdx )
		*newIndex = count;

	*newIndex += minusOne;
}

-(NSUInteger) searchNewPositionInChildrenForZ: (NSInteger) z
{
	NSUInteger count = [_children count];

	for( NSUInteger i=0; i < count; i++ ) {
		CCNode *child = [_children objectAtIndex:i];
		if (child.zOrder > z)
			return i;
	}
	return count;
}

// override removeChild:
-(void)removeChild: (CCParticleSystem*) child cleanup:(BOOL)doCleanup
{
	// explicit nil handling
	if (child == nil)
		return;

	NSAssert([_children containsObject:child], @"CCParticleBatchNode doesn't contain the sprite. Can't remove it");

	[super removeChild:child cleanup:doCleanup];

	// remove child helper
	[_textureAtlas removeQuadsAtIndex:child.atlasIndex amount:child.totalParticles];

	// after memmove of data, empty the quads at the end of array
	[_textureAtlas fillWithEmptyQuadsFromIndex:_textureAtlas.totalQuads amount:child.totalParticles];

	// paticle could be reused for self rendering
	[child setBatchNode:nil];

	[self updateAllAtlasIndexes];
}

-(void)removeChildAtIndex:(NSUInteger)index cleanup:(BOOL) doCleanup
{
	[self removeChild:(CCParticleSystem *)[_children objectAtIndex:index] cleanup:doCleanup];
}

-(void)removeAllChildrenWithCleanup:(BOOL)doCleanup
{
	[_children makeObjectsPerformSelector:@selector(setBatchNode:) withObject:nil];

	[super removeAllChildrenWithCleanup:doCleanup];

	[_textureAtlas removeAllQuads];
}

#pragma mark CCParticleBatchNode - Node overrides
-(void) draw
{
	CC_PROFILER_STOP(@"CCParticleBatchNode - draw");

	if( _textureAtlas.totalQuads == 0 )
		return;

	CC_NODE_DRAW_SETUP();

	ccGLBlendFunc( _blendFunc.src, _blendFunc.dst );

	[_textureAtlas drawQuads];

	CC_PROFILER_STOP(@"CCParticleBatchNode - draw");
}

#pragma mark CCParticleBatchNode - private

-(void) increaseAtlasCapacityTo:(NSUInteger) quantity
{
	CCLOG(@"cocos2d: CCParticleBatchNode: resizing TextureAtlas capacity from [%lu] to [%lu].",
		  (long)_textureAtlas.capacity,
		  (long)quantity);

	if( ! [_textureAtlas resizeCapacity:quantity] ) {
		// serious problems
		CCLOGWARN(@"cocos2d: WARNING: Not enough memory to resize the atlas");
		NSAssert(NO,@"XXX: CCParticleBatchNode #increaseAtlasCapacity SHALL handle this assert");
	}
}

//sets a 0'd quad into the quads array
-(void) disableParticle:(NSUInteger)particleIndex
{
	ccV3F_C4B_T2F_Quad* quad = &((_textureAtlas.quads)[particleIndex]);
	quad->br.vertices.x = quad->br.vertices.y = quad->tr.vertices.x = quad->tr.vertices.y = quad->tl.vertices.x = quad->tl.vertices.y = quad->bl.vertices.x = quad->bl.vertices.y = 0.0f;
}

#pragma mark CCParticleBatchNode - add / remove / reorder helper methods

// add child helper
-(void) insertChild:(CCParticleSystem*) pSystem inAtlasAtIndex:(NSUInteger)index
{
	pSystem.atlasIndex = index;

	if(_textureAtlas.totalQuads + pSystem.totalParticles > _textureAtlas.capacity)
	{
		[self increaseAtlasCapacityTo:_textureAtlas.totalQuads + pSystem.totalParticles];

		// after a realloc empty quads of textureAtlas can be filled with gibberish (realloc doesn't perform calloc), insert empty quads to prevent it
		[_textureAtlas fillWithEmptyQuadsFromIndex:_textureAtlas.capacity - pSystem.totalParticles amount:pSystem.totalParticles];
	}

	// make room for quads, not necessary for last child
	if (pSystem.atlasIndex + pSystem.totalParticles != _textureAtlas.totalQuads)
		[_textureAtlas moveQuadsFromIndex:index to:index+pSystem.totalParticles];

	// increase totalParticles here for new particles, update method of particlesystem will fill the quads
	[_textureAtlas increaseTotalQuadsWith:pSystem.totalParticles];

	[self updateAllAtlasIndexes];
}

//rebuild atlas indexes
-(void) updateAllAtlasIndexes
{
	NSUInteger index = 0;

    for (CCParticleSystem *child in _children)
	{
		child.atlasIndex = index;
		index += child.totalParticles;
	}
}

#pragma mark CCParticleBatchNode - CocosNodeTexture protocol

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

	// If the new texture has No premultiplied alpha, AND the blendFunc hasn't been changed, then update it
	if( texture && ! [texture hasPremultipliedAlpha] && ( _blendFunc.src == CC_BLEND_SRC && _blendFunc.dst == CC_BLEND_DST ) )
	{
			_blendFunc.src = GL_SRC_ALPHA;
			_blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
}

-(CCTexture*) texture
{
	return _textureAtlas.texture;
}

@end
