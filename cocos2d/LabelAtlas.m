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

#import "LabelAtlas.h"


@implementation LabelAtlas

#pragma mark LabelAtlas - Creation & Init
+(id) labelAtlasWithString:(NSString*) string charMapFile: (NSString*) charmapfile itemWidth:(int)w itemHeight:(int)h startCharMap:(char)c
{
	return [[[self alloc] initWithString:string charMapFile:charmapfile itemWidth:w itemHeight:h startCharMap:c] autorelease];
}


-(id) initWithString:(NSString*) theString charMapFile: (NSString*) charmapfile itemWidth:(int)w itemHeight:(int)h startCharMap:(char)c
{

	if (! [super initWithTileFile:charmapfile tileWidth:w tileHeight:h itemsToRender:[theString length] ] )
		return nil;

	string = [theString retain];
	mapStartChar = c;	
	
	[self updateAltasValues];

	return self;
}

-(void) dealloc
{
	[string release];

	[super dealloc];
}

#pragma mark LabelAtlas - Atlas generation

-(void) updateAltasValues
{
	int n = [string length];
	
	ccQuad2 texCoord;
	ccQuad3 vertex;

	const char *s = [string UTF8String];

	for( int i=0; i<n; i++) {
		char a = s[i] - mapStartChar;
		float row = (a % itemsPerRow) * texStepX;
		float col = (a / itemsPerRow) * texStepY;
		
		texCoord.bl_x = row;						// A - x
		texCoord.bl_y = col;						// A - y
		texCoord.br_x = row + texStepX;				// B - x
		texCoord.br_y = col;						// B - y
		texCoord.tl_x = row;						// C - x
		texCoord.tl_y = col + texStepY;				// C - y
		texCoord.tr_x = row + texStepX;				// D - x
		texCoord.tr_y = col + texStepY;				// D - y
		
		vertex.bl_x = i * itemWidth;				// A - x
		vertex.bl_y = 0;							// A - y
		vertex.bl_z = 0;							// A - z
		vertex.br_x = i * itemWidth + itemWidth;	// B - x
		vertex.br_y = 0;							// B - y
		vertex.br_z = 0;							// B - z
		vertex.tl_x = i * itemWidth;				// C - x
		vertex.tl_y = itemWidth;					// C - y
		vertex.tl_z = 0;							// C - z
		vertex.tr_x = i * itemWidth + itemWidth;	// D - x
		vertex.tr_y = itemWidth;					// D - y
		vertex.tr_z = 0;							// D - z
		
		[textureAtlas updateQuadWithTexture:&texCoord vertexQuad:&vertex atIndex:i];
	}
}

- (void) setString:(NSString*) newString
{
	if( newString.length > textureAtlas.totalQuads )
		[textureAtlas resizeCapacity: newString.length];

	[string release];
	string = [newString retain];
	[self updateAltasValues];
}


#pragma mark LabelAtlas - draw
- (void) draw
{
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	
	glEnable( GL_TEXTURE_2D);
	
	glColor4ub( r, g, b, opacity);
	
	[textureAtlas drawNumberOfQuads: string.length];
	
	// is this chepear than saving/restoring color state ?
	glColor4ub( 255, 255, 255, 255);
	
	glDisable( GL_TEXTURE_2D);
	
	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
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
