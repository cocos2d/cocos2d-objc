//
//  CCEffectRefraction.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 6/19/14.
//
//

#import "CCEffectRefraction.h"

#import "CCEffect_Private.h"
#import "CCRenderer.h"
#import "CCTexture.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
@implementation CCEffectRefraction

-(id)init
{
    CCEffectUniform* uniformRefraction = [CCEffectUniform uniform:@"float" name:@"u_refraction" value:[NSNumber numberWithFloat:1.0f]];
    CCEffectUniform* uniformEnvMap = [CCEffectUniform uniform:@"sampler2D" name:@"u_envMap" value:(NSValue*)[CCTexture none]];
    CCEffectUniform* uniformNormalMap = [CCEffectUniform uniform:@"sampler2D" name:@"u_normalMap" value:(NSValue*)[CCTexture none]];
    CCEffectUniform* uniformTangent = [CCEffectUniform uniform:@"vec2" name:@"u_tangent" value:[NSValue valueWithGLKVector2:GLKVector2Make(1.0f, 0.0f)]];
    CCEffectUniform* uniformBinormal = [CCEffectUniform uniform:@"vec2" name:@"u_binormal" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 1.0f)]];
    
    if((self = [super initWithFragmentUniforms:@[uniformRefraction, uniformEnvMap, uniformNormalMap, uniformTangent, uniformBinormal] vertextUniforms:nil varying:nil]))
    {
        self.debugName = @"CCEffectRefraction";
        return self;
    }
    return self;
}

-(id)initWithRefraction:(float)refraction environmentMap:(CCTexture *)envMap normalMap:(CCTexture *)normalMap;
{
    if((self = [self init]))
    {
        _refraction = refraction;
        _envMap = envMap;
        _normalMap = normalMap;
    }
    return self;
}

+(id)effectWithRefraction:(float)refraction environmentMap:(CCTexture *)envMap normalMap:(CCTexture *)normalMap;
{
    return [[self alloc] initWithRefraction:refraction environmentMap:envMap normalMap:normalMap];
}

-(void)buildFragmentFunctions
{
    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue" snippet:@"texture2D(cc_PreviousPassTexture, cc_FragTexCoord1)"];
    
    NSString* effectBody = CC_GLSL(
                                   // Compute screen space texture coordinates from the screen space
                                   // fragment position.
                                   highp vec2 texCoordOffset = vec2(-88.0, 44.0);
                                   highp vec2 texCoordScale = vec2(1.0 / 960.0, 1.0 / 640.0);
                                   vec2 screenTexCoords = (gl_FragCoord.xy + texCoordOffset) * texCoordScale;

                                   // Index the normal map and expand the color value from [0..1] to [-1..1]
                                   vec4 tangentSpaceNormal = texture2D(u_normalMap, cc_FragTexCoord1) * 2.0 - 1.0;
                                   
                                   // Convert the normal vector from tangent space to screen space
                                   vec2 normal = u_tangent * tangentSpaceNormal.x + u_binormal * tangentSpaceNormal.y;
                                   
                                   // Perturb the screen space texture coordinate by the scaled normal
                                   // vector.
                                   vec2 refractTexCoords = screenTexCoords + normal.xy * u_refraction;
                                   
                                   return texture2D(u_envMap, refractTexCoords);
//                                   return vec4(refractTexCoords, 0.0, 1.0);
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"refractionEffect" body:effectBody inputs:@[input] returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectRefraction *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.shader = self.shader;
    pass0.shaderUniforms = self.shaderUniforms;
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCTexture *previousPassTexture){
        pass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTexture;
        pass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        pass.shaderUniforms[self.uniformTranslationTable[@"u_refraction"]] = [NSNumber numberWithFloat:weakSelf.refraction];
        pass.shaderUniforms[self.uniformTranslationTable[@"u_envMap"]] = weakSelf.envMap;
        pass.shaderUniforms[self.uniformTranslationTable[@"u_normalMap"]] = weakSelf.normalMap;
        
        GLKVector4 tangent = GLKVector4Make(1.0f, 0.0f, 0.0f, 0.0f);
        tangent = GLKMatrix4MultiplyVector4(pass.transform, tangent);
        tangent = GLKVector4Normalize(tangent);
        
        GLKVector4 normal = GLKVector4Make(0.0f, 0.0f, 1.0f, 1.0f);
        GLKVector4 binormal = GLKVector4CrossProduct(normal, tangent);
        
        pass.shaderUniforms[self.uniformTranslationTable[@"u_tangent"]] = [NSValue valueWithGLKVector2:GLKVector2Make(tangent.x, tangent.y)];
        pass.shaderUniforms[self.uniformTranslationTable[@"u_binormal"]] = [NSValue valueWithGLKVector2:GLKVector2Make(binormal.x, binormal.y)];
        
    } copy]];
    
    self.renderPasses = @[pass0];
}

@end

#endif
