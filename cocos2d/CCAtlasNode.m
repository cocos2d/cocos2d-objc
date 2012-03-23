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

@synthesize textureAtlas = textureAtlas_;
@synthesize blendFunc = blendFunc_;
@synthesize quadsToDraw = quadsToDraw_;

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

-(id) initWithTileFile:(NSString*)tile tileWidth:(NSUInteger)w tileHeight:(NSUInteger)h itemsToRender: (NSUInteger) c
{
	if( (self=[super init]) ) {
		
		itemWidth_ = w;
		itemHeight_ = h;

		opacity_ = 255;
		color_ = colorUnmodified_ = ccWHITE;
		opacityModifyRGB_ = YES;

		blendFunc_.src = CC_BLEND_SRC;
		blendFunc_.dst = CC_BLEND_DST;

		CCTextureAtlas * newAtlas = [[CCTextureAtlas alloc] initWithFile:tile capacity:c];
		self.textureAtlas = newAtlas;
		[newAtlas release];		
		
		if( ! textureAtlas_ ) {
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
		uniformColor_ = glGetUniformLocation( shaderProgram_->program_, "u_color");
	}
	return self;
}

-(void) dealloc
{
	[textureAtlas_ release];

	[super dealloc];
}

#pragma mark CCAtlasNode - Atlas generation

-(void) calculateMaxItems
{
	CGSize s = [[textureAtlas_ texture] contentSize];
	itemsPerColumn_ = s.height / itemHeight_;
	itemsPerRow_ = s.width / itemWidth_;
}

-(void) updateAtlasValues
{
	[NSException raise:@"CCAtlasNode:Abstract" format:@"updateAtlasValue not overriden"];
}

#pragma mark CCAtlasNode - draw
- (void) draw
{
	CC_NODE_DRAW_SETUP();

	ccGLBlendFunc( blendFunc_.src, blendFunc_.dst );
	
	GLfloat colors[4] = {color_.r / 255.0f, color_.g / 255.0f, color_.b / 255.0f, opacity_ / 255.0f};
	[shaderProgram_ setUniformLocation:uniformColor_ with4fv:colors count:1];

	[textureAtlas_ drawNumberOfQuads:quadsToDraw_ fromIndex:0];
}

#pragma mark CCAtlasNode - RGBA protocol

- (ccColor3B) color
{
	if(opacityModifyRGB_)
		return colorUnmodified_;

	return color_;
}

-(void) setColor:(ccColor3B)color3
{
	color_ = colorUnmodified_ = color3;

	if( opacityModifyRGB_ ){
		color_.r = color3.r * opacity_/255;
		color_.g = color3.g * opacity_/255;
		color_.b = color3.b * opacity_/255;
	}
}

-(GLubyte) opacity
{
	return opacity_;
}

-(void) setOpacity:(GLubyte) anOpacity
{
	opacity_			= anOpacity;

	// special opacity for premultiplied textures
	if( opacityModifyRGB_ )
		[self setColor: colorUnmodified_];
}

-(void) setOpacityModifyRGB:(BOOL)modify
{
	ccColor3B oldColor	= self.color;
	opacityModifyRGB_	= modify;
	self.color			= oldColor;
}

-(BOOL) doesOpacityModifyRGB
{
	return opacityModifyRGB_;
}

-(void) updateOpacityModifyRGB
{
	opacityModifyRGB_ = [textureAtlas_.texture hasPremultipliedAlpha];
}

#pragma mark CCAtlasNode - CCNodeTexture protocol

-(void) updateBlendFunc
{
	if( ! [textureAtlas_.texture hasPremultipliedAlpha] ) {
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
}

-(void) setTexture:(CCTexture2D*)texture
{
	textureAtlas_.texture = texture;
	[self updateBlendFunc];
	[self updateOpacityModifyRGB];
}

-(CCTexture2D*) texture
{
	return textureAtlas_.texture;
}

@end
