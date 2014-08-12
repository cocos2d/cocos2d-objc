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
                                   
                                   // Make the color values to go from [-1, 1].
                                   vec4 distanceField = 2.0 * texture2D(cc_MainTexture, cc_FragTexCoord1) - 1.0;
                                   vec4 fw = fwidth(distanceField);
                                   vec4 mask = smoothstep(-fw, fw, distanceField);
                                   
                                   float distAlphaMask = distanceField.a;
                                   // outline
                                   const float min0 = 0.0;
                                   const float min1 = 0.4;
                                   const float max0 = 0.4;
                                   const float max1 = 0.9;
                                   
                                   bool less = distAlphaMask >= min0;
                                   bool more = distAlphaMask <= max1;
                                   
                                   if(less && more)
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
                                       
                                       mask = vec4(1.0, 0.0, 0.0, 1.0);//mix(mask, vec4(1.0, 1.0, 0.0, 1.0), oFactor);
                                       
                                   }
                                   
                                   if(distAlphaMask >= 0.5)
                                        mask.a = 1.0;
                                   else
                                        mask.a = 0.0;

                                   
                                   
                                   if(false) {
                                   vec4 glowTexel = texture2D(cc_MainTexture, cc_FragTexCoord1);
                                   vec4 glowc = vec4(1.0, 0.0, 0.0, 1.0) * smoothstep(0.0, 0.0, glowTexel.a);
                                   
                                   distanceField = mix(glowc, distanceField, mask);

                                   vec4 outputColor = distanceField;
                                   }
                                   
                                   
                                   return mask;
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
