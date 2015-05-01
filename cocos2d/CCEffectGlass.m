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


static const float CCEffectGlassDefaultFresnelBias = 0.1f;
static const float CCEffectGlassDefaultFresnelPower = 2.0f;


@interface CCEffectGlass ()
@property (nonatomic, assign) float conditionedRefraction;
@property (nonatomic, assign) float conditionedShininess;
@property (nonatomic, assign) float conditionedFresnelBias;
@property (nonatomic, assign) float conditionedFresnelPower;
@end


@interface CCEffectGlassImpl : CCEffectImpl
@property (nonatomic, weak) CCEffectGlass *interface;
@end

@implementation CCEffectGlassImpl

-(id)initWithInterface:(CCEffectGlass *)interface
{
    NSArray *fragUniforms = @[
                              [CCEffectUniform uniform:@"float" name:@"u_refraction" value:[NSNumber numberWithFloat:1.0f]],
                              
                              [CCEffectUniform uniform:@"float" name:@"u_shininess" value:[NSNumber numberWithFloat:1.0f]],
                              [CCEffectUniform uniform:@"float" name:@"u_fresnelBias" value:[NSNumber numberWithFloat:0.0f]],
                              [CCEffectUniform uniform:@"float" name:@"u_fresnelPower" value:[NSNumber numberWithFloat:0.0f]],
                              
                              [CCEffectUniform uniform:@"sampler2D" name:@"u_refractEnvMap" value:(NSValue*)[CCTexture none]],
                              [CCEffectUniform uniform:@"vec2" name:@"u_refractTangent" value:[NSValue valueWithGLKVector2:GLKVector2Make(1.0f, 0.0f)]],
                              [CCEffectUniform uniform:@"vec2" name:@"u_refractBinormal" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 1.0f)]],
                              
                              [CCEffectUniform uniform:@"sampler2D" name:@"u_reflectEnvMap" value:(NSValue*)[CCTexture none]],
                              [CCEffectUniform uniform:@"vec2" name:@"u_reflectTangent" value:[NSValue valueWithGLKVector2:GLKVector2Make(1.0f, 0.0f)]],
                              [CCEffectUniform uniform:@"vec2" name:@"u_reflectBinormal" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 1.0f)]],
                              
                          ];
    
    NSArray *vertUniforms = @[
                              [CCEffectUniform uniform:@"mat4" name:@"u_ndcToReflectEnv" value:[NSValue valueWithGLKMatrix4:GLKMatrix4Identity]],
                              [CCEffectUniform uniform:@"mat4" name:@"u_ndcToRefractEnv" value:[NSValue valueWithGLKMatrix4:GLKMatrix4Identity]]
                              ];
    
    NSArray *varyings = @[
                          [CCEffectVarying varying:@"vec2" name:@"v_refractEnvSpaceTexCoords"],
                          [CCEffectVarying varying:@"vec2" name:@"v_reflectEnvSpaceTexCoords"]
                          ];
    
    NSArray *fragFunctions = [CCEffectGlassImpl buildFragmentFunctions];
    NSArray *vertFunctions = [CCEffectGlassImpl buildVertexFunctions];
    NSArray *renderPasses = [CCEffectGlassImpl buildRenderPassesWithInterface:interface];
    
    if((self = [super initWithRenderPasses:renderPasses fragmentFunctions:fragFunctions vertexFunctions:vertFunctions fragmentUniforms:fragUniforms vertexUniforms:vertUniforms varyings:varyings]))
    {
        self.interface = interface;
        self.debugName = @"CCEffectGlass";
    }
    return self;
}

+ (NSArray *)buildFragmentFunctions
{
    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue" initialSnippet:CCEffectDefaultInitialInputSnippet snippet:CCEffectDefaultInputSnippet];
    
    NSString* effectBody = CC_GLSL(
                                   const float EPSILON = 0.000001;
                                   
                                   // Index the normal map and expand the color value from [0..1] to [-1..1]
                                   vec4 normalMap = texture2D(cc_NormalMapTexture, cc_FragTexCoord2);
                                   vec4 tangentSpaceNormal = normalMap * 2.0 - 1.0;
                                   

                                   // Convert the normal vector from tangent space to environment space
                                   vec3 refractNormal = normalize(vec3(u_refractTangent * tangentSpaceNormal.x + u_refractBinormal * tangentSpaceNormal.y, tangentSpaceNormal.z));
                                   vec2 refractOffset = refract(vec3(0,0,1), refractNormal, 1.0).xy * u_refraction;
                                   
                                   // Perturb the screen space texture coordinate by the scaled normal
                                   // vector.
                                   vec2 refractTexCoords = v_refractEnvSpaceTexCoords + refractOffset;
                                   
                                   // This is positive if refractTexCoords is in [0..1] and negative otherwise.
                                   vec2 compare = 0.5 - abs(refractTexCoords - 0.5);
                                   
                                   // This is 1.0 if both refracted texture coords are in bounds and 0.0 otherwise.
                                   float inBounds = step(0.0, min(compare.x, compare.y));
                                   
                                   
                                   
                                   // Convert the normal vector from tangent space to environment space
                                   vec3 reflectNormal = normalize(vec3(u_reflectTangent * tangentSpaceNormal.x + u_reflectBinormal * tangentSpaceNormal.y, tangentSpaceNormal.z));
                                   
                                   float nDotV = dot(reflectNormal, vec3(0,0,1));
                                   vec2 reflectOffset = reflectNormal.xy * pow(1.0 - nDotV, 3.0) / 8.0;
                                   
                                   // Perturb the screen space texture coordinate by the scaled normal
                                   // vector.
                                   vec2 reflectTexCoords = v_reflectEnvSpaceTexCoords + reflectOffset;
                                   
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
                                   
                                   // Compute Schlick's approximation (http://en.wikipedia.org/wiki/Schlick's_approximation) of the
                                   // fresnel reflectance.
                                   float fresnel = clamp(u_fresnelBias + (1.0 - u_fresnelBias) * pow(max((1.0 - nDotV), EPSILON), u_fresnelPower), 0.0, 1.0);
                                   
                                   // Apply a cutoff to nDotV to reduce the aliasing that occurs in the reflected
                                   // image. As the surface normal approaches a 90 degree angle relative to the viewing
                                   // direction, the sampling of the reflection map becomes more and more compressed
                                   // which can lead to undesirable aliasing artifacts. The cutoff threshold reduces
                                   // the contribution of these pixels to the final image and hides this aliasing.
                                   const float NDOTV_CUTOFF = 0.2;
                                   fresnel *= smoothstep(0.0, NDOTV_CUTOFF, nDotV);
                                   
                                   // Add the reflected color modulated by the fresnel term. Multiplying by the normal
                                   // map alpha also allows the effect to be disabled for specific pixels.
                                   vec4 reflection = normalMap.a * fresnel * u_shininess * texture2D(u_reflectEnvMap, reflectTexCoords);

                                   return primaryColor + refraction + reflection;
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"glassEffectFrag" body:effectBody inputs:@[input] returnType:@"vec4"];
    return @[fragmentFunction];
}

+ (NSArray *)buildVertexFunctions
{
    NSString* effectBody = CC_GLSL(
                                   // Compute environment space texture coordinates from the vertex positions.
                                   
                                   // Reflect space coords
                                   vec4 reflectEnvSpaceTexCoords = u_ndcToReflectEnv * cc_Position;
                                   v_reflectEnvSpaceTexCoords = reflectEnvSpaceTexCoords.xy;

                                   // Refract space coords
                                   vec4 refractEnvSpaceTexCoords = u_ndcToRefractEnv * cc_Position;
                                   v_refractEnvSpaceTexCoords = refractEnvSpaceTexCoords.xy;
                                   
                                   return cc_Position;
                                   );
    
    CCEffectFunction *vertexFunction = [[CCEffectFunction alloc] initWithName:@"glassEffectVtx" body:effectBody inputs:nil returnType:@"vec4"];
    return @[vertexFunction];
}

+ (NSArray *)buildRenderPassesWithInterface:(CCEffectGlass *)interface
{
    __weak CCEffectGlass *weakInterface = interface;

    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectGlass pass 0";
    pass0.beginBlocks = @[[[CCEffectRenderPassBeginBlockContext alloc] initWithBlock:^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){
        
        passInputs.shaderUniforms[CCShaderUniformMainTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Center] = [NSValue valueWithGLKVector2:passInputs.texCoord1Center];
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Extents] = [NSValue valueWithGLKVector2:passInputs.texCoord1Extents];

        if (weakInterface.normalMap)
        {
            passInputs.shaderUniforms[CCShaderUniformNormalMapTexture] = weakInterface.normalMap.texture;
            
            CCSpriteTexCoordSet texCoords = [CCSprite textureCoordsForTexture:weakInterface.normalMap.texture withRect:weakInterface.normalMap.rect rotated:weakInterface.normalMap.rotated xFlipped:NO yFlipped:NO];
            CCSpriteVertexes verts = passInputs.verts;
            verts.bl.texCoord2 = texCoords.bl;
            verts.br.texCoord2 = texCoords.br;
            verts.tr.texCoord2 = texCoords.tr;
            verts.tl.texCoord2 = texCoords.tl;            
            [passInputs setVertsWorkAround:&verts];
        }
        
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_refraction"]] = [NSNumber numberWithFloat:weakInterface.conditionedRefraction];
        
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_shininess"]] = [NSNumber numberWithFloat:weakInterface.conditionedShininess];
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_fresnelBias"]] = [NSNumber numberWithFloat:weakInterface.conditionedFresnelBias];
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_fresnelPower"]] = [NSNumber numberWithFloat:weakInterface.conditionedFresnelPower];
        
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_refractEnvMap"]] = weakInterface.refractionEnvironment.texture ?: [CCTexture none];
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_reflectEnvMap"]] = weakInterface.reflectionEnvironment.texture ?: [CCTexture none];
        
        
        
        // Get the transform from the affected node's local coordinates to the environment node.
        GLKMatrix4 effectNodeToRefractEnvNode = weakInterface.refractionEnvironment ? CCEffectUtilsTransformFromNodeToNode(passInputs.sprite, weakInterface.refractionEnvironment, nil) : GLKMatrix4Identity;
        
        // Concatenate the node to environment transform with the environment node to environment texture transform.
        // The result takes us from the affected node's coordinates to the environment's texture coordinates. We need
        // this when computing the tangent and normal vectors below.
        GLKMatrix4 effectNodeToRefractEnvTexture = GLKMatrix4Multiply(CCEffectUtilsMat4FromAffineTransform(weakInterface.refractionEnvironment.nodeToTextureTransform), effectNodeToRefractEnvNode);
        
        // Concatenate the node to environment texture transform together with the transform from NDC to local node
        // coordinates. (NDC == normalized device coordinates == render target coordinates that are normalized to the
        // range 0..1). The shader uses this to map from NDC directly to environment texture coordinates.
        GLKMatrix4 ndcToRefractEnvTexture = GLKMatrix4Multiply(effectNodeToRefractEnvTexture, passInputs.ndcToNodeLocal);
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_ndcToRefractEnv"]] = [NSValue valueWithGLKMatrix4:ndcToRefractEnvTexture];
        
        // Setup the tangent and binormal vectors for the refraction environment
        GLKVector4 refractTangent = GLKVector4Normalize(GLKMatrix4MultiplyVector4(effectNodeToRefractEnvTexture, GLKVector4Make(1.0f, 0.0f, 0.0f, 0.0f)));
        GLKVector4 refractNormal = GLKVector4Make(0.0f, 0.0f, 1.0f, 1.0f);
        GLKVector4 refractBinormal = GLKVector4CrossProduct(refractNormal, refractTangent);
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_refractTangent"]] = [NSValue valueWithGLKVector2:GLKVector2Make(refractTangent.x, refractTangent.y)];
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_refractBinormal"]] = [NSValue valueWithGLKVector2:GLKVector2Make(refractBinormal.x, refractBinormal.y)];

        
        
        // Get the transform from the affected node's local coordinates to the environment node.
        GLKMatrix4 effectNodeToReflectEnvNode = weakInterface.reflectionEnvironment ? CCEffectUtilsTransformFromNodeToNode(passInputs.sprite, weakInterface.reflectionEnvironment, nil) : GLKMatrix4Identity;
        
        // Concatenate the node to environment transform with the environment node to environment texture transform.
        // The result takes us from the affected node's coordinates to the environment's texture coordinates. We need
        // this when computing the tangent and normal vectors below.
        GLKMatrix4 effectNodeToReflectEnvTexture = GLKMatrix4Multiply(CCEffectUtilsMat4FromAffineTransform(weakInterface.reflectionEnvironment.nodeToTextureTransform), effectNodeToReflectEnvNode);
        
        // Concatenate the node to environment texture transform together with the transform from NDC to local node
        // coordinates. (NDC == normalized device coordinates == render target coordinates that are normalized to the
        // range 0..1). The shader uses this to map from NDC directly to environment texture coordinates.
        GLKMatrix4 ndcToReflectEnvTexture = GLKMatrix4Multiply(effectNodeToReflectEnvTexture, passInputs.ndcToNodeLocal);
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_ndcToReflectEnv"]] = [NSValue valueWithGLKMatrix4:ndcToReflectEnvTexture];
        
        // Setup the tangent and binormal vectors for the reflection environment
        GLKVector4 reflectTangent = GLKVector4Normalize(GLKMatrix4MultiplyVector4(effectNodeToReflectEnvTexture, GLKVector4Make(1.0f, 0.0f, 0.0f, 0.0f)));
        GLKVector4 reflectNormal = GLKVector4Make(0.0f, 0.0f, 1.0f, 1.0f);
        GLKVector4 reflectBinormal = GLKVector4CrossProduct(reflectNormal, reflectTangent);
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_reflectTangent"]] = [NSValue valueWithGLKVector2:GLKVector2Make(reflectTangent.x, reflectTangent.y)];
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_reflectBinormal"]] = [NSValue valueWithGLKVector2:GLKVector2Make(reflectBinormal.x, reflectBinormal.y)];
        
        
    }]];
    
    return @[pass0];
}

@end



@implementation CCEffectGlass

-(id)init
{
    return [self initWithShininess:1.0f refraction:1.0f refractionEnvironment:nil reflectionEnvironment:nil normalMap:nil];
}

-(id)initWithShininess:(float)shininess refraction:(float)refraction refractionEnvironment:(CCSprite *)refractionEnvironment reflectionEnvironment:(CCSprite *)reflectionEnvironment
{
    return [self initWithShininess:shininess refraction:refraction refractionEnvironment:refractionEnvironment reflectionEnvironment:reflectionEnvironment normalMap:nil];
}

-(id)initWithShininess:(float)shininess refraction:(float)refraction refractionEnvironment:(CCSprite *)refractionEnvironment reflectionEnvironment:(CCSprite *)reflectionEnvironment normalMap:(CCSpriteFrame *)normalMap
{
    if((self = [super init]))
    {
        _refraction = refraction;
        _shininess = shininess;
        _fresnelBias = CCEffectGlassDefaultFresnelBias;
        _fresnelPower = CCEffectGlassDefaultFresnelPower;
        _refractionEnvironment = refractionEnvironment;
        _reflectionEnvironment = reflectionEnvironment;
        _normalMap = normalMap;
        
        _conditionedRefraction = CCEffectUtilsConditionRefraction(_refraction);
        _conditionedShininess = CCEffectUtilsConditionShininess(_shininess);
        _conditionedFresnelBias = CCEffectUtilsConditionFresnelBias(_fresnelBias);
        _conditionedFresnelPower = CCEffectUtilsConditionFresnelPower(_fresnelPower);

        self.effectImpl = [[CCEffectGlassImpl alloc] initWithInterface:self];
        self.debugName = @"CCEffectGlass";
    }
    return self;
}

+(instancetype)effectWithShininess:(float)shininess refraction:(float)refraction refractionEnvironment:(CCSprite *)refractionEnvironment reflectionEnvironment:(CCSprite *)reflectionEnvironment
{
    return [[self alloc] initWithShininess:shininess refraction:refraction refractionEnvironment:refractionEnvironment reflectionEnvironment:reflectionEnvironment];
}

+(instancetype)effectWithShininess:(float)shininess refraction:(float)refraction refractionEnvironment:(CCSprite *)refractionEnvironment reflectionEnvironment:(CCSprite *)reflectionEnvironment normalMap:(CCSpriteFrame *)normalMap
{
    return [[self alloc] initWithShininess:shininess refraction:refraction refractionEnvironment:refractionEnvironment reflectionEnvironment:reflectionEnvironment normalMap:normalMap];
}

-(void)setRefraction:(float)refraction
{
    _refraction = refraction;
    _conditionedRefraction = CCEffectUtilsConditionRefraction(refraction);
}

-(void)setShininess:(float)shininess
{
    _shininess = shininess;
    _conditionedShininess = CCEffectUtilsConditionShininess(shininess);
}

-(void)setFresnelBias:(float)bias
{
    _fresnelBias = bias;
    _conditionedFresnelBias = CCEffectUtilsConditionFresnelBias(bias);
}

-(void)setFresnelPower:(float)power
{
    _fresnelPower = power;
    _conditionedFresnelPower = CCEffectUtilsConditionFresnelPower(power);
}

@end
