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

// support
#import "Support/Texture2D.h"

@interface TextureAtlas (Private)
-(void) initIndices;
@end


@implementation TextureAtlas

@synthesize totalQuads, texture;

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
	
	bzero( texCoordinates, sizeof(texCoordinates[0]) * totalQuads );
	bzero( vertices, sizeof(vertices[0]) * totalQuads );	
	bzero( indices, sizeof(indices[0]) * totalQuads );	
	
	[self initIndices];
	
	return self;
}

-(void) dealloc
{
	free(vertices);
	free(texCoordinates);
	free(indices);
	
	[texture release];

	[super dealloc];
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

#pragma mark TextureAtlas - Resize

-(void) resizeCapacity: (NSUInteger) n
{
	if( n == totalQuads )
		return;
	
	totalQuads = n;

	texCoordinates = realloc( texCoordinates, sizeof(texCoordinates[0]) * totalQuads );
	vertices = realloc( vertices, sizeof(vertices[0]) * totalQuads );
	indices = realloc( indices, sizeof(indices[0]) * totalQuads * 6 );
	
	if( ! ( texCoordinates && vertices && indices) ) {
		NSLog(@"TextureAtlas: not enough memory");
		if( texCoordinates )
			free(texCoordinates);
		if( vertices )
			free(vertices);
		if( indices )
			free(vertices);
		[NSException raise:@"TextureAtlas:NoMemory" format:@"Texture Atlas. Not enough memory to resize the capacity"];
	}
	
	bzero( texCoordinates, sizeof(texCoordinates[0]) * totalQuads );
	bzero( vertices, sizeof(vertices[0]) * totalQuads );	
	bzero( indices, sizeof(indices[0]) * totalQuads );
	
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
	glDrawElements(GL_TRIANGLES, n*6, GL_UNSIGNED_SHORT, indices);	
}

@end
