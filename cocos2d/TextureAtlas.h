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

#import "Texture2D.h"
#import "types.h"

@interface TextureAtlas : Texture2D {
	int			totalQuads;
	ccQuad2		*texCoordinates;
	ccQuad3		*vertices;
	GLushort	*indices;
}

/** creates a TextureAtlas with an iname and with a capacity for n Quads
 * n is the number of Quads that will be rendered at once from this Atlas
 * n is the maximun number of Quads it will be able to render, but not the minimun
 */
+(id) textureAtlasWithImage:(UIImage*)image capacity: (int) n;

/** initializes a TextureAtlas with an iname and with a capacity for n Quads
 * n is the number of Quads that will be rendered at once from this Atlas
 * n is the maximun number of Quads it will be able to render, but not the minimun
 */
-(id) initWithImage: (UIImage*) image capacity:(int)n;

/** updates a certain texture coordinate & vertex with new Quads.
 * n must be between 0 and the atlas capacity - 1
 * The default value of all of the Quads is 0,0,0,0,0,0,0,0, so this selector
 * must be called to initializes every Quad
 */
-(void) updateQuadWithTexture: (ccQuad2*) quadT vertexQuad:(ccQuad3*) quadV atIndex:(int) n;


/** draws n quads
 * n can't be greater than the capacity of the Atlas
 */
-(void) drawNumberOfQuads: (int) n;

/** draws all the Atlas's Quads
 */
-(void) drawQuads;

@end
