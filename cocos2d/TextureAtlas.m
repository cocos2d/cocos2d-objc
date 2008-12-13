/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "TextureAtlas.h"
#import "TextureMgr.h"

@interface TextureAtlas (Private)
-(void) initIndices;
@end


@implementation TextureAtlas

@synthesize totalQuads, texture;

#pragma mark TextureAtlas - alloc & init

+(id) textureAtlasWithFile:(NSString*) file capacity: (int) n
{
	return [[[self alloc] initWithFile:file capacity:n] autorelease];
}

-(id) initWithFile:(NSString*)file capacity:(int)n
{
	if( ! (self=[super init]) )
		return nil;
	
	totalQuads = n;
	
	// retained in property
	self.texture = [[TextureMgr sharedTextureMgr] addImage:file];
	
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
	for( int i=0;i<totalQuads;i++) {
		indices[i*6+0] = i*4+0;
		indices[i*6+1] = i*4+1;
		indices[i*6+2] = i*4+2;

		indices[i*6+3] = i*4+1;
		indices[i*6+4] = i*4+2;
		indices[i*6+5] = i*4+3;
	}
}

#pragma mark TextureAtlas - Updates

-(void) updateQuadWithTexture: (ccQuad2*) quadT vertexQuad:(ccQuad3*) quadV atIndex:(int) n
{
	
	NSAssert( n >= 0 && n < totalQuads, @"updateQuadWithTexture: Invalid index");

	texCoordinates[n] = *quadT;
	vertices[n] = *quadV;
}

#pragma mark TextureAtlas - Resize

-(void) resizeCapacity: (int) n
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

-(void) drawNumberOfQuads: (int) n
{
//	int	minFilter, magFilter;
//	int	wrapS, wrapT;
	
//	glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, &minFilter);
//	glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, &magFilter);
//	glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, &wrapS);
//	glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, &wrapT);
	
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		
	glBindTexture(GL_TEXTURE_2D, [texture name]);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoordinates);
	glDrawElements(GL_TRIANGLES, n*6, GL_UNSIGNED_SHORT, indices);
	
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapS);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapT);
}

@end
