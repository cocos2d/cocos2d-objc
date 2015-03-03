//
//  CCEffectReflection.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/14/14.
//
//

#import "CCEffectReflection.h"

#import "CCDirector.h"
#import "CCEffectUtils.h"
#import "CCRenderer.h"
#import "CCSpriteFrame.h"
#import "CCTexture.h"

#import "CCEffect_Private.h"
#import "CCSprite_Private.h"



@interface CCEffectReflection ()
@property (nonatomic, assign) float conditionedShininess;
@property (nonatomic, assign) float conditionedFresnelBias;
@property (nonatomic, assign) float conditionedFresnelPower;
@end


@interface CCEffectReflectionImpl : CCEffectImpl
@property (nonatomic, weak) CCEffectReflection *interface;
@end

@implementation CCEffectReflectionImpl

-(id)initWithInterface:(CCEffectReflection *)interface
{
    NSArray *fragUniforms = @[
                              [CCEffectUniform uniform:@"float" name:@"u_shininess" value:[NSNumber numberWithFloat:1.0f]],
                              [CCEffectUniform uniform:@"float" name:@"u_fresnelBias" value:[NSNumber numberWithFloat:1.0f]],
                              [CCEffectUniform uniform:@"float" name:@"u_fresnelPower" value:[NSNumber numberWithFloat:0.0f]],
                              [CCEffectUniform uniform:@"sampler2D" name:@"u_envMap" value:(NSValue*)[CCTexture none]],
                              [CCEffectUniform uniform:@"vec2" name:@"u_tangent" value:[NSValue valueWithGLKVector2:GLKVector2Make(1.0f, 0.0f)]],
                              [CCEffectUniform uniform:@"vec2" name:@"u_binormal" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 1.0f)]],
                              ];
    
    NSArray *vertUniforms = @[
                              [CCEffectUniform uniform:@"mat4" name:@"u_ndcToEnv" value:[NSValue valueWithGLKMatrix4:GLKMatrix4Identity]]
                              ];
    
    NSArray *varyings = @[
                          [CCEffectVarying varying:@"vec2" name:@"v_envSpaceTexCoords"]
                         ];
    
    NSArray *fragFunctions = [CCEffectReflectionImpl buildFragmentFunctions];
    NSArray *vertFunctions = [CCEffectReflectionImpl buildVertexFunctions];
    NSArray *renderPasses = [CCEffectReflectionImpl buildRenderPassesWithInterface:interface];
    
    if((self = [super initWithRenderPasses:renderPasses fragmentFunctions:fragFunctions vertexFunctions:vertFunctions fragmentUniforms:fragUniforms vertexUniforms:vertUniforms varyings:varyings]))
    {
        self.interface = interface;
        self.debugName = @"CCEffectReflectionImpl";
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
                                   vec3 normal = normalize(vec3(u_tangent * tangentSpaceNormal.x + u_binormal * tangentSpaceNormal.y, tangentSpaceNormal.z));
                                   
                                   float nDotV = dot(normal, vec3(0,0,1));
                                   vec2 reflectOffset = normal.xy * pow(1.0 - nDotV, 3.0) / 8.0;
                                   
                                   // Perturb the screen space texture coordinate by the scaled normal
                                   // vector.
                                   vec2 reflectTexCoords = v_envSpaceTexCoords + reflectOffset;

                                   // Feed the resulting coordinates through cos() so they reflect when
                                   // they would otherwise be outside of [0..1].
                                   const float M_PI = 3.14159265358979323846264338327950288;
                                   reflectTexCoords.x = (1.0 - cos(reflectTexCoords.x * M_PI)) * 0.5;
                                   reflectTexCoords.y = (1.0 - cos(reflectTexCoords.y * M_PI)) * 0.5;
                                   
                                   // Compute the combination of the sprite's color and texture.
                                   vec4 primaryColor = inputValue;
                                   
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

                                   // If the reflected texture coordinates are within the bounds of the environment map
                                   // blend the primary color with the reflected environment. Multiplying by the normal
                                   // map alpha also allows the effect to be disabled for specific pixels.
                                   primaryColor += normalMap.a * fresnel * u_shininess * texture2D(u_envMap, reflectTexCoords);
                                   return primaryColor;
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"reflectionEffectFrag" body:effectBody inputs:@[input] returnType:@"vec4"];
    return @[fragmentFunction];
}

+ (NSArray *)buildVertexFunctions
{
    NSString* effectBody = CC_GLSL(
                                   // Compute environment space texture coordinates from the vertex positions.
                                   vec4 envSpaceTexCoords = u_ndcToEnv * cc_Position;
                                   v_envSpaceTexCoords = envSpaceTexCoords.xy;
                                   return cc_Position;
                                   );
    
    CCEffectFunction *vertexFunction = [[CCEffectFunction alloc] initWithName:@"reflectionEffectVtx" body:effectBody inputs:nil returnType:@"vec4"];
    return @[vertexFunction];
}

+ (NSArray *)buildRenderPassesWithInterface:(CCEffectReflection *)interface
{
    __weak CCEffectReflection *weakInterface = interface;

    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectReflection pass 0";
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
            passInputs.verts = verts;
        }
        
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_shininess"]] = [NSNumber numberWithFloat:weakInterface.conditionedShininess];
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_fresnelBias"]] = [NSNumber numberWithFloat:weakInterface.conditionedFresnelBias];
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_fresnelPower"]] = [NSNumber numberWithFloat:weakInterface.conditionedFresnelPower];
        
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_envMap"]] = weakInterface.environment.texture ?: [CCTexture none];
        
        // Get the transform from the affected node's local coordinates to the environment node.
        GLKMatrix4 effectNodeToReflectEnvNode = weakInterface.environment ? CCEffectUtilsTransformFromNodeToNode(passInputs.sprite, weakInterface.environment, nil) : GLKMatrix4Identity;
        
        // Concatenate the node to environment transform with the environment node to environment texture transform.
        // The result takes us from the affected node's coordinates to the environment's texture coordinates. We need
        // this when computing the tangent and normal vectors below.
        GLKMatrix4 effectNodeToReflectEnvTexture = GLKMatrix4Multiply(CCEffectUtilsMat4FromAffineTransform(weakInterface.environment.nodeToTextureTransform), effectNodeToReflectEnvNode);
        
        // Concatenate the node to environment texture transform together with the transform from NDC to local node
        // coordinates. (NDC == normalized device coordinates == render target coordinates that are normalized to the
        // range 0..1). The shader uses this to map from NDC directly to environment texture coordinates.
        GLKMatrix4 ndcToReflectEnvTexture = GLKMatrix4Multiply(effectNodeToReflectEnvTexture, passInputs.ndcToNodeLocal);
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_ndcToEnv"]] = [NSValue valueWithGLKMatrix4:ndcToReflectEnvTexture];
        
        // Setup the tangent and binormal vectors for the reflection environment
        GLKVector4 reflectTangent = GLKVector4Normalize(GLKMatrix4MultiplyVector4(effectNodeToReflectEnvTexture, GLKVector4Make(1.0f, 0.0f, 0.0f, 0.0f)));
        GLKVector4 reflectNormal = GLKVector4Make(0.0f, 0.0f, 1.0f, 1.0f);
        GLKVector4 reflectBinormal = GLKVector4CrossProduct(reflectNormal, reflectTangent);
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_tangent"]] = [NSValue valueWithGLKVector2:GLKVector2Make(reflectTangent.x, reflectTangent.y)];
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_binormal"]] = [NSValue valueWithGLKVector2:GLKVector2Make(reflectBinormal.x, reflectBinormal.y)];
        
    }]];
    
    return @[pass0];
}

@end


@implementation CCEffectReflection

-(id)init
{
    return [self initWithShininess:1.0f environment:nil];
}

-(id)initWithShininess:(float)shininess environment:(CCSprite *)environment
{
    return [self initWithShininess:shininess environment:environment normalMap:nil];
}

-(id)initWithShininess:(float)shininess environment:(CCSprite *)environment normalMap:(CCSpriteFrame *)normalMap
{
    return [self initWithShininess:shininess fresnelBias:1.0f fresnelPower:0.0f environment:environment normalMap:normalMap];
}

-(id)initWithShininess:(float)shininess fresnelBias:(float)bias fresnelPower:(float)power environment:(CCSprite *)environment
{
    return [self initWithShininess:shininess fresnelBias:bias fresnelPower:power environment:environment normalMap:nil];
}

-(id)initWithShininess:(float)shininess fresnelBias:(float)bias fresnelPower:(float)power environment:(CCSprite *)environment normalMap:(CCSpriteFrame *)normalMap
{
    if((self = [super init]))
    {
        _shininess = shininess;
        _fresnelBias = bias;
        _fresnelPower = power;
        _environment = environment;
        _normalMap = normalMap;
        
        _conditionedShininess = CCEffectUtilsConditionShininess(_shininess);
        _conditionedFresnelBias = CCEffectUtilsConditionFresnelBias(_fresnelBias);
        _conditionedFresnelPower = CCEffectUtilsConditionFresnelPower(_fresnelPower);
        
        self.effectImpl = [[CCEffectReflectionImpl alloc] initWithInterface:self];
        self.debugName = @"CCEffectReflection";
    }
    return self;
}

+(instancetype)effectWithShininess:(float)shininess environment:(CCSprite *)environment
{
    return [[self alloc] initWithShininess:shininess environment:environment];
}

+(instancetype)effectWithShininess:(float)shininess environment:(CCSprite *)environment normalMap:(CCSpriteFrame *)normalMap
{
    return [[self alloc] initWithShininess:shininess environment:environment normalMap:normalMap];
}

+(instancetype)effectWithShininess:(float)shininess fresnelBias:(float)bias fresnelPower:(float)power environment:(CCSprite *)environment
{
    return [[self alloc] initWithShininess:shininess fresnelBias:bias fresnelPower:power environment:environment];
}

+(instancetype)effectWithShininess:(float)shininess fresnelBias:(float)bias fresnelPower:(float)power environment:(CCSprite *)environment normalMap:(CCSpriteFrame *)normalMap
{
    return [[self alloc] initWithShininess:shininess fresnelBias:bias fresnelPower:power environment:environment normalMap:normalMap];
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


