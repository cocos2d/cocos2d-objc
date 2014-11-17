//
//  CCEffectHue.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/9/14.
//


#import "CCEffectHue.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

static float conditionHue(float hue);

static GLKMatrix4 matrixWithHue(float hue);

@interface CCEffectHue ()
@property (nonatomic, strong) NSValue *hueRotationMtx;
@end


@interface CCEffectHueImpl : CCEffectImpl
@property (nonatomic, weak) CCEffectHue *interface;
@end

@implementation CCEffectHueImpl

-(id)initWithInterface:(CCEffectHue *)interface
{
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"mat4" name:@"u_hueRotationMtx" value:[NSValue valueWithGLKMatrix4:GLKMatrix4Identity]]
                          ];
    
    NSArray *fragFunctions = [CCEffectHueImpl buildFragmentFunctions];
    NSArray *renderPasses = [CCEffectHueImpl buildRenderPassesWithInterface:interface];
    
    if((self = [super initWithRenderPasses:renderPasses fragmentFunctions:fragFunctions vertexFunctions:nil fragmentUniforms:uniforms vertexUniforms:nil varyings:nil]))
    {
        self.debugName = @"CCEffectHueImpl";
    }
    return self;
}

+ (NSArray *)buildFragmentFunctions
{
    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue" initialSnippet:CCEffectDefaultInitialInputSnippet snippet:CCEffectDefaultInputSnippet];

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

    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectHue pass 0";
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){

        passInputs.shaderUniforms[CCShaderUniformMainTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Center] = [NSValue valueWithGLKVector2:passInputs.texCoord1Center];
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Extents] = [NSValue valueWithGLKVector2:passInputs.texCoord1Extents];

        passInputs.shaderUniforms[pass.uniformTranslationTable[@"u_hueRotationMtx"]] = weakInterface.hueRotationMtx;
    } copy]];
    
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
        self.effectImpl = [[CCEffectHueImpl alloc] initWithInterface:self];
        self.debugName = @"CCEffectHue";

        self.hue = hue;
    }
    return self;
}

+(id)effectWithHue:(float)hue
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

