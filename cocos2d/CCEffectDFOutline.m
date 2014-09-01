//
//  CCEffectDFOutline.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 8/29/14.
//
//

#import "CCEffectDFOutline.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

@implementation CCEffectDFOutline

-(id)init
{
    return [self initWithOutlineColor:[CCColor redColor] fillColor:[CCColor blackColor]];
}

-(id)initWithOutlineColor:(CCColor*)outlineColor fillColor:(CCColor*)fillColor
{
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"vec4" name:@"u_fillColor" value:[NSValue valueWithGLKVector4:[CCColor blackColor].glkVector4]],
                          [CCEffectUniform uniform:@"vec4" name:@"u_outlineColor" value:[NSValue valueWithGLKVector4:outlineColor.glkVector4]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_outlineOuterWidth" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.5, 1.0)]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_outlineInnerWidth" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.4, 0.42)]]
                          ];
    
    if((self = [super initWithFragmentUniforms:uniforms vertexUniforms:nil varyings:nil]))
    {
        _outlineInnerWidth = 0.08;
        _outlineOuterWidth = 0.08;
        _fillColor = fillColor;
        _outlineColor = outlineColor;
        
        self.debugName = @"CCEffectDFOutline";
    }
    return self;
}

+(id)effectWithOutlineColor:(CCColor*)outlineColor fillColor:(CCColor*)fillColor
{
    return [[self alloc] initWithOutlineColor:outlineColor fillColor:fillColor];
}

-(void)buildFragmentFunctions
{
    self.fragmentFunctions = [[NSMutableArray alloc] init];
    
    NSString* effectBody = CC_GLSL(
                                   vec4 outputColor = u_fillColor;
                                   outputColor.a = 1.0;
                                   float distAlphaMask = texture2D(cc_MainTexture, cc_FragTexCoord1).r;
                                   
                                   float center = 0.5;
                                   float transition = fwidth(distAlphaMask) * 1.0;
                                   
                                   float min = center - transition;
                                   float max = center + transition;
                                   
                                   // soft edges
                                   outputColor.a *= smoothstep(min, max, distAlphaMask);
                                   
                                   vec4 glowTexel = texture2D(cc_MainTexture, cc_FragTexCoord1);
//                                       min -= 0.2;
//                                       max += 0.2;
                                   
                                   min = u_outlineOuterWidth.x;
                                   max = u_outlineOuterWidth.y;
                                   min = 0.3;
                                   max = 0.34;
                                   
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
        
        pass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTexture;
        pass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_fillColor"]] = [NSValue valueWithGLKVector4:weakSelf.fillColor.glkVector4];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_outlineColor"]] = [NSValue valueWithGLKVector4:weakSelf.outlineColor.glkVector4];
        
        // 0.5 == center(edge),  < 0.5 == outside, > 0.5 == inside
        float innerMin = 0.5;
        float innerMax = (0.5 * _outlineInnerWidth) + innerMin;
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_outlineInnerWidth"]] = [NSValue valueWithGLKVector2:GLKVector2Make(innerMin, innerMax)];
        
        float outerMin = (0.5 * (1.0 - _outlineOuterWidth));
        float outerMax = 0.5;
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_outlineOuterWidth"]] = [NSValue valueWithGLKVector2:GLKVector2Make(outerMin, outerMax)];
        
//        float glowWidthMin = (0.5 * (1.0 - _glowWidth));
//        float glowWidthMax = 0.5;
//        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_glowWidth"]] = [NSValue valueWithGLKVector2:GLKVector2Make(glowWidthMin, glowWidthMax)];
//        
//        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_outline"]] = _outline ? [NSNumber numberWithFloat:1.0f] : [NSNumber numberWithFloat:0.0f];
//        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_glow"]] = _glow ? [NSNumber numberWithFloat:1.0f] : [NSNumber numberWithFloat:0.0f];
//        
//        GLKVector2 offset = GLKVector2Make(weakSelf.glowOffset.x /  previousPassTexture.contentSize.width, weakSelf.glowOffset.y /  previousPassTexture.contentSize.height);
//        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_glowOffset"]] = [NSValue valueWithGLKVector2:offset];
        
    } copy]];
    
    self.renderPasses = @[pass0];
}

-(void)setOutlineInnerWidth:(float)outlineInnerWidth
{
    _outlineInnerWidth = clampf(outlineInnerWidth, 0.0f, 1.0f);
}

-(void)setOutlineOuterWidth:(float)outlineOuterWidth
{
    _outlineOuterWidth = clampf(outlineOuterWidth, 0.0f, 1.0f);
}

@end
