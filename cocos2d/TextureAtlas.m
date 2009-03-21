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

@synthesize totalQuads, texture;
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
	
	totalQuads = n;
	
	// retained in property
	self.texture = tex;

	_withColorArray = NO;

	texCoordinates = malloc( sizeof(texCoordinates[0]) * totalQuads );
	vertices = malloc( sizeof(vertices[0]) * totalQuads );
	indices = malloc( sizeof(indices[0]) * totalQuads * 6 );
	
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
	return [NSString stringWithFormat:@"<%@ = %08X | totalQuads =  %i>", [self class], self, totalQuads];
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
		colors = malloc( sizeof(colors[0]) * totalQuads * 4 );
		memset(colors, 0xFF,  totalQuads * 4 * sizeof(colors[0]));
		_withColorArray = YES;
	}
}

-(void) initIndices
{
	for( NSUInteger i=0;i<totalQuads;i++) {
		indices[i*6+0] = i*4+0;
		indices[i*6+1] = i*4+1;
		indices[i*6+2] = i*4+2;

		// inverted index. issue #179
		indices[i*6+5] = i*4+1;
		indices[i*6+4] = i*4+2;
		indices[i*6+3] = i*4+3;
		
	}
}

#pragma mark TextureAtlas - Updates

-(void) updateQuadWithTexture: (ccQuad2*) quadT vertexQuad:(ccQuad3*) quadV atIndex:(NSUInteger) n
{
	
	NSAssert( n >= 0 && n < totalQuads, @"updateQuadWithTexture: Invalid index");

	texCoordinates[n] = *quadT;
	vertices[n] = *quadV;
}

-(void) updateColorWithColorQuad:(ccColorB*)color atIndex:(NSUInteger)n
{
	NSAssert( n >= 0 && n < totalQuads, @"updateColorWithQuadColor: Invalid index");

	if( ! _withColorArray )
		[self initColorArray];
	for( int i=0;i<4;i++)
		colors[n*4+i] = *color;
}

#pragma mark TextureAtlas - Resize

-(void) resizeCapacity: (NSUInteger) n
{
	if( n == totalQuads )
		return;
	
	totalQuads = n;

	texCoordinates = realloc( texCoordinates, sizeof(texCoordinates[0]) * totalQuads );
	vertices = realloc( vertices, sizeof(vertices[0]) * totalQuads );
	indices = realloc( indices, sizeof(indices[0]) * totalQuads * 6 );
	
	if( _withColorArray )
		colors = realloc( colors, sizeof(colors[0]) * totalQuads * 4 );
	
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
	return [self drawNumberOfQuads: totalQuads];
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
