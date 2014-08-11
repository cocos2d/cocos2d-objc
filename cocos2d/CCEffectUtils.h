//
//  CCEffectUtils.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/17/14.
//
//

#import "CCSprite.h"


CGAffineTransform CCEffectUtilsWorldToEnvironmentTransform(CCSprite *environment);
GLKVector4 CCEffectUtilsTangentInEnvironmentSpace(GLKMatrix4 effectToWorldMat, GLKMatrix4 worldToEnvMat);
GLKMatrix4 CCEffectUtilsMat4FromAffineTransform(CGAffineTransform at);
float CCEffectUtilsConditionRefraction(float refraction);
float CCEffectUtilsConditionShininess(float shininess);
float CCEffectUtilsConditionFresnelBias(float bias);
float CCEffectUtilsConditionFresnelPower(float power);

