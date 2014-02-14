/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2014 Cocos2D Authors
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

#import "cocos2d.h"
#import "CCRenderer_private.h"
#import "CCCache.h"
#import "CCTexture_Private.h"


//MARK: NSValue Additions.
@implementation NSValue(CCRenderer)

+(NSValue *)valueWithGLKVector2:(GLKVector2)vector
{
	return [NSValue valueWithBytes:&vector objCType:@encode(GLKVector2)];
}

+(NSValue *)valueWithGLKVector3:(GLKVector3)vector
{
	return [NSValue valueWithBytes:&vector objCType:@encode(GLKVector3)];
}

+(NSValue *)valueWithGLKVector4:(GLKVector4)vector
{
	return [NSValue valueWithBytes:&vector objCType:@encode(GLKVector4)];
}

@end


//MARK: Option Keys.
const NSString *CCRenderStateBlendMode = @"CCRenderStateBlendMode";
const NSString *CCRenderStateShader = @"CCRenderStateShader";
const NSString *CCRenderStateUniforms = @"CCRenderStateUniforms";

const NSString *CCBlendFuncSrcColor = @"CCBlendFuncSrcColor";
const NSString *CCBlendFuncDstColor = @"CCBlendFuncDstColor";
const NSString *CCBlendEquationColor = @"CCBlendEquationColor";
const NSString *CCBlendFuncSrcAlpha = @"CCBlendFuncSrcAlpha";
const NSString *CCBlendFuncDstAlpha = @"CCBlendFuncDstAlpha";
const NSString *CCBlendEquationAlpha = @"CCBlendEquationAlpha";

const NSString *CCMainTexture = @"CCMainTexture";


//MARK: Blend Modes.
@interface CCBlendMode()

-(instancetype)initWithOptions:(NSDictionary *)options;

@end


@interface CCBlendModeCache : CCCache
@end


@implementation CCBlendModeCache

-(id)objectForKey:(id<NSCopying>)options
{
	CCBlendMode *blendMode = [self rawObjectForKey:options];
	if(blendMode) return blendMode;
	
	// Normalize the blending mode to use for the key.
	id src = (options[CCBlendFuncSrcColor] ?: @(GL_ONE));
	id dst = (options[CCBlendFuncDstColor] ?: @(GL_ZERO));
	id equation = (options[CCBlendEquationColor] ?: @(GL_FUNC_ADD));
	
	NSDictionary *normalized = @{
		CCBlendFuncSrcColor: src,
		CCBlendFuncDstColor: dst,
		CCBlendEquationColor: equation,
		
		// Assume they meant non-separate blending if they didn't fill in the keys.
		CCBlendFuncSrcAlpha: (options[CCBlendFuncSrcAlpha] ?: src),
		CCBlendFuncDstAlpha: (options[CCBlendFuncDstAlpha] ?: dst),
		CCBlendEquationAlpha: (options[CCBlendEquationAlpha] ?: equation),
	};
	
	// Create the key using the normalized blending mode.
	blendMode = [super objectForKey:normalized];
	
	// Make an alias for the unnormalized version
	[self makeAlias:options forKey:normalized];
	
	return blendMode;
}

-(id)createSharedDataForKey:(NSDictionary *)options
{
	return options;
}

-(id)createPublicObjectForSharedData:(NSDictionary *)options
{
	return [[CCBlendMode alloc] initWithOptions:options];
}

// Nothing special
-(void)disposeOfSharedData:(id)data {}

@end


@implementation CCBlendMode {
	NSDictionary *_options;
}

-(instancetype)initWithOptions:(NSDictionary *)options
{
	if((self = [super init])){
		_options = options;
	}
	
	return self;
}

static CCBlendModeCache *CCBLEND_CACHE = nil;

// Default modes
static CCBlendMode *CCBLEND_DISABLED = nil;
static CCBlendMode *CCBLEND_ALPHA = nil;
static CCBlendMode *CCBLEND_PREMULTIPLIED_ALPHA = nil;
static CCBlendMode *CCBLEND_ADD = nil;
static CCBlendMode *CCBLEND_MULTIPLY = nil;

static NSDictionary *CCBLEND_DISABLED_OPTIONS = nil;

+(void)initialize
{
	CCBLEND_CACHE = [[CCBlendModeCache alloc] init];
	
	// Add the default modes
	CCBLEND_DISABLED = [self blendModeWithOptions:@{}];
	CCBLEND_DISABLED_OPTIONS = CCBLEND_DISABLED.options;
	
	CCBLEND_ALPHA = [self blendModeWithOptions:@{
		CCBlendFuncSrcColor: @(GL_SRC_ALPHA),
		CCBlendFuncDstColor: @(GL_ONE_MINUS_SRC_ALPHA),
	}];
	
	CCBLEND_PREMULTIPLIED_ALPHA = [self blendModeWithOptions:@{
		CCBlendFuncSrcColor: @(GL_ONE),
		CCBlendFuncDstColor: @(GL_ONE_MINUS_SRC_ALPHA),
	}];
	
	CCBLEND_ADD = [self blendModeWithOptions:@{
		CCBlendFuncSrcColor: @(GL_ONE),
		CCBlendFuncDstColor: @(GL_ONE),
	}];
	
	CCBLEND_MULTIPLY = [self blendModeWithOptions:@{
		CCBlendFuncSrcColor: @(GL_DST_COLOR),
		CCBlendFuncDstColor: @(GL_ZERO),
	}];
}

+(CCBlendMode *)blendModeWithOptions:(NSDictionary *)options
{
	return [CCBLEND_CACHE objectForKey:options];
}

+(CCBlendMode *)disabledMode
{
	return CCBLEND_DISABLED;
}

+(CCBlendMode *)alphaMode
{
	return CCBLEND_ALPHA;
}

+(CCBlendMode *)premultipliedAlphaMode
{
	return CCBLEND_PREMULTIPLIED_ALPHA;
}

+(CCBlendMode *)addMode
{
	return CCBLEND_ADD;
}

+(CCBlendMode *)multiplyMode
{
	return CCBLEND_MULTIPLY;
}

@end


//MARK: Render States.
@interface CCRenderState()

-(instancetype)initWithOptions:(NSDictionary *)options;

@end


@interface CCRenderStateCache : CCCache
@end


@implementation CCRenderStateCache

-(id)objectForKey:(id<NSCopying>)options
{
	CCRenderState *renderState = [self rawObjectForKey:options];
	if(renderState) return renderState;
	
	// Normalize the render state to use for the key.
	id blendMode = (options[CCRenderStateBlendMode] ?: CCBLEND_DISABLED);
	NSAssert([blendMode isKindOfClass:[CCBlendMode class]], @"CCRenderStateBlendMode value is not a CCBlendMode object.");
	
	id shader = (options[CCRenderStateShader] ?: [NSNull null]);
	NSAssert([shader isKindOfClass:[CCGLProgram class]], @"CCRenderStateShader value is not a CCGLProgram object.");
	
	id uniforms = ([options[CCRenderStateUniforms] copy] ?: @{});
	NSAssert([uniforms isKindOfClass:[NSDictionary class]], @"CCRenderStateShaderUniforms value is not a NSDictionary object.");
	
	NSDictionary *normalized = @{
		CCRenderStateBlendMode: blendMode,
		CCRenderStateShader: shader,
		CCRenderStateUniforms: uniforms,
	};
	
	// Create the key using the normalized blending mode.
	renderState = [super objectForKey:normalized];
	
	// Make an alias for the unnormalized version
	[self makeAlias:options forKey:normalized];
	
	return renderState;
}

-(id)createSharedDataForKey:(NSDictionary *)options
{
	return options;
}

-(id)createPublicObjectForSharedData:(NSDictionary *)options
{
	return [[CCRenderState alloc] initWithOptions:options];
}

// Nothing special
-(void)disposeOfSharedData:(id)data {}

@end


@implementation CCRenderState {
	NSDictionary *_options;
}

-(instancetype)initWithOptions:(NSDictionary *)options
{
	if((self = [super init])){
		_options = options;
	}
	
	return self;
}

static CCRenderStateCache *CCRENDERSTATE_CACHE = nil;

+(void)initialize
{
	CCRENDERSTATE_CACHE = [[CCRenderStateCache alloc] init];
}

+(CCRenderState *)renderStateWithOptions:(NSDictionary *)options
{
	return [CCRENDERSTATE_CACHE objectForKey:options];
}

@end


//MARK: Render Queue
@implementation CCRenderer {
	NSDictionary *_renderOptions;
	
	NSDictionary *_blendOptions;
	
	// TODO buffer the full texture state.
	CCTexture *_texture;
	
	CCGLProgram *_shader;
	NSDictionary *_uniforms;
}

-(void)invalidateState
{
	_renderOptions = nil;
	_blendOptions = nil;
	_texture = nil;
	_shader = nil;
	_uniforms = nil;
}

-(instancetype)init
{
	if((self = [super init])){
	}
	
	return self;
}

-(void)setBlendOptions:(NSDictionary *)blendOptions;
{
	// TODO should cache enable status, but need to deal with nil.
	if(blendOptions == CCBLEND_DISABLED_OPTIONS){
		glDisable(GL_BLEND);
	} else {
		glEnable(GL_BLEND);
		
		glBlendFuncSeparate(
			[blendOptions[CCBlendFuncSrcColor] unsignedIntValue],
			[blendOptions[CCBlendFuncDstColor] unsignedIntValue],
			[blendOptions[CCBlendFuncSrcAlpha] unsignedIntValue],
			[blendOptions[CCBlendFuncDstAlpha] unsignedIntValue]
		);
		
		glBlendEquationSeparate(
			[blendOptions[CCBlendEquationColor] unsignedIntValue],
			[blendOptions[CCBlendEquationAlpha] unsignedIntValue]
		);
	}
	
	_blendOptions = blendOptions;
}

-(void)setRenderState:(CCRenderState *)renderState
{
	NSDictionary *renderOptions = renderState.options;
	if(renderOptions == _renderOptions) return;
	
	NSDictionary *blendOptions = [(CCBlendMode *)renderOptions[CCRenderStateBlendMode] options];
	if(blendOptions != _blendOptions) [self setBlendOptions:blendOptions];
	
	CCGLProgram *shader = renderOptions[CCRenderStateShader];
	if(shader != _shader) [shader use];
	
	NSDictionary *uniforms = renderOptions[CCRenderStateUniforms];
	if(uniforms != _uniforms){
		// TODO finish me!
		CCTexture *texture = uniforms[CCMainTexture];
		if(texture != _texture && texture != [NSNull null]){
			glBindTexture(GL_TEXTURE_2D, texture.name);
			_texture = texture;
		}
	}
}

@end
