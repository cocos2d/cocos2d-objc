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
-(void) initColorArray;
@end


@implementation TextureAtlas

@synthesize totalQuads = _totalQuads, capacity = _capacity;
@synthesize texture;
@synthesize withColorArray = _withColorArray;

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
	
	_capacity = n;
	
	// retained in property
	self.texture = tex;

	_withColorArray = NO;

	texCoordinates = malloc( sizeof(texCoordinates[0]) * _capacity );
	vertices = malloc( sizeof(vertices[0]) * _capacity );
	indices = malloc( sizeof(indices[0]) * _capacity * 6 );
	
	if( ! ( texCoordinates && vertices && indices) ) {
		NSLog(@"TextureAtlas: not enough memory");
		if( texCoordinates )
			free(texCoordinates);
		if( vertices )
			free(vertices);
		if( indices )
			free(vertices);
		return nil;
	}

	[self initIndices];
	
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | totalQuads =  %i>", [self class], self, _totalQuads];
}

-(void) dealloc
{
	CCLOG(@"deallocing %@",self);

	free(vertices);
	free(texCoordinates);
	free(indices);
	if(_withColorArray)
		free(colors);
	
	[texture release];

	[super dealloc];
}

-(void) initColorArray
{
	if( ! _withColorArray ) {
		colors = malloc( sizeof(colors[0]) * _capacity * 4 );
		// default color: 255,255,255,255
		memset(colors, 0xFF,  _capacity * 4 * sizeof(colors[0]));
		_withColorArray = YES;
	}
}

-(void) initIndices
{
	for( NSUInteger i=0;i< _capacity;i++) {
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
	
	NSAssert( n >= 0 && n < _capacity, @"updateQuadWithTexture: Invalid index");

	_totalQuads =  MAX( n+1, _totalQuads);

	texCoordinates[n] = *quadT;
	vertices[n] = *quadV;
}

-(void) updateColorWithColorQuad:(ccColorB*)color atIndex:(NSUInteger)n
{
	NSAssert( n >= 0 && n < _capacity, @"updateColorWithQuadColor: Invalid index");

	_totalQuads =  MAX( n+1, _totalQuads);
	
	if( ! _withColorArray )
		[self initColorArray];
	for( int i=0;i<4;i++)
		colors[n*4+i] = *color;
}

-(void) insertQuadWithTexture:(ccQuad2*)texCoords vertexQuad:(ccQuad3*)vertexCoords atIndex:(NSUInteger)index
{
	NSAssert( index >= 0 && index < _capacity, @"updateQuadWithTexture: Invalid index");
	
	_totalQuads++;
	
	NSUInteger remaining = (_totalQuads-1) - index;
	
	// last object doesn't need to be moved
	if( remaining ) {
		// tex coordinates
		memmove( &texCoordinates[index+1],&texCoordinates[index], sizeof(texCoordinates[0]) * remaining );
		// vertices
		memmove( &vertices[index+1], &vertices[index], sizeof(vertices[0]) * remaining );
		// colors
		if(_withColorArray)
			memmove(&colors[(index+1)*4], &colors[index*4], sizeof(colors[0]) * remaining * 4);
	}
	
	texCoordinates[index] = *texCoords;
	vertices[index] = *vertexCoords;
}


-(void) insertQuadFromIndex:(NSUInteger)oldIndex atIndex:(NSUInteger)newIndex
{
	NSAssert( newIndex >= 0 && newIndex < _totalQuads, @"insertQuadFromIndex:atIndex: Invalid index");
	NSAssert( oldIndex >= 0 && oldIndex < _totalQuads, @"insertQuadFromIndex:atIndex: Invalid index");

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

	// vertices coordinates
	ccQuad3 vertexQuadBackup = vertices[oldIndex];
	memmove( &vertices[dst], &vertices[src], sizeof(vertices[0]) * howMany );
	vertices[newIndex] = vertexQuadBackup;

	// colors
	if( _withColorArray ) {
		ccColorB colorsBackup[4];

		for(int i=0;i<4;i++)
			colorsBackup[i] = colors[oldIndex*4+i];
		
		memmove(&colors[dst*4], &colors[(src)*4], sizeof(colors[0]) * howMany * 4);

		for(int i=0;i<4;i++)
			colors[newIndex*4+i] = colorsBackup[i];
	}	
}

-(void) removeQuadAtIndex:(NSUInteger) index
{
	NSAssert( index >= 0 && index < _totalQuads, @"removeQuadAtIndex: Invalid index");
	
	NSUInteger remaining = (_totalQuads-1) - index;
	
	// last object doesn't need to be moved
	if( remaining ) {
		// tex coordinates
		memmove( &texCoordinates[index],&texCoordinates[index+1], sizeof(texCoordinates[0]) * remaining );
		// vertices
		memmove( &vertices[index], &vertices[index+1], sizeof(vertices[0]) * remaining );
		// colors
		if(_withColorArray)
			memmove(&colors[index*4], &colors[(index+1)*4], sizeof(colors[0]) * remaining * 4);
	}
	
	_totalQuads--;
}

-(void) removeAllQuads
{
	_totalQuads = 0;
}

#pragma mark TextureAtlas - Resize

-(void) resizeCapacity: (NSUInteger) n
{
	if( n == _capacity )
		return;
	
	_capacity = n;

	texCoordinates = realloc( texCoordinates, sizeof(texCoordinates[0]) * _capacity );
	vertices = realloc( vertices, sizeof(vertices[0]) * _capacity );
	indices = realloc( indices, sizeof(indices[0]) * _capacity * 6 );
	
	if( _withColorArray )
		colors = realloc( colors, sizeof(colors[0]) * _capacity * 4 );
	
	if( ! ( texCoordinates && vertices && indices) ) {
		NSLog(@"TextureAtlas: not enough memory");
		if( texCoordinates )
			free(texCoordinates);
		if( vertices )
			free(vertices);
		if( indices )
			free(vertices);
		if( colors )
			free( colors );
		[NSException raise:@"TextureAtlas:NoMemory" format:@"Texture Atlas. Not enough memory to resize the capacity"];
	}
	
	[self initIndices];
}

#pragma mark TextureAtlas - Drawing

-(void) drawQuads
{
	return [self drawNumberOfQuads: _totalQuads];
}

-(void) drawNumberOfQuads: (NSUInteger) n
{		
	glBindTexture(GL_TEXTURE_2D, [texture name]);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoordinates);
	if( _withColorArray )
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	glDrawElements(GL_TRIANGLES, n*6, GL_UNSIGNED_SHORT, indices);	
}

@end
