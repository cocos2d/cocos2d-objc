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

#import "LabelAtlas.h"


@implementation LabelAtlas

#pragma mark LabelAtlas - Creation & Init
+(id) labelAtlasWithString:(NSString*) string charMapFile: (NSString*) charmapfile itemWidth:(int)w itemHeight:(int)h startCharMap:(char)c
{
	return [[[self alloc] initWithString:string charMapFile:charmapfile itemWidth:w itemHeight:h startCharMap:c] autorelease];
}


-(id) initWithString:(NSString*) theString charMapFile: (NSString*) charmapfile itemWidth:(int)w itemHeight:(int)h startCharMap:(char)c
{

	if (! (self=[super initWithTileFile:charmapfile tileWidth:w tileHeight:h itemsToRender:[theString length] ]) )
		return nil;

	string = [theString retain];
	mapStartChar = c;	
	
	[self updateAtlasValues];

	return self;
}

-(void) dealloc
{
	[string release];

	[super dealloc];
}

#pragma mark LabelAtlas - Atlas generation

-(void) updateAtlasValues
{
	int n = [string length];
	
	ccV3F_C4B_T2F_Quad quad;

	const char *s = [string UTF8String];

	for( int i=0; i<n; i++) {
		char a = s[i] - mapStartChar;
		float row = (a % itemsPerRow) * texStepX;
		float col = (a / itemsPerRow) * texStepY;
		
		quad.tl.texCoords.u = row;
		quad.tl.texCoords.v = col;
		quad.tr.texCoords.u = row + texStepX;
		quad.tr.texCoords.v = col;
		quad.bl.texCoords.u = row;
		quad.bl.texCoords.v = col + texStepY;
		quad.br.texCoords.u = row + texStepX;
		quad.br.texCoords.v = col + texStepY;
		
		quad.bl.vertices.x = (int) (i * itemWidth);
		quad.bl.vertices.y = 0;
		quad.bl.vertices.z = 0.0f;
		quad.br.vertices.x = (int)(i * itemWidth + itemWidth);
		quad.br.vertices.y = 0;
		quad.br.vertices.z = 0.0f;
		quad.tl.vertices.x = (int)(i * itemWidth);
		quad.tl.vertices.y = (int)(itemHeight);
		quad.tl.vertices.z = 0.0f;
		quad.tr.vertices.x = (int)(i * itemWidth + itemWidth);
		quad.tr.vertices.y = (int)(itemHeight);
		quad.tr.vertices.z = 0.0f;
		
		[textureAtlas_ updateQuad:&quad atIndex:i];
	}
}

- (void) setString:(NSString*) newString
{
	if( newString.length > textureAtlas_.totalQuads )
		[textureAtlas_ resizeCapacity: newString.length];

	[string release];
	string = [newString retain];
	[self updateAtlasValues];
}

#pragma mark LabelAtlas - protocol related

-(CGSize) contentSize
{
	CGSize s;
	s.width = [string length] * itemWidth;
	s.height = itemHeight;
	return s;
}
@end
