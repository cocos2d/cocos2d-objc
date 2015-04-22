//
//  CCEffectHue.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/9/14.
//


#import "CCEffectHue.h"
#import "CCEffectShader.h"
#import "CCEffectShaderBuilderGL.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

static float conditionHue(float hue);

static GLKMatrix4 matrixWithHue(float hue);

@interface CCEffectHue ()
@property (nonatomic, strong) NSValue *hueRotationMtx;
@end


@interface CCEffectHueImplGL : CCEffectImpl
@property (nonatomic, weak) CCEffectHue *interface;
@end

@implementation CCEffectHueImplGL

-(id)initWithInterface:(CCEffectHue *)interface
{
    NSArray *renderPasses = [CCEffectHueImplGL buildRenderPassesWithInterface:interface];
    NSArray *shaders = [CCEffectHueImplGL buildShaders];
    
    if((self = [super initWithRenderPassDescriptors:renderPasses shaders:shaders]))
    {
        self.interface = interface;
        self.debugName = @"CCEffectHueImplGL";
    }
    return self;
}

+ (NSArray *)buildShaders
{
    return @[[[CCEffectShader alloc] initWithVertexShaderBuilder:[CCEffectShaderBuilderGL defaultVertexShaderBuilder] fragmentShaderBuilder:[CCEffectHueImplGL fragShaderBuilder]]];
}

+ (CCEffectShaderBuilder *)fragShaderBuilder
{
    NSArray *functions = [CCEffectHueImplGL buildFragmentFunctions];
    NSArray *temporaries = @[[CCEffectFunctionTemporary temporaryWithType:@"vec4" name:@"tmp" initializer:CCEffectInitPreviousPass]];
    NSArray *calls = @[[[CCEffectFunctionCall alloc] initWithFunction:functions[0] outputName:@"hue" inputs:@{@"inputValue" : @"tmp"}]];
    
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"sampler2D" name:CCShaderUniformPreviousPassTexture value:(NSValue *)[CCTexture none]],
                          [CCEffectUniform uniform:@"vec2" name:CCShaderUniformTexCoord1Center value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
                          [CCEffectUniform uniform:@"vec2" name:CCShaderUniformTexCoord1Extents value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
                          [CCEffectUniform uniform:@"mat4" name:@"u_hueRotationMtx" value:[NSValue valueWithGLKMatrix4:GLKMatrix4Identity]]
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

    // The non-color matrix shader is based on the hue filter in GPUImage - https://github.com/BradLarson/GPUImage
    NSString* effectBody = CC_GLSL(
                                   return u_hueRotationMtx * inputValue;
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"hueEffect" body:effectBody inputs:@[input] returnType:@"vec4"];
    return @[fragmentFunction];
}

+ (NSArray *)buildRenderPassesWithInterface:(CCEffectHue *)interface
{
    __weak CCEffectHue *weakInterface = interface;

    CCEffectRenderPassDescriptor *pass0 = [CCEffectRenderPassDescriptor descriptor];
    pass0.debugLabel = @"CCEffectHue pass 0";
    pass0.beginBlocks = @[[[CCEffectRenderPassBeginBlockContext alloc] initWithBlock:^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){

        passInputs.shaderUniforms[CCShaderUniformMainTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Center] = [NSValue valueWithGLKVector2:passInputs.texCoord1Center];
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Extents] = [NSValue valueWithGLKVector2:passInputs.texCoord1Extents];

        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_hueRotationMtx"]] = weakInterface.hueRotationMtx;
    }]];
    
    return @[pass0];
}

@end



@implementation CCEffectHue

-(id)init
{
    return [self initWithHue:0.0f];
}

-(id)initWithHue:(float)hue
{
    if((self = [super init]))
    {
        self.effectImpl = [[CCEffectHueImplGL alloc] initWithInterface:self];
        self.debugName = @"CCEffectHue";

        self.hue = hue;
    }
    return self;
}

+(instancetype)effectWithHue:(float)hue
{
    return [[self alloc] initWithHue:hue];
}

-(void)setHue:(float)hue
{
    _hue = hue;
    _hueRotationMtx = [NSValue valueWithGLKMatrix4:matrixWithHue(conditionHue(hue))];
}

@end




float conditionHue(float hue)
{
    NSCAssert((hue >= -180.0f) && (hue <= 180.0), @"Supplied hue out of range [-180.0..180.0].");
    return clampf(hue, -180.0f, 180.0f) * M_PI / 180.0f;
}

GLKMatrix4 matrixWithHue(float hue)
{
    // RGB to YIQ and YIQ to RGB matrix values source from here:
    //   http://en.wikipedia.org/wiki/YIQ
    //
    // Note that GL matrices are column major so we have to transpose them when loading them in
    // the order specified here.
    
    GLKMatrix4 rgbToYiq = GLKMatrix4MakeAndTranspose(0.299,     0.587,     0.114,    0.0,
                                                     0.595716, -0.274453, -0.321263, 0.0,
                                                     0.211456, -0.522591,  0.31135,  0.0,
                                                     0.0,       0.0,       0.0,      1.0);
    GLKMatrix4 yiqToRgb = GLKMatrix4MakeAndTranspose(1.0,  0.9563,  0.6210, 0.0,
                                                     1.0, -0.2721, -0.6474, 0.0,
                                                     1.0, -1.1070,  1.7046, 0.0,
                                                     0.0,  0.0,     0.0,    1.0);
    
    // Positive rotation in YIQ is the opposite of positive rotation in HSV so negate the
    // rotation value. See this:
    //   http://upload.wikimedia.org/wikipedia/commons/8/82/YIQ_IQ_plane.svg
    // And this:
    //   http://upload.wikimedia.org/wikipedia/commons/5/52/HSL-HSV_hue_and_chroma.svg
    // To visualize the difference between the two color spaces.
    //
    GLKMatrix4 rotation = GLKMatrix4MakeRotation(-hue, 1.0f, 0.0f, 0.0f);

    // Put everything together into one color matrix.
    GLKMatrix4 composed = GLKMatrix4Multiply(yiqToRgb, GLKMatrix4Multiply(rotation, rgbToYiq));
    return composed;
}

