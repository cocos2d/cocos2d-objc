//
//  CCEffectBrightness.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 5/7/14.
//
//

#import "CCEffectBrightness.h"
#import "CCEffectShader.h"
#import "CCEffectShaderBuilderGL.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

static float conditionBrightness(float brightness);

@interface CCEffectBrightness ()
@property (nonatomic, strong) NSNumber *conditionedBrightness;
@end

@interface CCEffectBrightnessImplGL : CCEffectImpl
@property (nonatomic, weak) CCEffectBrightness *interface;
@end


@implementation CCEffectBrightnessImplGL

-(id)initWithInterface:(CCEffectBrightness *)interface
{
    NSArray *renderPasses = [CCEffectBrightnessImplGL buildRenderPassesWithInterface:interface];
    NSArray *shaders = [CCEffectBrightnessImplGL buildShaders];
    
    if((self = [super initWithRenderPassDescriptors:renderPasses shaders:shaders]))
    {
        self.interface = interface;
        self.debugName = @"CCEffectBrightnessImplGL";
    }
    return self;
}

+ (NSArray *)buildShaders
{
    return @[[[CCEffectShader alloc] initWithVertexShaderBuilder:[CCEffectShaderBuilderGL defaultVertexShaderBuilder] fragmentShaderBuilder:[CCEffectBrightnessImplGL fragShaderBuilder]]];
}

+ (CCEffectShaderBuilder *)fragShaderBuilder
{
    NSArray *functions = [CCEffectBrightnessImplGL buildFragmentFunctions];
    NSArray *temporaries = @[[CCEffectFunctionTemporary temporaryWithType:@"vec4" name:@"tmp" initializer:CCEffectInitPreviousPass]];
    NSArray *calls = @[[[CCEffectFunctionCall alloc] initWithFunction:functions[0] outputName:@"brightness" inputs:@{@"inputValue" : @"tmp"}]];
    
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"sampler2D" name:CCShaderUniformPreviousPassTexture value:(NSValue *)[CCTexture none]],
                          [CCEffectUniform uniform:@"vec2" name:CCShaderUniformTexCoord1Center value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
                          [CCEffectUniform uniform:@"vec2" name:CCShaderUniformTexCoord1Extents value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
                          [CCEffectUniform uniform:@"float" name:@"u_brightness" value:[NSNumber numberWithFloat:0.0f]]
                          ];
    
    return [[CCEffectShaderBuilderGL alloc] initWithType:CCEffectShaderBuilderFragment
                                               functions:functions
                                                   calls:calls
                                             temporaries:temporaries
                                                uniforms:uniforms
                                                varyings:@[]];
}

+ (NSArray *)buildFragmentFunctions
{
    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue"];

    NSString* effectBody = CC_GLSL(
                                   return vec4((inputValue.rgb + vec3(u_brightness * inputValue.a)), inputValue.a);
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"brightnessEffect" body:effectBody inputs:@[input] returnType:@"vec4"];
    return @[fragmentFunction];
}

+ (NSArray *)buildRenderPassesWithInterface:(CCEffectBrightness *)interface
{
    __weak CCEffectBrightness *weakInterface = interface;

    CCEffectRenderPassDescriptor *pass0 = [CCEffectRenderPassDescriptor descriptor];
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

        self.effectImpl = [[CCEffectBrightnessImplGL alloc] initWithInterface:self];
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
