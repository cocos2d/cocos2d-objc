//
//  CCEffectPixellate.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/8/14.
//
//

#import "CCEffectPixellate.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@implementation CCEffectPixellate

-(id)initWithPixelSize:(float)pixelSize
{
    float uStep = pixelSize;
    float vStep = pixelSize;
    
    CCEffectUniform* uniformUStep = [CCEffectUniform uniform:@"float" name:@"u_uStep" value:[NSNumber numberWithFloat:uStep]];
    CCEffectUniform* uniformVStep = [CCEffectUniform uniform:@"float" name:@"u_vStep" value:[NSNumber numberWithFloat:vStep]];

    if((self = [super initWithUniforms:@[uniformUStep, uniformVStep] vertextUniforms:nil varying:nil]))
    {
        _pixelSize = pixelSize;
    }
    return self;
}

-(void)buildFragmentFunctions
{
    // Image pixellation shader based on pixellation filter in GPUImage - https://github.com/BradLarson/GPUImage
    NSString* effectBody = CC_GLSL(
                                   vec2 samplePos = cc_FragTexCoord1 - mod(cc_FragTexCoord1, vec2(u_uStep, u_vStep)) + 0.5 * vec2(u_uStep, u_vStep);
                                   return texture2D(cc_PreviousPassTexture, samplePos);
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"pixellateEffect" body:effectBody returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(NSInteger)renderPassesRequired
{
    return 1;
}

-(void)renderPassBegin:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    renderPass.sprite.anchorPoint = ccp(0.0, 0.0);
    
    CCTexture *texture = renderPass.sprite.shaderUniforms[@"cc_PreviousPassTexture"];

    float aspect = texture.contentSize.width / texture.contentSize.height;
    float uStep = self.pixelSize / texture.contentSize.width;
    float vStep = uStep * aspect;
    
    renderPass.sprite.shaderUniforms[@"u_uStep"] = [NSNumber numberWithFloat:uStep];
    renderPass.sprite.shaderUniforms[@"u_vStep"] = [NSNumber numberWithFloat:vStep];
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
