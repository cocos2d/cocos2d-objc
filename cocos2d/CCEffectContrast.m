//
//  CCEffectContrast.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/7/14.
//
//

#import "CCEffectContrast.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@implementation CCEffectContrast

-(id)initWithContrast:(float)contrast
{
    CCEffectUniform* uniformContrast = [CCEffectUniform uniform:@"float" name:@"u_contrast" value:[NSNumber numberWithFloat:contrast]];
    
    if((self = [super initWithUniforms:@[uniformContrast] vertextUniforms:nil varying:nil]))
    {
        _contrast = contrast;
    }
    return self;
}

-(void)buildFragmentFunctions
{
    NSString* effectBody = CC_GLSL(
                                   vec4 inputValue = texture2D(cc_PreviousPassTexture, cc_FragTexCoord1);
                                   return vec4(((inputValue.rgb - vec3(0.5)) * vec3(u_contrast) + vec3(0.5)), inputValue.a);
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"contrastEffect" body:effectBody returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(NSInteger)renderPassesRequired
{
    return 1;
}

-(void)renderPassBegin:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    renderPass.sprite.anchorPoint = ccp(0.0, 0.0);
    renderPass.sprite.shaderUniforms[@"u_contrast"] = [NSNumber numberWithFloat:self.contrast];
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
