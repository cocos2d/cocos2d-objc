//
//  CCEffectUtils.h
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/17/14.
//
//

#import "CCSprite.h"

typedef struct CCEffectBlurParams
{
    NSUInteger trueRadius;
    NSUInteger radius;
    NSUInteger numberOfOptimizedOffsets;
    GLfloat sigma;

} CCEffectBlurParams;

CCNode* CCEffectUtilsGetNodeParent(CCNode *node);
CCScene* CCEffectUtilsGetNodeScene(CCNode *node);

CCNode* CCEffectUtilsFindCommonAncestor(CCNode *first, CCNode *second);
GLKMatrix4 CCEffectUtilsTransformFromNodeToAncestor(CCNode *descendant, CCNode *ancestor);
GLKMatrix4 CCEffectUtilsTransformFromNodeToNode(CCNode *first, CCNode *second, BOOL *isPossible);

GLKMatrix4 CCEffectUtilsMat4FromAffineTransform(CGAffineTransform at);
GLKMatrix2 CCEffectUtilsMatrix2InvertAndTranspose(GLKMatrix2 matrix, bool *isInvertible);
GLKVector2 CCEffectUtilsMatrix2MultiplyVector2(GLKMatrix2 matrix, GLKVector2 vector);

float CCEffectUtilsConditionRefraction(float refraction);
float CCEffectUtilsConditionShininess(float shininess);
float CCEffectUtilsConditionFresnelBias(float bias);
float CCEffectUtilsConditionFresnelPower(float power);
void CCEffectUtilsPrintMatrix(NSString *label, GLKMatrix4 matrix);

CCEffectBlurParams CCEffectUtilsComputeBlurParams(NSUInteger radius);
