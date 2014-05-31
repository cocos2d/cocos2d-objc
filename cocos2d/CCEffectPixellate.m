//
//  CCEffectPixellate.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/8/14.
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


#import "CCEffectPixellate.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
static float conditionBlockSize(float blockSize);

@implementation CCEffectPixellate


-(id)init
{
    CCEffectUniform* uniformUStep = [CCEffectUniform uniform:@"float" name:@"u_uStep" value:[NSNumber numberWithFloat:1.0f]];
    CCEffectUniform* uniformVStep = [CCEffectUniform uniform:@"float" name:@"u_vStep" value:[NSNumber numberWithFloat:1.0f]];
    
    if((self = [super initWithUniforms:@[uniformUStep, uniformVStep] vertextUniforms:nil varying:nil]))
    {
        self.debugName = @"CCEffectPixellate";
        return self;
    }
    return self;
}

-(id)initWithBlockSize:(float)blockSize
{
    if((self = [self init]))
    {
        _blockSize = conditionBlockSize(blockSize);
    }
    return self;
}

+(id)effectWithBlockSize:(float)blockSize;
{
    return [[self alloc] initWithBlockSize:blockSize];
}

-(void)buildFragmentFunctions
{
    // Image pixellation shader based on pixellation filter in GPUImage - https://github.com/BradLarson/GPUImage
    NSString* effectBody = CC_GLSL(
                                   vec2 samplePos = cc_FragTexCoord1 - mod(cc_FragTexCoord1, vec2(u_uStep, u_vStep)) + 0.5 * vec2(u_uStep, u_vStep);
                                   return texture2D(cc_PreviousPassTexture, samplePos);
                                   );

    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"pixellateEffect" body:effectBody returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectPixellate *weakSelf = self;
    __weak CCEffectRenderPass *weakPass = nil;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    weakPass = pass0;
    pass0.shader = self.shader;
    pass0.shaderUniforms = self.shaderUniforms;
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlock = ^(CCTexture *previousPassTexture){
        
        weakPass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTexture;
        weakPass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;

        float aspect = previousPassTexture.contentSize.width / previousPassTexture.contentSize.height;
        float uStep = self.blockSize / previousPassTexture.contentSize.width;
        float vStep = uStep * aspect;
        
        weakPass.shaderUniforms[@"u_uStep"] = [NSNumber numberWithFloat:uStep];
        weakPass.shaderUniforms[@"u_vStep"] = [NSNumber numberWithFloat:vStep];
    };
    
    self.renderPasses = @[pass0];
}

-(void)setBlockSize:(float)blockSize
{
    _blockSize = conditionBlockSize(blockSize);
}

@end

float conditionBlockSize(float blockSize)
{
    // If the user requests an illegal pixel size value, just force
    // the value to 1.0 which results in the effect being a NOOP.
    return (blockSize <= 1.0f) ? 1.0f : blockSize;
}

#endif
