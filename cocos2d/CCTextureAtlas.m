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
#import "CCTexture2D.h"
#import "CCTextureCache.h"
#import "CCGLProgram.h"
#import "ccGLStateCache.h"
#import "CCDirector.h"
#import "CCConfiguration.h"

#import "Support/NSThread+performBlock.h"
#import "Support/OpenGL_Internal.h"

@interface CCTextureAtlas ()
-(void) setupIndices;
-(void) mapBuffers;

#if CC_TEXTURE_ATLAS_USE_VAO
-(void) setupVBOandVAO;
#else
-(void) setupVBO;
#endif
@end

//According to some tests GL_TRIANGLE_STRIP is slower, MUCH slower. Probably I'm doing something very wrong

@implementation CCTextureAtlas

@synthesize totalQuads = totalQuads_, capacity = capacity_;
@synthesize texture = texture_;
@synthesize quads = quads_;

#pragma mark TextureAtlas - alloc & init

+(id) textureAtlasWithFile:(NSString*) file capacity: (NSUInteger) n
{
	return [[[self alloc] initWithFile:file capacity:n] autorelease];
}

+(id) textureAtlasWithTexture:(CCTexture2D *)tex capacity:(NSUInteger)n
{
	return [[[self alloc] initWithTexture:tex capacity:n] autorelease];
}

-(id) initWithFile:(NSString*)file capacity:(NSUInteger)n
{
	// retained in property
	CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:file];
	if( tex )
		return [self initWithTexture:tex capacity:n];

	// else
	{
		CCLOG(@"cocos2d: Could not open file: %@", file);
		[self release];
		return nil;
	}
}

-(id) initWithTexture:(CCTexture2D*)tex capacity:(NSUInteger)n
{
	if( (self=[super init]) ) {

		capacity_ = n;
		totalQuads_ = 0;

		// retained in property
		self.texture = tex;

		// Re-initialization is not allowed
		NSAssert(quads_==nil && indices_==nil, @"CCTextureAtlas re-initialization is not allowed");

		quads_ = calloc( sizeof(quads_[0]) * capacity_, 1 );
		indices_ = calloc( sizeof(indices_[0]) * capacity_ * 6, 1 );

		if( ! ( quads_ && indices_) ) {
			CCLOG(@"cocos2d: CCTextureAtlas: not enough memory");
			if( quads_ )
				free(quads_);
			if( indices_ )
				free(indices_);

			[self release];
			return nil;
		}

		[self setupIndices];

#if CC_TEXTURE_ATLAS_USE_VAO
		[self setupVBOandVAO];	
#else	
		[self setupVBO];
#endif

		dirty_ = YES;
	}

	return self;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | totalQuads =  %lu>", [self class], self, (unsigned long)totalQuads_];
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@",self);

	free(quads_);
	free(indices_);

	glDeleteBuffers(2, buffersVBO_);

#if CC_TEXTURE_ATLAS_USE_VAO
	glDeleteVertexArrays(1, &VAOname_);
#endif

	[texture_ release];

	[super dealloc];
}

-(void) setupIndices
{
	for( NSUInteger i = 0; i < capacity_;i++)
    {
#if CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP
		indices_[i*6+0] = i*4+0;
		indices_[i*6+1] = i*4+0;
		indices_[i*6+2] = i*4+2;
		indices_[i*6+3] = i*4+1;
		indices_[i*6+4] = i*4+3;
		indices_[i*6+5] = i*4+3;
#else
		indices_[i*6+0] = i*4+0;
		indices_[i*6+1] = i*4+1;
		indices_[i*6+2] = i*4+2;
		
		// inverted index. issue #179
		indices_[i*6+3] = i*4+3;
		indices_[i*6+4] = i*4+2;
		indices_[i*6+5] = i*4+1;
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
		glGenVertexArrays(1, &VAOname_);
		ccGLBindVAO(VAOname_);

	#define kQuadSize sizeof(quads_[0].bl)

		glGenBuffers(2, &buffersVBO_[0]);

		glBindBuffer(GL_ARRAY_BUFFER, buffersVBO_[0]);
		glBufferData(GL_ARRAY_BUFFER, sizeof(quads_[0]) * capacity_, quads_, GL_DYNAMIC_DRAW);

		// vertices
		glEnableVertexAttribArray(kCCVertexAttrib_Position);
		glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, vertices));

		// colors
		glEnableVertexAttribArray(kCCVertexAttrib_Color);
		glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, colors));

		// tex coords
		glEnableVertexAttribArray(kCCVertexAttrib_TexCoords);
		glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, texCoords));

		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffersVBO_[1]);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices_[0]) * capacity_ * 6, indices_, GL_STATIC_DRAW);

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
	glGenBuffers(2, &buffersVBO_[0]);
	
	[self mapBuffers];
}
#endif // ! // CC_TEXTURE_ATLAS_USE_VAO


-(void) mapBuffers
{
	// Avoid changing the element buffer for whatever VAO might be bound.
	ccGLBindVAO(0);
	
	glBindBuffer(GL_ARRAY_BUFFER, buffersVBO_[0]);
	glBufferData(GL_ARRAY_BUFFER, sizeof(quads_[0]) * capacity_, quads_, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffersVBO_[1]);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices_[0]) * capacity_ * 6, indices_, GL_STATIC_DRAW);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

	CHECK_GL_ERROR_DEBUG();
}

#pragma mark TextureAtlas - Update, Insert, Move & Remove

-(ccV3F_C4B_T2F_Quad *) quads
{
	//if someone accesses the quads directly, presume that changes will be made
	dirty_ = YES;
	return quads_;
}

-(void) updateQuad:(ccV3F_C4B_T2F_Quad*)quad atIndex:(NSUInteger) n
{
	NSAssert(n < capacity_, @"updateQuadWithTexture: Invalid index");

	totalQuads_ =  MAX( n+1, totalQuads_);

	quads_[n] = *quad;

	dirty_ = YES;
}

-(void) insertQuad:(ccV3F_C4B_T2F_Quad*)quad atIndex:(NSUInteger)index
{
	NSAssert(index < capacity_, @"insertQuadWithTexture: Invalid index");

	totalQuads_++;
	NSAssert( totalQuads_ <= capacity_, @"invalid totalQuads");

	// issue #575. index can be > totalQuads
	NSInteger remaining = (totalQuads_-1) - index;

	// last object doesn't need to be moved
	if( remaining > 0)
		// tex coordinates
		memmove( &quads_[index+1],&quads_[index], sizeof(quads_[0]) * remaining );

	quads_[index] = *quad;

	dirty_ = YES;
}

-(void) insertQuads:(ccV3F_C4B_T2F_Quad*)quads atIndex:(NSUInteger)index amount:(NSUInteger) amount
{
	NSAssert(index + amount <= capacity_, @"insertQuadWithTexture: Invalid index + amount");

	totalQuads_+= amount;

	NSAssert( totalQuads_ <= capacity_, @"invalid totalQuads");

	// issue #575. index can be > totalQuads
	NSInteger remaining = (totalQuads_-1) - index - amount;

	// last object doesn't need to be moved
	if( remaining > 0)
		// tex coordinates
		memmove( &quads_[index+amount],&quads_[index], sizeof(quads_[0]) * remaining );



	NSUInteger max = index + amount;
	NSUInteger j = 0;
	for (NSUInteger i = index; i < max ; i++)
	{
		quads_[index] = quads[j];
		index++;
		j++;
	}

	dirty_ = YES;
}

-(void) insertQuadFromIndex:(NSUInteger)oldIndex atIndex:(NSUInteger)newIndex
{
	NSAssert(newIndex < totalQuads_, @"insertQuadFromIndex:atIndex: Invalid index");
	NSAssert(oldIndex < totalQuads_, @"insertQuadFromIndex:atIndex: Invalid index");

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
	ccV3F_C4B_T2F_Quad quadsBackup = quads_[oldIndex];
	memmove( &quads_[dst],&quads_[src], sizeof(quads_[0]) * howMany );
	quads_[newIndex] = quadsBackup;

	dirty_ = YES;
}

-(void) moveQuadsFromIndex:(NSUInteger)oldIndex amount:(NSUInteger) amount atIndex:(NSUInteger)newIndex
{
	NSAssert(newIndex + amount <= totalQuads_, @"insertQuadFromIndex:atIndex: Invalid index");
	NSAssert(oldIndex < totalQuads_, @"insertQuadFromIndex:atIndex: Invalid index");

	if( oldIndex == newIndex )
		return;

	//create buffer
	size_t quadSize = sizeof(ccV3F_C4B_T2F_Quad);
	ccV3F_C4B_T2F_Quad *tempQuads = malloc( quadSize * amount);
	memcpy( tempQuads, &quads_[oldIndex], quadSize * amount );

	if (newIndex < oldIndex)
	{
		// move quads from newIndex to newIndex + amount to make room for buffer
		memmove( &quads_[newIndex], &quads_[newIndex+amount], (oldIndex-newIndex)*quadSize);
	}
	else
	{
		// move quads above back
		memmove( &quads_[oldIndex], &quads_[oldIndex+amount], (newIndex-oldIndex)*quadSize);
	}
	memcpy( &quads_[newIndex], tempQuads, amount*quadSize);

	free(tempQuads);

	dirty_ = YES;
}

-(void) removeQuadAtIndex:(NSUInteger) index
{
	NSAssert(index < totalQuads_, @"removeQuadAtIndex: Invalid index");

	NSUInteger remaining = (totalQuads_-1) - index;

	// last object doesn't need to be moved
	if( remaining )
		memmove( &quads_[index],&quads_[index+1], sizeof(quads_[0]) * remaining );

	totalQuads_--;

	dirty_ = YES;
}

-(void) removeQuadsAtIndex:(NSUInteger) index amount:(NSUInteger) amount
{
	NSAssert(index + amount <= totalQuads_, @"removeQuadAtIndex: index + amount out of bounds");

	NSUInteger remaining = (totalQuads_) - (index + amount);

	totalQuads_ -= amount;

	if ( remaining )
		memmove( &quads_[index], &quads_[index+amount], sizeof(quads_[0]) * remaining );

	dirty_ = YES;
}

-(void) removeAllQuads
{
	totalQuads_ = 0;
}

#pragma mark TextureAtlas - Resize

-(BOOL) resizeCapacity: (NSUInteger) newCapacity
{
	if( newCapacity == capacity_ )
		return YES;

	// update capacity and totolQuads
	totalQuads_ = MIN(totalQuads_,newCapacity);
	capacity_ = newCapacity;

	void * tmpQuads = realloc( quads_, sizeof(quads_[0]) * capacity_ );
	void * tmpIndices = realloc( indices_, sizeof(indices_[0]) * capacity_ * 6 );

	if( ! ( tmpQuads && tmpIndices) ) {
		CCLOG(@"cocos2d: CCTextureAtlas: not enough memory");
		if( tmpQuads )
			free(tmpQuads);
		else
			free(quads_);

		if( tmpIndices )
			free(tmpIndices);
		else
			free(indices_);

		indices_ = nil;
		quads_ = nil;
		capacity_ = totalQuads_ = 0;
		return NO;
	}

	quads_ = tmpQuads;
	indices_ = tmpIndices;

	// Update Indices
	[self setupIndices];
	[self mapBuffers];

	dirty_ = YES;

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
		quads_[i] = quad;
	}

}
-(void) increaseTotalQuadsWith:(NSUInteger) amount
{
	totalQuads_ += amount;
}

-(void) moveQuadsFromIndex:(NSUInteger) index to:(NSUInteger) newIndex
{
	NSAssert(newIndex + (totalQuads_ - index) <= capacity_, @"moveQuadsFromIndex move is out of bounds");

	memmove(quads_ + newIndex,quads_ + index, (totalQuads_ - index) * sizeof(quads_[0]));
}

#pragma mark TextureAtlas - Drawing

-(void) drawQuads
{
	[self drawNumberOfQuads: totalQuads_ fromIndex:0];
}

-(void) drawNumberOfQuads: (NSUInteger) n
{
	[self drawNumberOfQuads:n fromIndex:0];
}

-(void) drawNumberOfQuads: (NSUInteger) n fromIndex: (NSUInteger) start
{
	ccGLBindTexture2D( [texture_ name] );

#if CC_TEXTURE_ATLAS_USE_VAO

	//
	// Using VBO and VAO
	//
	// XXX: update is done in draw... perhaps it should be done in a timer
	if (dirty_) {
		glBindBuffer(GL_ARRAY_BUFFER, buffersVBO_[0]);
		// option 1: subdata
//		glBufferSubData(GL_ARRAY_BUFFER, sizeof(quads_[0])*start, sizeof(quads_[0]) * n , &quads_[start] );
		
		// option 2: data
//		glBufferData(GL_ARRAY_BUFFER, sizeof(quads_[0]) * (n-start), &quads_[start], GL_DYNAMIC_DRAW);
		
		// option 3: orphaning + glMapBuffer
		glBufferData(GL_ARRAY_BUFFER, sizeof(quads_[0]) * (n-start), nil, GL_DYNAMIC_DRAW);
		void *buf = glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
		memcpy(buf, quads_, sizeof(quads_[0])* (n-start));
		glUnmapBuffer(GL_ARRAY_BUFFER);		
		
		glBindBuffer(GL_ARRAY_BUFFER, 0);

		dirty_ = NO;
	}

	ccGLBindVAO( VAOname_ );

#if CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP
	glDrawElements(GL_TRIANGLE_STRIP, (GLsizei) n*6, GL_UNSIGNED_SHORT, (GLvoid*) (start*6*sizeof(indices_[0])) );
#else
	glDrawElements(GL_TRIANGLES, (GLsizei) n*6, GL_UNSIGNED_SHORT, (GLvoid*) (start*6*sizeof(indices_[0])) );
#endif // CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP
	
//	glBindVertexArray(0);
	

#else // ! CC_TEXTURE_ATLAS_USE_VAO
	
	//
	// Using VBO without VAO
	//

#define kQuadSize sizeof(quads_[0].bl)
	glBindBuffer(GL_ARRAY_BUFFER, buffersVBO_[0]);
    
	// XXX: update is done in draw... perhaps it should be done in a timer
	if (dirty_) {
//		glBufferSubData(GL_ARRAY_BUFFER, sizeof(quads_[0])*start, sizeof(quads_[0]) * n , &quads_[start] );

		// Apparently this is faster... need to do performance tests
		glBufferData(GL_ARRAY_BUFFER, sizeof(quads_[0]) * n, quads_, GL_DYNAMIC_DRAW);
		dirty_ = NO;
	}

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );

	// vertices
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, vertices));
	
	// colors
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, colors));
	
	// tex coords
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (GLvoid*) offsetof( ccV3F_C4B_T2F, texCoords));

	glBindBuffer(GL_ARRAY_BUFFER, 0);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffersVBO_[1]);

#if CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP
	glDrawElements(GL_TRIANGLE_STRIP, (GLsizei) n*6, GL_UNSIGNED_SHORT, (GLvoid*) (start*6*sizeof(indices_[0])) );
#else
	glDrawElements(GL_TRIANGLES, (GLsizei) n*6, GL_UNSIGNED_SHORT, (GLvoid*) (start*6*sizeof(indices_[0])) );
#endif // CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

#endif // CC_TEXTURE_ATLAS_USE_VAO

	CC_INCREMENT_GL_DRAWS(1);

	CHECK_GL_ERROR_DEBUG();
}
@end
