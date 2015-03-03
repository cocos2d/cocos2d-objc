//
//  CCEffectRefraction.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 6/19/14.
//
//

#import "CCEffectRefraction.h"

#import "CCDirector.h"
#import "CCEffectUtils.h"
#import "CCRenderer.h"
#import "CCSpriteFrame.h"
#import "CCTexture.h"

#import "CCEffect_Private.h"
#import "CCSprite_Private.h"


@interface CCEffectRefraction ()
@property (nonatomic, assign) float conditionedRefraction;
@end


@interface CCEffectRefractionImpl : CCEffectImpl
@property (nonatomic, weak) CCEffectRefraction *interface;
@end


@implementation CCEffectRefractionImpl

-(id)initWithInterface:(CCEffectRefraction *)interface
{
    NSArray *fragUniforms = @[
                              [CCEffectUniform uniform:@"float" name:@"u_refraction" value:[NSNumber numberWithFloat:1.0f]],
                              [CCEffectUniform uniform:@"sampler2D" name:@"u_envMap" value:(NSValue*)[CCTexture none]],
                              [CCEffectUniform uniform:@"vec2" name:@"u_tangent" value:[NSValue valueWithGLKVector2:GLKVector2Make(1.0f, 0.0f)]],
                              [CCEffectUniform uniform:@"vec2" name:@"u_binormal" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 1.0f)]]
                              ];

    NSArray *vertUniforms = @[
                              [CCEffectUniform uniform:@"mat4" name:@"u_ndcToEnv" value:[NSValue valueWithGLKMatrix4:GLKMatrix4Identity]],
                              ];
    
    NSArray *varyings = @[
                          [CCEffectVarying varying:@"vec2" name:@"v_envSpaceTexCoords"],
                          ];
    
    NSArray *fragFunctions = [CCEffectRefractionImpl buildFragmentFunctions];
    NSArray *vertFunctions = [CCEffectRefractionImpl buildVertexFunctions];
    NSArray *renderPasses = [CCEffectRefractionImpl buildRenderPassesWithInterface:interface];
    
    if((self = [super initWithRenderPasses:renderPasses fragmentFunctions:fragFunctions vertexFunctions:vertFunctions fragmentUniforms:fragUniforms vertexUniforms:vertUniforms varyings:varyings]))
    {
        self.interface = interface;
        self.debugName = @"CCEffectRefractionImpl";
    }
    return self;
}

+ (NSArray *)buildFragmentFunctions
{
    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue" initialSnippet:CCEffectDefaultInitialInputSnippet snippet:CCEffectDefaultInputSnippet];

    NSString* effectBody = CC_GLSL(
                                   // Index the normal map and expand the color value from [0..1] to [-1..1]
                                   vec4 normalMap = texture2D(cc_NormalMapTexture, cc_FragTexCoord2);
                                   vec4 tangentSpaceNormal = normalMap * 2.0 - 1.0;
                                   
                                   // Convert the normal vector from tangent space to environment space
                                   vec3 normal = normalize(vec3(u_tangent * tangentSpaceNormal.x + u_binormal * tangentSpaceNormal.y, tangentSpaceNormal.z));
                                   vec2 refractOffset = refract(vec3(0,0,1), normal, 1.0).xy * u_refraction;
                                   
                                   // Perturb the screen space texture coordinate by the scaled normal
                                   // vector.
                                   vec2 refractTexCoords = v_envSpaceTexCoords + refractOffset;
                                   
                                   // This is positive if refractTexCoords is in [0..1] and negative otherwise.
                                   vec2 compare = 0.5 - abs(refractTexCoords - 0.5);
                                   
                                   // This is 1.0 if both refracted texture coords are in bounds and 0.0 otherwise.
                                   float inBounds = step(0.0, min(compare.x, compare.y));

                                   // Compute the combination of the sprite's color and texture.
                                   vec4 primaryColor = inputValue;

                                   // If the refracted texture coordinates are within the bounds of the environment map
                                   // blend the primary color with the refracted environment. Multiplying by the normal
                                   // map alpha also allows the effect to be disabled for specific pixels.
                                   primaryColor += inBounds * normalMap.a * texture2D(u_envMap, refractTexCoords) * (1.0 - primaryColor.a);
                                   
                                   return primaryColor;
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"refractionEffectFrag" body:effectBody inputs:@[input] returnType:@"vec4"];
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
    
    CCEffectFunction *vertexFunction = [[CCEffectFunction alloc] initWithName:@"refractionEffectVtx" body:effectBody inputs:nil returnType:@"vec4"];
    return @[vertexFunction];
}

+ (NSArray *)buildRenderPassesWithInterface:(CCEffectRefraction *)interface
{
    __weak CCEffectRefraction *weakInterface = interface;

    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectRefraction pass 0";
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
        
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_refraction"]] = [NSNumber numberWithFloat:weakInterface.conditionedRefraction];
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_envMap"]] = weakInterface.environment.texture ?: [CCTexture none];
        
        // Get the transform from the affected node's local coordinates to the environment node.
        GLKMatrix4 effectNodeToRefractEnvNode = weakInterface.environment ? CCEffectUtilsTransformFromNodeToNode(passInputs.sprite, weakInterface.environment, nil) : GLKMatrix4Identity;

        // Concatenate the node to environment transform with the environment node to environment texture transform.
        // The result takes us from the affected node's coordinates to the environment's texture coordinates. We need
        // this when computing the tangent and normal vectors below.
        GLKMatrix4 effectNodeToRefractEnvTexture = GLKMatrix4Multiply(CCEffectUtilsMat4FromAffineTransform(weakInterface.environment.nodeToTextureTransform), effectNodeToRefractEnvNode);

        // Concatenate the node to environment texture transform together with the transform from NDC to local node
        // coordinates. (NDC == normalized device coordinates == render target coordinates that are normalized to the
        // range 0..1). The shader uses this to map from NDC directly to environment texture coordinates.
        GLKMatrix4 ndcToRefractEnvTexture = GLKMatrix4Multiply(effectNodeToRefractEnvTexture, passInputs.ndcToNodeLocal);
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_ndcToEnv"]] = [NSValue valueWithGLKMatrix4:ndcToRefractEnvTexture];
        
        // Setup the tangent and binormal vectors for the refraction environment
        GLKVector4 refractTangent = GLKVector4Normalize(GLKMatrix4MultiplyVector4(effectNodeToRefractEnvTexture, GLKVector4Make(1.0f, 0.0f, 0.0f, 0.0f)));
        GLKVector4 refractNormal = GLKVector4Make(0.0f, 0.0f, 1.0f, 1.0f);
        GLKVector4 refractBinormal = GLKVector4CrossProduct(refractNormal, refractTangent);
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_tangent"]] = [NSValue valueWithGLKVector2:GLKVector2Make(refractTangent.x, refractTangent.y)];
        passInputs.shaderUniforms[passInputs.uniformTranslationTable[@"u_binormal"]] = [NSValue valueWithGLKVector2:GLKVector2Make(refractBinormal.x, refractBinormal.y)];
        
    }]];
    
    return @[pass0];
}

-(void)setRefraction:(float)refraction
{
}

@end


@implementation CCEffectRefraction

-(id)init
{
    return [self initWithRefraction:1.0f environment:nil normalMap:nil];
}

-(id)initWithRefraction:(float)refraction environment:(CCSprite *)environment
{
    return [self initWithRefraction:refraction environment:environment normalMap:nil];
}

-(id)initWithRefraction:(float)refraction environment:(CCSprite *)environment normalMap:(CCSpriteFrame *)normalMap
{
    if((self = [super init]))
    {
        _refraction = refraction;
        _environment = environment;
        _normalMap = normalMap;

        _conditionedRefraction = CCEffectUtilsConditionRefraction(refraction);
        
        self.effectImpl = [[CCEffectRefractionImpl alloc] initWithInterface:self];
        self.debugName = @"CCEffectRefraction";
    }
    return self;
}

+(instancetype)effectWithRefraction:(float)refraction environment:(CCSprite *)environment
{
    return [[self alloc] initWithRefraction:refraction environment:environment];
}

+(instancetype)effectWithRefraction:(float)refraction environment:(CCSprite *)environment normalMap:(CCSpriteFrame *)normalMap
{
    return [[self alloc] initWithRefraction:refraction environment:environment normalMap:normalMap];
}

-(void)setRefraction:(float)refraction
{
    _refraction = refraction;
    _conditionedRefraction = CCEffectUtilsConditionRefraction(refraction);
}

@end
