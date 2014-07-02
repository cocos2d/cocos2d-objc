//
//  CCEffectSaturation.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/14/14.
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


#import "CCEffectSaturation.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@implementation CCEffectSaturation


-(id)init
{
    CCEffectUniform* uniformSaturation = [CCEffectUniform uniform:@"float" name:@"u_saturation" value:[NSNumber numberWithFloat:1.0f]];
    
    if((self = [super initWithUniforms:@[uniformSaturation] vertextUniforms:nil varying:nil]))
    {
        self.debugName = @"CCEffectSaturation";
        return self;
    }
    return self;
}

-(id)initWithSaturation:(float)saturation
{
    if((self = [self init]))
    {
        _saturation = saturation;
    }
    return self;
}

+(id)effectWithSaturation:(float)saturation
{
    return [[self alloc] initWithSaturation:saturation];
}

-(void)buildFragmentFunctions
{
    // Image saturation shader based on saturation filter in GPUImage - https://github.com/BradLarson/GPUImage
    NSString* effectBody = CC_GLSL(
                                   const vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);

                                   vec4 inputValue = texture2D(cc_PreviousPassTexture, cc_FragTexCoord1);
                                   float luminance = dot(inputValue.rgb, luminanceWeighting);
                                   vec3 greyScaleColor = vec3(luminance);

                                   return vec4(mix(greyScaleColor, inputValue.rgb, u_saturation), inputValue.a);
                                   );

    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"saturationEffect" body:effectBody returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectSaturation *weakSelf = self;
    __weak CCEffectRenderPass *weakPass = nil;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    weakPass = pass0;
    pass0.shader = self.shader;
    pass0.shaderUniforms = self.shaderUniforms;
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlock = ^(CCTexture *previousPassTexture){
        weakPass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        weakPass.shaderUniforms[@"u_saturation"] = [NSNumber numberWithFloat:weakSelf.saturation];
    };
    
    self.renderPasses = @[pass0];
}

@end
#endif
