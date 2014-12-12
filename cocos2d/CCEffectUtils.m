//
//  CCEffectUtils.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/17/14.
//
//

#import "CCEffectUtils.h"
#import "CCRenderTexture_Private.h"

#ifndef BLUR_OPTIMIZED_RADIUS_MAX
#define BLUR_OPTIMIZED_RADIUS_MAX 4UL
#endif


static const float CCEffectUtilsMinRefract = -0.25;
static const float CCEffectUtilsMaxRefract = 0.043;

static CCNode* CCEffectUtilsGetNodeParent(CCNode *node);
static BOOL CCEffectUtilsNodeIsDescendantOfNode(CCNode *descendant, CCNode *ancestor);



CCNode* CCEffectUtilsFindCommonAncestor(CCNode *first, CCNode *second)
{
    NSCAssert(first, @"First node is nil.");
    NSCAssert(second, @"Second node is nil.");

    // First find the common ancestor of the two nodes. If there isn't
    // one then don't do anything else.
    NSMutableSet *visited1 = [[NSMutableSet alloc] init];
    for (CCNode *n1 = first; n1 != nil; n1 = CCEffectUtilsGetNodeParent(n1))
    {
        NSCAssert(![visited1 containsObject:n1], @"n1's node hierarchy contains a cycle!");
        [visited1 addObject:n1];
    }

    CCNode *commonAncestor = nil;
    NSMutableSet *visited2 = [[NSMutableSet alloc] init];
    for (CCNode *n2 = second; n2 != nil; n2 = CCEffectUtilsGetNodeParent(n2))
    {
        NSCAssert(![visited2 containsObject:n2], @"n2's node hierarchy contains a cycle!");
        [visited2 addObject:n2];

        if ([visited1 containsObject:n2])
        {
            commonAncestor = n2;
            break;
        }
    }

    return commonAncestor;
}

GLKMatrix4 CCEffectUtilsTransformFromNodeToAncestor(CCNode *descendant, CCNode *ancestor)
{
    NSCAssert(CCEffectUtilsNodeIsDescendantOfNode(descendant, ancestor), @"The supplied nodes are not related to each other.");
                                                  
    // Compute the transform from this node to the common ancestor
    CGAffineTransform t = [descendant nodeToParentTransform];
    for (CCNode *p = CCEffectUtilsGetNodeParent(descendant); p != CCEffectUtilsGetNodeParent(ancestor); p = CCEffectUtilsGetNodeParent(p))
    {
        t = CGAffineTransformConcat(t, [p nodeToParentTransform]);
    }
    return CCEffectUtilsMat4FromAffineTransform(t);
}

GLKMatrix4 CCEffectUtilsTransformFromNodeToNode(CCNode *first, CCNode *second, BOOL *success)
{
    // Find the common ancestor if there is one.
    CCNode *commonAncestor = CCEffectUtilsFindCommonAncestor(first, second);
    if (success)
    {
        *success = (commonAncestor != nil);
    }
    if (commonAncestor == nil)
    {
        return GLKMatrix4Identity;
    }
    
    // Find the transforms to the common ancestor.
    GLKMatrix4 t1 = CCEffectUtilsTransformFromNodeToAncestor(first, commonAncestor);
    GLKMatrix4 t2 = CCEffectUtilsTransformFromNodeToAncestor(second, commonAncestor);

    // Concatenate t1 and the inverse of t2 to give us the transform from the first node
    // to the second.
    return GLKMatrix4Multiply(GLKMatrix4Invert(t2, nil), t1);
}

CCNode* CCEffectUtilsGetNodeParent(CCNode *node)
{
    if ([node isKindOfClass:[CCRenderTextureSprite class]])
    {
        CCRenderTextureSprite *rtSprite = (CCRenderTextureSprite *)node;
        return rtSprite.renderTexture;
    }
    else
    {
        return node.parent;
    }
}

BOOL CCEffectUtilsNodeIsDescendantOfNode(CCNode *descendant, CCNode *ancestor)
{
    NSCAssert(descendant != nil, @"Descendant node is nil.");
    NSCAssert(ancestor != nil, @"Ancestor node is nil.");

    CCNode *n = nil;
    for (n = descendant; (n != nil) && (n != ancestor); n = CCEffectUtilsGetNodeParent(n))
    {
    }
    
    return (n == ancestor);
}

GLKMatrix4 CCEffectUtilsMat4FromAffineTransform(CGAffineTransform at)
{
    return GLKMatrix4Make(at.a,  at.b,  0.0f,  0.0f,
                          at.c,  at.d,  0.0f,  0.0f,
                          0.0f,  0.0f,  1.0f,  0.0f,
                          at.tx, at.ty, 0.0f,  1.0f);
}

GLKMatrix2 CCEffectUtilsMatrix2InvertAndTranspose(GLKMatrix2 matrix, bool *isInvertible)
{
    GLKMatrix2 result;

    float det = matrix.m00 * matrix.m11 - matrix.m01 * matrix.m10;
    if (fabsf(det) < FLT_EPSILON)
    {
        if (isInvertible)
        {
            *isInvertible = NO;
        }
        result.m00 = result.m11 = 1.0f;
        result.m01 = result.m10 = 0.0f;
    }
    else
    {
        if (isInvertible)
        {
            *isInvertible = YES;
        }
        float invDet = 1.0f / det;
        result.m00 =  matrix.m11 * invDet; result.m01 = -matrix.m01 * invDet;
        result.m10 = -matrix.m10 * invDet; result.m11 =  matrix.m00 * invDet;
    }
    
    return result;
}

GLKVector2 CCEffectUtilsMatrix2MultiplyVector2(GLKMatrix2 m, GLKVector2 v)
{
    GLKVector2 result = {{ m.m[0] * v.v[0] + m.m[2] * v.v[1],
                           m.m[1] * v.v[0] + m.m[3] * v.v[1] }};
    return result;
}

float CCEffectUtilsConditionRefraction(float refraction)
{
    NSCAssert((refraction >= -1.0f) && (refraction <= 1.0f), @"Supplied refraction out of range [-1..1].");
    
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

float CCEffectUtilsConditionShininess(float shininess)
{
    NSCAssert((shininess >= 0.0f) && (shininess <= 1.0f), @"Supplied shininess out of range [0..1].");
    return clampf(shininess, 0.0f, 1.0f);
}

float CCEffectUtilsConditionFresnelBias(float bias)
{
    NSCAssert((bias >= 0.0f) && (bias <= 1.0f), @"Supplied bias out of range [0..1].");
    return clampf(bias, 0.0f, 1.0f);
}

float CCEffectUtilsConditionFresnelPower(float power)
{
    NSCAssert(power >= 0.0f, @"Supplied power out of range [0..inf].");
    return (power < 0.0f) ? 0.0f : power;
}

void CCEffectUtilsPrintMatrix(NSString *label, GLKMatrix4 matrix)
{
    NSLog(@"%@", label);
    NSLog(@"%f %f %f %f", matrix.m00, matrix.m01, matrix.m02, matrix.m03);
    NSLog(@"%f %f %f %f", matrix.m10, matrix.m11, matrix.m12, matrix.m13);
    NSLog(@"%f %f %f %f", matrix.m20, matrix.m21, matrix.m22, matrix.m23);
    NSLog(@"%f %f %f %f", matrix.m30, matrix.m31, matrix.m32, matrix.m33);
}

CCEffectBlurParams CCEffectUtilsComputeBlurParams(NSUInteger radius)
{
    CCEffectBlurParams result;
    
    result.trueRadius = radius;
    result.radius = MIN(radius, BLUR_OPTIMIZED_RADIUS_MAX);
    result.sigma = result.trueRadius / 2;
    if(result.sigma == 0.0)
    {
        result.sigma = 1.0f;
    }
    result.numberOfOptimizedOffsets = MIN(result.radius / 2 + (result.radius % 2), BLUR_OPTIMIZED_RADIUS_MAX);

    return result;
}


