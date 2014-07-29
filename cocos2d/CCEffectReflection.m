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

@property (nonatomic) float conditionedShininess;
@property (nonatomic) float conditionedFresnelBias;
@property (nonatomic) float conditionedFresnelPower;

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
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"float" name:@"u_shininess" value:[NSNumber numberWithFloat:1.0f]],
                          [CCEffectUniform uniform:@"float" name:@"u_fresnelBias" value:[NSNumber numberWithFloat:1.0f]],
                          [CCEffectUniform uniform:@"float" name:@"u_fresnelPower" value:[NSNumber numberWithFloat:0.0f]],
                          [CCEffectUniform uniform:@"sampler2D" name:@"u_envMap" value:(NSValue*)[CCTexture none]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_tangent" value:[NSValue valueWithGLKVector2:GLKVector2Make(1.0f, 0.0f)]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_binormal" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 1.0f)]],
                          [CCEffectUniform uniform:@"mat4" name:@"u_screenToEnv" value:[NSValue valueWithGLKMatrix4:GLKMatrix4Identity]],
                          ];
    
    if((self = [super initWithFragmentUniforms:uniforms vertexUniforms:nil varyings:nil]))
    {
        _shininess = shininess;
        _conditionedShininess = CCEffectUtilsConditionShininess(shininess);
        
        _fresnelBias = bias;
        _conditionedFresnelBias = CCEffectUtilsConditionFresnelBias(bias);
        
        _fresnelPower = power;
        _conditionedFresnelPower = CCEffectUtilsConditionFresnelPower(power);
        
        _environment = environment;
        _normalMap = normalMap;
        
        self.debugName = @"CCEffectReflection";
    }
    return self;
}

+(id)effectWithShininess:(float)shininess environment:(CCSprite *)environment
{
    return [[self alloc] initWithShininess:shininess environment:environment];
}

+(id)effectWithShininess:(float)shininess environment:(CCSprite *)environment normalMap:(CCSpriteFrame *)normalMap
{
    return [[self alloc] initWithShininess:shininess environment:environment normalMap:normalMap];
}

+(id)effectWithShininess:(float)shininess fresnelBias:(float)bias fresnelPower:(float)power environment:(CCSprite *)environment
{
    return [[self alloc] initWithShininess:shininess fresnelBias:bias fresnelPower:power environment:environment];
}

+(id)effectWithShininess:(float)shininess fresnelBias:(float)bias fresnelPower:(float)power environment:(CCSprite *)environment normalMap:(CCSpriteFrame *)normalMap
{
    return [[self alloc] initWithShininess:shininess fresnelBias:bias fresnelPower:power environment:environment normalMap:normalMap];
}

-(void)buildFragmentFunctions
{
    self.fragmentFunctions = [[NSMutableArray alloc] init];
    
    CCEffectFunctionInput *input = [[CCEffectFunctionInput alloc] initWithType:@"vec4" name:@"inputValue" snippet:@"cc_FragColor * texture2D(cc_PreviousPassTexture, cc_FragTexCoord1)"];
    
    NSString* effectBody = CC_GLSL(
                                   // Compute environment space texture coordinates from the screen space
                                   // fragment position.
                                   vec4 envSpaceTexCoords = u_screenToEnv * gl_FragCoord;
                                   
                                   // Index the normal map and expand the color value from [0..1] to [-1..1]
                                   vec4 normalMap = texture2D(cc_NormalMapTexture, cc_FragTexCoord2);
                                   vec4 tangentSpaceNormal = normalMap * 2.0 - 1.0;
                                   
                                   // Convert the normal vector from tangent space to environment space
                                   vec3 normal = normalize(vec3(u_tangent * tangentSpaceNormal.x + u_binormal * tangentSpaceNormal.y, tangentSpaceNormal.z));
                                   
                                   float nDotV = dot(normal, vec3(0,0,1));
                                   vec3 reflectOffset = normal * pow(1.0 - nDotV, 3.0) / 8.0;
                                   
                                   // Perturb the screen space texture coordinate by the scaled normal
                                   // vector.
                                   vec2 reflectTexCoords = envSpaceTexCoords.xy + reflectOffset.xy;

                                   // Feed the resulting coordinates through cos() so they reflect when
                                   // they would otherwise be outside of [0..1].
                                   const float M_PI = 3.14159265358979323846264338327950288;
                                   reflectTexCoords.x = (1.0 - cos(reflectTexCoords.x * M_PI)) * 0.5;
                                   reflectTexCoords.y = (1.0 - cos(reflectTexCoords.y * M_PI)) * 0.5;
                                   
                                   // Compute the combination of the sprite's color and texture.
                                   vec4 primaryColor = inputValue;
                                   
                                   float fresnel = max(u_fresnelBias + (1.0 - u_fresnelBias) * pow((1.0 - nDotV), u_fresnelPower), 0.0);
                                   
                                   // If the refracted texture coordinates are within the bounds of the environment map
                                   // blend the primary color with the refracted environment. Multiplying by the normal
                                   // map alpha also allows the effect to be disabled for specific pixels.
                                   primaryColor += normalMap.a * fresnel * u_shininess * texture2D(u_envMap, reflectTexCoords);
                                   return primaryColor;
                                   );
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"reflectionEffect" body:effectBody inputs:@[input] returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectReflection *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectReflection pass 0";
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
        
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_shininess"]] = [NSNumber numberWithFloat:weakSelf.conditionedShininess];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_fresnelBias"]] = [NSNumber numberWithFloat:weakSelf.conditionedFresnelBias];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_fresnelPower"]] = [NSNumber numberWithFloat:weakSelf.conditionedFresnelPower];
        
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_envMap"]] = weakSelf.environment.texture ?: [CCTexture none];
        
        CGFloat scale = [CCDirector sharedDirector].contentScaleFactor;
        CGAffineTransform screenToWorld = CGAffineTransformMake(1.0f / scale, 0.0f, 0.0f, 1.0f / scale, 0.0f, 0.0f);
        
        // Setup the screen space to environment space matrix.
        CGAffineTransform worldToReflectEnvTexture =  CCEffectUtilsWorldToEnvironmentTransform(weakSelf.environment);
        CGAffineTransform screenToReflectEnvTexture = CGAffineTransformConcat(screenToWorld, worldToReflectEnvTexture);
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_screenToEnv"]] = [NSValue valueWithGLKMatrix4:CCEffectUtilsMat4FromAffineTransform(screenToReflectEnvTexture)];
        
        // Setup the tangent and binormal vectors for the refraction environment
        GLKVector4 reflectTangent = CCEffectUtilsTangentInEnvironmentSpace(pass.transform, CCEffectUtilsMat4FromAffineTransform(worldToReflectEnvTexture));
        GLKVector4 reflectNormal = GLKVector4Make(0.0f, 0.0f, 1.0f, 1.0f);
        GLKVector4 reflectBinormal = GLKVector4CrossProduct(reflectNormal, reflectTangent);
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_tangent"]] = [NSValue valueWithGLKVector2:GLKVector2Make(reflectTangent.x, reflectTangent.y)];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_binormal"]] = [NSValue valueWithGLKVector2:GLKVector2Make(reflectBinormal.x, reflectBinormal.y)];
        
    } copy]];
    
    self.renderPasses = @[pass0];
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

