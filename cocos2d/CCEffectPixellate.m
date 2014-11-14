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

static float conditionBlockSize(float blockSize);

@interface CCEffectPixellateImpl : CCEffectImpl

@property (nonatomic, assign) float conditionedBlockSize;

@end


@implementation CCEffectPixellateImpl

-(id)initWithBlockSize:(float)blockSize
{
    NSArray *fragUniforms = @[
                              [CCEffectUniform uniform:@"float" name:@"u_uStep" value:[NSNumber numberWithFloat:1.0f]],
                              [CCEffectUniform uniform:@"float" name:@"u_vStep" value:[NSNumber numberWithFloat:1.0f]]
                              ];
    
    NSArray *fragFunctions = [CCEffectPixellateImpl buildFragmentFunctions];
    NSArray *renderPasses = [self buildRenderPasses];
    
    if((self = [super initWithRenderPasses:renderPasses fragmentFunctions:fragFunctions vertexFunctions:nil fragmentUniforms:fragUniforms vertexUniforms:nil varyings:nil firstInStack:YES]))
    {
        _conditionedBlockSize = conditionBlockSize(blockSize);

        self.debugName = @"CCEffectPixellateImpl";
        self.stitchFlags = CCEffectFunctionStitchAfter;
    }
    
    return self;
}

+ (NSArray *)buildFragmentFunctions
{
    // Image pixellation shader based on pixellation filter in GPUImage - https://github.com/BradLarson/GPUImage
    NSString* effectBody = CC_GLSL(
                                   vec2 samplePos = cc_FragTexCoord1 - mod(cc_FragTexCoord1, vec2(u_uStep, u_vStep)) + 0.5 * vec2(u_uStep, u_vStep);
                                   return texture2D(cc_PreviousPassTexture, samplePos);
                                   );

    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"pixellateEffect" body:effectBody inputs:nil returnType:@"vec4"];
    return @[fragmentFunction];
}

- (NSArray *)buildRenderPasses
{
    __weak CCEffectPixellateImpl *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectPixellate pass 0";
    pass0.shader = self.shader;
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){

        passInputs.shaderUniforms[CCShaderUniformMainTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;

        float aspect = passInputs.previousPassTexture.contentSize.width / passInputs.previousPassTexture.contentSize.height;
        float uStep = weakSelf.conditionedBlockSize / passInputs.previousPassTexture.contentSize.width;
        float vStep = uStep * aspect;
        
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_uStep"]] = [NSNumber numberWithFloat:uStep];
        passInputs.shaderUniforms[weakSelf.uniformTranslationTable[@"u_vStep"]] = [NSNumber numberWithFloat:vStep];
    } copy]];
    
    return @[pass0];
}

-(void)setBlockSize:(float)blockSize
{
    _conditionedBlockSize = conditionBlockSize(blockSize);
}

@end


@implementation CCEffectPixellate

-(id)init
{
    return [self initWithBlockSize:1.0f];
}

-(id)initWithBlockSize:(float)blockSize
{
    if((self = [super init]))
    {
        _blockSize = blockSize;
        
        self.effectImpl = [[CCEffectPixellateImpl alloc] initWithBlockSize:blockSize];
        self.debugName = @"CCEffectPixellate";
    }
    return self;
}

+(id)effectWithBlockSize:(float)blockSize
{
    return [[self alloc] initWithBlockSize:blockSize];
}

-(void)setBlockSize:(float)blockSize
{
    _blockSize = blockSize;
    
    CCEffectPixellateImpl *pixellateImpl = (CCEffectPixellateImpl *)self.effectImpl;
    [pixellateImpl setBlockSize:blockSize];
}

@end



float conditionBlockSize(float blockSize)
{
    // If the user requests an illegal pixel size value, just force
    // the value to 1.0 which results in the effect being a NOOP.
    return (blockSize <= 1.0f) ? 1.0f : blockSize;
}

