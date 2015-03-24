//
//  CCEffectColorChannelOffset.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 8/19/14.
//
//

#import "CCEffectColorChannelOffset.h"
#import "CCEffectShader.h"
#import "CCEffectShaderBuilderGL.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"


@interface CCEffectColorChannelOffsetImpl : CCEffectImpl

@property (nonatomic, weak) CCEffectColorChannelOffset *interface;

@end


@implementation CCEffectColorChannelOffsetImpl

-(id)initWithInterface:(CCEffectColorChannelOffset *)interface
{
    NSArray *renderPasses = [CCEffectColorChannelOffsetImpl buildRenderPassesWithInterface:interface];
    NSArray *shaders = [CCEffectColorChannelOffsetImpl buildShaders];

    if((self = [super initWithRenderPasses:renderPasses shaders:shaders]))
    {
        self.interface = interface;
        self.debugName = @"CCEffectColorChannelOffsetImpl";
        self.stitchFlags = CCEffectFunctionStitchAfter;
    }
    
    return self;
}

+ (NSArray *)buildShaders
{
    return @[[[CCEffectShader alloc] initWithVertexShaderBuilder:[CCEffectShaderBuilderGL defaultVertexShaderBuilder] fragmentShaderBuilder:[CCEffectColorChannelOffsetImpl fragShaderBuilder]]];
}

+ (CCEffectShaderBuilder *)fragShaderBuilder
{
    NSArray *functions = [CCEffectColorChannelOffsetImpl buildFragmentFunctions];
    NSArray *temporaries = @[[[CCEffectFunctionTemporary alloc] initWithType:@"vec4" name:@"tmp" initializer:CCEffectInitFragColor]];
    NSArray *calls = @[[[CCEffectFunctionCall alloc] initWithFunction:functions[0] outputName:@"colorChannelOffset" inputs:@{@"inputValue" : @"tmp"}]];
    
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"sampler2D" name:CCShaderUniformPreviousPassTexture value:(NSValue *)[CCTexture none]],
                          [CCEffectUniform uniform:@"vec2" name:CCShaderUniformTexCoord1Center value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
                          [CCEffectUniform uniform:@"vec2" name:CCShaderUniformTexCoord1Extents value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_redOffset" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_greenOffset" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_blueOffset" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]]
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

    // Image pixellation shader based on pixellation filter in GPUImage - https://github.com/BradLarson/GPUImage
    NSString* effectBody = CC_GLSL(
                                   vec2 redSamplePos = cc_FragTexCoord1 + u_redOffset;
                                   vec2 redCompare = cc_FragTexCoord1Extents - abs(redSamplePos - cc_FragTexCoord1Center);
                                   float redInBounds = step(0.0, min(redCompare.x, redCompare.y));
                                   vec4 redSample = inputValue * texture2D(cc_PreviousPassTexture, redSamplePos) * redInBounds;

                                   vec2 greenSamplePos = cc_FragTexCoord1 + u_greenOffset;
                                   vec2 greenCompare = cc_FragTexCoord1Extents - abs(greenSamplePos - cc_FragTexCoord1Center);
                                   float greenInBounds = step(0.0, min(greenCompare.x, greenCompare.y));
                                   vec4 greenSample = inputValue * texture2D(cc_PreviousPassTexture, greenSamplePos) * greenInBounds;

                                   vec2 blueSamplePos = cc_FragTexCoord1 + u_blueOffset;
                                   vec2 blueCompare = cc_FragTexCoord1Extents - abs(blueSamplePos - cc_FragTexCoord1Center);
                                   float blueInBounds = step(0.0, min(blueCompare.x, blueCompare.y));
                                   vec4 blueSample = inputValue * texture2D(cc_PreviousPassTexture, blueSamplePos) * blueInBounds;
                                   
                                   return vec4(redSample.r, greenSample.g, blueSample.b, (redSample.a + greenSample.a + blueSample.a) / 3.0);
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"colorChannelOffsetEffect" body:effectBody inputs:@[input] returnType:@"vec4"];
    return @[fragmentFunction];
}

static GLKVector2
GLKVector2fromCGPoint(CGPoint p)
{
    return GLKVector2Make(p.x, p.y);
}

+ (NSArray *)buildRenderPassesWithInterface:(CCEffectColorChannelOffset *)interface
{
    __weak CCEffectColorChannelOffset *weakInterface = interface;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectPixellate pass 0";
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlocks = @[[[CCEffectRenderPassBeginBlockContext alloc] initWithBlock:^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){
        
        passInputs.shaderUniforms[CCShaderUniformMainTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Center] = [NSValue valueWithGLKVector2:passInputs.texCoord1Center];
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Extents] = [NSValue valueWithGLKVector2:passInputs.texCoord1Extents];
        
        GLKVector2 scale = GLKVector2Make(-1.0f / passInputs.previousPassTexture.contentSize.width, -1.0f / passInputs.previousPassTexture.contentSize.height);
        CGPoint redOffsetUV = weakInterface.redOffset;
        CGPoint greenOffsetUV = weakInterface.greenOffset;
        CGPoint blueOffsetUV = weakInterface.blueOffset;
			
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_redOffset"]] = [NSValue valueWithGLKVector2:GLKVector2Make(redOffsetUV.x * scale.x, redOffsetUV.y * scale.y)];
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_greenOffset"]] = [NSValue valueWithGLKVector2:GLKVector2Make(greenOffsetUV.x * scale.x, greenOffsetUV.y * scale.y)];
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_blueOffset"]] = [NSValue valueWithGLKVector2:GLKVector2Make(blueOffsetUV.x * scale.x, blueOffsetUV.y * scale.y)];
        
    }]];
    
    return @[pass0];
}

@end


@implementation CCEffectColorChannelOffset

-(id)init
{
    return [self initWithRedOffset:CGPointZero greenOffset:CGPointZero blueOffset:CGPointZero];
}

-(id)initWithRedOffset:(CGPoint)redOffset greenOffset:(CGPoint)greenOffset blueOffset:(CGPoint)blueOffset
{    
    if((self = [super init]))
    {
        _redOffset = redOffset;
        _greenOffset = greenOffset;
        _blueOffset = blueOffset;
        
        self.effectImpl = [[CCEffectColorChannelOffsetImpl alloc] initWithInterface:self];
        self.debugName = @"CCEffectColorChannelOffset";
    }
    
    return self;
}

+(instancetype)effectWithRedOffset:(CGPoint)redOffset greenOffset:(CGPoint)greenOffset blueOffset:(CGPoint)blueOffset
{
    return [[self alloc] initWithRedOffset:redOffset greenOffset:greenOffset blueOffset:blueOffset];
}

- (CGPoint)redOffsetWithPoint
{
    return CGPointMake(_redOffset.x, _redOffset.y);
}

@end

