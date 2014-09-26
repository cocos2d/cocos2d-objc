//
//  CCEffectUtils.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/17/14.
//
//

#import "CCSprite.h"

GLKMatrix4 CCEffectUtilsTransformFromNodeToNode(CCNode *first, CCNode *second, BOOL *isPossible);

GLKMatrix4 CCEffectUtilsMat4FromAffineTransform(CGAffineTransform at);
float CCEffectUtilsConditionRefraction(float refraction);
float CCEffectUtilsConditionShininess(float shininess);
float CCEffectUtilsConditionFresnelBias(float bias);
float CCEffectUtilsConditionFresnelPower(float power);
void CCEffectUtilsPrintMatrix(NSString *label, GLKMatrix4 matrix);
