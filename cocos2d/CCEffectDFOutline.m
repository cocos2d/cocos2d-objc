//
//  CCEffectDFOutline.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 8/29/14.
//
//

#import "CCEffectDFOutline.h"

#if CC_EFFECTS_EXPERIMENTAL

#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

@implementation CCEffectDFOutline {
    float _outerMin;
    float _outerMax;
    float _fieldScaleFactor;
}

-(id)init
{
    return [self initWithOutlineColor:[CCColor redColor] fillColor:[CCColor blackColor] outlineWidth:3 fieldScale:32 distanceField:[CCTexture none]];
}

-(id)initWithOutlineColor:(CCColor*)outlineColor fillColor:(CCColor*)fillColor outlineWidth:(int)outlineWidth fieldScale:(float)fieldScale distanceField:(CCTexture*)distanceField
{
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"vec4" name:@"u_fillColor" value:[NSValue valueWithGLKVector4:[CCColor blackColor].glkVector4]],
                          [CCEffectUniform uniform:@"vec4" name:@"u_outlineColor" value:[NSValue valueWithGLKVector4:outlineColor.glkVector4]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_outlineOuterWidth" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.5, 1.0)]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_outlineInnerWidth" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.4, 0.42)]]
                          ];
    
    if((self = [super initWithFragmentUniforms:uniforms vertexUniforms:nil varyings:nil]))
    {
        _fieldScaleFactor = fieldScale; // 32 4096/128 (input distance field size / output df size)
        self.outlineWidth = outlineWidth;
        _fillColor = fillColor;
        _outlineColor = outlineColor;
        _distanceField = distanceField;
        
        self.debugName = @"CCEffectDFOutline";
    }
    return self;
}

+(id)effectWithOutlineColor:(CCColor*)outlineColor fillColor:(CCColor*)fillColor outlineWidth:(int)outlineWidth fieldScale:(float)fieldScale distanceField:(CCTexture*)distanceField
{
    return [[self alloc] initWithOutlineColor:outlineColor fillColor:fillColor outlineWidth:outlineWidth fieldScale:fieldScale distanceField:distanceField];
}

-(void)buildFragmentFunctions
{
    self.fragmentFunctions = [[NSMutableArray alloc] init];
    
    NSString* effectBody = CC_GLSL(
                                   vec4 outputColor = u_fillColor;
                                   if(u_fillColor.a == 0.0)
                                       outputColor = texture2D(cc_MainTexture, cc_FragTexCoord1);
                                   
                                   float distAlphaMask = texture2D(cc_NormalMapTexture, cc_FragTexCoord1).r;
                                   
                                   float center = 0.5;
                                   float transition = fwidth(distAlphaMask) * 1.0;
                                   
                                   float min = center - transition;
                                   float max = center + transition;
                                   
                                   // soft edges
                                   outputColor.a *= smoothstep(min, max, distAlphaMask);
                                   
                                   min = u_outlineOuterWidth.x;
                                   max = u_outlineOuterWidth.y;
                                   
                                   if(min == 0.5 && max == 0.5)
                                   {
                                       vec4 glowc = u_fillColor * smoothstep(min, max, transition);
                                       outputColor = mix(glowc, outputColor, outputColor.a);
                                       return outputColor;
                                   }
                                   
                                   vec4 glowTexel = texture2D(cc_NormalMapTexture, cc_FragTexCoord1);
                                   
                                   vec4 glowc = u_outlineColor * smoothstep(min, max, glowTexel.r);
                                   
                                   outputColor = mix(glowc, outputColor, outputColor.a);

                                   return outputColor;
                                   
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"outlineEffect"
                                                                           body:effectBody inputs:nil returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectDFOutline *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectDFOutline pass 0";
    pass0.shader = self.shader;
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCTexture *previousPassTexture) {
        
        pass.shaderUniforms[CCShaderUniformNormalMapTexture] = weakSelf.distanceField;
        pass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTexture;
        pass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_fillColor"]] = [NSValue valueWithGLKVector4:weakSelf.fillColor.glkVector4];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_outlineColor"]] = [NSValue valueWithGLKVector4:weakSelf.outlineColor.glkVector4];
        
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_outlineOuterWidth"]] = [NSValue valueWithGLKVector2:GLKVector2Make(_outerMin, _outerMax)];
        
    } copy]];
    
    self.renderPasses = @[pass0];
}

-(void)setOutlineWidth:(int)outlineWidth
{
    
    _outlineWidth = outlineWidth;//clampf(outlineOuterWidth, 0.0f, 1.0f);
    
    float outlineWidthNormalized = ((float)outlineWidth)/255.0 * _fieldScaleFactor;
    float edgeSoftness = _outlineWidth * 0.1; // randomly chosen number that looks good to me, based on a 200 pixel spread (note: this should adjustable).
    
    // 0.5 == center(edge),  < 0.5 == outside, > 0.5 == inside
    _outerMin = (0.5 * (1.0 - outlineWidthNormalized));
    _outerMax = _outerMin + _outerMin * edgeSoftness;

}

@end

#endif
