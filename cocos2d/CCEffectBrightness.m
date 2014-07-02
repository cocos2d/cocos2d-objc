//
//  CCEffectBrightness.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/7/14.
//
//

#import "CCEffectBrightness.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
static float conditionBrightness(float brightness);

@implementation CCEffectBrightness

-(id)init
{
    CCEffectUniform* uniformBrightness = [CCEffectUniform uniform:@"float" name:@"u_brightness" value:[NSNumber numberWithFloat:0.0f]];
    
    if((self = [super initWithUniforms:@[uniformBrightness] vertextUniforms:nil varying:nil]))
    {
        self.debugName = @"CCEffectBrightness";
        return self;
    }
    return self;
}

-(id)initWithBrightness:(float)brightness
{
    if((self = [self init]))
    {
        _brightness = conditionBrightness(brightness);
    }    
    return self;
}

+(id)effectWithBrightness:(float)brightness
{
    return [[self alloc] initWithBrightness:brightness];
}

-(void)buildFragmentFunctions
{
    NSString* effectBody = CC_GLSL(
                                   vec4 inputValue = texture2D(cc_PreviousPassTexture, cc_FragTexCoord1);
                                   return vec4((inputValue.rgb + vec3(u_brightness * inputValue.a)), inputValue.a);
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"brightnessEffect" body:effectBody returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectBrightness *weakSelf = self;
    __weak CCEffectRenderPass *weakPass = nil;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    weakPass = pass0;
    pass0.shader = self.shader;
    pass0.shaderUniforms = self.shaderUniforms;
    pass0.beginBlock = ^(CCTexture *previousPassTexture){
        weakPass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTexture;
        weakPass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        weakPass.shaderUniforms[@"u_brightness"] = [NSNumber numberWithFloat:weakSelf.brightness];
    };
    
    self.renderPasses = @[pass0];
}

-(void)setBrightness:(float)brightness
{
    _brightness = conditionBrightness(brightness);
}

@end

float conditionBrightness(float brightness)
{
    return clampf(brightness, -1.0f, 1.0f);
}

#endif
