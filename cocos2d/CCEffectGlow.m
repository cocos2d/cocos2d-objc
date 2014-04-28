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

@implementation CCEffectGlow

-(id)init
{
    CCEffectUniform* uniformEnableGlowMap = [CCEffectUniform uniform:@"float" name:@"u_enableGlowMap" value:[NSNumber numberWithFloat:0.0f]];

    CCTexture* texture = [CCTexture none];
    CCEffectUniform* uniformSampler2 = [CCEffectUniform uniform:@"sampler2D" name:@"u_sampler2" value:(NSValue*)texture];

    if(self = [super initWithUniforms:[NSArray arrayWithObjects:uniformEnableGlowMap, uniformSampler2, nil] vertextUniforms:nil])
    {
        return self;
    }
    
    return self;
}

-(void)buildFragmentFunctions
{

    NSString* effectBody = CC_GLSL(
                                   
                                   // TODO: do a multi pass blur instead, this is a place holder radial guassian blur.
                                   vec4 sum = vec4(0.0);
                                   vec4 source = texture2D(cc_MainTexture, cc_FragTexCoord1);
                                   int samples = 20;
                                   int diff = (samples - 1) / 2;
                                   vec2 sizeFactor = vec2(0.005, 0.005); // make this smaller for a smoother glow
                                   
                                   for(int x = -diff; x <= diff; x++)
                                   {
                                       for(int y = -diff; y <= diff; y++)
                                       {
                                           vec2 offset = vec2(x, y) * sizeFactor;
                                           sum += texture2D(cc_MainTexture, cc_FragTexCoord1 + offset);
                                       }
                                   }
                           
                                   vec4 src = vec4(0.0, 0.0, 0.0, 0.0);
                                   if(u_enableGlowMap == 1.0)
                                   {
                                       src = texture2D(u_sampler2, cc_FragTexCoord1);
                                   }
                                   
                                   vec4 dst = ((sum / float(samples * samples)) + (texture2D(cc_MainTexture, cc_FragTexCoord1) * 0.5));
                                   
                                   return (src + dst) - (src * dst);

    );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"glowEffect" body:effectBody returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(NSInteger)renderPassesRequired
{
    return 3;
}

-(void)renderPassBegin:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    renderPass.sprite.anchorPoint = ccp(0.0, 0.0);
    
    if(renderPass.renderPassId == 1)
    {
        renderPass.sprite.texture = renderPass.textures[0];
    }
    else if(renderPass.renderPassId == 2)
    {
        renderPass.sprite.texture = renderPass.textures[0];
        
        // tell shader to use 2nd texture
        renderPass.sprite.shaderUniforms[@"u_enableGlowMap"] = [NSNumber numberWithFloat:1.0f];
        renderPass.sprite.shaderUniforms[@"u_sampler2"] = renderPass.textures[1];
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
    else if(renderPass.renderPassId == 1 || renderPass.renderPassId == 2)
    {
        [renderPass.renderer enqueueClear:0 color:clearColor depth:0.0f stencil:0];
        [renderPass.sprite visit:renderPass.renderer parentTransform:&transform];
    }
}

-(void)renderPassEnd:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    if(renderPass.renderPassId == 2)
    {
        GLKMatrix4 transform = renderPass.transform;
        renderPass.sprite.texture = renderPass.textures[2];
        renderPass.sprite.shader = [CCShader positionTextureColorShader];
        [renderPass.sprite visit:renderPass.renderer parentTransform:&transform];
    }
}

@end
