//
//  CCEffectUtils.m
//  cocos2d-ios
//
//  Created by Thayer J Andrews on 7/17/14.
//
//

#import "CCEffectUtils.h"
#import "CCRenderTexture_Private.h"


static const float CCEffectUtilsMinRefract = -0.25;
static const float CCEffectUtilsMaxRefract = 0.043;

static CCNode* CCEffectUtilsGetNodeParent(CCNode *node);


GLKMatrix4 CCEffectUtilsTransformFromNodeToNode(CCNode *first, CCNode *second, BOOL *isPossible)
{
    NSCAssert(first, @"CCEffectUtilsTransformFromNodeToNode supplied nil node.");
    NSCAssert(second, @"CCEffectUtilsTransformFromNodeToNode supplied nil node.");

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

    if (isPossible)
    {
        *isPossible = (commonAncestor != nil);
    }
    if (commonAncestor == nil)
    {
        return GLKMatrix4Identity;
    }

    // Compute the transform from this node to the common ancestor
    CGAffineTransform t1 = [first nodeToParentTransform];
    for (CCNode *p = CCEffectUtilsGetNodeParent(first); p != CCEffectUtilsGetNodeParent(commonAncestor); p = CCEffectUtilsGetNodeParent(p))
    {
        t1 = CGAffineTransformConcat(t1, [p nodeToParentTransform]);
    }

    // Compute the transform from this node to the common ancestor
    CGAffineTransform t2 = [second nodeToParentTransform];
    for (CCNode *p = CCEffectUtilsGetNodeParent(second); p != CCEffectUtilsGetNodeParent(commonAncestor); p = CCEffectUtilsGetNodeParent(p))
    {
        t2 = CGAffineTransformConcat(t2, [p nodeToParentTransform]);
    }

    // Invert the second transform since we're interested in the transform
    // from the common ancestor to the second node and we currently have
    // the reverse of this.
    CGAffineTransform invt2 = CGAffineTransformInvert(t2);

    // Concatenate t1 and invt2 to give us the transform from the first node
    // to the second.
    return CCEffectUtilsMat4FromAffineTransform(CGAffineTransformConcat(t1, invt2));
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

GLKMatrix4 CCEffectUtilsMat4FromAffineTransform(CGAffineTransform at)
{
    return GLKMatrix4Make(at.a,  at.b,  0.0f,  0.0f,
                          at.c,  at.d,  0.0f,  0.0f,
                          0.0f,  0.0f,  1.0f,  0.0f,
                          at.tx, at.ty, 0.0f,  1.0f);
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



