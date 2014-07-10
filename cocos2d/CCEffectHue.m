//
//  CCEffectHue.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/9/14.
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


#import "CCEffectHue.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
static float conditionHue(float hue);

@interface CCEffectHue ()

@property (nonatomic) float conditionedHue;

@end


@implementation CCEffectHue

-(id)init
{
    return [self initWithHue:0.0f];
}

-(id)initWithHue:(float)hue
{
    CCEffectUniform* uniformHue = [CCEffectUniform uniform:@"float" name:@"u_hue" value:[NSNumber numberWithFloat:hue]];
    
    if((self = [super initWithFragmentUniforms:@[uniformHue] vertexUniforms:nil varying:nil]))
    {
        _hue = hue;
        _conditionedHue = conditionHue(hue);
        
        self.debugName = @"CCEffectHue";
    }
    return self;
}

+(id)effectWithHue:(float)hue
{
    return [[self alloc] initWithHue:hue];
}

-(void)buildFragmentFunctions
{
    self.fragmentFunctions = [[NSMutableArray alloc] init];

    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue" snippet:@"texture2D(cc_PreviousPassTexture, cc_FragTexCoord1)"];

    // Image hue shader based on hue filter in GPUImage - https://github.com/BradLarson/GPUImage
    NSString* effectBody = CC_GLSL(
                                   const highp vec4  kRGBToYPrime = vec4 (0.299, 0.587, 0.114, 0.0);
                                   const highp vec4  kRGBToI      = vec4 (0.595716, -0.274453, -0.321263, 0.0);
                                   const highp vec4  kRGBToQ      = vec4 (0.211456, -0.522591, 0.31135, 0.0);
                                   
                                   const highp vec4  kYIQToR      = vec4 (1.0, 0.9563, 0.6210, 0.0);
                                   const highp vec4  kYIQToG      = vec4 (1.0, -0.2721, -0.6474, 0.0);
                                   const highp vec4  kYIQToB      = vec4 (1.0, -1.1070, 1.7046, 0.0);
                                   
                                   // Convert to YIQ
                                   highp float YPrime = dot (inputValue, kRGBToYPrime);
                                   highp float I      = dot (inputValue, kRGBToI);
                                   highp float Q      = dot (inputValue, kRGBToQ);
                                   
                                   // Calculate the hue and chroma
                                   highp float hue    = atan (Q, I);
                                   highp float chroma = sqrt (I * I + Q * Q);
                                   
                                   // Make the user's adjustments.
                                   hue += -u_hue; // Why is this negative?
                                   
                                   // Convert back to YIQ
                                   Q = chroma * sin (hue);
                                   I = chroma * cos (hue);
                                   
                                   // Convert back to RGB
                                   vec4 outputColor;
                                   highp vec4    yIQ   = vec4 (YPrime, I, Q, 0.0);
                                   outputColor.r = dot (yIQ, kYIQToR);
                                   outputColor.g = dot (yIQ, kYIQToG);
                                   outputColor.b = dot (yIQ, kYIQToB);
                                   outputColor.a = inputValue.a;
                                   
                                   return outputColor;
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"hueEffect" body:effectBody inputs:@[input] returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectHue *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.shader = self.shader;
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCTexture *previousPassTexture){
        pass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTexture;
        pass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_hue"]] = [NSNumber numberWithFloat:weakSelf.conditionedHue];
    } copy]];
    
    self.renderPasses = @[pass0];
}

-(void)setHue:(float)hue
{
    _hue = hue;
    _conditionedHue = conditionHue(hue);
}

@end

float conditionHue(float hue)
{
    NSCAssert((hue >= -180.0f) && (hue <= 180.0), @"Supplied hue out of range [-180.0..180.0].");
    return clampf(hue, -180.0f, 180.0f) * M_PI / 180.0f;
}

#endif
