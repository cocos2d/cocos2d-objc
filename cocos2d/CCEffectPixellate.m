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

-(id)initWithPixelScale:(float)pixelScale
{
    CCEffectUniform* uniformPixelScale = [CCEffectUniform uniform:@"float" name:@"u_pixelScale" value:[NSNumber numberWithFloat:pixelScale]];
    
    if((self = [super initWithUniforms:@[uniformPixelScale] vertextUniforms:nil varying:nil]))
    {
        _pixelScale = pixelScale;
    }
    return self;
}

-(void)buildFragmentFunctions
{
    // Image pixellation shader based on pixellation filter in GPUImage - https://github.com/BradLarson/GPUImage
    NSString* effectBody = CC_GLSL(
                                   vec2 samplePos = cc_FragTexCoord1 - mod(cc_FragTexCoord1, vec2(u_pixelScale) + 0.5 * vec2(u_pixelScale));
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
    renderPass.sprite.shaderUniforms[@"u_pixelScale"] = [NSNumber numberWithFloat:self.pixelScale];
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
