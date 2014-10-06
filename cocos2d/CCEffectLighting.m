//
//  CCEffectLighting.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 10/2/14.
//
//

#import "CCEffectLighting.h"

#import "CCDirector.h"
#import "CCEffectUtils.h"
#import "CCRenderer.h"
#import "CCSpriteFrame.h"
#import "CCTexture.h"

#import "CCEffect_Private.h"
#import "CCSprite_Private.h"

@interface CCEffectLighting ()

@end


@implementation CCEffectLighting

-(id)init
{
    return [self initWithLight:nil];
}

-(id)initWithLight:(CCLightNode *)light
{
    NSArray *fragUniforms = @[
                              [CCEffectUniform uniform:@"vec4" name:@"u_lightColor" value:[NSValue valueWithGLKVector4:GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f)]],
                              [CCEffectUniform uniform:@"vec4" name:@"u_ambientColor" value:[NSValue valueWithGLKVector4:GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f)]],
                              ];
    
    NSArray *vertUniforms = @[
                              [CCEffectUniform uniform:@"mat4" name:@"u_ndcToTangentSpace" value:[NSValue valueWithGLKMatrix4:GLKMatrix4Identity]],
                              [CCEffectUniform uniform:@"vec4" name:@"u_lightPosition" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 0.0f)]]
                              ];
    
    NSArray *varyings = @[
                          [CCEffectVarying varying:@"vec4" name:@"v_tangentSpaceLightDir"]
                          ];
    
    if((self = [super initWithFragmentUniforms:fragUniforms vertexUniforms:vertUniforms varyings:varyings]))
    {
        self.debugName = @"CCEffectLighting";
        
        _light = light;
    }
    return self;
}

+(id)effectWithLight:(CCLightNode *)light
{
    return [[self alloc] initWithLight:light];
}

-(void)buildFragmentFunctions
{
    self.fragmentFunctions = [[NSMutableArray alloc] init];
    
    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue" initialSnippet:CCEffectDefaultInitialInputSnippet snippet:CCEffectDefaultInputSnippet];
    
    NSString* effectBody = CC_GLSL(
                                   // Index the normal map and expand the color value from [0..1] to [-1..1]
                                   vec4 normalMap = texture2D(cc_NormalMapTexture, cc_FragTexCoord2);
                                   vec4 tangentSpaceNormal = normalMap * 2.0 - 1.0;
                                   
                                   float NdotL = dot(tangentSpaceNormal, v_tangentSpaceLightDir);
                                   if (normalMap.a > 0.0)
                                   {
                                       return inputValue * (u_lightColor * NdotL + u_ambientColor);
                                   }
                                   else
                                   {
                                       return vec4(0,0,0,1);
                                   }
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"lightingEffectFrag" body:effectBody inputs:@[input] returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildVertexFunctions
{
    self.vertexFunctions = [[NSMutableArray alloc] init];
    
    NSString* effectBody = CC_GLSL(
                                   // Compute the tangent space lighting direction vector for each
                                   // vertex. cc_Position was transformed on the CPU so we need to
                                   // back it out from NDC (normalized device coords) to tangent
                                   // space before using it to compute the light direction.
                                   vec4 tangentSpacePosition = u_ndcToTangentSpace * cc_Position;
                                   v_tangentSpaceLightDir = normalize(u_lightPosition - tangentSpacePosition);
                                   return cc_Position;
                                   );
    
    CCEffectFunction *vertexFunction = [[CCEffectFunction alloc] initWithName:@"lightingEffectVtx" body:effectBody inputs:nil returnType:@"vec4"];
    [self.vertexFunctions addObject:vertexFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectLighting *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectLighting pass 0";
    pass0.shader = self.shader;
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCTexture *previousPassTexture){
        
        pass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTexture;
        pass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        pass.shaderUniforms[CCShaderUniformTexCoord1Center] = [NSValue valueWithGLKVector2:pass.texCoord1Center];
        pass.shaderUniforms[CCShaderUniformTexCoord1Extents] = [NSValue valueWithGLKVector2:pass.texCoord1Extents];
        
        // Get the transform from the light's coordinate space to the effect's coordinate space.
        GLKMatrix4 lightNodeToEffectNode = weakSelf.light ? CCEffectUtilsTransformFromNodeToNode(weakSelf.light, pass.node, nil) : GLKMatrix4Identity;
        
        // Compute the light's position in the effect node's coordinate system.
        GLKVector4 lightPosition = GLKMatrix4MultiplyVector4(lightNodeToEffectNode, GLKVector4Make(weakSelf.light.anchorPointInPoints.x, weakSelf.light.anchorPointInPoints.y, 500.0f, 1.0f));
        
        GLKVector4 lightColor = GLKVector4MultiplyScalar(weakSelf.light.color.glkVector4, weakSelf.light.intensity);
        GLKVector4 ambientColor = GLKVector4MultiplyScalar(weakSelf.light.ambientColor.glkVector4, weakSelf.light.ambientIntensity);
        
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_lightColor"]] = [NSValue valueWithGLKVector4:lightColor];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_lightPosition"]] = [NSValue valueWithGLKVector4:lightPosition];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_ambientColor"]] = [NSValue valueWithGLKVector4:ambientColor];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_ndcToTangentSpace"]] = [NSValue valueWithGLKMatrix4:pass.ndcToNodeLocal];
        
    } copy]];
    
    self.renderPasses = @[pass0];
}

@end

