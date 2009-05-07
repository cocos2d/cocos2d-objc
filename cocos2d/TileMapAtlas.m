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

#import "TileMapAtlas.h"
#import "ccMacros.h"
#import "Support/FileUtils.h"

@interface TileMapAtlas (Private)
-(void) loadTGAfile:(NSString*)file;
-(void) calculateItemsToRender;
-(void) updateAtlasValueAt:(ccGridSize)pos withValue:(ccRGBB)value withIndex:(int)idx;
@end


@implementation TileMapAtlas

@synthesize contentSize;
@synthesize tgaInfo;

#pragma mark TileMapAtlas - Creation & Init
+(id) tileMapAtlasWithTileFile:(NSString*)tile mapFile:(NSString*)map tileWidth:(int)w tileHeight:(int)h
{
	return [[[self alloc] initWithTileFile:tile mapFile:map tileWidth:w tileHeight:h] autorelease];
}


-(id) initWithTileFile:(NSString*)tile mapFile:(NSString*)map tileWidth:(int)w tileHeight:(int)h
{
	[self loadTGAfile: map];
	[self calculateItemsToRender];

	if( !(self=[super initWithTileFile:tile tileWidth:w tileHeight:h itemsToRender: itemsToRender]) )
		return nil;

	posToAtlasIndex = [[NSMutableDictionary dictionaryWithCapacity:itemsToRender] retain];

	[self updateAtlasValues];
	
	contentSize.width = tgaInfo->width * itemWidth;
	contentSize.height = tgaInfo->height * itemHeight;

	return self;
}

-(void) dealloc
{
	if( tgaInfo )
		tgaDestroy(tgaInfo);

	[posToAtlasIndex release];

	[super dealloc];
}

-(void) releaseMap
{
	if( tgaInfo )
		tgaDestroy(tgaInfo);
	tgaInfo = nil;

	[posToAtlasIndex release];
	posToAtlasIndex = nil;
}

-(void) calculateItemsToRender
{
	NSAssert( tgaInfo != nil, @"tgaInfo must be non-nil");

	itemsToRender = 0;
	for(int x=0;x < tgaInfo->width; x++ ) {
		for( int y=0; y < tgaInfo->height; y++ ) {
			ccRGBB *ptr = (ccRGBB*) tgaInfo->imageData;
			ccRGBB value = ptr[x + y * tgaInfo->width];
			if( value.r )
				itemsToRender++;
		}
	}
}

-(void) loadTGAfile:(NSString*)file
{
	NSAssert( file != nil, @"file must be non-nil");

	NSString *path = [FileUtils fullPathFromRelativePath:file ];

//	//Find the path of the file
//	NSBundle *mainBndl = [NSBundle mainBundle];
//	NSString *resourcePath = [mainBndl resourcePath];
//	NSString * path = [resourcePath stringByAppendingPathComponent:file];
	
	tgaInfo = tgaLoad( [path UTF8String] );
#if 1
	if( tgaInfo->status != TGA_OK ) {
		[NSException raise:@"TileMapAtlasLoadTGA" format:@"TileMapAtas cannot load TGA file"];
	}
#endif
}

#pragma mark TileMapAtlas - Atlas generation / updates

-(void) setTile:(ccRGBB) tile at:(ccGridSize) pos
{
	NSAssert( tgaInfo != nil, @"tgaInfo must not be nil");
	NSAssert( posToAtlasIndex != nil, @"posToAtlasIndex must not be nil");
	NSAssert( pos.x < tgaInfo->width, @"Invalid position.x");
	NSAssert( pos.y < tgaInfo->height, @"Invalid position.x");
	NSAssert( tile.r != 0, @"R component must be non 0");
	
	ccRGBB *ptr = (ccRGBB*) tgaInfo->imageData;
	ccRGBB value = ptr[pos.x + pos.y * tgaInfo->width];
	if( value.r == 0 ) {
		CCLOG(@"Value.r must be non 0.");
	} else {
		ptr[pos.x + pos.y * tgaInfo->width] = tile;
		
		// XXX: this method consumes a lot of memory
		// XXX: a tree of something like that shall be impolemented
		NSNumber *num = [posToAtlasIndex objectForKey: [NSString stringWithFormat:@"%d,%d", pos.x, pos.y]];
		[self updateAtlasValueAt:pos withValue:tile withIndex: [num integerValue]];
	}	
}

-(ccRGBB) tileAt:(ccGridSize) pos
{
	NSAssert( tgaInfo != nil, @"tgaInfo must not be nil");
	NSAssert( pos.x < tgaInfo->width, @"Invalid position.x");
	NSAssert( pos.y < tgaInfo->height, @"Invalid position.y");
	
	ccRGBB *ptr = (ccRGBB*) tgaInfo->imageData;
	ccRGBB value = ptr[pos.x + pos.y * tgaInfo->width];
	
	return value;	
}

-(void) updateAtlasValueAt:(ccGridSize)pos withValue:(ccRGBB)value withIndex:(int)idx
{
	ccQuad2 texCoord;
	ccQuad3 vertex;
	int x = pos.x;
	int y = pos.y;
	float row = (value.r % itemsPerRow) * texStepX;
	float col = (value.r / itemsPerRow) * texStepY;
	
	texCoord.bl_x = row;							// A - x
	texCoord.bl_y = col;							// A - y
	texCoord.br_x = row + texStepX;					// B - x
	texCoord.br_y = col;							// B - y
	texCoord.tl_x = row;							// C - x
	texCoord.tl_y = col + texStepY;					// C - y
	texCoord.tr_x = row + texStepX;					// D - x
	texCoord.tr_y = col + texStepY;					// D - y
	
	//					CCLOG(@"Tex coords: (%f,%f), (%f,%f), (%f,%f), (%f,%f)",
	//						  texCoord.bl_x,
	//						  texCoord.bl_y,
	//						  texCoord.br_x,
	//						  texCoord.br_y,
	//						  texCoord.tl_x,
	//						  texCoord.tl_y,
	//						  texCoord.tr_x,
	//						  texCoord.tr_y );
	
	vertex.bl_x = (int) (x * itemWidth);				// A - x
	vertex.bl_y = (int) (y * itemHeight);				// A - y
	vertex.bl_z = 0.0f;									// A - z
	vertex.br_x = (int)(x * itemWidth + itemWidth);		// B - x
	vertex.br_y = (int)(y * itemHeight);				// B - y
	vertex.br_z = 0.0f;									// B - z
	vertex.tl_x = (int)(x * itemWidth);					// C - x
	vertex.tl_y = (int)(y * itemHeight + itemHeight);	// C - y
	vertex.tl_z = 0.0f;									// C - z
	vertex.tr_x = (int)(x * itemWidth + itemWidth);		// D - x
	vertex.tr_y = (int)(y * itemHeight + itemHeight);	// D - y
	vertex.tr_z = 0.0f;									// D - z
	
	[textureAtlas_ updateQuadWithTexture:&texCoord vertexQuad:&vertex atIndex:idx];
}

-(void) updateAtlasValues
{
	NSAssert( tgaInfo != nil, @"tgaInfo must be non-nil");

	
	int total = 0;

	for(int x=0;x < tgaInfo->width; x++ ) {
		for( int y=0; y < tgaInfo->height; y++ ) {
			if( total < itemsToRender ) {
				ccRGBB *ptr = (ccRGBB*) tgaInfo->imageData;
				ccRGBB value = ptr[x + y * tgaInfo->width];
				
				if( value.r != 0 ) {
					[self updateAtlasValueAt:ccg(x,y) withValue:value withIndex:total];
					
					NSString *key = [NSString stringWithFormat:@"%d,%d", x,y];
					NSNumber *num = [NSNumber numberWithInt:total];
					[posToAtlasIndex setObject:num forKey:key];

					total++;
				}
			}
		}
	}
}
@end
