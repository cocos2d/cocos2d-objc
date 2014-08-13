//
//  CCEffectOuterGlow.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 8/8/14.
//
//

#import "CCEffectOuterGlow.h"

#import "CCEffectOuterGlow.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

@implementation CCEffectOuterGlow

-(id)init
{
    return [self initWithGlowColor:[CCColor blackColor]];
}

-(id)initWithGlowColor:(CCColor*)glowColor
{
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"vec4" name:@"u_glowColor" value: [NSValue valueWithGLKVector4:glowColor.glkVector4]]
                          ];
    
    if((self = [super initWithFragmentUniforms:uniforms vertexUniforms:nil varyings:nil]))
    {
        _glowColor = glowColor;
        self.debugName = @"CCEffectOuterGlow";
    }
    return self;
}

+(id)effectWithGlowColor:(CCColor*)glowColor
{
    return [[self alloc] initWithGlowColor:glowColor];
}

-(void)buildFragmentFunctions
{
    self.fragmentFunctions = [[NSMutableArray alloc] init];
    
    NSString* effectBody = CC_GLSL(
                                   
                                   vec4 outputColor = vec4(0.0);
                                   // Make the color values to go from [-1, 1].
                                   vec4 distanceField = 2.0 * texture2D(cc_MainTexture, cc_FragTexCoord1) - 1.0;
                                   vec4 fw = fwidth(distanceField);
                                   vec4 mask = smoothstep(-fw, fw, distanceField);
                                   
                                   float distAlphaMask = distanceField.r;
                                   // outline
                                   const float min0 = 0.0;
                                   const float min1 = 0.0;
                                   const float max0 = 0.4;
                                   const float max1 = 0.8;
                                   
                                   bool less = distAlphaMask >= min0;
                                   bool more = distAlphaMask <= max1;
                                   
                                   if(less && more && false) // outline
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
                                       
                                       mask = mix(mask, vec4(1.0, 0.0, 0.0, 1.0), oFactor);
                                       
                                   }
                                   
                                   if(false) // soft edges
                                   {
                                       const float min = 0.2;
                                       const float max = 0.8;
                                       distanceField.r *= smoothstep(min, max, distAlphaMask);
                                       distanceField.g *= smoothstep(min, max, distAlphaMask);
                                       distanceField.b *= smoothstep(min, max, distAlphaMask);
                                   }
                                   else
                                   {
                                       if(distAlphaMask >= 0.5)
                                       {
//                                            distanceField.a = 1.0;
                                           distanceField.rgb = vec3(1.0);
                                       }
                                       else
                                       {
                                            //distanceField.a = 0.0;
                                            distanceField.rgb = vec3(0.0);
                                       }
                                   }

                                   
                                   
                                   if(true) {
                                       vec4 glowTexel = texture2D(cc_MainTexture, cc_FragTexCoord1);
                                       vec4 glowc = vec4(1.0, 0.0, 0.0, 1.0) * smoothstep(0.2, 0.4, glowTexel.r);
                                       
                                       distanceField = mix(glowc, distanceField, mask);
                                   }
                                   //else
                                   {
                                       outputColor.r = distanceField.r + (1.0 - distanceField.r) * mask.r;
                                       outputColor.g = distanceField.g + (1.0 - distanceField.g) * mask.g;
                                       outputColor.b = distanceField.b + (1.0 - distanceField.b) * mask.b;
                                       outputColor.a = distanceField.a;
                                       //outputColor = distanceField + mask;
                                   }
                                   
                                   return outputColor;
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"outerGlowEffect"
                                                                           body:effectBody inputs:nil returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectOuterGlow *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectOuterGlow pass 0";
    pass0.shader = self.shader;
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCTexture *previousPassTexture){
        
        pass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTexture;
        pass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_glowColor"]] = [NSValue valueWithGLKVector4:weakSelf.glowColor.glkVector4];
        
    } copy]];
    
    self.renderPasses = @[pass0];
}

@end
