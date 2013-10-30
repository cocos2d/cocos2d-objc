/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#import "CCTextureAtlas.h"
#import "CCNode.h"
#import "CCProtocols.h"

@class CCTexture;

/** CCAtlasNode is a subclass of CCNode that implements the CCRGBAProtocol and
 CCTextureProtocol protocol

 It knows how to render a TextureAtlas object.
 If you are going to render a TextureAtlas consider sub-classing CCAtlasNode (or a subclass of CCAtlasNode)

 All features from CCNode are valid, plus the following features:
 - opacity and RGB colors
 */
@interface CCAtlasNode : CCNodeRGBA <CCTextureProtocol>
{
	// texture atlas
	CCTextureAtlas	*_textureAtlas;

	// chars per row
	NSUInteger		_itemsPerRow;
	// chars per column
	NSUInteger		_itemsPerColumn;

	// width of each char
	NSUInteger		_itemWidth;
	// height of each char
	NSUInteger		_itemHeight;

	// quads to draw
	NSUInteger		_quadsToDraw;

	// blend function
	ccBlendFunc		_blendFunc;

	// texture RGBA.
	ccColor3B	_colorUnmodified;
	BOOL		_opacityModifyRGB;

	// color uniform
	GLint	_uniformColor;
}

/** conforms to CCTextureProtocol protocol */
@property (nonatomic,readwrite,strong) CCTextureAtlas *textureAtlas;

/** conforms to CCTextureProtocol protocol */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;

/** conforms to CCRGBAProtocol protocol */
@property (nonatomic,readwrite) ccColor3B color;

/** how many quads to draw */
@property (nonatomic,readwrite) NSUInteger quadsToDraw;

/** creates a CCAtlasNode  with an Atlas file the width and height of each item measured in points and the quantity of items to render*/
+(id) atlasWithTileFile:(NSString*)tile tileWidth:(NSUInteger)w tileHeight:(NSUInteger)h itemsToRender: (NSUInteger) c;

/** initializes an CCAtlasNode  with an Atlas file the width and height of each item measured in points and the quantity of items to render*/
-(id) initWithTileFile:(NSString*)tile tileWidth:(NSUInteger)w tileHeight:(NSUInteger)h itemsToRender: (NSUInteger) c;

/** initializes an CCAtlasNode  with a texture the width and height of each item measured in points and the quantity of items to render*/
-(id) initWithTexture:(CCTexture*)texture tileWidth:(NSUInteger)w tileHeight:(NSUInteger)h itemsToRender: (NSUInteger) c;


/** updates the Atlas (indexed vertex array).
 * Shall be overridden in subclasses
 */
-(void) updateAtlasValues;
@end
