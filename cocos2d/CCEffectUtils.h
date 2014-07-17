//
//  CCEffectUtils.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/17/14.
//
//

#import "CCSprite.h"


#if CC_ENABLE_EXPERIMENTAL_EFFECTS

CGAffineTransform CCEffectUtilsWorldToEnvironmentTransform(CCSprite *environment);
GLKVector4 CCEffectUtilsTangentInEnvironmentSpace(GLKMatrix4 effectToWorldMat, GLKMatrix4 worldToEnvMat);
GLKMatrix4 CCEffectUtilsMat4FromAffineTransform(CGAffineTransform at);
float CCEffectUtilsConditionRefraction(float refraction);

#endif
