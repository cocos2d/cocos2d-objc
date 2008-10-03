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

#import "CocosNode.h"
#import "TextureAtlas.h"

/** A Label that laods the font from a Texture Atlas */
@interface LabelAtlas : CocosNode <CocosNodeOpacity> {
	
	/// texture atlas
	TextureAtlas	*texture;
	/// chars per row
	int				itemsPerRow;
	/// chars per column
	int				itemsPerColumn;
	
	/// texture coordinate x increment
	float			texStepX;
	/// texture coordinate y increment
	float			texStepY;

	/// width of each char
	int				itemWidth;
	/// height of each char
	int				itemHeight;
	
	/// string to render
	NSString		*string;
	
	/// the first char in the charmap
	char			mapStartChar;
	
	/// texture opacity
	GLubyte opacity;
	
	/// texture color
	GLubyte	r,g,b;
	
}

@property (readwrite,assign) GLubyte r, g, b, opacity;


/** creates the LabelAtlas with a string, a char map file(the atlas), the width and height of each element and the starting char of the atlas */
+(id) labelAtlasWithString:(NSString*) string charMapFile: (NSString*) charmapfile itemWidth:(int)w itemHeight:(int)h startCharMap:(char)c;

/** initializes the LabelAtlas with a string, a char map file(the atlas), the width and height of each element and the starting char of the atlas */
-(id) initWithString:(NSString*) string charMapFile: (NSString*) charmapfile itemWidth:(int)w itemHeight:(int)h startCharMap:(char)c;

/** returns the content size of the Label */
-(CGSize) contentSize;

/** set the color of the texture.
 * example:  [node setRGB: 255:128:25];
 */
-(void) setRGB: (GLubyte)r :(GLubyte)g :(GLubyte)b;

@end
