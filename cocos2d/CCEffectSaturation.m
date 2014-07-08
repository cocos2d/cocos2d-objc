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
static float conditionSaturation(float saturation);


@interface CCEffectSaturation ()

@property (nonatomic) float conditionedSaturation;

@end


@implementation CCEffectSaturation

-(id)init
{
    return [self initWithSaturation:0.0f];
}

-(id)initWithSaturation:(float)saturation
{
    CCEffectUniform* uniformSaturation = [CCEffectUniform uniform:@"float" name:@"u_saturation" value:[NSNumber numberWithFloat:1.0f]];
    
    if((self = [super initWithFragmentUniforms:@[uniformSaturation] vertexUniforms:nil varying:nil]))
    {
        _saturation = saturation;
        _conditionedSaturation = conditionSaturation(saturation);

        self.debugName = @"CCEffectSaturation";
    }
    return self;
}

+(id)effectWithSaturation:(float)saturation
{
    return [[self alloc] initWithSaturation:saturation];
}

-(void)buildFragmentFunctions
{
    self.fragmentFunctions = [[NSMutableArray alloc] init];

    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue" snippet:@"texture2D(cc_PreviousPassTexture, cc_FragTexCoord1)"];
    
    // Image saturation shader based on saturation filter in GPUImage - https://github.com/BradLarson/GPUImage
    NSString* effectBody = CC_GLSL(
                                   const vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);

                                   float luminance = dot(inputValue.rgb, luminanceWeighting);
                                   vec3 greyScaleColor = vec3(luminance);

                                   return vec4(mix(greyScaleColor, inputValue.rgb, u_saturation), inputValue.a);
                                   );

    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"saturationEffect" body:effectBody inputs:@[input] returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectSaturation *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.shader = self.shader;
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCTexture *previousPassTexture){
        pass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        pass.shaderUniforms[self.uniformTranslationTable[@"u_saturation"]] = [NSNumber numberWithFloat:weakSelf.conditionedSaturation];
    } copy]];
    
    self.renderPasses = @[pass0];
}

-(void)setSaturation:(float)saturation
{
    _saturation = saturation;
    _conditionedSaturation = conditionSaturation(saturation);
}
@end


float conditionSaturation(float saturation)
{
    NSCAssert((saturation >= -1.0) && (saturation <= 1.0), @"Supplied saturation out of range [-1..1].");
    
    // Map from [-1..1] to [0..2]. The input values are photoshop equivalents
    // (-1 is complete desaturation, 0 is no change, and 1 is saturation boost)
    // while the output values are fed into the GLSL mix mix(a, b, t) function
    // where t=0 yields a and t=1 yields b. In our case a is the grayscale value
    // and b is the unmodified color value.
    float clampedSaturation = clampf(saturation, -1.0f, 1.0f);
    return clampedSaturation += 1.0f;
}
#endif
