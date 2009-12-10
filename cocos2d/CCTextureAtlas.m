/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

// cocos2d
#import "CCTextureAtlas.h"
#import "CCTextureCache.h"
#import "ccMacros.h"

// support
#import "CCTexture2D.h"

@interface CCTextureAtlas (Private)
-(void) initIndices;
@end

//According to some tests GL_TRIANGLE_STRIP is slower, MUCH slower. Probably I'm doing something very wrong
//#define USE_TRIANGLE_STRIP 1

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
	
	return [self initWithTexture:tex capacity:n];
}

-(id) initWithTexture:(CCTexture2D*)tex capacity:(NSUInteger)n
{
	if( (self=[super init]) ) {
	
		capacity_ = n;
		
		// retained in property
		self.texture = tex;

		quads_ = calloc( sizeof(quads_[0]) * capacity_, 1 );
		indices = calloc( sizeof(indices[0]) * capacity_ * 6, 1 );
		
		if( ! ( quads_ && indices) ) {
			CCLOG(@"cocos2d: TextureAtlas: not enough memory");
			if( quads_ )
				free(quads_);
			if( indices )
				free(indices);
			return nil;
		}
		
#if CC_TEXTURE_ATLAS_USES_VBO
		// initial binding
		glGenBuffers(2, &buffersVBO[0]);		
#endif // CC_TEXTURE_ATLAS_USES_VBO

		[self initIndices];
	}
	
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | totalQuads =  %i>", [self class], self, totalQuads_];
}

-(void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@",self);

	free(quads_);
	free(indices);
	
#if CC_TEXTURE_ATLAS_USES_VBO
	glDeleteBuffers(2, buffersVBO);
#endif // CC_TEXTURE_ATLAS_USES_VBO
	
	
	[texture_ release];

	[super dealloc];
}

-(void) initIndices
{
	for( NSUInteger i=0;i< capacity_;i++) {
#if USE_TRIANGLE_STRIP
		indices[i*6+0] = i*4+0;
		indices[i*6+1] = i*4+0;
		indices[i*6+2] = i*4+2;		
		indices[i*6+3] = i*4+1;
		indices[i*6+4] = i*4+3;
		indices[i*6+5] = i*4+3;
#else
		indices[i*6+0] = i*4+0;
		indices[i*6+1] = i*4+1;
		indices[i*6+2] = i*4+2;
		
		// inverted index. issue #179
		indices[i*6+3] = i*4+3;
		indices[i*6+4] = i*4+2;
		indices[i*6+5] = i*4+1;		
//		indices[i*6+3] = i*4+2;
//		indices[i*6+4] = i*4+3;
//		indices[i*6+5] = i*4+1;	
#endif	
	}
	
#if CC_TEXTURE_ATLAS_USES_VBO
	glBindBuffer(GL_ARRAY_BUFFER, buffersVBO[0]);
	glBufferData(GL_ARRAY_BUFFER, sizeof(quads_[0]) * capacity_, quads_, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffersVBO[1]);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices[0]) * capacity_ * 6, indices, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
#endif // CC_TEXTURE_ATLAS_USES_VBO
}

#pragma mark TextureAtlas - Update, Insert, Move & Remove

-(void) updateQuad:(ccV3F_C4B_T2F_Quad*)quad atIndex:(NSUInteger) n
{
	NSAssert( n >= 0 && n < capacity_, @"updateQuadWithTexture: Invalid index");
	
	totalQuads_ =  MAX( n+1, totalQuads_);

	quads_[n] = *quad;	
}


-(void) insertQuad:(ccV3F_C4B_T2F_Quad*)quad atIndex:(NSUInteger)index
{
	NSAssert( index >= 0 && index < capacity_, @"insertQuadWithTexture: Invalid index");

	totalQuads_++;
	
	// issue #575. index can be > totalQuads
	int remaining = (totalQuads_-1) - index;
	
	// last object doesn't need to be moved
	if( remaining > 0) {
		// tex coordinates
		memmove( &quads_[index+1],&quads_[index], sizeof(quads_[0]) * remaining );
	}
	
	quads_[index] = *quad;
}


-(void) insertQuadFromIndex:(NSUInteger)oldIndex atIndex:(NSUInteger)newIndex
{
	NSAssert( newIndex >= 0 && newIndex < totalQuads_, @"insertQuadFromIndex:atIndex: Invalid index");
	NSAssert( oldIndex >= 0 && oldIndex < totalQuads_, @"insertQuadFromIndex:atIndex: Invalid index");

	if( oldIndex == newIndex )
		return;

	NSUInteger howMany = abs( oldIndex - newIndex);
	int dst = oldIndex;
	int src = oldIndex + 1;
	if( oldIndex > newIndex) {
		dst = newIndex+1;
		src = newIndex;
	}

	// tex coordinates
	ccV3F_C4B_T2F_Quad quadsBackup = quads_[oldIndex];
	memmove( &quads_[dst],&quads_[src], sizeof(quads_[0]) * howMany );
	quads_[newIndex] = quadsBackup;
}

-(void) removeQuadAtIndex:(NSUInteger) index
{
	NSAssert( index >= 0 && index < totalQuads_, @"removeQuadAtIndex: Invalid index");
	
	NSUInteger remaining = (totalQuads_-1) - index;
	
	// last object doesn't need to be moved
	if( remaining ) {
		// tex coordinates
		memmove( &quads_[index],&quads_[index+1], sizeof(quads_[0]) * remaining );
	}
	
	totalQuads_--;
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
	void * tmpIndices = realloc( indices, sizeof(indices[0]) * capacity_ * 6 );
	
	if( ! ( tmpQuads && tmpIndices) ) {
		CCLOG(@"cocos2d: TextureAtlas: not enough memory");
		if( tmpQuads )
			free(tmpQuads);
		else
			free(quads_);
		
		if( tmpIndices )
			free(tmpIndices);
		else
			free(indices);
		
		indices = nil;
		quads_ = nil;
		capacity_ = totalQuads_ = 0;
		return NO;
	}
		
	quads_ = tmpQuads;
	indices = tmpIndices;

	[self initIndices];	

	return YES;
}

#pragma mark TextureAtlas - Drawing

-(void) drawQuads
{
	return [self drawNumberOfQuads: totalQuads_];
}

-(void) drawNumberOfQuads: (NSUInteger) n
{	
	
	glBindTexture(GL_TEXTURE_2D, [texture_ name]);
#define kQuadSize sizeof(quads_[0].bl)


#if CC_TEXTURE_ATLAS_USES_VBO
	glBindBuffer(GL_ARRAY_BUFFER, buffersVBO[0]);
	
	// XXX: update is done in draw... perhaps it should be done in a timer
	glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(quads_[0]) * n, quads_);
	
	// vertices
	glVertexPointer(3, GL_FLOAT, kQuadSize, (void*) offsetof( ccV3F_C4B_T2F, vertices));
	
	// colors
	glColorPointer(4, GL_UNSIGNED_BYTE, kQuadSize, (void*) offsetof( ccV3F_C4B_T2F, colors));
	
	// tex coords
	glTexCoordPointer(2, GL_FLOAT, kQuadSize, (void*) offsetof( ccV3F_C4B_T2F, texCoords));
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffersVBO[1]);
#ifdef USE_TRIANGLE_STRIP
	glDrawElements(GL_TRIANGLE_STRIP, n*6, GL_UNSIGNED_SHORT, (void*)0);    
#else
	glDrawElements(GL_TRIANGLES, n*6, GL_UNSIGNED_SHORT, (void*)0); 
#endif // USE_TRIANGLE_STRIP
	
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	
#else // ! CC_TEXTURE_ATLAS_USES_VBO
	
	int offset = (int)quads_;

	// vertex
	int diff = offsetof( ccV3F_C4B_T2F, vertices);
	glVertexPointer(3, GL_FLOAT, kQuadSize, (void*) (offset + diff) );

	// color
	diff = offsetof( ccV3F_C4B_T2F, colors);
	glColorPointer(4, GL_UNSIGNED_BYTE, kQuadSize, (void*)(offset + diff));
	
	// tex coords
	diff = offsetof( ccV3F_C4B_T2F, texCoords);
	glTexCoordPointer(2, GL_FLOAT, kQuadSize, (void*)(offset + diff));
	
#if USE_TRIANGLE_STRIP
	glDrawElements(GL_TRIANGLE_STRIP, n*6, GL_UNSIGNED_SHORT, indices);	
#else
	glDrawElements(GL_TRIANGLES, n*6, GL_UNSIGNED_SHORT, indices);	
#endif
	
#endif // CC_TEXTURE_ATLAS_USES_VBO
}

@end
