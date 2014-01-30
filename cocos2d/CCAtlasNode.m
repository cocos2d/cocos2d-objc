/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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
#import "CCNode_Private.h"

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
	return [[self alloc] initWithTileFile:tile tileWidth:w tileHeight:h itemsToRender:c];
}

-(id) initWithTileFile:(NSString*)filename tileWidth:(NSUInteger)w tileHeight:(NSUInteger)h itemsToRender: (NSUInteger) c
{
	CCTexture *texture = [[CCTextureCache sharedTextureCache] addImage:filename];
	return [self initWithTexture:texture tileWidth:w tileHeight:h itemsToRender:c];
}

-(id) initWithTexture:(CCTexture*)texture tileWidth:(NSUInteger)w tileHeight:(NSUInteger)h itemsToRender: (NSUInteger) c;
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
	
	[_shaderProgram setUniformLocation:_uniformColor with4fv:&_displayColor count:1];

	[_textureAtlas drawNumberOfQuads:_quadsToDraw fromIndex:0];
}

#pragma mark CCAtlasNode - RGBA protocol

- (CCColor*) color
{
	if (_opacityModifyRGB)
		return [CCColor colorWithCcColor3b:_colorUnmodified];

	return super.color;
}

-(void) setColor:(CCColor*)color
{
	ccColor4F color4f = color.ccColor4f;
	_colorUnmodified = color.ccColor3b;

	if( _opacityModifyRGB ){
		// premultiply the alpha back in.
		color4f.r *= color4f.a;
		color4f.g *= color4f.a;
		color4f.b *= color4f.a;
		color = [CCColor colorWithCcColor4f:color4f];
	}
	[super setColor:color];
}

-(void) setOpacity:(CGFloat) anOpacity
{
    [super setOpacity:anOpacity];

	// special opacity for premultiplied textures
	if( _opacityModifyRGB )
		[self setColor: [CCColor colorWithCcColor3b:_colorUnmodified]];
}

-(void) setOpacityModifyRGB:(BOOL)modify
{
	CCColor* oldColor	= self.color;
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

-(void) setTexture:(CCTexture*)texture
{
	_textureAtlas.texture = texture;
	[self updateBlendFunc];
	[self updateOpacityModifyRGB];
}

-(CCTexture*) texture
{
	return _textureAtlas.texture;
}

@end
