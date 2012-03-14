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
#import "CCGrid.h"
#import "Support/CGPointExtension.h"
#import "CCParticleSystem.h"
#import "CCParticleSystem.h"
#import "CCParticleSystemPoint.h"

#import "Support/base64.h"
#import "Support/ZipUtils.h"
#import "Support/CCFileUtils.h"

#define kDefaultCapacity 500

//need to set z-order manualy, because fast reordering of childs would be complexer / slower
@implementation CCNode (extension)
-(void) setZOrder:(NSUInteger) z
{
	zOrder_ = z; 	
}
@end

@interface CCParticleBatchNode (private)
-(void) updateAllAtlasIndexes;
-(void) increaseAtlasCapacityTo:(NSUInteger) quantity;
-(NSUInteger) searchNewPositionInChildrenForZ:(NSInteger) z;
-(NSUInteger) addChildHelper: (CCNode*) child z:(NSInteger)z tag:(NSInteger) aTag;
-(void) moveSystem:(CCParticleSystem*) system toNewIndex:(NSUInteger) newIndex;
@end

@implementation CCParticleBatchNode

@synthesize textureAtlas = textureAtlas_;
@synthesize blendFunc = blendFunc_;

+(BOOL) extractTextureFromPlist:(NSString*) plistFile
{
	NSString *path = [CCFileUtils fullPathFromRelativePath:plistFile];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	
	NSAssert( dict != nil, @"ParticleBatchNode: plist file not found");
	
	NSString *textureName = [dict valueForKey:@"textureFileName"];
	
	CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:textureName];
	
	if( !tex )
	{
		NSString *textureData = [dict valueForKey:@"textureImageData"];
		NSAssert( textureData, @"CCuseQuad: Couldn't load texture");
		
		// if it fails, try to get it from the base64-gzipped data			
		unsigned char *buffer = NULL;
		int len = base64Decode((unsigned char*)[textureData UTF8String], (unsigned int)[textureData length], &buffer);
		NSAssert( buffer != NULL, @"CCuseQuad: error decoding textureImageData");
		
		unsigned char *deflated = NULL;
		NSUInteger deflatedLen = ccInflateMemory(buffer, len, &deflated);
		free( buffer );
		
		NSAssert( deflated != NULL, @"CCuseQuad: error ungzipping textureImageData");
		NSData *data = [[NSData alloc] initWithBytes:deflated length:deflatedLen];
		
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		UIImage *image = [[UIImage alloc] initWithData:data];
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		NSBitmapImageRep *image = [[NSBitmapImageRep alloc] initWithData:data];
#endif
		
		free(deflated); deflated = NULL;
		
		tex = [ [CCTextureCache sharedTextureCache] addCGImage:[image CGImage] forKey:textureName];
		[data release];
		[image release];
	}
	if (tex) return YES; 
	else return NO;
}

/*
 * creation with CCTexture2D
 */
+(id)particleBatchNodeWithTexture:(CCTexture2D *)tex
{
	return [[[self alloc] initWithTexture:tex capacity:kDefaultCapacity useQuad:YES additiveBlending:NO] autorelease];
}

+(id)particleBatchNodeWithTexture:(CCTexture2D *)tex capacity:(NSUInteger) capacity useQuad:(BOOL) useQuad additiveBlending:(BOOL) additive
{
	return [[[self alloc] initWithTexture:tex capacity:capacity useQuad:YES additiveBlending:additive] autorelease];
}

/*
 * creation with File Image
 */
+(id)particleBatchNodeWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity useQuad:(BOOL) useQuad additiveBlending:(BOOL) additive
{
	return [[[self alloc] initWithFile:fileImage capacity:capacity useQuad:useQuad additiveBlending:additive] autorelease];
}

+(id)particleBatchNodeWithFile:(NSString*) imageFile
{
	return [[[self alloc] initWithFile:imageFile capacity:kDefaultCapacity useQuad:YES additiveBlending:NO] autorelease];
}

/*
 * init with CCTexture2D
 */
-(id)initWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)capacity useQuad:(BOOL) useQuad additiveBlending:(BOOL) additive
{
	if (self = [super init])
	{
		useQuad_ = useQuad; 
		reorderDirty_ = NO;
		
		//TODO initialize point atlas here
		if (useQuad_) textureAtlas_ = [[CCTextureAtlas alloc] initWithTexture:tex capacity:capacity];
		
		if (additive) [self additiveBlending];
		else [self normalBlending];
		
		// no lazy alloc in this node
		children_ = [[CCArray alloc] initWithCapacity:5];
	}

	return self;
}

/*
 * init with FileImage
 */
-(id)initWithFile:(NSString *)fileImage capacity:(NSUInteger)capacity useQuad:(BOOL) useQuad additiveBlending:(BOOL) additive
{
	CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:fileImage];
	return [self initWithTexture:tex capacity:capacity useQuad:useQuad additiveBlending:additive];
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Tag = %i>", [self class], self, tag_ ];
}

-(void)dealloc
{	
	[textureAtlas_ release];
	[super dealloc];
}

#pragma mark CCParticleBatchNode - composition

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
	
	//update of particle system is called before reordering is done, data in texture atlas is not up to date yet, need to set quads again according to new atlasIndexes
	if (reorderDirty_) 
	{	
		[children_ makeObjectsPerformSelector:@selector(updateWithNoTime)];
		reorderDirty_ = NO;	
	}
	[self transform];
	
	[self draw];
		
	if ( grid_ && grid_.active)
		[grid_ afterDraw:self];
	
	glPopMatrix();
}

// override addChild:
-(void) addChild:(CCParticleSystem*)child z:(NSInteger)z tag:(NSInteger) aTag
{
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( [child isKindOfClass:[CCParticleSystem class]], @"CCParticleBatchNode only supports CCQuadParticleSystems as children");
	
	if (useQuad_) 
	{	
		NSAssert( child.texture.name == textureAtlas_.texture.name, @"CCParticleSystem is not using the same texture id");
	}
	
	//no lazy sorting, so don't call super addChild, call helper instead
	NSUInteger pos = [self addChildHelper:child z:z tag:aTag];
	
	//get new atlasIndex
	NSUInteger atlasIndex;
	
	if (pos != 0)
		atlasIndex = [[children_ objectAtIndex:pos-1] atlasIndex]+[[children_ objectAtIndex:pos-1] totalParticles];
	else
		atlasIndex = 0;
	
	[child useBatchNode:self];
	
	[self insertChild:child inAtlasAtIndex:atlasIndex];
}

//don't use lazy sorting, reordering the particle systems quads afterwards would be too complex
//XXX research whether lazy sorting + freeing current quads and calloc a new block with size of capacity would be faster
//XXX or possibly using vertexZ for reordering, that would be fastest
//this helper is almost equivalent to CCNode's addChild, but doesn't make use of the lazy sorting
-(NSUInteger) addChildHelper: (CCNode*) child z:(NSInteger)z tag:(NSInteger) aTag
{	
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( child.parent == nil, @"child already added. It can't be added again");
	
	if( ! children_ )
		children_ = [[CCArray alloc] initWithCapacity:4];
			
	//don't use a lazy insert
	NSUInteger pos = [self searchNewPositionInChildrenForZ:z];
	
	[children_ insertObject:child atIndex:pos];
	
	child.tag = aTag;
	[child setZOrder:z]; 
	
	[child setParent: self];
		
	if( isRunning_ ) {
		[child onEnter];
		[child onEnterTransitionDidFinish];
	}
	return pos;
}

// override reorderChild
-(void) reorderChild:(CCParticleSystem*)child z:(NSInteger)z
{
	NSAssert( child != nil, @"Child must be non-nil");
	NSAssert( [children_ containsObject:child], @"Child doesn't belong to Sprite" );
	
	if( z == child.zOrder )
		return;
	
	if ([children_ count] == 1) [child setZOrder:z];
	else
	{	
		reorderDirty_ = YES;
		[child retain]; 
		
		NSUInteger oldPos = [children_ indexOfObject:child]; 

		//only remove the child, not the scheduled update 
		[children_ removeObject:child]; 
		
		NSUInteger pos = [self searchNewPositionInChildrenForZ:z]; 
		
		if (pos != oldPos)
		{
			NSUInteger newIndex;
			if (pos == [children_ count])
				newIndex = textureAtlas_.totalQuads;
			else
				newIndex = [[children_ objectAtIndex:MIN([children_ count]-1,pos)] atlasIndex];
			
			//to correctly move the quads, the new index needs to be the left border of where the quads will be placed
			if (z > child.zOrder)
				newIndex -= child.totalParticles;
			
			 //move quads in textureAtlas
			[self moveSystem:child toNewIndex:newIndex]; 
		}
		[children_ insertObject:child atIndex:pos];  
		
		[child release];
		
		//renew atlasIndexes of children
		[self updateAllAtlasIndexes];
	}
}
					 
-(NSUInteger) searchNewPositionInChildrenForZ: (NSInteger) z
{
	int i = 0;
	NSUInteger count = [children_ count];
	CCNode* child;
	
	while (i < count) 
	{
		child = [children_ objectAtIndex:i];
		if (child.zOrder > z) return MAX(0,(i-1));
		
		i++;
	}

	if (z >= 0) return MAX(0,count);
	else return 0;
}

// override removeChild:
-(void)removeChild: (CCParticleSystem*) child cleanup:(BOOL) doCleanup
{
	// explicit nil handling
	if (child == nil)
		return;
	
	NSAssert([children_ containsObject:child], @"CCParticleBatchNode doesn't contain the sprite. Can't remove it");
	
	// cleanup before removing, issue 1316 clean before calling super
	[self removeChildFromAtlas:child cleanup:doCleanup];
	
	[super removeChild:child cleanup:doCleanup];
	
	[self updateAllAtlasIndexes];
}

-(void)removeChildAtIndex:(NSUInteger)index cleanup:(BOOL) doCleanup
{
	[self removeChild:(CCParticleSystem *)[children_ objectAtIndex:index] cleanup:doCleanup];
}

-(void)removeAllChildrenWithCleanup:(BOOL)doCleanup
{
	[children_ makeObjectsPerformSelector:@selector(useSelfRender)];
	
	[super removeAllChildrenWithCleanup:doCleanup];
	
	[textureAtlas_ removeAllQuads];
}

#pragma mark CCParticleBatchNode - draw
-(void) draw
{
	//don't call super draw, it's empty
	//[super draw];
	
	if( textureAtlas_.totalQuads == 0 )
		return;	

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

#pragma mark CCParticleBatchNode - private

-(void) increaseAtlasCapacityTo:(NSUInteger) quantity
{
	CCLOG(@"cocos2d: CCParticleBatchNode: resizing TextureAtlas capacity from [%lu] to [%lu].",
		  (long)textureAtlas_.capacity,
		  (long)quantity);
		
	if( ! [textureAtlas_ resizeCapacity:quantity] ) {
		// serious problems
		CCLOG(@"cocos2d: WARNING: Not enough memory to resize the atlas");
		NSAssert(NO,@"XXX: CCParticleBatchNode #increaseAtlasCapacity SHALL handle this assert");
	}	
}

-(void) moveSystem:(CCParticleSystem*) system toNewIndex:(NSUInteger) newIndex
{
	[textureAtlas_ insertQuadsFromIndex:system.atlasIndex amount:system.totalParticles atIndex:newIndex];
}

//sets a 0'd quad into the quads array
-(void) disableParticle:(NSUInteger) particleIndex
{
	ccV3F_C4B_T2F_Quad* quad = &((textureAtlas_.quads)[particleIndex]);
	quad->br.vertices.x = quad->br.vertices.y = quad->tr.vertices.x = quad->tr.vertices.y = quad->tl.vertices.x = quad->tl.vertices.y = quad->bl.vertices.x = quad->bl.vertices.y = 0.0f;		
}

#pragma mark CCParticleBatchNode - add / remove / reorder helper methods

// add child helper
-(void) insertChild:(CCParticleSystem*) pSystem inAtlasAtIndex:(NSUInteger)index
{
	pSystem.atlasIndex = index;
	
	if(textureAtlas_.totalQuads + pSystem.totalParticles > textureAtlas_.capacity)
	{	
		[self increaseAtlasCapacityTo:textureAtlas_.totalQuads + pSystem.totalParticles];
		
		//after a realloc empty quads of textureAtlas can be filled with gibberish (realloc doesn't perform calloc), insert empty quads to prevent it
		[textureAtlas_ fillWithEmptyQuadsFromIndex:textureAtlas_.capacity - pSystem.totalParticles amount:pSystem.totalParticles];
	}
	
	if (useQuad_) 
	{	
		//make room for quads, not necessary for last child		
		if (pSystem.atlasIndex+pSystem.totalParticles != textureAtlas_.totalQuads) [textureAtlas_ moveQuadsFromIndex:index to:index+pSystem.totalParticles];
		
		//increase totalParticles here for new particles, update method of particlesystem will fill the quads
		[textureAtlas_ increaseTotalQuadsWith:pSystem.totalParticles];
		
		[pSystem batchNodeInitialization];
	}
	
	[self updateAllAtlasIndexes];
}

// remove child helper
-(void) removeChildFromAtlas:(CCParticleSystem*) pSystem cleanup:(BOOL) doCleanUp
{
	[textureAtlas_ removeQuadsAtIndex:pSystem.atlasIndex amount:pSystem.totalParticles];
	
	//after memove of data, empty the quads at the end of array
	[textureAtlas_ fillWithEmptyQuadsFromIndex:textureAtlas_.totalQuads amount:pSystem.totalParticles];
	
	//with no cleanup the particle system could be reused for self rendering
	if (!doCleanUp) [pSystem useSelfRender];
	
}

//rebuild atlas indexes
-(void) updateAllAtlasIndexes
{
	CCParticleSystem* child;
	uint index = 0;

	CCARRAY_FOREACH(children_,child)
	{
		child.atlasIndex = index; 
		index += child.totalParticles;
	}
}	
	
#pragma mark CCParticleBatchNode - CocosNodeTexture protocol

-(void) additiveBlending
{
	blendFunc_.src = GL_SRC_ALPHA;
	blendFunc_.dst = GL_ONE;		
}

-(void) normalBlending
{
	if( ! [textureAtlas_.texture hasPremultipliedAlpha] ) {
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
	else 
	{
		blendFunc_.src = GL_ONE;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;	
	}
}

-(void) switchBlendingBetweenMultipliedAndPreMultiplied
{
	if (blendFunc_.src == GL_ONE) 
	{
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
	else 
	{
		blendFunc_.src = GL_ONE;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;	
	}
}

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
			
	// If the new texture has No premultiplied alpha, AND the blendFunc hasn't been changed, then update it
	if( texture && ! [texture hasPremultipliedAlpha] && ( blendFunc_.src == CC_BLEND_SRC && blendFunc_.dst == CC_BLEND_DST ) ) 
	{
			blendFunc_.src = GL_SRC_ALPHA;
			blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
}

-(CCTexture2D*) texture
{
	return textureAtlas_.texture;
}

@end