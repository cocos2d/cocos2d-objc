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


@interface CCEffectColorChannelOffset ()

@end


@implementation CCEffectColorChannelOffset

-(id)init
{
    return [self initWithRedOffset:GLKVector2Make(0.0f, 0.0f) greenOffset:GLKVector2Make(0.0f, 0.0f) blueOffset:GLKVector2Make(0.0f, 0.0f)];
}

-(id)initWithRedOffset:(GLKVector2)redOffset greenOffset:(GLKVector2)greenOffset blueOffset:(GLKVector2)blueOffset
{
    NSArray *fragUniforms = @[
                              [CCEffectUniform uniform:@"vec2" name:@"u_redOffset" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
                              [CCEffectUniform uniform:@"vec2" name:@"u_greenOffset" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]],
                              [CCEffectUniform uniform:@"vec2" name:@"u_blueOffset" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]]
                              ];
    
    if((self = [super initWithFragmentUniforms:fragUniforms vertexUniforms:nil varyings:nil]))
    {
        _redOffset = redOffset;
        _greenOffset = greenOffset;
        _blueOffset = blueOffset;
        
        self.debugName = @"CCEffectColorChannelOffset";
        self.stitchFlags = CCEffectFunctionStitchAfter;
    }
    
    return self;
}

+(id)effectWithRedOffset:(GLKVector2)redOffset greenOffset:(GLKVector2)greenOffset blueOffset:(GLKVector2)blueOffset;
{
    return [[self alloc] initWithRedOffset:redOffset greenOffset:greenOffset blueOffset:blueOffset];
}

-(void)buildFragmentFunctions
{
    self.fragmentFunctions = [[NSMutableArray alloc] init];
    
    // Image pixellation shader based on pixellation filter in GPUImage - https://github.com/BradLarson/GPUImage
    NSString* effectBody = CC_GLSL(
                                   vec2 redSamplePos = cc_FragTexCoord1 + u_redOffset;
                                   vec2 greenSamplePos = cc_FragTexCoord1 + u_greenOffset;
                                   vec2 blueSamplePos = cc_FragTexCoord1 + u_blueOffset;
                                   
                                   vec4 redSample = texture2D(cc_PreviousPassTexture, redSamplePos);
                                   vec4 greenSample = texture2D(cc_PreviousPassTexture, greenSamplePos);
                                   vec4 blueSample = texture2D(cc_PreviousPassTexture, blueSamplePos);
                                   
                                   return vec4(redSample.r, greenSample.g, blueSample.b, 1.0);
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"pixellateEffect" body:effectBody inputs:nil returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectColorChannelOffset *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectPixellate pass 0";
    pass0.shader = self.shader;
    pass0.blendMode = [CCBlendMode premultipliedAlphaMode];
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCTexture *previousPassTexture){
        
        pass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTexture;
        pass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        
        GLKVector2 scale = GLKVector2Make(-1.0f / previousPassTexture.contentSize.width, -1.0f / previousPassTexture.contentSize.height);
        GLKVector2 redOffsetUV = GLKVector2Multiply(weakSelf.redOffset, scale);
        GLKVector2 greenOffsetUV = GLKVector2Multiply(weakSelf.greenOffset, scale);
        GLKVector2 blueOffsetUV = GLKVector2Multiply(weakSelf.blueOffset, scale);
        
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_redOffset"]] = [NSValue valueWithGLKVector2:redOffsetUV];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_greenOffset"]] = [NSValue valueWithGLKVector2:greenOffsetUV];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_blueOffset"]] = [NSValue valueWithGLKVector2:blueOffsetUV];
        
    } copy]];
    
    self.renderPasses = @[pass0];
}

@end

