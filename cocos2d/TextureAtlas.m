/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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
#import "TextureAtlas.h"
#import "TextureMgr.h"
#import "ccMacros.h"

// support
#import "Support/Texture2D.h"

@interface TextureAtlas (Private)
-(void) initIndices;
-(BOOL) initColorArray;
@end


@implementation TextureAtlas

@synthesize totalQuads = totalQuads_, capacity = capacity_;
@synthesize texture;
@synthesize withColorArray = withColorArray_;

#pragma mark TextureAtlas - alloc & init

+(id) textureAtlasWithFile:(NSString*) file capacity: (NSUInteger) n
{
	return [[[self alloc] initWithFile:file capacity:n] autorelease];
}

+(id) textureAtlasWithTexture:(Texture2D *)tex capacity:(NSUInteger)n
{
	return [[[self alloc] initWithTexture:tex capacity:n] autorelease];
}

-(id) initWithFile:(NSString*)file capacity:(NSUInteger)n
{
	// retained in property
	Texture2D *tex = [[TextureMgr sharedTextureMgr] addImage:file];	
	
	return [self initWithTexture:tex capacity:n];
}

-(id) initWithTexture:(Texture2D*)tex capacity:(NSUInteger)n
{
	if( ! (self=[super init]) )
		return nil;
	
	capacity_ = n;
	
	// retained in property
	self.texture = tex;

	withColorArray_ = NO;

	texCoordinates = malloc( sizeof(texCoordinates[0]) * capacity_ );
	vertexCoordinates = malloc( sizeof(vertexCoordinates[0]) * capacity_ );
	indices = malloc( sizeof(indices[0]) * capacity_ * 6 );
	
	if( ! ( texCoordinates && vertexCoordinates && indices) ) {
		NSLog(@"TextureAtlas: not enough memory");
		if( texCoordinates )
			free(texCoordinates);
		if( vertexCoordinates )
			free(vertexCoordinates);
		if( indices )
			free(indices);
		return nil;
	}

	[self initIndices];
	
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | totalQuads =  %i>", [self class], self, totalQuads_];
}

-(void) dealloc
{
	CCLOG(@"deallocing %@",self);

	free(vertexCoordinates);
	free(texCoordinates);
	free(indices);
	if(withColorArray_)
		free(colors);
	
	[texture release];

	[super dealloc];
}

-(BOOL) initColorArray
{
	if( !withColorArray_ ) {
		colors = malloc( sizeof(colors[0]) * capacity_ * 4 );
		if(!colors) {
			CCLOG(@"TextureAtlas#initColorArray: not enough memory");
			// XXX: These kind of events should raise an exception instead of returning BOOL. 
			// XXX: For the moment lets continue handling like these.
			// XXX: But an exception hierarchy should be created
			// XXX: And the library should work with try() catch().
			return NO;
		} else {
			// default color: 255,255,255,255
			memset(colors, 0xFF,  capacity_ * 4 * sizeof(colors[0]));
			withColorArray_ = YES;
		}
	}
	
	return YES;
}

-(void) initIndices
{
	for( NSUInteger i=0;i< capacity_;i++) {
		indices[i*6+0] = i*4+0;
		indices[i*6+1] = i*4+1;
		indices[i*6+2] = i*4+2;

		// inverted index. issue #179
		indices[i*6+5] = i*4+1;
		indices[i*6+4] = i*4+2;
		indices[i*6+3] = i*4+3;
		
	}
}

#pragma mark TextureAtlas - Update, Insert, Move & Remove

-(void) updateQuadWithTexture: (ccQuad2*) quadT vertexQuad:(ccQuad3*) quadV atIndex:(NSUInteger) n
{
	
	NSAssert( n >= 0 && n < capacity_, @"updateQuadWithTexture: Invalid index");

	totalQuads_ =  MAX( n+1, totalQuads_);

	texCoordinates[n] = *quadT;
	vertexCoordinates[n] = *quadV;
}

-(void) updateColorWithColorQuad:(ccColor4B*)color atIndex:(NSUInteger)n
{
	NSAssert( n >= 0 && n < capacity_, @"updateColorWithQuadColor: Invalid index");

	totalQuads_ =  MAX( n+1, totalQuads_);
	
	if( ! withColorArray_ )
		[self initColorArray];
	
	// initColorArray might fail

	if( withColorArray_ ) {
		for( int i=0;i<4;i++)
			colors[n*4+i] = *color;
	}
}

-(void) insertQuadWithTexture:(ccQuad2*)texCoords vertexQuad:(ccQuad3*)vertexCoords atIndex:(NSUInteger)index
{
	NSAssert( index >= 0 && index < capacity_, @"updateQuadWithTexture: Invalid index");
	
	totalQuads_++;
	
	NSUInteger remaining = (totalQuads_-1) - index;
	
	// last object doesn't need to be moved
	if( remaining ) {
		// tex coordinates
		memmove( &texCoordinates[index+1],&texCoordinates[index], sizeof(texCoordinates[0]) * remaining );
		// vertexCoordinates
		memmove( &vertexCoordinates[index+1], &vertexCoordinates[index], sizeof(vertexCoordinates[0]) * remaining );
		// colors
		if(withColorArray_)
			memmove(&colors[(index+1)*4], &colors[index*4], sizeof(colors[0]) * remaining * 4);
	}
	
	texCoordinates[index] = *texCoords;
	vertexCoordinates[index] = *vertexCoords;
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
	ccQuad2 texCoordsBackup = texCoordinates[oldIndex];
	memmove( &texCoordinates[dst],&texCoordinates[src], sizeof(texCoordinates[0]) * howMany );
	texCoordinates[newIndex] = texCoordsBackup;

	// vertexCoordinates coordinates
	ccQuad3 vertexQuadBackup = vertexCoordinates[oldIndex];
	memmove( &vertexCoordinates[dst], &vertexCoordinates[src], sizeof(vertexCoordinates[0]) * howMany );
	vertexCoordinates[newIndex] = vertexQuadBackup;

	// colors
	if( withColorArray_ ) {
		ccColor4B colorsBackup[4];

		for(int i=0;i<4;i++)
			colorsBackup[i] = colors[oldIndex*4+i];
		
		memmove(&colors[dst*4], &colors[(src)*4], sizeof(colors[0]) * howMany * 4);

		for(int i=0;i<4;i++)
			colors[newIndex*4+i] = colorsBackup[i];
	}	
}

-(void) removeQuadAtIndex:(NSUInteger) index
{
	NSAssert( index >= 0 && index < totalQuads_, @"removeQuadAtIndex: Invalid index");
	
	NSUInteger remaining = (totalQuads_-1) - index;
	
	// last object doesn't need to be moved
	if( remaining ) {
		// tex coordinates
		memmove( &texCoordinates[index],&texCoordinates[index+1], sizeof(texCoordinates[0]) * remaining );
		// vertexCoordinates
		memmove( &vertexCoordinates[index], &vertexCoordinates[index+1], sizeof(vertexCoordinates[0]) * remaining );
		// colors
		if(withColorArray_)
			memmove(&colors[index*4], &colors[(index+1)*4], sizeof(colors[0]) * remaining * 4);
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
	
	void * tmpColors = nil;

	// update capacity and totolQuads
	totalQuads_ = MIN(totalQuads_,newCapacity);
	capacity_ = newCapacity;

	void * tmpTexCoords = realloc( texCoordinates, sizeof(texCoordinates[0]) * capacity_ );
	void * tmpVertexCoords = realloc( vertexCoordinates, sizeof(vertexCoordinates[0]) * capacity_ );
	void * tmpIndices = realloc( indices, sizeof(indices[0]) * capacity_ * 6 );
	
	if( withColorArray_ )
		tmpColors = realloc( colors, sizeof(colors[0]) * capacity_ * 4 );
	else
		tmpColors = (void*) 1;
	
	if( ! ( tmpTexCoords && tmpVertexCoords && tmpIndices && tmpColors) ) {
		NSLog(@"TextureAtlas: not enough memory");
		if( tmpTexCoords )
			free(tmpTexCoords);
		else
			free(texCoordinates);
		
		if( tmpVertexCoords )
			free(tmpVertexCoords);
		else
			free(vertexCoordinates);
		
		if( tmpIndices )
			free(tmpIndices);
		else
			free(indices);

		if( withColorArray_) {
			if( tmpColors )
				free( tmpColors );
			else
				free( colors);
		}
		
		texCoordinates = nil;
		vertexCoordinates = nil;
		indices = nil;
		colors = nil;
		
		capacity_ = totalQuads_ = 0;

		return NO;
	}
	
	texCoordinates = tmpTexCoords;
	vertexCoordinates = tmpVertexCoords;
	indices = tmpIndices;
	if( withColorArray_ )
		colors = tmpColors;

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
	glBindTexture(GL_TEXTURE_2D, [texture name]);
	glVertexPointer(3, GL_FLOAT, 0, vertexCoordinates);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoordinates);
	if( withColorArray_ )
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	glDrawElements(GL_TRIANGLES, n*6, GL_UNSIGNED_SHORT, indices);	
}

@end
