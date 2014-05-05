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
    
    CCTexture* texture = [CCTexture none];
    CCEffectUniform* u_sampler2 = [CCEffectUniform uniform:@"sampler2D" name:@"u_sampler2" value:(NSValue*)texture];

    if(self = [super initWithUniforms:[NSArray arrayWithObjects:u_enableGlowMap, u_sampler2, nil]
                      vertextUniforms:[NSArray arrayWithObjects:u_blurDirection, nil]
                              varying:[NSArray arrayWithObjects:v_centerTextureCoordinate, v_twoStepsLeftTextureCoordinate,
                                       v_oneStepLeftTextureCoordinate, v_oneStepRightTextureCoordinate,
                                       v_twoStepsRightTextureCoordinate, nil]])
    {
        return self;
    }
    
    return self;
}

-(void)buildFragmentFunctions
{

    NSString* effectBody = CC_GLSL(
                                   
                                   vec4 src = vec4(0.0);
                                   vec4 dst = vec4(0.0);
                                   
                                   if(u_enableGlowMap == 0.0)
                                   {
                                       lowp vec3 fragmentColor = texture2D(cc_MainTexture, v_centerTextureCoordinate).rgb * 0.2270270270;
                                       fragmentColor += texture2D(cc_MainTexture, v_oneStepLeftTextureCoordinate).rgb * 0.3162162162;
                                       fragmentColor += texture2D(cc_MainTexture, v_oneStepRightTextureCoordinate).rgb * 0.3162162162;
                                       fragmentColor += texture2D(cc_MainTexture, v_twoStepsLeftTextureCoordinate).rgb * 0.0702702703;
                                       fragmentColor += texture2D(cc_MainTexture, v_twoStepsRightTextureCoordinate).rgb * 0.0702702703;
                                       
                                       src = vec4(fragmentColor, 1.0);
                                   }
                                   else
                                   {
                                       dst = texture2D(cc_MainTexture, cc_FragTexCoord1);
                                       src = texture2D(u_sampler2, cc_FragTexCoord1);
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
    // pass 0: draws all children to texture[0]
    // pass 1: blurs (horizontal) texture[0] and outputs blurmap to texture[1]
    // pass 2: blurs (vertical) texture[1] and outputs to texture[2]
    // pass 3: blends texture[0] and texture[2] and outputs texture[3], once the blend is complete,
    //         we set the sprites shader back to a regular position/texture shader and assign texture[3] (bloom/glow) as the main texture of the sprite

    return 4;
}

-(void)renderPassBegin:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    renderPass.sprite.anchorPoint = ccp(0.0, 0.0);
    
    if(renderPass.renderPassId == 1)
    {
        renderPass.sprite.shaderUniforms[@"u_blurDirection"] = [NSValue valueWithGLKVector2:GLKVector2Make(0.023f, 0.0f)];
        renderPass.sprite.texture = renderPass.textures[0];
    }
    else if(renderPass.renderPassId == 2)
    {
        renderPass.sprite.shaderUniforms[@"u_blurDirection"] = [NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.023f)];
        renderPass.sprite.texture = renderPass.textures[1];
    }
    else if(renderPass.renderPassId == 3)
    {
        renderPass.sprite.texture = renderPass.textures[0];
        
        // tell shader to use 2nd texture
        renderPass.sprite.shaderUniforms[@"u_enableGlowMap"] = [NSNumber numberWithFloat:1.0f];
        renderPass.sprite.shaderUniforms[@"u_sampler2"] = renderPass.textures[2];
    }
}

-(void)renderPassUpdate:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    GLKMatrix4 transform = renderPass.transform;
    GLKVector4 clearColor;

    if(renderPass.renderPassId == 0)
    {
        if(defaultBlock)
            defaultBlock();
    }
    else if(renderPass.renderPassId == 1 || renderPass.renderPassId == 2 || renderPass.renderPassId == 3)
    {
        [renderPass.renderer enqueueClear:0 color:clearColor depth:0.0f stencil:0 globalSortOrder:NSIntegerMin];
        [renderPass.sprite visit:renderPass.renderer parentTransform:&transform];
    }
}

-(void)renderPassEnd:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    if(renderPass.renderPassId == 3)
    {
        GLKMatrix4 transform = renderPass.transform;
        renderPass.sprite.texture = renderPass.textures[2];
        renderPass.sprite.shader = [CCShader positionTextureColorShader];
        [renderPass.sprite visit:renderPass.renderer parentTransform:&transform];
    }
}

@end
#endif

