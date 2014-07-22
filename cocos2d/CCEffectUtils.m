//
//  CCEffectUtils.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/17/14.
//
//

#import "CCEffectUtils.h"


#if CC_ENABLE_EXPERIMENTAL_EFFECTS

static const float CCEffectUtilsMinRefract = -0.25;
static const float CCEffectUtilsMaxRefract = 0.043;


CGAffineTransform CCEffectUtilsWorldToEnvironmentTransform(CCSprite *environment)
{
    CGAffineTransform worldToEnvNode = environment.worldToNodeTransform;
    CGAffineTransform envNodeToEnvTexture = environment.nodeToTextureTransform;
    CGAffineTransform worldToEnvTexture = CGAffineTransformConcat(worldToEnvNode, envNodeToEnvTexture);
    return worldToEnvTexture;
}

GLKVector4 CCEffectUtilsTangentInEnvironmentSpace(GLKMatrix4 effectToWorldMat, GLKMatrix4 worldToEnvMat)
{
    GLKMatrix4 effectToEnvTextureMat = GLKMatrix4Multiply(effectToWorldMat, worldToEnvMat);
    
    GLKVector4 refractTangent = GLKVector4Make(1.0f, 0.0f, 0.0f, 0.0f);
    refractTangent = GLKMatrix4MultiplyVector4(effectToEnvTextureMat, refractTangent);
    return GLKVector4Normalize(refractTangent);
}

GLKMatrix4 CCEffectUtilsMat4FromAffineTransform(CGAffineTransform at)
{
    return GLKMatrix4Make(at.a,  at.b,  0.0f,  0.0f,
                          at.c,  at.d,  0.0f,  0.0f,
                          0.0f,  0.0f,  1.0f,  0.0f,
                          at.tx, at.ty, 0.0f,  1.0f);
}

float CCEffectUtilsConditionRefraction(float refraction)
{
    NSCAssert((refraction >= -1.0) && (refraction <= 1.0), @"Supplied refraction out of range [-1..1].");
    
    // Lerp between min and max
    if (refraction >= 0.0f)
    {
        return CCEffectUtilsMaxRefract * refraction;
    }
    else
    {
        return CCEffectUtilsMinRefract * -refraction;
    }
}

#endif
