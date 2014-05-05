//
//  CCEffectBrightnessAndContrast.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/1/14.
//
//

#import "CCEffectBrightnessAndContrast.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@implementation CCEffectBrightnessAndContrast

-(id)initWithBrightness:(float)brightness contrast:(float)contrast
{
    CCEffectUniform* uniformBrightness = [CCEffectUniform uniform:@"float" name:@"u_brightness" value:[NSNumber numberWithFloat:brightness]];
    CCEffectUniform* uniformContrast = [CCEffectUniform uniform:@"float" name:@"u_contrast" value:[NSNumber numberWithFloat:contrast]];
    
    if(self = [super initWithUniforms:[NSArray arrayWithObjects:uniformBrightness, uniformContrast, nil] vertextUniforms:nil varying:nil])
    {
        _brightness = brightness;
        _contrast = contrast;
        
        return self;
    }
    
    return self;
}

-(void)buildFragmentFunctions
{
    NSString* effectBody = CC_GLSL(
                                   vec4 pixelValue = texture2D(cc_MainTexture, cc_FragTexCoord1);
                                   if (u_brightness < 0.0)
                                   {
                                       pixelValue = pixelValue * (1.0 + u_brightness);
                                   }
                                   else
                                   {
                                       pixelValue = pixelValue + ((1.0 - pixelValue) * u_brightness);
                                   }
                                   return (pixelValue - 0.5) * u_contrast + 0.5;
                                   );

    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"brightnessAndContrastEffect" body:effectBody returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(NSInteger)renderPassesRequired
{
    return 2;
}

-(void)renderPassBegin:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    renderPass.sprite.anchorPoint = ccp(0.0, 0.0);
    
    if(renderPass.renderPassId == 1)
    {
        renderPass.sprite.texture = renderPass.textures[0];
        
        renderPass.sprite.shaderUniforms[@"u_brightness"] = [NSNumber numberWithFloat:self.brightness];
        renderPass.sprite.shaderUniforms[@"u_contrast"] = [NSNumber numberWithFloat:self.contrast];
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
    else if(renderPass.renderPassId == 1)
    {
        [renderPass.renderer enqueueClear:0 color:clearColor depth:0.0f stencil:0 globalSortOrder:NSIntegerMin];
        [renderPass.sprite visit:renderPass.renderer parentTransform:&transform];
    }

}

-(void)renderPassEnd:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    if (renderPass.renderPassId == 1)
    {
        GLKMatrix4 transform = renderPass.transform;
        renderPass.sprite.texture = renderPass.textures[1];
        renderPass.sprite.shader = [CCShader positionTextureColorShader];
        [renderPass.sprite visit:renderPass.renderer parentTransform:&transform];
    }
}

@end
#endif
