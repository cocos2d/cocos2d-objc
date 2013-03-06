/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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


#import "CCAtlasNode.h"
#import "ccMacros.h"
#import "CCGLProgram.h"
#import "CCTextureCache.h"
#import "CCShaderCache.h"
#import "ccGLStateCache.h"
#import "CCDirector.h"
#import "Support/TransformUtils.h"

// external
#import "kazmath/GL/matrix.h"


@interface CCAtlasNode ()
-(void) calculateMaxItems;
-(void) updateBlendFunc;
-(void) updateOpacityModifyRGB;
@end

@implementation CCAtlasNode

@synthesize textureAtlas = _textureAtlas;
@synthesize blendFunc = _blendFunc;
@synthesize quadsToDraw = _quadsToDraw;

#pragma mark CCAtlasNode - Creation & Init
- (id) init
{
	NSAssert( NO, @"Not supported - Use initWtihTileFile instead");
    return self;
}

+(id) atlasWithTileFile:(NSString*)tile tileWidth:(NSUInteger)w tileHeight:(NSUInteger)h itemsToRender: (NSUInteger) c
{
	return [[[self alloc] initWithTileFile:tile tileWidth:w tileHeight:h itemsToRender:c] autorelease];
}

-(id) initWithTileFile:(NSString*)filename tileWidth:(NSUInteger)w tileHeight:(NSUInteger)h itemsToRender: (NSUInteger) c
{
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:filename];
	return [self initWithTexture:texture tileWidth:w tileHeight:h itemsToRender:c];
}

-(id) initWithTexture:(CCTexture2D*)texture tileWidth:(NSUInteger)w tileHeight:(NSUInteger)h itemsToRender: (NSUInteger) c;
{
	if( (self=[super init]) ) {
		
		_itemWidth = w;
		_itemHeight = h;

		_colorUnmodified = ccWHITE;
		_opacityModifyRGB = YES;

		_blendFunc.src = CC_BLEND_SRC;
		_blendFunc.dst = CC_BLEND_DST;

		_textureAtlas = [[CCTextureAtlas alloc] initWithTexture:texture capacity:c];
		
		if( ! _textureAtlas ) {
			CCLOG(@"cocos2d: Could not initialize CCAtlasNode. Invalid Texture");
			[self release];
			return nil;
		}

		[self updateBlendFunc];
		[self updateOpacityModifyRGB];

		[self calculateMaxItems];

		self.quadsToDraw = c;

		// shader stuff
		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTexture_uColor];
		_uniformColor = glGetUniformLocation( _shaderProgram.program, "u_color");
	}
	return self;
}

-(void) dealloc
{
	[_textureAtlas release];

	[super dealloc];
}

#pragma mark CCAtlasNode - Atlas generation

-(void) calculateMaxItems
{
	CGSize s = [[_textureAtlas texture] contentSize];
	_itemsPerColumn = s.height / _itemHeight;
	_itemsPerRow = s.width / _itemWidth;
}

-(void) updateAtlasValues
{
	[NSException raise:@"CCAtlasNode:Abstract" format:@"updateAtlasValue not overriden"];
}

#pragma mark CCAtlasNode - draw
- (void) draw
{
	CC_NODE_DRAW_SETUP();

	ccGLBlendFunc( _blendFunc.src, _blendFunc.dst );
	
	GLfloat colors[4] = { _displayedColor.r / 255.0f,
                          _displayedColor.g / 255.0f,
                          _displayedColor.b / 255.0f,
                          _displayedOpacity / 255.0f};
	[_shaderProgram setUniformLocation:_uniformColor with4fv:colors count:1];

	[_textureAtlas drawNumberOfQuads:_quadsToDraw fromIndex:0];
}

#pragma mark CCAtlasNode - RGBA protocol

- (ccColor3B) color
{
	if (_opacityModifyRGB)
		return _colorUnmodified;

	return super.color;
}

-(void) setColor:(ccColor3B)color3
{
	_colorUnmodified = color3;

	if( _opacityModifyRGB ){
		color3.r = color3.r * _displayedOpacity/255;
		color3.g = color3.g * _displayedOpacity/255;
		color3.b = color3.b * _displayedOpacity/255;
	}
    [super setColor:color3];
}

-(void) setOpacity:(GLubyte) anOpacity
{
    [super setOpacity:anOpacity];

	// special opacity for premultiplied textures
	if( _opacityModifyRGB )
		[self setColor: _colorUnmodified];
}

-(void) setOpacityModifyRGB:(BOOL)modify
{
	ccColor3B oldColor	= self.color;
	_opacityModifyRGB	= modify;
	self.color			= oldColor;
}

-(BOOL) doesOpacityModifyRGB
{
	return _opacityModifyRGB;
}

-(void) updateOpacityModifyRGB
{
	_opacityModifyRGB = [_textureAtlas.texture hasPremultipliedAlpha];
}

#pragma mark CCAtlasNode - CCNodeTexture protocol

-(void) updateBlendFunc
{
	if( ! [_textureAtlas.texture hasPremultipliedAlpha] ) {
		_blendFunc.src = GL_SRC_ALPHA;
		_blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
}

-(void) setTexture:(CCTexture2D*)texture
{
	_textureAtlas.texture = texture;
	[self updateBlendFunc];
	[self updateOpacityModifyRGB];
}

-(CCTexture2D*) texture
{
	return _textureAtlas.texture;
}

@end
