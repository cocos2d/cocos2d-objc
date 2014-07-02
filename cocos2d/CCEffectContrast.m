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
static float conditionContrast(float contrast);

@implementation CCEffectContrast

-(id)init
{
    CCEffectUniform* uniformContrast = [CCEffectUniform uniform:@"float" name:@"u_contrast" value:[NSNumber numberWithFloat:1.0f]];
    
    if((self = [super initWithUniforms:@[uniformContrast] vertextUniforms:nil varying:nil]))
    {
        self.debugName = @"CCEffectContrast";
        return self;
    }
    return self;
}

-(id)initWithContrast:(float)contrast
{
    if((self = [self init]))
    {
        _contrast = conditionContrast(contrast);
    }
    return self;
}

+(id)effectWithContrast:(float)contrast
{
    return [[self alloc] initWithContrast:contrast];
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

-(void)buildRenderPasses
{
    __weak CCEffectContrast *weakSelf = self;
    __weak CCEffectRenderPass *weakPass = nil;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    weakPass = pass0;
    pass0.shader = self.shader;
    pass0.shaderUniforms = self.shaderUniforms;
    pass0.beginBlock = ^(CCTexture *previousPassTexture){
        weakPass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTexture;
        weakPass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        weakPass.shaderUniforms[@"u_contrast"] = [NSNumber numberWithFloat:weakSelf.contrast];
    };
    
    self.renderPasses = @[pass0];
}

-(void)setContrast:(float)contrast
{
    _contrast = conditionContrast(contrast);
}

@end

float conditionContrast(float contrast)
{
    // Yes, this value is somewhat magical. It was arrived at experimentally by comparing
    // our results at min and max contrast (-1 and 1 respectively) with the results from
    // various image editing applications at their own min and max contrast values.
    static const float kContrastBase = 4.0f;
    
    float clampedExp = clampf(contrast, -1.0f, 1.0f);
    return powf(kContrastBase, clampedExp);
}

#endif
