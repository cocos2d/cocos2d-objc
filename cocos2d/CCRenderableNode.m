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

#import "CCRenderableNode_Private.h"

#import "CCTexture.h"
#import "CCShader.h"
#import "CCRendererBasicTypes.h"


@implementation CCRenderableNode

-(instancetype)init
{
    if((self = [super init])){
		_shader = [CCShader positionColorShader];
		_blendMode = [CCBlendMode premultipliedAlphaMode];
    }
    
    return self;
}

// The default dictionary is either nil or only contains the main texture.
static inline BOOL
CheckDefaultUniforms(NSDictionary *uniforms, CCTexture *texture)
{
	if(uniforms == nil){
		return YES;
	} else {
		// Check that the uniforms has only one key for the main texture.
		return (uniforms.count == 1 && uniforms[CCShaderUniformMainTexture] == texture);
	}
}

-(CCRenderState *)renderState
{
	if(_renderState == nil){
		CCTexture *texture = (_texture ?: [CCTexture none]);
		
		if(CheckDefaultUniforms(_shaderUniforms, texture)){
			// Create a cached render state so we can use the fast path.
			_renderState = [CCRenderState renderStateWithBlendMode:_blendMode shader:_shader mainTexture:texture];
			
			// If the uniform dictionary was set, it was the default. Throw it away.
			_shaderUniforms = nil;
		} else {
			// Since the node has unique uniforms, it cannot be batched or use the fast path.
			_renderState = [CCRenderState renderStateWithBlendMode:_blendMode shader:_shader shaderUniforms:_shaderUniforms copyUniforms:NO];
		}
	}
	
	return _renderState;
}

-(CCShader *)shader
{
	return _shader;
}

-(void)setShader:(CCShader *)shader
{
	NSAssert(shader, @"CCNode.shader cannot be nil.");
	_shader = shader;
	_renderState = nil;
}

-(CCBlendMode *)blendMode
{
	return _blendMode;
}

-(BOOL)usesCustomShaderUniforms
{
	CCTexture *texture = (_texture ?: [CCTexture none]);
	if(CheckDefaultUniforms(_shaderUniforms, texture)){
		// If the uniform dictionary was set, it was the default. Throw it away.
		_shaderUniforms = nil;
		
		return NO;
	} else {
		return YES;
	}
}

-(NSMutableDictionary *)shaderUniforms
{
	if(_shaderUniforms == nil){
		_shaderUniforms = [NSMutableDictionary dictionaryWithObject:(_texture ?: [CCTexture none]) forKey:CCShaderUniformMainTexture];
		
		_renderState = nil;
	}
	
	return _shaderUniforms;
}

-(void)setBlendMode:(CCBlendMode *)blendMode
{
	NSAssert(blendMode, @"CCNode.blendMode cannot be nil.");
	if(_blendMode != blendMode){
		_blendMode = blendMode;
		_renderState = nil;
	}
}

-(CCTexture*)texture
{
	return _texture;
}

-(void)setTexture:(CCTexture *)texture
{
	if(_texture != texture){
		_texture = texture;
		_renderState = nil;
		
		// Set the main texture in the uniforms dictionary (if the dictionary exists).
		_shaderUniforms[CCShaderUniformMainTexture] = (_texture ?: [CCTexture none]);
	}
}

@end
