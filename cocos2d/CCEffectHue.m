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


@implementation CCEffectHue

-(id)init
{
    return [self initWithHue:0.0f];
}

-(id)initWithHue:(float)hue
{
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"mat4" name:@"u_hueRotationMtx" value:[NSValue valueWithGLKMatrix4:GLKMatrix4Identity]]
                          ];
    
    if((self = [super initWithFragmentUniforms:uniforms vertexUniforms:nil varyings:nil]))
    {
        _hue = hue;
        _hueRotationMtx = [NSValue valueWithGLKMatrix4:matrixWithHue(conditionHue(hue))];
        self.debugName = @"CCEffectHue";
    }
    return self;
}

+(id)effectWithHue:(float)hue
{
    return [[self alloc] initWithHue:hue];
}

-(void)buildFragmentFunctions
{
    self.fragmentFunctions = [[NSMutableArray alloc] init];

    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue" initialSnippet:CCEffectDefaultInitialInputSnippet snippet:CCEffectDefaultInputSnippet];

    // The non-color matrix shader is based on the hue filter in GPUImage - https://github.com/BradLarson/GPUImage
    NSString* effectBody = CC_GLSL(
                                   return u_hueRotationMtx * inputValue;
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"hueEffect" body:effectBody inputs:@[input] returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectHue *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectHue pass 0";
    pass0.shader = self.shader;
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCTexture *previousPassTexture){

        pass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTexture;
        pass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        pass.shaderUniforms[CCShaderUniformTexCoord1Center] = [NSValue valueWithGLKVector2:pass.texCoord1Center];
        pass.shaderUniforms[CCShaderUniformTexCoord1Extents] = [NSValue valueWithGLKVector2:pass.texCoord1Extents];

        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_hueRotationMtx"]] = weakSelf.hueRotationMtx;
    } copy]];
    
    self.renderPasses = @[pass0];
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

