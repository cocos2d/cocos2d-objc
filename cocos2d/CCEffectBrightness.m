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

-(NSInteger)renderPassesRequired
{
    return 1;
}

-(void)setBrightness:(float)brightness
{
    _brightness = conditionBrightness(brightness);
}

-(void)renderPassBegin:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    renderPass.shaderUniforms[@"u_brightness"] = [NSNumber numberWithFloat:self.brightness];
}

-(void)renderPassUpdate:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
    [renderPass.renderer enqueueClear:GL_COLOR_BUFFER_BIT color:[CCColor clearColor].glkVector4 depth:0.0f stencil:0 globalSortOrder:NSIntegerMin];
    [renderPass draw];
}

-(void)renderPassEnd:(CCEffectRenderPass*)renderPass defaultBlock:(void (^)())defaultBlock
{
}

@end

float conditionBrightness(float brightness)
{
    return clampf(brightness, -1.0f, 1.0f);
}

#endif
