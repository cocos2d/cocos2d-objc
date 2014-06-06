//
//  CCEffectGaussianBlur.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 5/12/14.
//
//
//  This effect makes use of algorithms and GLSL shaders from GPUImage whose
//  license is included here.
//
//  <Begin GPUImage license>
//
//  Copyright (c) 2012, Brad Larson, Ben Cochran, Hugues Lismonde, Keitaroh
//  Kobayashi, Alaric Cole, Matthew Clark, Jacob Gundersen, Chris Williams.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//  Neither the name of the GPUImage framework nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//  <End GPUImage license>

#import "CCEffect_Private.h"
#import "CCEffectGaussianBlur.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@implementation CCEffectGaussianBlur

-(id)init
{
    CCEffectUniform* u_blurDirection = [CCEffectUniform uniform:@"vec2" name:@"u_blurDirection" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]];
    CCEffectVarying* v_centerTextureCoordinate = [CCEffectVarying varying:@"vec2" name:@"v_centerTextureCoordinate"];
    CCEffectVarying* v_twoStepsLeftTextureCoordinate = [CCEffectVarying varying:@"vec2" name:@"v_twoStepsLeftTextureCoordinate"];
    CCEffectVarying* v_oneStepLeftTextureCoordinate = [CCEffectVarying varying:@"vec2" name:@"v_oneStepLeftTextureCoordinate"];
    CCEffectVarying* v_oneStepRightTextureCoordinate = [CCEffectVarying varying:@"vec2" name:@"v_oneStepRightTextureCoordinate"];
    CCEffectVarying* v_twoStepsRightTextureCoordinate = [CCEffectVarying varying:@"vec2" name:@"v_twoStepsRightTextureCoordinate"];
    
    if(self = [super initWithUniforms:nil
                      vertextUniforms:[NSArray arrayWithObjects:u_blurDirection, nil]
                              varying:[NSArray arrayWithObjects:v_centerTextureCoordinate, v_twoStepsLeftTextureCoordinate,
                                       v_oneStepLeftTextureCoordinate, v_oneStepRightTextureCoordinate,
                                       v_twoStepsRightTextureCoordinate, nil]])
    {
        self.debugName = @"CCEffectGaussianBlur";
        return self;
    }
    
    return self;
}


-(id)initWithbBurStrength:(float)blurStrength direction:(GLKVector2)direction
{
    if((self = [self init]))
    {
        _blurStrength = blurStrength;
        _blurDirection = direction;
        return self;
    }
    
    return self;
}

+(id)effectWithBlurStrength:(float)blurStrength direction:(GLKVector2)direction
{
    return [[self alloc] initWithbBurStrength:blurStrength direction:direction];
}

-(void)buildFragmentFunctions
{
    
    NSString* effectBody = CC_GLSL(
                                   lowp vec4 fragmentColor = texture2D(cc_PreviousPassTexture, v_centerTextureCoordinate) * 0.2270270270;
                                   fragmentColor += texture2D(cc_PreviousPassTexture, v_oneStepLeftTextureCoordinate) * 0.3162162162;
                                   fragmentColor += texture2D(cc_PreviousPassTexture, v_oneStepRightTextureCoordinate) * 0.3162162162;
                                   fragmentColor += texture2D(cc_PreviousPassTexture, v_twoStepsLeftTextureCoordinate) * 0.0702702703;
                                   fragmentColor += texture2D(cc_PreviousPassTexture, v_twoStepsRightTextureCoordinate) * 0.0702702703;
                                   
                                   return fragmentColor;
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"blurEffect" body:effectBody returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildVertexFunctions
{
    NSString* effectBody = CC_GLSL(
                                   
                                   vec2 firstOffset = vec2(1.3846153846, 1.3846153846) * u_blurDirection;
                                   vec2 secondOffset = vec2(3.2307692308, 3.2307692308) * u_blurDirection;
                                   
                                   v_centerTextureCoordinate = cc_TexCoord1;
                                   v_oneStepLeftTextureCoordinate = cc_TexCoord1 - firstOffset;
                                   v_twoStepsLeftTextureCoordinate = cc_TexCoord1 - secondOffset;
                                   v_oneStepRightTextureCoordinate = cc_TexCoord1 + firstOffset;
                                   v_twoStepsRightTextureCoordinate = cc_TexCoord1 + secondOffset;
                                   
                                   return cc_Position;
                                   );
    CCEffectFunction* vertexFunction = [[CCEffectFunction alloc] initWithName:@"glowEffect" body:effectBody returnType:@"vec4"];
    [self.vertexFunctions addObject:vertexFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectGaussianBlur *weakSelf = self;
    __weak CCEffectRenderPass *weakPass = nil;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    weakPass = pass0;
    pass0.shader = self.shader;
    pass0.shaderUniforms = self.shaderUniforms;
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlock = ^(CCTexture *previousPassTexture){
        weakPass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTexture;
        weakPass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        if([self radialBlur])
        {
            weakPass.shaderUniforms[@"u_blurDirection"] = [NSValue valueWithGLKVector2:GLKVector2Make(weakSelf.blurStrength, 0.0f)];
        }
        else
        {
            GLKVector2 dir = [self calculateBlurDirection];
            weakPass.shaderUniforms[@"u_blurDirection"] = [NSValue valueWithGLKVector2:dir];
        }
    };

    
    CCEffectRenderPass *pass1 = [[CCEffectRenderPass alloc] init];
    weakPass = pass1;
    pass1.shader = self.shader;
    pass1.shaderUniforms = self.shaderUniforms;
    pass1.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass1.beginBlock = ^(CCTexture *previousPassTexture){
        weakPass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        weakPass.shaderUniforms[@"u_blurDirection"] = [NSValue valueWithGLKVector2:GLKVector2Make(0.0f, weakSelf.blurStrength)];
    };
    
    self.renderPasses = @[pass0, pass1];
}

-(NSInteger)renderPassesRequired
{
    // optmized approach based on linear sampling - http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/ and GPUImage - https://github.com/BradLarson/GPUImage
    // pass 0: blurs (horizontal) texture[0] and outputs blurmap to texture[1]
    // pass 1: blurs (vertical) texture[1] and outputs to texture[2]
    
    return [self radialBlur] ? 2 : 1;
}

-(GLKVector2)calculateBlurDirection
{
    return GLKVector2Make(_blurDirection.x * _blurStrength, _blurDirection.y * _blurStrength);
}

-(BOOL)radialBlur
{
    BOOL ret = (_blurDirection.x == 0.0f && _blurDirection.y == 0.0f) ? YES : NO;
    return ret;
}

@end
#endif

