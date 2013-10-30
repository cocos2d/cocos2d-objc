/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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

// cocos2d
#import "CCTextureAtlas.h"
#import "ccMacros.h"
#import "CCTexture.h"
#import "CCTextureCache.h"
#import "CCGLProgram.h"
#import "ccGLStateCache.h"
#import "CCDirector.h"
#import "CCConfiguration.h"

#import "Support/NSThread+performBlock.h"
#import "Support/OpenGL_Internal.h"

#import "CCTexture_Private.h"

@interface CCTextureAtlas ()
-(void) setupIndices;

#if CC_TEXTURE_ATLAS_USE_VAO
-(void) setupVBOandVAO;
#else
-(void) setupVBO;
#endif
@end

//According to some tests GL_TRIANGLE_STRIP is slower, MUCH slower. Probably I'm doing something very wrong

@implementation CCTextureAtlas

@synthesize totalQuads = _totalQuads, capacity = _capacity;
@synthesize texture = _texture;
@synthesize quads = _quads;

#pragma mark TextureAtlas - alloc & init

+(id) textureAtlasWithFile:(NSString*) file capacity: (NSUInteger) n
{
	return [[self alloc] initWithFile:file capacity:n];
}

+(id) textureAtlasWithTexture:(CCTexture *)tex capacity:(NSUInteger)n
{
	return [[self alloc] initWithTexture:tex capacity:n];
}

-(id) initWithFile:(NSString*)file capacity:(NSUInteger)n
{
	// retained in property
	CCTexture *tex = [[CCTextureCache sharedTextureCache] addImage:file];
	if( tex )
		return [self initWithTexture:tex capacity:n];

	// else
	{
		CCLOG(@"cocos2d: Could not open file: %@", file);
		return nil;
	}
}

-(id) initWithTexture:(CCTexture*)tex capacity:(NSUInteger)n
{
	if( (self=[super init]) ) {

		_capacity = n;
		_totalQuads = 0;

		// retained in property
		self.texture = tex;

		// Re-initialization is not allowed
		NSAssert(_quads==nil && _indices==nil, @"CCTextureAtlas re-initialization is not allowed");

		_quads = calloc( sizeof(_quads[0]) * _capacity, 1 );
		_indices = calloc( sizeof(_indices[0]) * _capacity * 6, 1 );

		if( ! ( _quads && _indices) ) {
			CCLOG(@"cocos2d: CCTextureAtlas: not enough memory");
			if( _quads )
				free(_quads);
			if( _indices )
				free(_indices);

			return nil;
		}

		[self setupIndices];

#if CC_TEXTURE_ATLAS_USE_VAO
		[self setupVBOandVAO];	
#else	
		[self setupVBO];
#endif

		_dirty = YES;
	}

	return self;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | totalQuads =  %lu>", [self class], self, (unsigned long)_totalQuads];
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@",self);

	free(_quads);
	free(_indices);

	glDeleteBuffers(2, _buffersVBO);

#if CC_TEXTURE_ATLAS_USE_VAO
	glDeleteVertexArrays(1, &_VAOname);
#endif


}

-(void) setupIndices
{
	for( NSUInteger i = 0; i < _capacity;i++)
    {
#if CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP
		_indices[i*6+0] = i*4+0;
		_indices[i*6+1] = i*4+0;
		_indices[i*6+2] = i*4+2;
		_indices[i*6+3] = i*4+1;
		_indices[i*6+4] = i*4+3;
		_indices[i*6+5] = i*4+3;
#else
		_indices[i*6+0] = i*4+0;
		_indices[i*6+1] = i*4+1;
		_indices[i*6+2] = i*4+2;
		
		// inverted index. issue #179
		_indices[i*6+3] = i*4+3;
		_indices[i*6+4] = i*4+2;
		_indices[i*6+5] = i*4+1;
#endif
	}
}

#pragma mark TextureAtlas - VAO / VBO specific

#if CC_TEXTURE_ATLAS_USE_VAO
-(void) setupVBOandVAO
{
	// VAO requires GL_APPLE_vertex_array_object in order to be created on a different thread
	// https://devforums.apple.com/thread/145566?tstart=0

	void (^createVAO)(void) = ^{
		glGenVertexArrays(1, &_VAOname);
		ccGLBindVAO(_VAOname);

	#define kQuadSize sizeof(_quads[0].bl)

		glGenBuffers(2, &_buffersVBO[0]);

		glBindBuffer(GL_ARRAY_BUFFER, _buffersVBO[0]);

		// vertices
		glEnableVertexAttribArray(kCCVertexAttrib_Position);
		glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, vertices));

		// colors
		glEnableVertexAttribArray(kCCVertexAttrib_Color);
		glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, colors));

		// tex coords
		glEnableVertexAttribArray(kCCVertexAttrib_TexCoords);
		glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, texCoords));

		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _buffersVBO[1]);

		// Must unbind the VAO before changing the element buffer.
		ccGLBindVAO(0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);

		CHECK_GL_ERROR_DEBUG();
	};
	
	NSThread *cocos2dThread = [[CCDirector sharedDirector] runningThread];
	if( cocos2dThread == [NSThread currentThread] || [[CCConfiguration sharedConfiguration] supportsShareableVAO] )
		createVAO();
	else 
		[cocos2dThread performBlock:createVAO waitUntilDone:YES];
}
#else // CC_TEXTURE_ATLAS_USE_VAO
-(void) setupVBO
{
	glGenBuffers(2, &_buffersVBO[0]);
}
#endif // ! // CC_TEXTURE_ATLAS_USE_VAO

#pragma mark TextureAtlas - Update, Insert, Move & Remove

-(ccV3F_C4B_T2F_Quad *) quads
{
	//if someone accesses the quads directly, presume that changes will be made
	_dirty = YES;
	return _quads;
}

-(void) updateQuad:(ccV3F_C4B_T2F_Quad*)quad atIndex:(NSUInteger) n
{
	NSAssert(n < _capacity, @"updateQuadWithTexture: Invalid index");

	_totalQuads =  MAX( n+1, _totalQuads);

	_quads[n] = *quad;

	_dirty = YES;
}

-(void) insertQuad:(ccV3F_C4B_T2F_Quad*)quad atIndex:(NSUInteger)index
{
	NSAssert(index < _capacity, @"insertQuadWithTexture: Invalid index");

	_totalQuads++;
	NSAssert( _totalQuads <= _capacity, @"invalid totalQuads");

	// issue #575. index can be > totalQuads
	NSInteger remaining = (_totalQuads-1) - index;

	// last object doesn't need to be moved
	if( remaining > 0)
		// tex coordinates
		memmove( &_quads[index+1],&_quads[index], sizeof(_quads[0]) * remaining );

	_quads[index] = *quad;

	_dirty = YES;
}

-(void) insertQuads:(ccV3F_C4B_T2F_Quad*)quads atIndex:(NSUInteger)index amount:(NSUInteger) amount
{
	NSAssert(index + amount <= _capacity, @"insertQuadWithTexture: Invalid index + amount");

	_totalQuads+= amount;

	NSAssert( _totalQuads <= _capacity, @"invalid totalQuads");

	// issue #575. index can be > totalQuads
	NSInteger remaining = (_totalQuads-1) - index - amount;

	// last object doesn't need to be moved
	if( remaining > 0)
		// tex coordinates
		memmove( &_quads[index+amount],&_quads[index], sizeof(_quads[0]) * remaining );



	NSUInteger max = index + amount;
	NSUInteger j = 0;
	for (NSUInteger i = index; i < max ; i++)
	{
		_quads[index] = quads[j];
		index++;
		j++;
	}

	_dirty = YES;
}

-(void) insertQuadFromIndex:(NSUInteger)oldIndex atIndex:(NSUInteger)newIndex
{
	NSAssert(newIndex < _totalQuads, @"insertQuadFromIndex:atIndex: Invalid index");
	NSAssert(oldIndex < _totalQuads, @"insertQuadFromIndex:atIndex: Invalid index");

	if( oldIndex == newIndex )
		return;

	NSUInteger howMany = labs( oldIndex - newIndex);
	NSUInteger dst = oldIndex;
	NSUInteger src = oldIndex + 1;
	if( oldIndex > newIndex) {
		dst = newIndex+1;
		src = newIndex;
	}

	// tex coordinates
	ccV3F_C4B_T2F_Quad quadsBackup = _quads[oldIndex];
	memmove( &_quads[dst],&_quads[src], sizeof(_quads[0]) * howMany );
	_quads[newIndex] = quadsBackup;

	_dirty = YES;
}

-(void) moveQuadsFromIndex:(NSUInteger)oldIndex amount:(NSUInteger) amount atIndex:(NSUInteger)newIndex
{
	NSAssert(newIndex + amount <= _totalQuads, @"insertQuadFromIndex:atIndex: Invalid index");
	NSAssert(oldIndex < _totalQuads, @"insertQuadFromIndex:atIndex: Invalid index");

	if( oldIndex == newIndex )
		return;

	//create buffer
	size_t quadSize = sizeof(ccV3F_C4B_T2F_Quad);
	ccV3F_C4B_T2F_Quad *tempQuads = malloc( quadSize * amount);
	memcpy( tempQuads, &_quads[oldIndex], quadSize * amount );

	if (newIndex < oldIndex)
	{
		// move quads from newIndex to newIndex + amount to make room for buffer
		memmove( &_quads[newIndex], &_quads[newIndex+amount], (oldIndex-newIndex)*quadSize);
	}
	else
	{
		// move quads above back
		memmove( &_quads[oldIndex], &_quads[oldIndex+amount], (newIndex-oldIndex)*quadSize);
	}
	memcpy( &_quads[newIndex], tempQuads, amount*quadSize);

	free(tempQuads);

	_dirty = YES;
}

-(void) removeQuadAtIndex:(NSUInteger) index
{
	NSAssert(index < _totalQuads, @"removeQuadAtIndex: Invalid index");

	NSUInteger remaining = (_totalQuads-1) - index;

	// last object doesn't need to be moved
	if( remaining )
		memmove( &_quads[index],&_quads[index+1], sizeof(_quads[0]) * remaining );

	_totalQuads--;

	_dirty = YES;
}

-(void) removeQuadsAtIndex:(NSUInteger) index amount:(NSUInteger) amount
{
	NSAssert(index + amount <= _totalQuads, @"removeQuadAtIndex: index + amount out of bounds");

	NSUInteger remaining = (_totalQuads) - (index + amount);

	_totalQuads -= amount;

	if ( remaining )
		memmove( &_quads[index], &_quads[index+amount], sizeof(_quads[0]) * remaining );

	_dirty = YES;
}

-(void) removeAllQuads
{
	_totalQuads = 0;
}

#pragma mark TextureAtlas - Resize

-(BOOL) resizeCapacity: (NSUInteger) newCapacity
{
	if( newCapacity == _capacity )
		return YES;

	// update capacity and totolQuads
	_totalQuads = MIN(_totalQuads,newCapacity);
	_capacity = newCapacity;

	void * tmpQuads = realloc( _quads, sizeof(_quads[0]) * _capacity );
	void * tmpIndices = realloc( _indices, sizeof(_indices[0]) * _capacity * 6 );

	if( ! ( tmpQuads && tmpIndices) ) {
		CCLOG(@"cocos2d: CCTextureAtlas: not enough memory");
		if( tmpQuads )
			free(tmpQuads);
		else
			free(_quads);

		if( tmpIndices )
			free(tmpIndices);
		else
			free(_indices);

		_indices = nil;
		_quads = nil;
		_capacity = _totalQuads = 0;
		return NO;
	}

	_quads = tmpQuads;
	_indices = tmpIndices;

	// Update Indices
	[self setupIndices];

	_dirty = YES;

	return YES;
}

#pragma mark TextureAtlas - CCParticleBatchNode Specific

-(void) fillWithEmptyQuadsFromIndex:(NSUInteger) index amount:(NSUInteger) amount
{
	ccV3F_C4B_T2F_Quad quad;
	bzero( &quad, sizeof(quad) );

	NSUInteger to = index + amount;
	for (NSInteger i = index ; i < to ; i++)
	{
		_quads[i] = quad;
	}

}
-(void) increaseTotalQuadsWith:(NSUInteger) amount
{
	_totalQuads += amount;
}

-(void) moveQuadsFromIndex:(NSUInteger) index to:(NSUInteger) newIndex
{
	NSAssert(newIndex + (_totalQuads - index) <= _capacity, @"moveQuadsFromIndex move is out of bounds");

	memmove(_quads + newIndex,_quads + index, (_totalQuads - index) * sizeof(_quads[0]));
}

#pragma mark TextureAtlas - Drawing

-(void) drawQuads
{
	[self drawNumberOfQuads: _totalQuads fromIndex:0];
}

-(void) drawNumberOfQuads: (NSUInteger) n
{
	[self drawNumberOfQuads:n fromIndex:0];
}

-(void) drawNumberOfQuads: (NSUInteger) n fromIndex: (NSUInteger) start
{
	ccGLBindTexture2D( [_texture name] );

#if CC_TEXTURE_ATLAS_USE_VAO

	//
	// Using VBO and VAO
	//
	// XXX: update is done in draw... perhaps it should be done in a timer
	if (_dirty) {

        ccGLBindVAO(0);
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _buffersVBO[1]);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(_indices[0]) * _capacity * 6, _indices, GL_STATIC_DRAW);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        
        
		glBindBuffer(GL_ARRAY_BUFFER, _buffersVBO[0]);
		// option 1: subdata
//		glBufferSubData(GL_ARRAY_BUFFER, sizeof(_quads[0])*start, sizeof(_quads[0]) * n , &_quads[start] );
		
		// option 2: data
//		glBufferData(GL_ARRAY_BUFFER, sizeof(_quads[0]) * (n-start), &_quads[start], GL_DYNAMIC_DRAW);
		
		// option 3: orphaning + glMapBuffer
		glBufferData(GL_ARRAY_BUFFER, sizeof(_quads[0]) * (n-start), nil, GL_DYNAMIC_DRAW);
		void *buf = glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
		memcpy(buf, _quads, sizeof(_quads[0])* (n-start));
		glUnmapBuffer(GL_ARRAY_BUFFER);		
		
		glBindBuffer(GL_ARRAY_BUFFER, 0);

		_dirty = NO;
	}

	ccGLBindVAO( _VAOname );

#if CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP
	glDrawElements(GL_TRIANGLE_STRIP, (GLsizei) n*6, GL_UNSIGNED_SHORT, (GLvoid*) (start*6*sizeof(_indices[0])) );
#else
	glDrawElements(GL_TRIANGLES, (GLsizei) n*6, GL_UNSIGNED_SHORT, (GLvoid*) (start*6*sizeof(_indices[0])) );
#endif // CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP
	
//	glBindVertexArray(0);
	

#else // ! CC_TEXTURE_ATLAS_USE_VAO
	
	//
	// Using VBO without VAO
	//

#define kQuadSize sizeof(_quads[0].bl)
	glBindBuffer(GL_ARRAY_BUFFER, _buffersVBO[0]);
    
	// XXX: update is done in draw... perhaps it should be done in a timer
	if (_dirty) {
//		glBufferSubData(GL_ARRAY_BUFFER, sizeof(_quads[0])*start, sizeof(_quads[0]) * n , &_quads[start] );

		// Apparently this is faster... need to do performance tests
		glBufferData(GL_ARRAY_BUFFER, sizeof(_quads[0]) * n, _quads, GL_DYNAMIC_DRAW);
		_dirty = NO;
	}

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );

	// vertices
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, vertices));
	
	// colors
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, colors));
	
	// tex coords
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, texCoords));

	glBindBuffer(GL_ARRAY_BUFFER, 0);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _buffersVBO[1]);

#if CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP
	glDrawElements(GL_TRIANGLE_STRIP, (GLsizei) n*6, GL_UNSIGNED_SHORT, (GLvoid*) (start*6*sizeof(_indices[0])) );
#else
	glDrawElements(GL_TRIANGLES, (GLsizei) n*6, GL_UNSIGNED_SHORT, (GLvoid*) (start*6*sizeof(_indices[0])) );
#endif // CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

#endif // CC_TEXTURE_ATLAS_USE_VAO

	CC_INCREMENT_GL_DRAWS(1);

	CHECK_GL_ERROR_DEBUG();
}
@end
