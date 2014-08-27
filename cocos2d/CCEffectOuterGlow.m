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
                                   // works with DistanceFieldX.png
                                   
                                   vec4 outputColor = vec4(0.0, 0.0, 0.0, 1.0);
                                   float distAlphaMask = texture2D(cc_MainTexture, cc_FragTexCoord1).r;
                                   
                                   float center = 0.46;
                                   float transition = fwidth(distAlphaMask) * 1.0;
                                   
                                   float min = center - transition;
                                   float max = center + transition;

                                   // soft edges
                                   outputColor.a *= smoothstep(min, max, distAlphaMask);
                                   
                                   // glow
                                   if(true)
                                   {
                                       vec4 glowTexel = texture2D(cc_MainTexture, cc_FragTexCoord1);
                                       min -= 0.09;
                                       max -= 0.05;
                                       vec4 glowc = u_glowColor * smoothstep(min, max, glowTexel.r);
                                       
                                       outputColor = mix(glowc, outputColor, outputColor.a);
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
