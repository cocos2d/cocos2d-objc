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


@interface CCEffectBrightnessImpl : CCEffectImpl

@property (nonatomic, strong) NSNumber *conditionedBrightness;

@end


@implementation CCEffectBrightnessImpl

-(id)initWithBrightness:(float)brightness
{
    CCEffectUniform* uniformBrightness = [CCEffectUniform uniform:@"float" name:@"u_brightness" value:[NSNumber numberWithFloat:0.0f]];
    
    NSArray *fragFunctions = [CCEffectBrightnessImpl buildFragmentFunctions];
    NSArray *renderPasses = [self buildRenderPasses];
    
    if((self = [super initWithRenderPasses:renderPasses fragmentFunctions:fragFunctions vertexFunctions:nil fragmentUniforms:@[uniformBrightness] vertexUniforms:nil varyings:nil]))
    {
        _conditionedBrightness = [NSNumber numberWithFloat:conditionBrightness(brightness)];
        
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

- (NSArray *)buildRenderPasses
{
    __weak CCEffectBrightnessImpl *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectBrightness pass 0";
    pass0.shader = self.shader;
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){
        
        passInputs.shaderUniforms[CCShaderUniformMainTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Center] = [NSValue valueWithGLKVector2:passInputs.texCoord1Center];
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Extents] = [NSValue valueWithGLKVector2:passInputs.texCoord1Extents];

        passInputs.shaderUniforms[pass.uniformTranslationTable[@"u_brightness"]] = weakSelf.conditionedBrightness;
    } copy]];
    
    return @[pass0];
}

-(void)setBrightness:(float)brightness
{
    _conditionedBrightness = [NSNumber numberWithFloat:conditionBrightness(brightness)];
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
        
        self.effectImpl = [[CCEffectBrightnessImpl alloc] initWithBrightness:brightness];
        self.debugName = @"CCEffectBrightness";
    }
    return self;
}

+(id)effectWithBrightness:(float)brightness
{
    return [[self alloc] initWithBrightness:brightness];
}

-(void)setBrightness:(float)brightness
{
    _brightness = brightness;
    
    CCEffectBrightnessImpl *brightnessImpl = (CCEffectBrightnessImpl *)self.effectImpl;
    [brightnessImpl setBrightness:brightness];
}

@end



float conditionBrightness(float brightness)
{
    NSCAssert((brightness >= -1.0) && (brightness <= 1.0), @"Supplied brightness out of range [-1..1].");
    return clampf(brightness, -1.0f, 1.0f);
}
