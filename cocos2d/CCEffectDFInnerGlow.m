//
//  CCEffectDFInnerGlow.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 9/11/14.
//
//

#import "CCEffectDFInnerGlow.h"

#if CC_EFFECTS_EXPERIMENTAL

#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

@implementation CCEffectDFInnerGlow {
    float _innerMin;
    float _innerMax;
    float _fieldScaleFactor;
}

-(id)init
{
    return [self initWithGlowColor:[CCColor redColor] fillColor:[CCColor blackColor] glowWidth:3 fieldScale:32 distanceField:[CCTexture none]];
}

-(id)initWithGlowColor:(CCColor*)glowColor fillColor:(CCColor*)fillColor glowWidth:(int)glowWidth fieldScale:(float)fieldScale distanceField:(CCTexture*)distanceField
{
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"vec4" name:@"u_fillColor"
                                             value:[NSValue valueWithGLKVector4:[CCColor blackColor].glkVector4]],
                          [CCEffectUniform uniform:@"vec4" name:@"u_glowColor"
                                             value:[NSValue valueWithGLKVector4:glowColor.glkVector4]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_glowInnerWidth"
                                             value:[NSValue valueWithGLKVector2:GLKVector2Make(0.5, 1.0)]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_glowOuterWidth"
                                             value:[NSValue valueWithGLKVector2:GLKVector2Make(0.47, 0.5)]]
                          ];
    
    if((self = [super initWithFragmentUniforms:uniforms vertexUniforms:nil varyings:nil]))
    {
        _fieldScaleFactor = fieldScale; // 32 4096/128 (input distance field size / output df size)
        self.glowWidth = glowWidth;
        _fillColor = fillColor;
        _glowColor = glowColor;
        _distanceField = distanceField;
        
        self.debugName = @"CCEffectDFInnerGlow";
    }
    return self;
}

+(id)effectWithGlowColor:(CCColor*)glowColor fillColor:(CCColor*)fillColor glowWidth:(int)glowWidth fieldScale:(float)fieldScale distanceField:(CCTexture*)distanceField
{
    return [[self alloc] initWithGlowColor:glowColor fillColor:fillColor glowWidth:glowWidth fieldScale:fieldScale distanceField:distanceField];
}

-(void)buildFragmentFunctions
{
    self.fragmentFunctions = [[NSMutableArray alloc] init];
    
    NSString* effectBody = CC_GLSL(
                                   vec4 outputColor = u_fillColor;
                                   if(u_fillColor.a == 0.0)
                                       outputColor = texture2D(cc_MainTexture, cc_FragTexCoord1);
                                   
                                   float distAlphaMask = texture2D(cc_NormalMapTexture, cc_FragTexCoord1).r;
                                   
                                   float min = u_glowInnerWidth.x;
                                   float max = u_glowInnerWidth.y;

                                   if(min == 0.5 && max == 0.5)
                                   {
                                       float center = 0.5;
                                       float transition = fwidth(distAlphaMask) * 1.0;
                                       
                                       min = center - transition;
                                       max = center + transition;
                                       
                                       // soft edges
                                       outputColor.a *= smoothstep(min, max, distAlphaMask);
                                       
                                       vec4 glowc = u_fillColor * smoothstep(min, max, transition);
                                       outputColor = mix(glowc, outputColor, outputColor.a);

                                       return outputColor;
                                   }
                                   
                                   // 0.5 == center(edge),  < 0.5 == outside, > 0.5 == inside
                                   float min0 = u_glowOuterWidth.x;
                                   float max0 = u_glowOuterWidth.y;
                                   float min1 = u_glowInnerWidth.x;
                                   float max1 = u_glowInnerWidth.y;
                                   if(distAlphaMask >= min0 && distAlphaMask <= max1) // apply glow
                                   {
                                       float oFactor = 1.0;
                                       if(distAlphaMask <= min1)
                                       {
                                           oFactor = smoothstep(min0, min1, distAlphaMask);
                                       }
                                       else
                                       {
                                           oFactor = smoothstep(max1, max0, distAlphaMask);
                                       }
                                       
                                       outputColor = mix(outputColor, u_glowColor, oFactor);
                                   }
                                   
                                   float center = 0.5;
                                   float transition = fwidth(distAlphaMask) * 1.0;
                                   
                                   min = center - transition;
                                   max = center + transition;
                                   
                                   // soft edges
                                   outputColor.a *= smoothstep(min, max, distAlphaMask);
                                   
                                   vec4 glowc = u_fillColor * smoothstep(min, max, transition);
                                   outputColor = mix(glowc, outputColor, outputColor.a);
                                   
                                   return outputColor;
                                   
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"outlineEffect"
                                                                           body:effectBody inputs:nil returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectDFInnerGlow *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectDFInnerGlow pass 0";
    pass0.shader = self.shader;
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCTexture *previousPassTexture) {
        
        pass.shaderUniforms[CCShaderUniformNormalMapTexture] = weakSelf.distanceField;
        pass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTexture;
        pass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_fillColor"]] = [NSValue valueWithGLKVector4:weakSelf.fillColor.glkVector4];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_glowColor"]] = [NSValue valueWithGLKVector4:weakSelf.glowColor.glkVector4];
        
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_glowInnerWidth"]] = [NSValue valueWithGLKVector2:GLKVector2Make(_innerMin, _innerMax)];
        
    } copy]];
    
    self.renderPasses = @[pass0];
}

-(void)setGlowWidth:(int)glowWidth
{
    _glowWidth = glowWidth;
    
    float glowWidthNormalized = ((float)glowWidth)/255.0 * _fieldScaleFactor;

    // 0.5 == center(edge), < 0.5 == outside, > 0.5 == inside
    _innerMin = 0.5;
    _innerMax = _innerMin + glowWidthNormalized;
}

@end

#endif
