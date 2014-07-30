//
//  CCEffectGlass.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/15/14.
//
//

#import "CCEffectGlass.h"

#import "CCDirector.h"
#import "CCEffectUtils.h"
#import "CCRenderer.h"
#import "CCSpriteFrame.h"
#import "CCTexture.h"

#import "CCEffect_Private.h"
#import "CCSprite_Private.h"


@interface CCEffectGlass ()

@property (nonatomic) float conditionedRefraction;

@end


@implementation CCEffectGlass

-(id)init
{
    return [self initWithRefraction:1.0f refractionEnvironment:nil reflectionEnvironment:nil normalMap:nil];
}

-(id)initWithRefraction:(float)refraction refractionEnvironment:(CCSprite *)refractionEnvironment reflectionEnvironment:(CCSprite *)reflectionEnvironment
{
    return [self initWithRefraction:refraction refractionEnvironment:refractionEnvironment reflectionEnvironment:reflectionEnvironment normalMap:nil];
}

-(id)initWithRefraction:(float)refraction refractionEnvironment:(CCSprite *)refractionEnvironment reflectionEnvironment:(CCSprite *)reflectionEnvironment normalMap:(CCSpriteFrame *)normalMap
{
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"float" name:@"u_refraction" value:[NSNumber numberWithFloat:1.0f]],
                          
                          [CCEffectUniform uniform:@"float" name:@"u_fresnelBias" value:[NSNumber numberWithFloat:0.0f]],
                          [CCEffectUniform uniform:@"float" name:@"u_fresnelPower" value:[NSNumber numberWithFloat:0.0f]],
                          
                          [CCEffectUniform uniform:@"sampler2D" name:@"u_refractEnvMap" value:(NSValue*)[CCTexture none]],
                          [CCEffectUniform uniform:@"mat4" name:@"u_screenToRefractEnv" value:[NSValue valueWithGLKMatrix4:GLKMatrix4Identity]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_refractTangent" value:[NSValue valueWithGLKVector2:GLKVector2Make(1.0f, 0.0f)]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_refractBinormal" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 1.0f)]],

                          [CCEffectUniform uniform:@"sampler2D" name:@"u_reflectEnvMap" value:(NSValue*)[CCTexture none]],
                          [CCEffectUniform uniform:@"mat4" name:@"u_screenToReflectEnv" value:[NSValue valueWithGLKMatrix4:GLKMatrix4Identity]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_reflectTangent" value:[NSValue valueWithGLKVector2:GLKVector2Make(1.0f, 0.0f)]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_reflectBinormal" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 1.0f)]],
                          
                          ];
    
    if((self = [super initWithFragmentUniforms:uniforms vertexUniforms:nil varying:nil]))
    {
        _refraction = refraction;
        _fresnelBias = 0.1f;
        _fresnelPower = 2.0f;
        _conditionedRefraction = CCEffectUtilsConditionRefraction(refraction);
        _refractionEnvironment = refractionEnvironment;
        _reflectionEnvironment = reflectionEnvironment;
        _normalMap = normalMap;
        
        self.debugName = @"CCEffectGlass";
    }
    return self;
}
+(id)effectWithRefraction:(float)refraction refractionEnvironment:(CCSprite *)refractionEnvironment reflectionEnvironment:(CCSprite *)reflectionEnvironment
{
    return [[self alloc] initWithRefraction:refraction refractionEnvironment:refractionEnvironment reflectionEnvironment:reflectionEnvironment];
}

+(id)effectWithRefraction:(float)refraction refractionEnvironment:(CCSprite *)refractionEnvironment reflectionEnvironment:(CCSprite *)reflectionEnvironment normalMap:(CCSpriteFrame *)normalMap
{
    return [[self alloc] initWithRefraction:refraction refractionEnvironment:refractionEnvironment reflectionEnvironment:reflectionEnvironment normalMap:normalMap];
}

-(void)buildFragmentFunctions
{
    self.fragmentFunctions = [[NSMutableArray alloc] init];
    
    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue" snippet:@"cc_FragColor * texture2D(cc_PreviousPassTexture, cc_FragTexCoord1)"];
    
    NSString* effectBody = CC_GLSL(
                                   // Index the normal map and expand the color value from [0..1] to [-1..1]
                                   vec4 normalMap = texture2D(cc_NormalMapTexture, cc_FragTexCoord2);
                                   vec4 tangentSpaceNormal = normalMap * 2.0 - 1.0;
                                   

                                   
                                   // Compute environment space texture coordinates from the screen space
                                   // fragment position.
                                   vec4 refractEnvSpaceTexCoords = u_screenToRefractEnv * gl_FragCoord;
                                   
                                   // Convert the normal vector from tangent space to environment space
                                   vec3 refractNormal = normalize(vec3(u_refractTangent * tangentSpaceNormal.x + u_refractBinormal * tangentSpaceNormal.y, tangentSpaceNormal.z));
                                   vec3 refractOffset = refract(vec3(0,0,1), refractNormal, 1.0) * u_refraction;
                                   
                                   // Perturb the screen space texture coordinate by the scaled normal
                                   // vector.
                                   vec2 refractTexCoords = refractEnvSpaceTexCoords.xy + refractOffset.xy;
                                   
                                   // This is positive if refractTexCoords is in [0..1] and negative otherwise.
                                   vec2 compare = 0.5 - abs(refractTexCoords - 0.5);
                                   
                                   // This is 1.0 if both refracted texture coords are in bounds and 0.0 otherwise.
                                   float inBounds = step(0.0, min(compare.x, compare.y));
                                   
                                   
                                   
                                   // Compute environment space texture coordinates from the screen space
                                   // fragment position.
                                   vec4 reflectEnvSpaceTexCoords = u_screenToReflectEnv * gl_FragCoord;
                                   
                                   // Convert the normal vector from tangent space to environment space
                                   vec3 reflectNormal = normalize(vec3(u_reflectTangent * tangentSpaceNormal.x + u_reflectBinormal * tangentSpaceNormal.y, tangentSpaceNormal.z));
                                   
                                   float nDotV = dot(reflectNormal, vec3(0,0,1));
                                   vec3 reflectOffset = reflectNormal * pow(1.0 - nDotV, 3.0) / 8.0;
                                   
                                   // Perturb the screen space texture coordinate by the scaled normal
                                   // vector.
                                   vec2 reflectTexCoords = reflectEnvSpaceTexCoords.xy + reflectOffset.xy;
                                   
                                   // Feed the resulting coordinates through cos() so they reflect when
                                   // they would otherwise be outside of [0..1].
                                   const float M_PI = 3.14159265358979323846264338327950288;
                                   reflectTexCoords.x = (1.0 - cos(reflectTexCoords.x * M_PI)) * 0.5;
                                   reflectTexCoords.y = (1.0 - cos(reflectTexCoords.y * M_PI)) * 0.5;
                                   
                                   
                                   
                                   // Compute the combination of the sprite's color and texture.
                                   vec4 primaryColor = inputValue;
                                   
                                   // If the refracted texture coordinates are within the bounds of the environment map
                                   // blend the primary color with the refracted environment. Multiplying by the normal
                                   // map alpha also allows the effect to be disabled for specific pixels.
                                   vec4 refraction = normalMap.a * inBounds * texture2D(u_refractEnvMap, refractTexCoords) * (1.0 - primaryColor.a);
                                   
                                   // Add the reflected color modulated by the fresnel term. Multiplying by the normal
                                   // map alpha also allows the effect to be disabled for specific pixels.
                                   float fresnel = max(u_fresnelBias + (1.0 - u_fresnelBias) * pow((1.0 - nDotV), u_fresnelPower), 0.0);
                                   vec4 reflection = normalMap.a * fresnel * texture2D(u_reflectEnvMap, reflectTexCoords);

                                   return primaryColor + refraction + reflection;
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"glassEffect" body:effectBody inputs:@[input] returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectGlass *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectGlass pass 0";
    pass0.shader = self.shader;
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCTexture *previousPassTexture){
        
        pass.shaderUniforms[CCShaderUniformMainTexture] = previousPassTexture;
        pass.shaderUniforms[CCShaderUniformPreviousPassTexture] = previousPassTexture;
        if (weakSelf.normalMap)
        {
            pass.shaderUniforms[CCShaderUniformNormalMapTexture] = weakSelf.normalMap.texture;
            
            CCSpriteTexCoordSet texCoords = [CCSprite textureCoordsForTexture:weakSelf.normalMap.texture withRect:weakSelf.normalMap.rect rotated:weakSelf.normalMap.rotated xFlipped:NO yFlipped:NO];
            CCSpriteVertexes verts = pass.verts;
            verts.bl.texCoord2 = texCoords.bl;
            verts.br.texCoord2 = texCoords.br;
            verts.tr.texCoord2 = texCoords.tr;
            verts.tl.texCoord2 = texCoords.tl;
            pass.verts = verts;
        }
        
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_refraction"]] = [NSNumber numberWithFloat:weakSelf.conditionedRefraction];
        
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_fresnelBias"]] = [NSNumber numberWithFloat:weakSelf.fresnelBias];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_fresnelPower"]] = [NSNumber numberWithFloat:weakSelf.fresnelPower];
        
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_refractEnvMap"]] = weakSelf.refractionEnvironment.texture ?: [CCTexture none];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_reflectEnvMap"]] = weakSelf.reflectionEnvironment.texture ?: [CCTexture none];
        
        
        CGFloat scale = [CCDirector sharedDirector].contentScaleFactor;
        CGAffineTransform screenToWorld = CGAffineTransformMake(1.0f / scale, 0.0f, 0.0f, 1.0f / scale, 0.0f, 0.0f);

        
        
        // Setup the screen space to refract environment space matrix.
        CGAffineTransform worldToRefractEnvTexture =  CCEffectUtilsWorldToEnvironmentTransform(weakSelf.refractionEnvironment);
        CGAffineTransform screenToRefractEnvTexture = CGAffineTransformConcat(screenToWorld, worldToRefractEnvTexture);
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_screenToRefractEnv"]] = [NSValue valueWithGLKMatrix4:CCEffectUtilsMat4FromAffineTransform(screenToRefractEnvTexture)];
        
        // Setup the screen space to reflect environment space matrix.
        CGAffineTransform worldToReflectEnvTexture = CCEffectUtilsWorldToEnvironmentTransform(weakSelf.reflectionEnvironment);
        CGAffineTransform screenToReflectEnvTexture = CGAffineTransformConcat(screenToWorld, worldToReflectEnvTexture);
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_screenToReflectEnv"]] = [NSValue valueWithGLKMatrix4:CCEffectUtilsMat4FromAffineTransform(screenToReflectEnvTexture)];
        
        // Setup the tangent and binormal vectors for the refraction environment
        GLKVector4 refractTangent = CCEffectUtilsTangentInEnvironmentSpace(pass.transform, CCEffectUtilsMat4FromAffineTransform(worldToRefractEnvTexture));
        GLKVector4 refractNormal = GLKVector4Make(0.0f, 0.0f, 1.0f, 1.0f);
        GLKVector4 refractBinormal = GLKVector4CrossProduct(refractNormal, refractTangent);
        
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_refractTangent"]] = [NSValue valueWithGLKVector2:GLKVector2Make(refractTangent.x, refractTangent.y)];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_refractBinormal"]] = [NSValue valueWithGLKVector2:GLKVector2Make(refractBinormal.x, refractBinormal.y)];

        
        
        // Setup the tangent and binormal vectors for the reflection environment.
        GLKVector4 reflectTangent = CCEffectUtilsTangentInEnvironmentSpace(pass.transform, CCEffectUtilsMat4FromAffineTransform(worldToReflectEnvTexture));
        GLKVector4 reflectNormal = GLKVector4Make(0.0f, 0.0f, 1.0f, 1.0f);
        GLKVector4 reflectBinormal = GLKVector4CrossProduct(reflectNormal, reflectTangent);
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_reflectTangent"]] = [NSValue valueWithGLKVector2:GLKVector2Make(reflectTangent.x, reflectTangent.y)];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_reflectBinormal"]] = [NSValue valueWithGLKVector2:GLKVector2Make(reflectBinormal.x, reflectBinormal.y)];

    } copy]];
    
    self.renderPasses = @[pass0];
}

-(void)setRefraction:(float)refraction
{
    _refraction = refraction;
    _conditionedRefraction = CCEffectUtilsConditionRefraction(refraction);
}
@end
