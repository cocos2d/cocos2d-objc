//
//  CCEffectStereo.m
//  cocos2d
//
//  Created by Thayer J Andrews on 3/16/15.
//
//

#import "CCEffectStereo.h"

#if CC_EFFECTS_EXPERIMENTAL

#import "CCEffectShader.h"
#import "CCEffectShaderBuilderGL.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"



@interface CCEffectStereoImplGL : CCEffectImpl

@property (nonatomic, weak) CCEffectStereo *interface;

@end


@implementation CCEffectStereoImplGL

-(id)initWithInterface:(CCEffectStereo *)interface
{
    NSArray *renderPasses = [CCEffectStereoImplGL buildRenderPassesWithInterface:interface];
    NSArray *shaders = [CCEffectStereoImplGL buildShaders];
    
    if((self = [super initWithRenderPasses:renderPasses shaders:shaders]))
    {
        self.interface = interface;
        self.debugName = @"CCEffectStereoImpl";
        self.stitchFlags = CCEffectFunctionStitchAfter;
    }
    return self;
}

+ (NSArray *)buildShaders
{
    return @[[[CCEffectShader alloc] initWithVertexShaderBuilder:[CCEffectShaderBuilderGL defaultVertexShaderBuilder] fragmentShaderBuilder:[CCEffectStereoImplGL fragShaderBuilder]]];
}

+ (CCEffectShaderBuilder *)fragShaderBuilder
{
    NSArray *functions = [CCEffectStereoImplGL buildFragmentFunctions];
    NSArray *temporaries = @[[CCEffectFunctionTemporary temporaryWithType:@"vec4" name:@"tmp" initializer:CCEffectInitPreviousPass]];
    NSArray *calls = @[[[CCEffectFunctionCall alloc] initWithFunction:functions[0] outputName:@"stereoOffset" inputs:@{@"inputValue" : @"tmp"}]];
    
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"sampler2D" name:CCShaderUniformPreviousPassTexture value:(NSValue *)[CCTexture none]],
                          [CCEffectUniform uniform:@"vec2" name:CCShaderUniformTexCoord1Center value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
                          [CCEffectUniform uniform:@"vec2" name:CCShaderUniformTexCoord1Extents value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
                          [CCEffectUniform uniform:@"float" name:@"u_channelSelect" value:[NSNumber numberWithFloat:0.0f]]
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
    
    NSString* effectPrefix =
    @"#ifdef GL_ES\n"
    @"#ifdef GL_EXT_shader_framebuffer_fetch\n"
    @"#extension GL_EXT_shader_framebuffer_fetch : enable\n"
    @"#endif\n"
    @"#endif\n";
    
    NSString* effectBody = CC_GLSL(
                                   vec4 result;
                                   vec4 fbPixel = gl_LastFragData[0];
                                   float dstAlpha = 1.0 - inputValue.a;
                                   
                                   if (u_channelSelect == 0.0)
                                   {
                                       result = vec4(inputValue.r + fbPixel.r * dstAlpha, fbPixel.g, fbPixel.b, 1);
                                   }
                                   else
                                   {
                                       result = vec4(fbPixel.r, inputValue.g + fbPixel.g * dstAlpha, inputValue.b + fbPixel.b * dstAlpha, 1);
                                   }
                                   return result;
                                   );
    
    return @[[[CCEffectFunction alloc] initWithName:@"stereoEffect" body:[effectPrefix stringByAppendingString:effectBody] inputs:@[input] returnType:@"vec4"]];
}

+ (NSArray *)buildRenderPassesWithInterface:(CCEffectStereo *)interface
{
    __weak CCEffectStereo *weakInterface = interface;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectPixellate pass 0";
    pass0.blendMode = [CCBlendMode disabledMode];
    pass0.beginBlocks = @[[[CCEffectRenderPassBeginBlockContext alloc] initWithBlock:^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){
        
        passInputs.shaderUniforms[CCShaderUniformMainTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Center] = [NSValue valueWithGLKVector2:passInputs.texCoord1Center];
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Extents] = [NSValue valueWithGLKVector2:passInputs.texCoord1Extents];
        
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_channelSelect"]] = (interface.channelSelect == CCEffectStereoSelectRed) ? @(0.0f) : @(1.0f);
        
    }]];
    
    return @[pass0];
}

@end


@implementation CCEffectStereo

-(id)init
{
    return [self initWithChannelSelect:CCEffectStereoSelectRed];
}

-(id)initWithChannelSelect:(CCEffectStereoChannelSelect)channelSelect
{
    if((self = [super init]))
    {
        _channelSelect = channelSelect;
        
        self.effectImpl = [[CCEffectStereoImplGL alloc] initWithInterface:self];
        self.debugName = @"CCEffectStereo";
    }
    
    return self;
}

+(instancetype)effectWithChannelSelect:(CCEffectStereoChannelSelect)channelSelect
{
    return [[self alloc] initWithChannelSelect:channelSelect];
}

@end

#endif

