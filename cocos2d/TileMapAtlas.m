/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */

#import "TileMapAtlas.h"
#import "TGAlib.h"


@interface TileMapAtlas (Private)
-(void) loadTGAfile:(NSString*)file;
@end


@implementation TileMapAtlas

#pragma mark TileMapAtlas - Creation & Init
+(id) tileMapAtlasWithTileFile:(NSString*)tile mapFile:(NSString*)map tileWidth:(int)w tileHeight:(int)h
{
	return [[[self alloc] initWithTileFile:tile mapFile:map tileWidth:w tileHeight:h] autorelease];
}


-(id) initWithTileFile:(NSString*)tile mapFile:(NSString*)map tileWidth:(int)w tileHeight:(int)h
{
	// XXX: 200 can't be hardcoded
	if( ![super initWithTileFile:tile tileWidth:w tileHeight:h itemsToRender: 1000] )
		return nil;

	[self loadTGAfile: map];
	[self updateAltasValues];

	return self;
}

-(void) dealloc
{	
	tgaDestroy(tgaInfo);
	[super dealloc];
}

-(void) loadTGAfile:(NSString*)file
{
	//Find the path of the file
	NSBundle *mainBndl = [NSBundle mainBundle];
	NSString *resourcePath = [mainBndl resourcePath];
	NSString * path = [resourcePath stringByAppendingPathComponent:file];
	
	tgaInfo = tgaLoad( [path UTF8String] );
	if( tgaInfo->status != TGA_OK ) {
		[NSException raise:@"TileMapAtlasLoadTGA" format:@"TileMapAtas cannot load TGA file"];
	}	
}

#pragma mark TileMapAtlas - Atlas generation

-(void) updateAltasValues {	
	int n = 1000;
	
	ccQuad2 texCoord;
	ccQuad3 vertex;
	
	int total = 0;

	for(int x=0;x < tgaInfo->width; x++ ) {
		for( int y=0; y < tgaInfo->height; y++ ) {
			if( total < n ) {
				ccRGBB *ptr = (ccRGBB*) tgaInfo->imageData;
				ccRGBB value = ptr[x + y * tgaInfo->width];
				
				if( value.r != 0 ) {
				
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
					
					vertex.bl_x = x * itemWidth;					// A - x
					vertex.bl_y = y * itemHeight;					// A - y
					vertex.bl_z = 0;								// A - z
					vertex.br_x = x * itemWidth + itemWidth-0;		// B - x
					vertex.br_y = y * itemHeight;					// B - y
					vertex.br_z = 0;								// B - z
					vertex.tl_x = x * itemWidth;					// C - x
					vertex.tl_y = y * itemHeight + itemHeight-0;	// C - y
					vertex.tl_z = 0;								// C - z
					vertex.tr_x = x * itemWidth + itemWidth-0;		// D - x
					vertex.tr_y = y * itemHeight + itemHeight-0;	// D - y
					vertex.tr_z = 0;								// D - z
					
					[texture updateQuadWithTexture:&texCoord vertexQuad:&vertex atIndex:total];

					total++;
				}
			}
		}
	}
}
@end
