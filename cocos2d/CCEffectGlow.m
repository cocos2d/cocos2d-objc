//
//  CCEffectGlow.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/14/14.
//
//

#import "CCEffectGlow.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@implementation CCEffectGlow

-(id)init
{
    CCEffectUniform* u_enableGlowMap = [CCEffectUniform uniform:@"float" name:@"u_enableGlowMap" value:[NSNumber numberWithFloat:0.0f]];
    CCEffectUniform* u_blurDirection = [CCEffectUniform uniform:@"vec2" name:@"u_blurDirection" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]];
    CCEffectVarying* v_centerTextureCoordinate = [CCEffectVarying varying:@"vec2" name:@"v_centerTextureCoordinate"];
    CCEffectVarying* v_twoStepsLeftTextureCoordinate = [CCEffectVarying varying:@"vec2" name:@"v_twoStepsLeftTextureCoordinate"];
    CCEffectVarying* v_oneStepLeftTextureCoordinate = [CCEffectVarying varying:@"vec2" name:@"v_oneStepLeftTextureCoordinate"];
    CCEffectVarying* v_oneStepRightTextureCoordinate = [CCEffectVarying varying:@"vec2" name:@"v_oneStepRightTextureCoordinate"];
    CCEffectVarying* v_twoStepsRightTextureCoordinate = [CCEffectVarying varying:@"vec2" name:@"v_twoStepsRightTextureCoordinate"];
    
    if(self = [super initWithUniforms:[NSArray arrayWithObjects:u_enableGlowMap, nil]
                      vertextUniforms:[NSArray arrayWithObjects:u_blurDirection, nil]
                              varying:[NSArray arrayWithObjects:v_centerTextureCoordinate, v_twoStepsLeftTextureCoordinate,
                                       v_oneStepLeftTextureCoordinate, v_oneStepRightTextureCoordinate,
                                       v_twoStepsRightTextureCoordinate, nil]])
    {
        return self;
    }
    
    return self;
}

-(id)initWithbBlurStrength:(float)blurStrength
{
    if((self = [self init]))
    {
        _blurStrength = blurStrength;
        return self;
    }

    return self;
}

+(id)effectWithBlurStrength:(float)blurStrength
{
    return [[self alloc] initWithbBlurStrength:blurStrength];
}

-(void)buildFragmentFunctions
{

    NSString* effectBody = CC_GLSL(
                                   
                                   vec4 src = vec4(0.0);
                                   vec4 dst = vec4(0.0);
                                   
                                   if(u_enableGlowMap == 0.0)
                                   {
                                       lowp vec4 fragmentColor = texture2D(cc_PreviousPassTexture, v_centerTextureCoordinate) * 0.2270270270;
                                       fragmentColor += texture2D(cc_PreviousPassTexture, v_oneStepLeftTextureCoordinate) * 0.3162162162;
                                       fragmentColor += texture2D(cc_PreviousPassTexture, v_oneStepRightTextureCoordinate) * 0.3162162162;
                                       fragmentColor += texture2D(cc_PreviousPassTexture, v_twoStepsLeftTextureCoordinate) * 0.0702702703;
                                       fragmentColor += texture2D(cc_PreviousPassTexture, v_twoStepsRightTextureCoordinate) * 0.0702702703;
                                       
                                       src = fragmentColor;
                                   }
                                   else
                                   {
                                       dst = texture2D(cc_MainTexture, cc_FragTexCoord1);
                                       src = texture2D(cc_PreviousPassTexture, cc_FragTexCoord1);
                                   }
                                   
                                   return (src + dst) - (src * dst);

    );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"glowEffect" body:effectBody returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildVertexFunctions
{
    NSString* effectBody = CC_GLSL(
                                   
                                   vec2 firstOffset = vec2(1.3846153846, 1.3846153846) * u_blurDirection;
                                   vec2 secondOffset = vec2(3.2307692308, 3.2307692308) * u_blurDirection;
                                   
                                   v_centerTextureCoordinate = cc_TexCoord1;
                                   v_oneStepLeftTextureCoordinate = cc_TexCoord1 - firstOffset;
                                   v_twoStepsLeftTextureCoordinate = cc_TexCoord1 - secondOffset;
                                   v_oneStepRightTextureCoordinate = cc_TexCoord1 + firstOffset;
                                   v_twoStepsRightTextureCoordinate = cc_TexCoord1 + secondOffset;
    
                                   return cc_Position;
    );
    CCEffectFunction* vertexFunction = [[CCEffectFunction alloc] initWithName:@"glowEffect" body:effectBody returnType:@"vec4"];
    [self.vertexFunctions addObject:vertexFunction];
}

-(NSInteger)renderPassesRequired
{
    // optmized approach based on linear sampling - http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/ and GPUImage - https://github.com/BradLarson/GPUImage
    // pass 0: blurs (horizontal) texture[0] and outputs blurmap to texture[1]
    // pass 1: blurs (vertical) texture[1] and outputs to texture[2]
    // pass 2: blends texture[0] and texture[2] and outputs to texture[3]
    
    return 3;
}

-(void)renderPassBegin:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    renderPass.sprite.anchorPoint = ccp(0.0, 0.0);
    
    if(renderPass.renderPassId == 0)
    {
        renderPass.sprite.shaderUniforms[@"u_enableGlowMap"] = [NSNumber numberWithFloat:0.0f];
        renderPass.sprite.shaderUniforms[@"u_blurDirection"] = [NSValue valueWithGLKVector2:GLKVector2Make(_blurStrength, 0.0f)];
    }
    else if(renderPass.renderPassId == 1)
    {
        renderPass.sprite.shaderUniforms[@"u_enableGlowMap"] = [NSNumber numberWithFloat:0.0f];
        renderPass.sprite.shaderUniforms[@"u_blurDirection"] = [NSValue valueWithGLKVector2:GLKVector2Make(0.0f, _blurStrength)];
    }
    else if(renderPass.renderPassId == 2)
    {
        renderPass.sprite.shaderUniforms[@"u_enableGlowMap"] = [NSNumber numberWithFloat:1.0f];
    }
}

-(void)renderPassUpdate:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    GLKMatrix4 transform = renderPass.transform;
    [renderPass.sprite visit:renderPass.renderer parentTransform:&transform];
}

-(void)renderPassEnd:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
}

@end
#endif

