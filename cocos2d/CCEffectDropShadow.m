//
//  CCEffectDropShadow.m
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

#import "CCEffectDropShadow.h"
#import "CCEffectUtils.h"
#import "CCEffect_Private.h"
#import "CCTexture.h"


@interface CCEffectDropShadowImpl : CCEffectImpl

@property (nonatomic, weak) CCEffectDropShadow *interface;

@end


@implementation CCEffectDropShadowImpl

-(id)initWithInterface:(CCEffectDropShadow *)interface
{
    CCEffectBlurParams blurParams = CCEffectUtilsComputeBlurParams(interface.blurRadius);
    
    CCEffectUniform* u_blurDirection = [CCEffectUniform uniform:@"highp vec2" name:@"u_blurDirection"
                                                          value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]];
    
    CCEffectUniform* u_composite = [CCEffectUniform uniform:@"float" name:@"u_composite"
                                                          value:[NSNumber numberWithFloat:0.0f]];
    
    CCEffectUniform* u_shadowOffset = [CCEffectUniform uniform:@"vec2" name:@"u_shadowOffset"
                                                         value:[NSValue valueWithCGPoint:interface.shadowOffsetWithPoint]];
    
    CCEffectUniform* u_shadowColor = [CCEffectUniform uniform:@"vec4" name:@"u_shadowColor"
                                                        value:[NSValue valueWithGLKVector4:interface.shadowColor.glkVector4]];

    NSArray *fragUniforms = @[u_composite, u_blurDirection, u_shadowOffset, u_shadowColor];
    NSArray *vertUniforms = @[u_blurDirection];
    
    unsigned long count = (unsigned long)(1 + (blurParams.numberOfOptimizedOffsets * 2));
    CCEffectVarying* v_blurCoords = [CCEffectVarying varying:@"vec2" name:@"v_blurCoordinates" count:count];
    NSArray *varyings = @[v_blurCoords];

    NSArray *fragFunctions = [CCEffectDropShadowImpl buildFragmentFunctionsWithBlurParams:blurParams];
    NSArray *vertFunctions = [CCEffectDropShadowImpl buildVertexFunctionsWithBlurParams:blurParams];
    NSArray *renderPasses = [CCEffectDropShadowImpl buildRenderPassesWithInterface:interface];
    
    if((self = [super initWithRenderPasses:renderPasses fragmentFunctions:fragFunctions vertexFunctions:vertFunctions fragmentUniforms:fragUniforms vertexUniforms:vertUniforms varyings:varyings]))
    {
        self.interface = interface;
        self.debugName = @"CCEffectDropShadowImpl";        
        self.stitchFlags = 0;
        return self;
    }
    
    return self;
}

+ (NSArray *)buildFragmentFunctionsWithBlurParams:(CCEffectBlurParams)blurParams
{
    GLfloat *standardGaussianWeights = calloc(blurParams.trueRadius + 1, sizeof(GLfloat));
    GLfloat sumOfWeights = 0.0;
    for (NSUInteger currentGaussianWeightIndex = 0; currentGaussianWeightIndex < blurParams.trueRadius + 1; currentGaussianWeightIndex++)
    {
        standardGaussianWeights[currentGaussianWeightIndex] = (1.0 / sqrt(2.0 * M_PI * pow(blurParams.sigma, 2.0))) * exp(-pow(currentGaussianWeightIndex, 2.0) / (2.0 * pow(blurParams.sigma, 2.0)));
        
        if (currentGaussianWeightIndex == 0)
        {
            sumOfWeights += standardGaussianWeights[currentGaussianWeightIndex];
        }
        else
        {
            sumOfWeights += 2.0 * standardGaussianWeights[currentGaussianWeightIndex];
        }
    }
    
    // Next, normalize these weights to prevent the clipping of the Gaussian curve at the end of the discrete samples from reducing luminance
    for (NSUInteger currentGaussianWeightIndex = 0; currentGaussianWeightIndex < blurParams.trueRadius + 1; currentGaussianWeightIndex++)
    {
        standardGaussianWeights[currentGaussianWeightIndex] = standardGaussianWeights[currentGaussianWeightIndex] / sumOfWeights;
    }
    
    // From these weights we calculate the offsets to read interpolated values from
    NSUInteger trueNumberOfOptimizedOffsets = blurParams.trueRadius / 2 + (blurParams.trueRadius % 2);
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    
    // Header
    [shaderString appendString:@"\
    if(u_composite == 1.0)\n\
    {\n\
        highp float shadowOffsetAlpha = texture2D(cc_PreviousPassTexture, cc_FragTexCoord1 - u_shadowOffset).a;\n\
        vec4 shadowColor = u_shadowColor * shadowOffsetAlpha;\n\
        vec4 outputColor = inputValue * texture2D(cc_MainTexture, cc_FragTexCoord1);\n\
        outputColor = outputColor + (1.0 - outputColor.a) * shadowColor;\n\
        return outputColor;\n\
     }\n"];
    
    [shaderString appendFormat:@"\
     highp vec4 sum = vec4(0.0);\n"];
    
    // Inner texture loop
    [shaderString appendFormat:@"sum += texture2D(cc_PreviousPassTexture, v_blurCoordinates[0]) * %f;\n", standardGaussianWeights[0]];
    
    for (NSUInteger currentBlurCoordinateIndex = 0; currentBlurCoordinateIndex < blurParams.numberOfOptimizedOffsets; currentBlurCoordinateIndex++)
    {
        GLfloat firstWeight = standardGaussianWeights[currentBlurCoordinateIndex * 2 + 1];
        GLfloat secondWeight = standardGaussianWeights[currentBlurCoordinateIndex * 2 + 2];
        GLfloat optimizedWeight = firstWeight + secondWeight;
        
        [shaderString appendFormat:@"sum += texture2D(cc_PreviousPassTexture, v_blurCoordinates[%lu]) * %f;\n", (unsigned long)((currentBlurCoordinateIndex * 2) + 1), optimizedWeight];
        [shaderString appendFormat:@"sum += texture2D(cc_PreviousPassTexture, v_blurCoordinates[%lu]) * %f;\n", (unsigned long)((currentBlurCoordinateIndex * 2) + 2), optimizedWeight];
    }
    
    // If the number of required samples exceeds the amount we can pass in via varyings, we have to do dependent texture reads in the fragment shader
    if (trueNumberOfOptimizedOffsets > blurParams.numberOfOptimizedOffsets)
    {
        [shaderString appendString:@"highp vec2 singleStepOffset = u_blurDirection;\n"];
        
        for (NSUInteger currentOverlowTextureRead = blurParams.numberOfOptimizedOffsets; currentOverlowTextureRead < trueNumberOfOptimizedOffsets; currentOverlowTextureRead++)
        {
            GLfloat firstWeight = standardGaussianWeights[currentOverlowTextureRead * 2 + 1];
            GLfloat secondWeight = standardGaussianWeights[currentOverlowTextureRead * 2 + 2];
            
            GLfloat optimizedWeight = firstWeight + secondWeight;
            GLfloat optimizedOffset = (firstWeight * (currentOverlowTextureRead * 2 + 1) + secondWeight * (currentOverlowTextureRead * 2 + 2)) / optimizedWeight;
            
            [shaderString appendFormat:@"sum += texture2D(cc_PreviousPassTexture, v_blurCoordinates[0] + singleStepOffset * %f) * %f;\n", optimizedOffset, optimizedWeight];
            [shaderString appendFormat:@"sum += texture2D(cc_PreviousPassTexture, v_blurCoordinates[0] - singleStepOffset * %f) * %f;\n", optimizedOffset, optimizedWeight];
        }
    }
    
    [shaderString appendString:@"\
     return sum;\n"];

    free(standardGaussianWeights);
    
    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue" initialSnippet:@"cc_FragColor" snippet:@"vec4(1,1,1,1)"];
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"blurEffect" body:shaderString inputs:@[input] returnType:@"vec4"];
    return @[fragmentFunction];
}

+ (NSArray *)buildVertexFunctionsWithBlurParams:(CCEffectBlurParams)blurParams
{
    GLfloat* standardGaussianWeights = calloc(blurParams.trueRadius + 1, sizeof(GLfloat));
    GLfloat sumOfWeights = 0.0;
    for (NSUInteger currentGaussianWeightIndex = 0; currentGaussianWeightIndex < blurParams.trueRadius + 1; currentGaussianWeightIndex++)
    {
        standardGaussianWeights[currentGaussianWeightIndex] = (1.0 / sqrt(2.0 * M_PI * pow(blurParams.sigma, 2.0))) * exp(-pow(currentGaussianWeightIndex, 2.0) / (2.0 * pow(blurParams.sigma, 2.0)));
        
        if (currentGaussianWeightIndex == 0)
        {
            sumOfWeights += standardGaussianWeights[currentGaussianWeightIndex];
        }
        else
        {
            sumOfWeights += 2.0 * standardGaussianWeights[currentGaussianWeightIndex];
        }
    }
    
    // Next, normalize these weights to prevent the clipping of the Gaussian curve at the end of the discrete samples from reducing luminance
    for (NSUInteger currentGaussianWeightIndex = 0; currentGaussianWeightIndex < blurParams.trueRadius + 1; currentGaussianWeightIndex++)
    {
        standardGaussianWeights[currentGaussianWeightIndex] = standardGaussianWeights[currentGaussianWeightIndex] / sumOfWeights;
    }
    
    // From these weights we calculate the offsets to read interpolated values from
    GLfloat* optimizedGaussianOffsets = calloc(blurParams.numberOfOptimizedOffsets, sizeof(GLfloat));
    
    for (NSUInteger currentOptimizedOffset = 0; currentOptimizedOffset < blurParams.numberOfOptimizedOffsets; currentOptimizedOffset++)
    {
        GLfloat firstWeight = standardGaussianWeights[currentOptimizedOffset*2 + 1];
        GLfloat secondWeight = standardGaussianWeights[currentOptimizedOffset*2 + 2];
        
        GLfloat optimizedWeight = firstWeight + secondWeight;
        
        optimizedGaussianOffsets[currentOptimizedOffset] = (firstWeight * (currentOptimizedOffset*2 + 1) + secondWeight * (currentOptimizedOffset*2 + 2)) / optimizedWeight;
    }
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];

    [shaderString appendString:@"\
     \n\
     vec2 singleStepOffset = u_blurDirection;\n"];
    
    // Inner offset loop
    [shaderString appendString:@"v_blurCoordinates[0] = cc_TexCoord1.xy;\n"];
    for (NSUInteger currentOptimizedOffset = 0; currentOptimizedOffset < blurParams.numberOfOptimizedOffsets; currentOptimizedOffset++)
    {
        [shaderString appendFormat:@"\
         v_blurCoordinates[%lu] = cc_TexCoord1.xy + singleStepOffset * %f;\n\
         v_blurCoordinates[%lu] = cc_TexCoord1.xy - singleStepOffset * %f;\n", (unsigned long)((currentOptimizedOffset * 2) + 1), optimizedGaussianOffsets[currentOptimizedOffset], (unsigned long)((currentOptimizedOffset * 2) + 2), optimizedGaussianOffsets[currentOptimizedOffset]];
    }
    
    [shaderString appendString:@"return cc_Position;\n"];

    free(optimizedGaussianOffsets);
    free(standardGaussianWeights);
    
    CCEffectFunction* vertexFunction = [[CCEffectFunction alloc] initWithName:@"blurEffect" body:shaderString inputs:nil returnType:@"vec4"];
    return @[vertexFunction];
}

+ (NSArray *)buildRenderPassesWithInterface:(CCEffectDropShadow *)interface
{
    // optmized approach based on linear sampling - http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/ and GPUImage - https://github.com/BradLarson/GPUImage
    // pass 0: blurs (horizontal) texture[0] and outputs blurmap to texture[1]
    // pass 1: blurs (vertical) texture[1] and outputs to texture[2]
    
    __weak CCEffectDropShadow *weakInterface = interface;

    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectDropShadow pass 0";
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlocks = @[[[CCEffectRenderPassBeginBlockContext alloc] initWithBlock:^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){

        passInputs.shaderUniforms[CCShaderUniformMainTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        
        GLKVector2 dur = GLKVector2Make(1.0 / (passInputs.previousPassTexture.pixelWidth / passInputs.previousPassTexture.contentScale), 0.0);
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_blurDirection"]] = [NSValue valueWithGLKVector2:dur];
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_composite"]] = [NSNumber numberWithFloat:0.0f];
        
    }]];

    
    CCEffectRenderPass *pass1 = [[CCEffectRenderPass alloc] init];
    pass1.debugLabel = @"CCEffectDropShadow pass 1";
    pass1.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass1.beginBlocks = @[[[CCEffectRenderPassBeginBlockContext alloc] initWithBlock:^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){

        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        GLKVector2 dur = GLKVector2Make(0.0, 1.0 / (passInputs.previousPassTexture.pixelHeight / passInputs.previousPassTexture.contentScale));
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_blurDirection"]] = [NSValue valueWithGLKVector2:dur];
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_composite"]] = [NSNumber numberWithFloat:0.0f];
        
    }]];
    
    CCEffectRenderPass *pass3 = [[CCEffectRenderPass alloc] init];
    pass3.debugLabel = @"CCEffectDropShadow pass 3";
    pass3.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass3.beginBlocks = @[[[CCEffectRenderPassBeginBlockContext alloc] initWithBlock:^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){
        
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        GLKVector2 dur = GLKVector2Make(0.0, 1.0 / (passInputs.previousPassTexture.pixelHeight / passInputs.previousPassTexture.contentScale));
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_blurDirection"]] = [NSValue valueWithGLKVector2:dur];
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_composite"]] = [NSNumber numberWithFloat:1.0f];
        
        CGPoint offset = weakInterface.shadowOffsetWithPoint;
        offset.x /= passInputs.previousPassTexture.contentSize.width;
        offset.y /= passInputs.previousPassTexture.contentSize.height;
        
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_shadowOffset"]] = [NSValue valueWithCGPoint:offset];
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_shadowColor"]] = [NSValue valueWithGLKVector4:weakInterface.shadowColor.glkVector4];
        
    }]];
    
    return @[pass0, pass1, pass3];
}

@end


@implementation CCEffectDropShadow
{
    BOOL _shaderDirty;
}

-(id)init
{
    return [self initWithShadowOffset:GLKVector2Make(5, -5) shadowColor:[CCColor blackColor] blurRadius:2];
}

-(id)initWithShadowOffset:(GLKVector2)shadowOffset shadowColor:(CCColor*)shadowColor blurRadius:(NSUInteger)blurRadius
{
    if((self = [super init]))
    {
        _shadowColor = shadowColor;
        _shadowOffset = shadowOffset;
        self.blurRadius = blurRadius;
        
        self.effectImpl = [[CCEffectDropShadowImpl alloc] initWithInterface:self];
        self.debugName = @"CCEffectDropShadow";
    }
    return self;
}

+(instancetype)effectWithShadowOffset:(GLKVector2)shadowOffset shadowColor:(CCColor*)shadowColor blurRadius:(NSUInteger)blurRadius
{
    return [[self alloc] initWithShadowOffset:shadowOffset shadowColor:shadowColor blurRadius:blurRadius];
}

-(void)setBlurRadius:(NSUInteger)blurRadius
{
    _blurRadius = blurRadius;
    
    // The shader is constructed dynamically based on the blur radius
    // so mark it dirty.
    _shaderDirty = YES;
}

- (CCEffectPrepareResult)prepareForRenderingWithSprite:(CCSprite *)sprite
{
    CCEffectPrepareResult result = CCEffectPrepareNoop;
    if (_shaderDirty)
    {
        self.effectImpl = [[CCEffectDropShadowImpl alloc] initWithInterface:self];
        
        _shaderDirty = NO;
        
        result.status = CCEffectPrepareSuccess;
        result.changes = CCEffectPrepareShaderChanged;
    }
    return result;
}


- (CGPoint)shadowOffsetWithPoint
{
    return CGPointMake(_shadowOffset.x, _shadowOffset.y);
}

- (void)setShadowOffsetWithPoint:(CGPoint)shadowOffsetWithPoint
{
    _shadowOffset = GLKVector2Make(shadowOffsetWithPoint.x, shadowOffsetWithPoint.y);
}

@end

