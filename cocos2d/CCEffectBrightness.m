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

static float conditionBrightness(float brightness);

@interface CCEffectBrightness ()
@property (nonatomic, strong) NSNumber *conditionedBrightness;
@end

@interface CCEffectBrightnessImpl : CCEffectImpl
@property (nonatomic, weak) CCEffectBrightness *interface;
@end


@implementation CCEffectBrightnessImpl

-(id)initWithInterface:(CCEffectBrightness *)interface
{
    CCEffectUniform* uniformBrightness = [CCEffectUniform uniform:@"float" name:@"u_brightness" value:[NSNumber numberWithFloat:0.0f]];
    
    NSArray *fragFunctions = [CCEffectBrightnessImpl buildFragmentFunctions];
    NSArray *renderPasses = [CCEffectBrightnessImpl buildRenderPassesWithInterface:interface];
    
    if((self = [super initWithRenderPasses:renderPasses fragmentFunctions:fragFunctions vertexFunctions:nil fragmentUniforms:@[uniformBrightness] vertexUniforms:nil varyings:nil]))
    {
        self.interface = interface;
        self.debugName = @"CCEffectBrightnessImpl";
    }
    return self;
}

+ (NSArray *)buildFragmentFunctions
{
    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue" initialSnippet:CCEffectDefaultInitialInputSnippet snippet:CCEffectDefaultInputSnippet];

    NSString* effectBody = CC_GLSL(
                                   return vec4((inputValue.rgb + vec3(u_brightness * inputValue.a)), inputValue.a);
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"brightnessEffect" body:effectBody inputs:@[input] returnType:@"vec4"];
    return @[fragmentFunction];
}

+ (NSArray *)buildRenderPassesWithInterface:(CCEffectBrightness *)interface
{
    __weak CCEffectBrightness *weakInterface = interface;

    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectBrightness pass 0";
    pass0.beginBlocks = @[[[CCEffectRenderPassBeginBlockContext alloc] initWithBlock:^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){
        
        passInputs.shaderUniforms[CCShaderUniformMainTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Center] = [NSValue valueWithGLKVector2:passInputs.texCoord1Center];
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Extents] = [NSValue valueWithGLKVector2:passInputs.texCoord1Extents];

        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_brightness"]] = weakInterface.conditionedBrightness;
    }]];
    
    return @[pass0];
}

@end


@implementation CCEffectBrightness

-(id)init
{
    return [self initWithBrightness:0.0f];
}

-(id)initWithBrightness:(float)brightness
{
    if((self = [super init]))
    {
        _brightness = brightness;
        _conditionedBrightness = [NSNumber numberWithFloat:conditionBrightness(brightness)];

        self.effectImpl = [[CCEffectBrightnessImpl alloc] initWithInterface:self];
        self.debugName = @"CCEffectBrightness";
    }
    return self;
}

+(instancetype)effectWithBrightness:(float)brightness
{
    return [[self alloc] initWithBrightness:brightness];
}

-(void)setBrightness:(float)brightness
{
    _brightness = brightness;
    _conditionedBrightness = [NSNumber numberWithFloat:conditionBrightness(brightness)];
}

@end



float conditionBrightness(float brightness)
{
    NSCAssert((brightness >= -1.0) && (brightness <= 1.0), @"Supplied brightness out of range [-1..1].");
    return clampf(brightness, -1.0f, 1.0f);
}
