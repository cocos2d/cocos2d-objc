//
//  CCEffectSaturation.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/14/14.
//
//

#import "CCEffectSaturation.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@implementation CCEffectSaturation

-(id)initWithSaturation:(float)saturation
{
    CCEffectUniform* uniformSaturation = [CCEffectUniform uniform:@"float" name:@"u_saturation" value:[NSNumber numberWithFloat:saturation]];
    
    if((self = [super initWithUniforms:@[uniformSaturation] vertextUniforms:nil varying:nil]))
    {
        _saturation = saturation;
    }
    return self;
}

-(void)buildFragmentFunctions
{
    // Image saturation shader based on saturation filter in GPUImage - https://github.com/BradLarson/GPUImage
    NSString* effectBody = CC_GLSL(
                                   const vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);
                                   
                                   vec4 inputValue = texture2D(cc_PreviousPassTexture, cc_FragTexCoord1);
                                   float luminance = dot(inputValue.rgb, luminanceWeighting);
                                   vec3 greyScaleColor = vec3(luminance);
                                   
                                   return vec4(mix(greyScaleColor, inputValue.rgb, u_saturation), inputValue.a);
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"saturationEffect" body:effectBody returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(NSInteger)renderPassesRequired
{
    return 1;
}

-(void)renderPassBegin:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    renderPass.sprite.anchorPoint = ccp(0.0, 0.0);
    renderPass.sprite.shaderUniforms[@"u_saturation"] = [NSNumber numberWithFloat:self.saturation];
}

-(void)renderPassUpdate:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    GLKMatrix4 transform = renderPass.transform;
    GLKVector4 clearColor;
    
    [renderPass.renderer enqueueClear:0 color:clearColor depth:0.0f stencil:0 globalSortOrder:NSIntegerMin];
    [renderPass.sprite visit:renderPass.renderer parentTransform:&transform];
}

-(void)renderPassEnd:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
}

@end
#endif
