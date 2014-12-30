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
#import "CCLightCollection.h"
#import "CCLightGroups.h"
#import "CCLightNode.h"
#import "CCRenderer.h"
#import "CCScene.h"
#import "CCSpriteFrame.h"
#import "CCTexture.h"

#import "CCEffect_Private.h"
#import "CCSprite_Private.h"


typedef struct _CCLightKey
{
    NSUInteger pointLightMask;
    NSUInteger directionalLightMask;

} CCLightKey;

static const NSUInteger CCEffectLightingMaxLightCount = 8;

static CCLightKey CCLightKeyMake(NSArray *lights);
static BOOL CCLightKeyCompare(CCLightKey a, CCLightKey b);
static float conditionShininess(float shininess);


@interface CCEffectLighting ()
@property (nonatomic, strong) NSNumber *conditionedShininess;
@property (nonatomic, assign) CCLightGroupMask groupMask;
@property (nonatomic, assign) BOOL groupMaskDirty;
@property (nonatomic, copy) NSArray *closestLights;
@property (nonatomic, assign) CCLightKey lightKey;
@property (nonatomic, readonly) BOOL needsSpecular;
@property (nonatomic, readonly) BOOL needsNormalMap;
@property (nonatomic, assign) BOOL shaderHasSpecular;
@property (nonatomic, assign) BOOL shaderHasNormalMap;

@end


@interface CCEffectLightingImpl : CCEffectImpl
@property (nonatomic, weak) CCEffectLighting *interface;
@end


@implementation CCEffectLightingImpl

-(id)initWithInterface:(CCEffectLighting *)interface
{
    NSMutableArray *fragUniforms = [[NSMutableArray alloc] initWithArray:@[
                                                                           [CCEffectUniform uniform:@"vec4" name:@"u_globalAmbientColor" value:[NSValue valueWithGLKVector4:GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f)]],
                                                                           [CCEffectUniform uniform:@"vec2" name:@"u_worldSpaceTangent" value:[NSValue valueWithGLKVector2:GLKVector2Make(1.0f, 0.0f)]],
                                                                           [CCEffectUniform uniform:@"vec2" name:@"u_worldSpaceBinormal" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 1.0f)]]
                                                                           ]];
    NSMutableArray *vertUniforms = [[NSMutableArray alloc] initWithArray:@[
                                                                           [CCEffectUniform uniform:@"mat4" name:@"u_ndcToWorld" value:[NSValue valueWithGLKMatrix4:GLKMatrix4Identity]]
                                                                           ]];
    NSMutableArray *varyings = [[NSMutableArray alloc] init];
    
    for (NSUInteger lightIndex = 0; lightIndex < interface.closestLights.count; lightIndex++)
    {
        CCLightNode *light = interface.closestLights[lightIndex];
        
        [vertUniforms addObject:[CCEffectUniform uniform:@"vec3" name:[NSString stringWithFormat:@"u_lightVector%lu", (unsigned long)lightIndex] value:[NSValue valueWithGLKVector3:GLKVector3Make(0.0f, 0.0f, 0.0f)]]];
        [fragUniforms addObject:[CCEffectUniform uniform:@"vec4" name:[NSString stringWithFormat:@"u_lightColor%lu", (unsigned long)lightIndex] value:[NSValue valueWithGLKVector4:GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f)]]];
        if (interface.needsSpecular)
        {
            [fragUniforms addObject:[CCEffectUniform uniform:@"vec4" name:[NSString stringWithFormat:@"u_lightSpecularColor%lu", (unsigned long)lightIndex] value:[NSValue valueWithGLKVector4:GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f)]]];
        }
        
        if (light.type != CCLightDirectional)
        {
            [fragUniforms addObject:[CCEffectUniform uniform:@"vec4" name:[NSString stringWithFormat:@"u_lightFalloff%lu", (unsigned long)lightIndex] value:[NSValue valueWithGLKVector4:GLKVector4Make(-1.0f, 1.0f, -1.0f, 1.0f)]]];
        }
        
        [varyings addObject:[CCEffectVarying varying:@"highp vec3" name:[NSString stringWithFormat:@"v_worldSpaceLightDir%lu", (unsigned long)lightIndex]]];
    }
    
    if (interface.needsSpecular)
    {
        [fragUniforms addObject:[CCEffectUniform uniform:@"float" name:@"u_specularExponent" value:[NSNumber numberWithFloat:5.0f]]];
        [fragUniforms addObject:[CCEffectUniform uniform:@"vec4" name:@"u_specularColor" value:[NSValue valueWithGLKVector4:GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f)]]];
    }
    
    NSArray *fragFunctions = [CCEffectLightingImpl buildFragmentFunctionsWithLights:interface.closestLights normalMap:interface.needsNormalMap specular:interface.needsSpecular];
    NSArray *vertFunctions = [CCEffectLightingImpl buildVertexFunctionsWithLights:interface.closestLights];
    NSArray *renderPasses = [CCEffectLightingImpl buildRenderPassesWithInterface:interface];
    
    if((self = [super initWithRenderPasses:renderPasses fragmentFunctions:fragFunctions vertexFunctions:vertFunctions fragmentUniforms:fragUniforms vertexUniforms:vertUniforms varyings:varyings]))
    {
        self.interface = interface;
        self.debugName = @"CCEffectLightingImpl";
    }
    return self;
}

+(NSArray *)buildFragmentFunctionsWithLights:(NSArray*)lights normalMap:(BOOL)needsNormalMap specular:(BOOL)needsSpecular
{
    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue" initialSnippet:CCEffectDefaultInitialInputSnippet snippet:CCEffectDefaultInputSnippet];
    
    NSMutableString *effectBody = [[NSMutableString alloc] init];
    [effectBody appendString:CC_GLSL(
                                     vec4 lightColor;
                                     vec4 lightSpecularColor;
                                     vec4 diffuseSum = u_globalAmbientColor;
                                     vec4 specularSum = vec4(0,0,0,0);
                                     
                                     vec3 worldSpaceLightDir;
                                     vec3 halfAngleDir;
                                     
                                     float lightDist;
                                     float falloffTermA;
                                     float falloffTermB;
                                     float falloffSelect;
                                     float falloffTerm;
                                     float diffuseTerm;
                                     float specularTerm;
                                     float composedAlpha = inputValue.a;
                                     )];

    if (needsNormalMap)
    {
        [effectBody appendString:CC_GLSL(
                                         // Index the normal map and expand the color value from [0..1] to [-1..1]
                                         vec4 normalMap = texture2D(cc_NormalMapTexture, cc_FragTexCoord2);
                                         vec3 tangentSpaceNormal = normalize(normalMap.xyz * 2.0 - 1.0);
                                         
                                         // Convert the normal vector from tangent space to world space
                                         vec3 worldSpaceNormal = normalize(vec3(u_worldSpaceTangent, 0.0) * tangentSpaceNormal.x + vec3(u_worldSpaceBinormal, 0.0) * tangentSpaceNormal.y + vec3(0.0, 0.0, tangentSpaceNormal.z));

                                         composedAlpha *= normalMap.a;
                                         )];
    }
    else
    {
        [effectBody appendString:@"vec3 worldSpaceNormal = vec3(0,0,1);\n"];
    }
    
    [effectBody appendString:CC_GLSL(
                                     if (composedAlpha == 0.0)
                                     {
                                         return inputValue;
                                     }
                                     )];
    
    for (NSUInteger lightIndex = 0; lightIndex < lights.count; lightIndex++)
    {
        CCLightNode *light = lights[lightIndex];
        if (light.type == CCLightDirectional)
        {
            [effectBody appendFormat:@"worldSpaceLightDir = v_worldSpaceLightDir%lu.xyz;\n", (unsigned long)lightIndex];
            [effectBody appendFormat:@"lightColor = u_lightColor%lu;\n", (unsigned long)lightIndex];
            if (needsSpecular)
            {
                [effectBody appendFormat:@"lightSpecularColor = u_lightSpecularColor%lu;\n", (unsigned long)lightIndex];
            }
        }
        else
        {
            [effectBody appendFormat:@"worldSpaceLightDir = normalize(v_worldSpaceLightDir%lu.xyz);\n", (unsigned long)lightIndex];
            [effectBody appendFormat:@"lightDist = length(v_worldSpaceLightDir%lu.xy);\n", (unsigned long)lightIndex];
            
            [effectBody appendFormat:@"falloffTermA = clamp((lightDist * u_lightFalloff%lu.y + 1.0), 0.0, 1.0);\n", (unsigned long)lightIndex];
            [effectBody appendFormat:@"falloffTermB = clamp((lightDist * u_lightFalloff%lu.z + u_lightFalloff%lu.w), 0.0, 1.0);\n", (unsigned long)lightIndex, (unsigned long)lightIndex];
            [effectBody appendFormat:@"falloffSelect = step(u_lightFalloff%lu.x, lightDist);\n", (unsigned long)lightIndex];
            [effectBody appendFormat:@"falloffTerm = (1.0 - falloffSelect) * falloffTermA + falloffSelect * falloffTermB;\n"];

            [effectBody appendFormat:@"lightColor = u_lightColor%lu * falloffTerm;\n", (unsigned long)lightIndex];
            if (needsSpecular)
            {
                [effectBody appendFormat:@"lightSpecularColor = u_lightSpecularColor%lu * falloffTerm;\n", (unsigned long)lightIndex];
            }
        }
        [effectBody appendString:@"diffuseTerm = max(0.0, dot(worldSpaceNormal, worldSpaceLightDir));\n"];
        [effectBody appendString:@"diffuseSum += lightColor * diffuseTerm;\n"];
        
        if (needsSpecular)
        {
            [effectBody appendString:@"halfAngleDir = (2.0 * dot(worldSpaceLightDir, worldSpaceNormal) * worldSpaceNormal - worldSpaceLightDir);\n"];
            [effectBody appendString:@"specularTerm = max(0.0, dot(halfAngleDir, vec3(0,0,1))) * step(0.0, diffuseTerm);\n"];
            [effectBody appendString:@"specularSum += lightSpecularColor * pow(specularTerm, u_specularExponent);\n"];
        }
    }
    [effectBody appendString:@"vec4 resultColor = diffuseSum * inputValue;\n"];
    if (needsSpecular)
    {
        [effectBody appendString:@"resultColor += specularSum * u_specularColor;\n"];
    }
    [effectBody appendString:@"return vec4(resultColor.xyz, inputValue.a);\n"];
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"lightingEffectFrag" body:effectBody inputs:@[input] returnType:@"vec4"];
    return @[fragmentFunction];
}

+(NSArray *)buildVertexFunctionsWithLights:(NSArray*)lights
{
    NSMutableString *effectBody = [[NSMutableString alloc] init];
    for (NSUInteger lightIndex = 0; lightIndex < lights.count; lightIndex++)
    {
        CCLightNode *light = lights[lightIndex];
        
        if (light.type == CCLightDirectional)
        {
            [effectBody appendFormat:@"v_worldSpaceLightDir%lu = u_lightVector%lu;", (unsigned long)lightIndex, (unsigned long)lightIndex];
        }
        else
        {
            [effectBody appendFormat:@"v_worldSpaceLightDir%lu = u_lightVector%lu - (u_ndcToWorld * cc_Position).xyz;", (unsigned long)lightIndex, (unsigned long)lightIndex];
        }
    }
    [effectBody appendString:@"return cc_Position;"];
    
    CCEffectFunction *vertexFunction = [[CCEffectFunction alloc] initWithName:@"lightingEffectVtx" body:effectBody inputs:nil returnType:@"vec4"];
    return @[vertexFunction];
}

+(NSArray *)buildRenderPassesWithInterface:(CCEffectLighting *)interface
{
    __weak CCEffectLighting *weakInterface = interface;

    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectLighting pass 0";
    pass0.beginBlocks = @[[^(CCEffectRenderPass *pass, CCEffectRenderPassInputs *passInputs){
        
        passInputs.shaderUniforms[CCShaderUniformMainTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformPreviousPassTexture] = passInputs.previousPassTexture;
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Center] = [NSValue valueWithGLKVector2:passInputs.texCoord1Center];
        passInputs.shaderUniforms[CCShaderUniformTexCoord1Extents] = [NSValue valueWithGLKVector2:passInputs.texCoord1Extents];

        GLKMatrix4 nodeLocalToWorld = CCEffectUtilsMat4FromAffineTransform(passInputs.sprite.nodeToWorldTransform);
        GLKMatrix4 ndcToWorld = GLKMatrix4Multiply(nodeLocalToWorld, passInputs.ndcToNodeLocal);
        

        GLKMatrix2 tangentMatrix = CCEffectUtilsMatrix2InvertAndTranspose(GLKMatrix4GetMatrix2(nodeLocalToWorld), nil);
        GLKVector2 reflectTangent = GLKVector2Normalize(CCEffectUtilsMatrix2MultiplyVector2(tangentMatrix, GLKVector2Make(1.0f, 0.0f)));
        GLKVector2 reflectBinormal = GLKVector2Make(-reflectTangent.y, reflectTangent.x);

        passInputs.shaderUniforms[pass.uniformTranslationTable[@"u_worldSpaceTangent"]] = [NSValue valueWithGLKVector2:reflectTangent];
        passInputs.shaderUniforms[pass.uniformTranslationTable[@"u_worldSpaceBinormal"]] = [NSValue valueWithGLKVector2:reflectBinormal];

        
        // Matrix for converting NDC (normalized device coordinates (aka normalized render target coordinates)
        // to node local coordinates.
        passInputs.shaderUniforms[pass.uniformTranslationTable[@"u_ndcToWorld"]] = [NSValue valueWithGLKMatrix4:ndcToWorld];

        for (NSUInteger lightIndex = 0; lightIndex < weakInterface.closestLights.count; lightIndex++)
        {
            CCLightNode *light = weakInterface.closestLights[lightIndex];
            
            // Get the transform from the light's coordinate space to the effect's coordinate space.
            GLKMatrix4 lightNodeToWorld = CCEffectUtilsMat4FromAffineTransform(light.nodeToWorldTransform);
            
            // Compute the light's position in the effect node's coordinate system.
            GLKVector4 lightVector = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);
            if (light.type == CCLightDirectional)
            {
                lightVector = GLKVector4Normalize(GLKMatrix4MultiplyVector4(lightNodeToWorld, GLKVector4Make(0.0f, 1.0f, light.depth, 0.0f)));
            }
            else
            {
                lightVector = GLKMatrix4MultiplyVector4(lightNodeToWorld, GLKVector4Make(light.anchorPointInPoints.x, light.anchorPointInPoints.y, light.depth, 1.0f));

                float scale0 = GLKVector4Length(GLKMatrix4GetColumn(lightNodeToWorld, 0));
                float scale1 = GLKVector4Length(GLKMatrix4GetColumn(lightNodeToWorld, 1));
                float maxScale = MAX(scale0, scale1);

                float cutoffRadius = light.cutoffRadius * maxScale;

                GLKVector4 falloffTerms = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
                if (cutoffRadius > 0.0f)
                {
                    float xIntercept = cutoffRadius * light.halfRadius;
                    float r1 = 2.0f * xIntercept;
                    float r2 = cutoffRadius;
                    
                    falloffTerms.x = xIntercept;
                    
                    if (light.halfRadius > 0.0f)
                    {
                        falloffTerms.y = -1.0f / r1;
                    }
                    else
                    {
                        falloffTerms.y = 0.0f;
                    }
                    
                    if (light.halfRadius < 1.0f)
                    {
                        falloffTerms.z = -0.5f / (r2 - xIntercept);
                        falloffTerms.w = 0.5f - xIntercept * falloffTerms.z;
                    }
                    else
                    {
                        falloffTerms.z = 0.0f;
                        falloffTerms.w = 0.0f;
                    }
                }
                
                NSString *lightFalloffLabel = [NSString stringWithFormat:@"u_lightFalloff%lu", (unsigned long)lightIndex];
                passInputs.shaderUniforms[pass.uniformTranslationTable[lightFalloffLabel]] = [NSValue valueWithGLKVector4:falloffTerms];
            }
            
            // Compute the real light color based on color and intensity.
            GLKVector4 lightColor = GLKVector4MultiplyScalar(light.color.glkVector4, light.intensity);
            
            NSString *lightColorLabel = [NSString stringWithFormat:@"u_lightColor%lu", (unsigned long)lightIndex];
            passInputs.shaderUniforms[pass.uniformTranslationTable[lightColorLabel]] = [NSValue valueWithGLKVector4:lightColor];

            NSString *lightVectorLabel = [NSString stringWithFormat:@"u_lightVector%lu", (unsigned long)lightIndex];
            passInputs.shaderUniforms[pass.uniformTranslationTable[lightVectorLabel]] = [NSValue valueWithGLKVector3:GLKVector3Make(lightVector.x, lightVector.y, lightVector.z)];

            if (weakInterface.needsSpecular)
            {
                GLKVector4 lightSpecularColor = GLKVector4MultiplyScalar(light.specularColor.glkVector4, light.specularIntensity);

                NSString *lightSpecularColorLabel = [NSString stringWithFormat:@"u_lightSpecularColor%lu", (unsigned long)lightIndex];
                passInputs.shaderUniforms[pass.uniformTranslationTable[lightSpecularColorLabel]] = [NSValue valueWithGLKVector4:lightSpecularColor];
            }
        }

        CCColor *ambientColor = [CCEffectUtilsGetNodeScene(passInputs.sprite).lights findAmbientSumForLightsWithMask:weakInterface.groupMask];
        passInputs.shaderUniforms[pass.uniformTranslationTable[@"u_globalAmbientColor"]] = [NSValue valueWithGLKVector4:ambientColor.glkVector4];
        
        if (weakInterface.needsSpecular)
        {
            passInputs.shaderUniforms[pass.uniformTranslationTable[@"u_specularExponent"]] = weakInterface.conditionedShininess;
            passInputs.shaderUniforms[pass.uniformTranslationTable[@"u_specularColor"]] = [NSValue valueWithGLKVector4:weakInterface.specularColor.glkVector4];
        }
        
    } copy]];
    
    return @[pass0];
}

@end


@implementation CCEffectLighting

-(id)init
{
    return [self initWithGroups:@[] specularColor:[CCColor whiteColor] shininess:0.5f];
}

-(id)initWithGroups:(NSArray *)groups specularColor:(CCColor *)specularColor shininess:(float)shininess
{
    if((self = [super init]))
    {
        self.effectImpl = [[CCEffectLightingImpl alloc] initWithInterface:self];
        self.debugName = @"CCEffectLighting";
        
        _groups = [groups copy];
        _groupMaskDirty = YES;
        _specularColor = specularColor;
        _shininess = shininess;
        _conditionedShininess = [NSNumber numberWithFloat:conditionShininess(shininess)];
    }
    return self;
}


+(id)effectWithGroups:(NSArray *)groups specularColor:(CCColor *)specularColor shininess:(float)shininess
{
    return [[self alloc] initWithGroups:groups specularColor:specularColor shininess:shininess];
}

- (CCEffectPrepareResult)prepareForRenderingWithSprite:(CCSprite *)sprite
{
    CCEffectPrepareResult result = CCEffectPrepareNoop;

    _needsNormalMap = (sprite.normalMapSpriteFrame != nil);
    
    CGAffineTransform spriteTransform = sprite.nodeToWorldTransform;
    CGPoint spritePosition = CGPointApplyAffineTransform(sprite.anchorPointInPoints, sprite.nodeToWorldTransform);
    
    CCLightCollection *lightCollection = CCEffectUtilsGetNodeScene(sprite).lights;
    if (self.groupMaskDirty)
    {
        self.groupMask = [lightCollection maskForGroups:self.groups];
        self.groupMaskDirty = NO;
    }
    
    self.closestLights = [lightCollection findClosestKLights:CCEffectLightingMaxLightCount toPoint:spritePosition withMask:self.groupMask];
    CCLightKey newLightKey = CCLightKeyMake(self.closestLights);
    
    if (!CCLightKeyCompare(newLightKey, self.lightKey) ||
        (self.shaderHasSpecular != self.needsSpecular) ||
        (self.shaderHasNormalMap != self.needsNormalMap))
    {
        self.lightKey = newLightKey;
        self.shaderHasSpecular = self.needsSpecular;
        self.shaderHasNormalMap = _needsNormalMap;
        
        self.effectImpl = [[CCEffectLightingImpl alloc] initWithInterface:self];

        result.status = CCEffectPrepareSuccess;
        result.changes = CCEffectPrepareShaderChanged | CCEffectPrepareUniformsChanged;
    }
    return result;
}

- (BOOL)needsSpecular
{
    return (!ccc4FEqual(self.specularColor.ccColor4f, ccc4f(0.0f, 0.0f, 0.0f, 0.0f)) && (self.shininess > 0.0f));
}

-(void)setGroups:(NSArray *)groups
{
    _groups = [groups copy];
    _groupMaskDirty = YES;
}

-(void)setShininess:(float)shininess
{
    _shininess = shininess;
    _conditionedShininess = [NSNumber numberWithFloat:conditionShininess(shininess)];
}

@end


CCLightKey CCLightKeyMake(NSArray *lights)
{
    CCLightKey lightKey;
    lightKey.pointLightMask = 0;
    lightKey.directionalLightMask = 0;
    
    for (NSUInteger lightIndex = 0; lightIndex < lights.count; lightIndex++)
    {
        CCLightNode *light = lights[lightIndex];
        if (light.type == CCLightPoint)
        {
            lightKey.pointLightMask |= (1 << lightIndex);
        }
        else if (light.type == CCLightDirectional)
        {
            lightKey.directionalLightMask |= (1 << lightIndex);
        }
    }
    return lightKey;
}

BOOL CCLightKeyCompare(CCLightKey a, CCLightKey b)
{
    return (((a.pointLightMask) == (b.pointLightMask)) &&
            ((a.directionalLightMask) == (b.directionalLightMask)));
}

float conditionShininess(float shininess)
{
    // Map supplied shininess from [0..1] to [1..100]
    NSCAssert((shininess >= 0.0f) && (shininess <= 1.0f), @"Supplied shininess out of range [0..1].");
    shininess = clampf(shininess, 0.0f, 1.0f);
    return ((shininess * 99.0f) + 1.0f);
}

