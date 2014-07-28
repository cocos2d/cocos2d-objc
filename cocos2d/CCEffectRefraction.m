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

@property (nonatomic) float conditionedRefraction;

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
    NSArray *uniforms = @[
                          [CCEffectUniform uniform:@"float" name:@"u_refraction" value:[NSNumber numberWithFloat:1.0f]],
                          [CCEffectUniform uniform:@"sampler2D" name:@"u_envMap" value:(NSValue*)[CCTexture none]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_tangent" value:[NSValue valueWithGLKVector2:GLKVector2Make(1.0f, 0.0f)]],
                          [CCEffectUniform uniform:@"vec2" name:@"u_binormal" value:[NSValue valueWithGLKVector2:GLKVector2Make(0.0f, 1.0f)]],
                          [CCEffectUniform uniform:@"mat4" name:@"u_screenToEnv" value:[NSValue valueWithGLKMatrix4:GLKMatrix4Identity]],
                          ];
    
    if((self = [super initWithFragmentUniforms:uniforms vertexUniforms:nil varying:nil]))
    {
        _refraction = refraction;
        _conditionedRefraction = CCEffectUtilsConditionRefraction(refraction);
        _environment = environment;
        _normalMap = normalMap;

        self.debugName = @"CCEffectRefraction";
    }
    return self;
}

+(id)effectWithRefraction:(float)refraction environment:(CCSprite *)environment
{
    return [[self alloc] initWithRefraction:refraction environment:environment];
}

+(id)effectWithRefraction:(float)refraction environment:(CCSprite *)environment normalMap:(CCSpriteFrame *)normalMap
{
    return [[self alloc] initWithRefraction:refraction environment:environment normalMap:normalMap];
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
                                   vec3 refractOffset = refract(vec3(0,0,1), normal, 1.0) * u_refraction;
                                   
                                   // Perturb the screen space texture coordinate by the scaled normal
                                   // vector.
                                   vec2 refractTexCoords = envSpaceTexCoords.xy + refractOffset.xy;
                                   
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
    
    CCEffectFunction* fragmentFunction = [[CCEffectFunction alloc] initWithName:@"refractionEffect" body:effectBody inputs:@[input] returnType:@"vec4"];
    [self.fragmentFunctions addObject:fragmentFunction];
}

-(void)buildRenderPasses
{
    __weak CCEffectRefraction *weakSelf = self;
    
    CCEffectRenderPass *pass0 = [[CCEffectRenderPass alloc] init];
    pass0.debugLabel = @"CCEffectRefraction pass 0";
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
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_envMap"]] = weakSelf.environment.texture ?: [CCTexture none];
        
        CGFloat scale = [CCDirector sharedDirector].contentScaleFactor;
        CGAffineTransform screenToWorld = CGAffineTransformMake(1.0f / scale, 0.0f, 0.0f, 1.0f / scale, 0.0f, 0.0f);
        
        // Setup the screen space to environment space matrix.
        CGAffineTransform worldToRefractEnvTexture =  CCEffectUtilsWorldToEnvironmentTransform(weakSelf.environment);
        CGAffineTransform screenToRefractEnvTexture = CGAffineTransformConcat(screenToWorld, worldToRefractEnvTexture);
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_screenToEnv"]] = [NSValue valueWithGLKMatrix4:CCEffectUtilsMat4FromAffineTransform(screenToRefractEnvTexture)];

        // Setup the tangent and binormal vectors for the refraction environment
        GLKVector4 refractTangent = CCEffectUtilsTangentInEnvironmentSpace(pass.transform, CCEffectUtilsMat4FromAffineTransform(worldToRefractEnvTexture));
        GLKVector4 refractNormal = GLKVector4Make(0.0f, 0.0f, 1.0f, 1.0f);
        GLKVector4 refractBinormal = GLKVector4CrossProduct(refractNormal, refractTangent);
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_tangent"]] = [NSValue valueWithGLKVector2:GLKVector2Make(refractTangent.x, refractTangent.y)];
        pass.shaderUniforms[weakSelf.uniformTranslationTable[@"u_binormal"]] = [NSValue valueWithGLKVector2:GLKVector2Make(refractBinormal.x, refractBinormal.y)];

    } copy]];
    
    self.renderPasses = @[pass0];
}

-(void)setRefraction:(float)refraction
{
    _refraction = refraction;
    _conditionedRefraction = CCEffectUtilsConditionRefraction(refraction);
}
@end

