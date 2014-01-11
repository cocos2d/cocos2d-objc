/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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

/** CCAtlasNode is a subclass of CCNode that implements the CCTextureProtocol protocol

 It knows how to render a TextureAtlas object.
 If you are going to render a TextureAtlas consider sub-classing CCAtlasNode (or a subclass of CCAtlasNode)

 All features from CCNode are valid, plus the following features:
 - opacity and RGB colors
 */
@interface CCAtlasNode : CCNode <CCTextureProtocol> {
	// Texture Atlas.
	CCTextureAtlas	*_textureAtlas;

	// Chars per row.
	NSUInteger		_itemsPerRow;
    
	// Chars per column.
	NSUInteger		_itemsPerColumn;

	// Width of each char.
	NSUInteger		_itemWidth;
    
	// Height of each char.
	NSUInteger		_itemHeight;

	// Quads to draw.
	NSUInteger		_quadsToDraw;

	// Blend function.
	ccBlendFunc		_blendFunc;

	// Texture RGBA.
	ccColor3B	_colorUnmodified;
	BOOL		_opacityModifyRGB;

	// Color uniform.
	GLint	_uniformColor;
}


/// -----------------------------------------------------------------------
/// @name Accessing the Atlas Node Attributes
/// -----------------------------------------------------------------------

/** Conforms to CCTextureProtocol protocol. */
@property (nonatomic,readwrite,strong) CCTextureAtlas *textureAtlas;

/** Conforms to CCTextureProtocol protocol. */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;

/** How many quads to draw. */
@property (nonatomic,readwrite) NSUInteger quadsToDraw;


/// -----------------------------------------------------------------------
/// @name Creating a CCAtlasNode Object
/// -----------------------------------------------------------------------

/**
 *  Creates a CCAtlasNode with an Atlas file the width and height of each item measured in points and the quantity of items to render.
 *
 *  @param tile Tile filename.
 *  @param w    Width of tile node.
 *  @param h    Height of tile node.
 *  @param c    Number of tiles to render.
 *
 *  @return A newly initialized CCAtlasNode.
 */
+(id) atlasWithTileFile:(NSString*)tile tileWidth:(NSUInteger)w tileHeight:(NSUInteger)h itemsToRender: (NSUInteger) c;


/// -----------------------------------------------------------------------
/// @name Initializing a CCAtlasNode Object
/// -----------------------------------------------------------------------

/**
 *  Initializes an CCAtlasNode with an Atlas file the width and height of each item measured in points and the quantity of items to render
 *
 *  @param tile Tile filename.
 *  @param w    Width of tile node.
 *  @param h    Height of tile node.
 *  @param c    Number of tiles to render.
 *
 *  @return A newly initialized CCAtlasNode.
 */
-(id) initWithTileFile:(NSString*)tile tileWidth:(NSUInteger)w tileHeight:(NSUInteger)h itemsToRender: (NSUInteger) c;

/**
 *  Initializes an CCAtlasNode  with a texture the width and height of each item measured in points and the quantity of items to render.
 *
 *  @param texture Texture.
 *  @param w       Width of tile node.
 *  @param h       Height of tile node.
 *  @param c       Number of tiles to render.
 *
 *  @return A newly initialized CCAtlasNode.
 */
-(id) initWithTexture:(CCTexture*)texture tileWidth:(NSUInteger)w tileHeight:(NSUInteger)h itemsToRender: (NSUInteger) c;

/** Updates the Atlas (indexed vertex array). Shall be overridden in subclasses. */
-(void) updateAtlasValues;

@end
