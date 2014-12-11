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


static float conditionSaturation(float saturation);


@interface CCEffectSaturation ()
@property (nonatomic, strong) NSNumber *conditionedSaturation;
@end


@interface CCEffectSaturationImpl : CCEffectImpl
@property (nonatomic, weak) CCEffectSaturation *interface;
@end


@implementation CCEffectSaturationImpl

-(id)initWithInterface:(CCEffectSaturation *)interface
{
    CCEffectUniform* uniformSaturation = [CCEffectUniform uniform:@"float" name:@"u_saturation" value:[NSNumber numberWithFloat:1.0f]];
    
    NSArray *fragFunctions = [CCEffectSaturationImpl buildFragmentFunctions];
    NSArray *renderPasses = [CCEffectSaturationImpl buildRenderPassesWithInterface:interface];
    
    if((self = [super initWithRenderPasses:renderPasses fragmentFunctions:fragFunctions vertexFunctions:nil fragmentUniforms:@[uniformSaturation] vertexUniforms:nil varyings:nil]))
    {
        self.interface = interface;
        self.debugName = @"CCEffectSaturationImpl";
    }
    return self;
}

+ (NSArray *)buildFragmentFunctions
{
    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue" initialSnippet:CCEffectDefaultInitialInputSnippet snippet:CCEffectDefaultInputSnippet];

    // Image saturation shader based on saturation filter in GPUImage - https://github.com/BradLarson/GPUImage
    NSString* effectBody = CC_GLSL(
                                   const vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);

                                   float luminance = dot(inputValue.rgb, luminanceWeighting);
                                   vec3 greyScaleColor = vec3(luminance);

                                   return vec4(mix(greyScaleColor, inputValue.rgb, u_saturation), inputValue.a);
                                   );

    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"saturationEffect" body:effectBody inputs:@[input] returnType:@"vec4"];
    return @[fragmentFunction];
}

+ (NSArray *)buildRenderPassesWithInterface:(CCEffectSaturation *)interface
{
    __weak CCEffectSaturation *weakInterface = interface;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectSaturation pass 0";
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){
        
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Center] = [NSValue valueWithGLKVector2:passInputs.texCoord1Center];
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Extents] = [NSValue valueWithGLKVector2:passInputs.texCoord1Extents];

        passInputs.shaderUniforms[pass.uniformTranslationTable[@"u_saturation"]] = weakInterface.conditionedSaturation;
    } copy]];
    
    return @[pass0];
}

@end


@implementation CCEffectSaturation

-(id)init
{
    return [self initWithSaturation:0.0f];
}

-(id)initWithSaturation:(float)saturation
{
    if((self = [super init]))
    {
        _saturation = saturation;
        _conditionedSaturation = [NSNumber numberWithFloat:conditionSaturation(saturation)];

        self.effectImpl = [[CCEffectSaturationImpl alloc] initWithInterface:self];
        self.debugName = @"CCEffectSaturation";
    }
    return self;
}

+(id)effectWithSaturation:(float)saturation
{
    return [[self alloc] initWithSaturation:saturation];
}

-(void)setSaturation:(float)saturation
{
    _saturation = saturation;
    _conditionedSaturation = [NSNumber numberWithFloat:conditionSaturation(saturation)];
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
