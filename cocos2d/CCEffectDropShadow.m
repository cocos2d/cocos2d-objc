//
//  CCEffectDropShadow.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 8/7/14.
//
//

#import "CCEffectDropShadow.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

@implementation CCEffectDropShadow

-(id)init
{
    return [self initWithShadowOffset:GLKVector2Make(5, -5) shadowColor:[CCColor blackColor]];
}

-(id)initWithShadowOffset:(GLKVector2)shadowOffset shadowColor:(CCColor*)shadowColor
{
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"vec2" name:@"u_shadowOffset" value:[NSValue valueWithGLKVector2:shadowOffset]],
                          [CCEffectUniform uniform:@"vec4" name:@"u_shadowColor" value: [NSValue valueWithGLKVector4:shadowColor.glkVector4]],
                          ];
    
    if((self = [super initWithFragmentUniforms:uniforms vertexUniforms:nil varying:nil]))
    {
        _shadowColor = shadowColor;
        _shadowOffset = shadowOffset;
        self.debugName = @"CCEffectDropShadow";
    }
    return self;
}

+(id)effectWithShadowOffset:(GLKVector2)shadowOffset shadowColor:(CCColor*)shadowColor
{
    return [[self alloc] initWithShadowOffset:shadowOffset shadowColor:shadowColor];
}

-(void)buildFragmentFunctions
{
    self.fragmentFunctions = [[NSMutableArray alloc] init];
    
    NSString* effectBody = CC_GLSL(
                                   
                                   vec4 outputColor = texture2D(cc_MainTexture, cc_FragTexCoord1);

                                   // Grab the alpha at the shadowOffset, we will use this to determine the shadow alpha and if a
                                   // shadowColor should be added at all.
                                   float shadowOffsetAlpha = texture2D(cc_MainTexture, cc_FragTexCoord1 - u_shadowOffset).a;
                                   
                                   vec4 shadowColor = vec4(u_shadowColor.rgb, shadowOffsetAlpha * u_shadowColor.a);
                                   
                                   // Since we use premultiplied alpha, we need to be careful and avoid changing the
                                   // output color of every fragment. If we add a non-zero shadowColor to the output, then
                                   // we will end up tinting the whole quad with a shadowColor.
                                   const float alphaThreshold = 0.2; // Maybe make this a uniform? it's kind of hacky..
                                   if(shadowOffsetAlpha < alphaThreshold)
                                       return outputColor; //shadowColor = vec4(0.0);
                                   
                                   // Ensures that the cc_MainTexture color does not get over written by the shadowcolor
                                   outputColor = outputColor + (1.0 - outputColor.a) * shadowColor;

                                   return outputColor;
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"dropShadowEffect"
                                                                           body:effectBody inputs:nil returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectDropShadow *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectDropShadow pass 0";
    pass0.shader = self.shader;
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCTexture *previousPassTexture){
        
        pass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTexture;
        pass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        
        GLKVector2 offset = GLKVector2Make(weakSelf.shadowOffset.x /  previousPassTexture.contentSize.width, weakSelf.shadowOffset.y /  previousPassTexture.contentSize.height);
        
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_shadowOffset"]] = [NSValue valueWithGLKVector2:offset];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_shadowColor"]] = [NSValue valueWithGLKVector4:weakSelf.shadowColor.glkVector4];
        
    } copy]];
    
    self.renderPasses = @[pass0];
}

@end

