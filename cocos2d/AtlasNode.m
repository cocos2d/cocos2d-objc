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

#import "AtlasNode.h"


@interface AtlasNode (Private)
-(void) calculateMaxItems;
-(void) calculateTexCoordsSteps;
@end

@implementation AtlasNode

@synthesize	opacity;

#pragma mark AtlasNode - Creation & Init
+(id) atlasWithTileFile:(NSString*)tile tileWidth:(int)w tileHeight:(int)h itemsToRender: (int) c
{
	return [[[self alloc] initWithTileFile:tile tileWidth:w tileHeight:h itemsToRender:c] autorelease];
}


-(id) initWithTileFile:(NSString*)tile tileWidth:(int)w tileHeight:(int)h itemsToRender: (int) c
{
	if( ! (self=[super init]) )
		return nil;
	
	textureAtlas = [[TextureAtlas textureAtlasWithFile:tile capacity:c] retain];
	
	itemWidth = w;
	itemHeight = h;

	opacity = 255;
	r = g = b = 255;
		
	[self calculateMaxItems];
	[self calculateTexCoordsSteps];
	
	return self;
}

-(void) dealloc
{
	[textureAtlas release];
	
	[super dealloc];
}

#pragma mark AtlasNode - Atlas generation

-(void) calculateMaxItems
{
	CGSize s = [[textureAtlas texture] contentSize];
	itemsPerColumn = s.height / itemHeight;
	itemsPerRow = s.width / itemWidth;
}

-(void) calculateTexCoordsSteps
{
	texStepX = itemWidth / (float) [[textureAtlas texture] pixelsWide];
	texStepY = itemHeight / (float) [[textureAtlas texture] pixelsHigh]; 	
}

-(void) updateAltasValues
{
	[NSException raise:@"AtlasNode:Abstract" format:@"updateAtlasValue not overriden"];
}

#pragma mark AtlasNode - draw
- (void) draw
{
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	
	glEnable( GL_TEXTURE_2D);


	glColor4ub( r, g, b, opacity);

	[textureAtlas drawQuads];
	
	// is this chepear than saving/restoring color state ?
	glColor4ub( 255, 255, 255, 255);

	glDisable( GL_TEXTURE_2D);
	
	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
}

#pragma mark AtlasNode - protocol related

-(void) setRGB: (GLubyte) rr :(GLubyte) gg :(GLubyte)bb
{
	r=rr;
	g=gg;
	b=bb;
}

-(CGSize) contentSize
{
	[NSException raise:@"ContentSizeAbstract" format:@"ContentSize was not overriden"];
	return CGSizeMake(0,0);
}

@end
