//
//  CCEffectColorChannelOffset.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 8/19/14.
//
//

#import "CCEffectColorChannelOffset.h"
#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"


@interface CCEffectColorChannelOffsetImpl : CCEffectImpl

@property (nonatomic, weak) CCEffectColorChannelOffset *interface;

@end


@implementation CCEffectColorChannelOffsetImpl

-(id)initWithInterface:(CCEffectColorChannelOffset *)interface
{
    NSArray *fragUniforms = @[
                              [CCEffectUniform uniform:@"vec2" name:@"u_redOffset" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
                              [CCEffectUniform uniform:@"vec2" name:@"u_greenOffset" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
                              [CCEffectUniform uniform:@"vec2" name:@"u_blueOffset" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]]
                              ];
    
    NSArray *fragFunctions = [CCEffectColorChannelOffsetImpl buildFragmentFunctions];
    NSArray *renderPasses = [CCEffectColorChannelOffsetImpl buildRenderPassesWithInterface:interface];
    
    if((self = [super initWithRenderPasses:renderPasses fragmentFunctions:fragFunctions vertexFunctions:nil fragmentUniforms:fragUniforms vertexUniforms:nil varyings:nil]))
    {
        self.interface = interface;
        self.debugName = @"CCEffectColorChannelOffsetImpl";
        self.stitchFlags = CCEffectFunctionStitchAfter;
    }
    
    return self;
}

+ (NSArray *)buildFragmentFunctions
{
    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue" initialSnippet:@"cc_FragColor" snippet:@"vec4(1,1,1,1)"];

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

+ (NSArray *)buildRenderPassesWithInterface:(CCEffectColorChannelOffset *)interface
{
    __weak CCEffectColorChannelOffset *weakInterface = interface;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectPixellate pass 0";
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){
        
        passInputs.shaderUniforms[CCShaderUniformMainTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Center] = [NSValue valueWithGLKVector2:passInputs.texCoord1Center];
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Extents] = [NSValue valueWithGLKVector2:passInputs.texCoord1Extents];
        
        GLKVector2 scale = GLKVector2Make(-1.0f / passInputs.previousPassTexture.contentSize.width, -1.0f / passInputs.previousPassTexture.contentSize.height);
        GLKVector2 redOffsetUV = GLKVector2Multiply(weakInterface.redOffset, scale);
        GLKVector2 greenOffsetUV = GLKVector2Multiply(weakInterface.greenOffset, scale);
        GLKVector2 blueOffsetUV = GLKVector2Multiply(weakInterface.blueOffset, scale);
        
        passInputs.shaderUniforms[pass.uniformTranslationTable[@"u_redOffset"]] = [NSValue valueWithGLKVector2:redOffsetUV];
        passInputs.shaderUniforms[pass.uniformTranslationTable[@"u_greenOffset"]] = [NSValue valueWithGLKVector2:greenOffsetUV];
        passInputs.shaderUniforms[pass.uniformTranslationTable[@"u_blueOffset"]] = [NSValue valueWithGLKVector2:blueOffsetUV];
        
    } copy]];
    
    return @[pass0];
}

@end


@implementation CCEffectColorChannelOffset

-(id)init
{
    return [self initWithRedOffset:GLKVector2Make(0.0f, 0.0f) greenOffset:GLKVector2Make(0.0f, 0.0f) blueOffset:GLKVector2Make(0.0f, 0.0f)];
}

-(id)initWithRedOffset:(GLKVector2)redOffset greenOffset:(GLKVector2)greenOffset blueOffset:(GLKVector2)blueOffset
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

+(id)effectWithRedOffset:(GLKVector2)redOffset greenOffset:(GLKVector2)greenOffset blueOffset:(GLKVector2)blueOffset;
{
    return [[self alloc] initWithRedOffset:redOffset greenOffset:greenOffset blueOffset:blueOffset];
}

- (CGPoint)redOffsetWithPoint
{
    return CGPointMake(_redOffset.x, _redOffset.y);
}

- (void)setRedOffsetWithPoint:(CGPoint)offset
{
    _redOffset = GLKVector2Make(offset.x, offset.y);
}

- (CGPoint)greenOffsetWithPoint
{
    return CGPointMake(_greenOffset.x, _greenOffset.y);
}

- (void)setGreenOffsetWithPoint:(CGPoint)offset
{
    _greenOffset = GLKVector2Make(offset.x, offset.y);
}

- (CGPoint)blueOffsetWithPoint
{
    return CGPointMake(_blueOffset.x, _blueOffset.y);
}

- (void)setBlueOffsetWithPoint:(CGPoint)offset
{
    _blueOffset = GLKVector2Make(offset.x, offset.y);
}

@end

