//
//  CCVector4.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/10/14.
//
//

#ifndef __CC_VECTOR_4_H
#define __CC_VECTOR_4_H

#include <stdbool.h>
#include <math.h>

#if defined(__ARM_NEON__)
#include <arm_neon.h>
#endif

#import "CCMathTypesAndroid.h"

#if __CC_PLATFORM_ANDROID

#ifdef __cplusplus
extern "C" {
#endif
    
    static inline CCVector4 CCVector4Make(float x, float y, float z, float w)
    {
        CCVector4 v = { { x, y, z, w } };
        return v;
    }
    
    static inline CCVector4 CCVector4MakeWithArray(float values[4])
    {
#if defined(__ARM_NEON__)
        float32x4_t v = vld1q_f32(values);
        return *(CCVector4 *)&v;
#else
        CCVector4 v = { { values[0], values[1], values[2], values[3] } };
        return v;
#endif
    }
    
    static inline CCVector4 CCVector4MakeWithVector3(CCVector3 vector, float w)
    {
        CCVector4 v = { { vector.v[0], vector.v[1], vector.v[2], w } };
        return v;
    }
    
    static inline CCVector4 CCVector4Negate(CCVector4 vector)
    {
#if defined(__ARM_NEON__)
        float32x4_t v = vnegq_f32(*(float32x4_t *)&vector);
        return *(CCVector4 *)&v;
#else
        CCVector4 v = { { -vector.v[0], -vector.v[1], -vector.v[2], -vector.v[3] } };
        return v;
#endif
    }
    
    static inline CCVector4 CCVector4Add(CCVector4 vectorLeft, CCVector4 vectorRight)
    {
#if defined(__ARM_NEON__)
        float32x4_t v = vaddq_f32(*(float32x4_t *)&vectorLeft,
                                  *(float32x4_t *)&vectorRight);
        return *(CCVector4 *)&v;
#else
        CCVector4 v = { { vectorLeft.v[0] + vectorRight.v[0],
            vectorLeft.v[1] + vectorRight.v[1],
            vectorLeft.v[2] + vectorRight.v[2],
            vectorLeft.v[3] + vectorRight.v[3] } };
        return v;
#endif
    }
    
    static inline CCVector4 CCVector4Subtract(CCVector4 vectorLeft, CCVector4 vectorRight)
    {
#if defined(__ARM_NEON__)
        float32x4_t v = vsubq_f32(*(float32x4_t *)&vectorLeft,
                                  *(float32x4_t *)&vectorRight);
        return *(CCVector4 *)&v;
#else
        CCVector4 v = { { vectorLeft.v[0] - vectorRight.v[0],
            vectorLeft.v[1] - vectorRight.v[1],
            vectorLeft.v[2] - vectorRight.v[2],
            vectorLeft.v[3] - vectorRight.v[3] } };
        return v;
#endif
    }
    
    static inline CCVector4 CCVector4Multiply(CCVector4 vectorLeft, CCVector4 vectorRight)
    {
#if defined(__ARM_NEON__)
        float32x4_t v = vmulq_f32(*(float32x4_t *)&vectorLeft,
                                  *(float32x4_t *)&vectorRight);
        return *(CCVector4 *)&v;
#else
        CCVector4 v = { { vectorLeft.v[0] * vectorRight.v[0],
            vectorLeft.v[1] * vectorRight.v[1],
            vectorLeft.v[2] * vectorRight.v[2],
            vectorLeft.v[3] * vectorRight.v[3] } };
        return v;
#endif
    }
    
    static inline CCVector4 CCVector4Divide(CCVector4 vectorLeft, CCVector4 vectorRight)
    {
#if defined(__ARM_NEON__)
        float32x4_t *vLeft = (float32x4_t *)&vectorLeft;
        float32x4_t *vRight = (float32x4_t *)&vectorRight;
        float32x4_t estimate = vrecpeq_f32(*vRight);
        estimate = vmulq_f32(vrecpsq_f32(*vRight, estimate), estimate);
        estimate = vmulq_f32(vrecpsq_f32(*vRight, estimate), estimate);
        float32x4_t v = vmulq_f32(*vLeft, estimate);
        return *(CCVector4 *)&v;
#else
        CCVector4 v = { { vectorLeft.v[0] / vectorRight.v[0],
            vectorLeft.v[1] / vectorRight.v[1],
            vectorLeft.v[2] / vectorRight.v[2],
            vectorLeft.v[3] / vectorRight.v[3] } };
        return v;
#endif
    }
    
    static inline CCVector4 CCVector4AddScalar(CCVector4 vector, float value)
    {
#if defined(__ARM_NEON__)
        float32x4_t v = vaddq_f32(*(float32x4_t *)&vector,
                                  vdupq_n_f32((float32_t)value));
        return *(CCVector4 *)&v;
#else
        CCVector4 v = { { vector.v[0] + value,
            vector.v[1] + value,
            vector.v[2] + value,
            vector.v[3] + value } };
        return v;
#endif
    }
    
    static inline CCVector4 CCVector4SubtractScalar(CCVector4 vector, float value)
    {
#if defined(__ARM_NEON__)
        float32x4_t v = vsubq_f32(*(float32x4_t *)&vector,
                                  vdupq_n_f32((float32_t)value));
        return *(CCVector4 *)&v;
#else
        CCVector4 v = { { vector.v[0] - value,
            vector.v[1] - value,
            vector.v[2] - value,
            vector.v[3] - value } };
        return v;
#endif
    }
    
    static inline CCVector4 CCVector4MultiplyScalar(CCVector4 vector, float value)
    {
#if defined(__ARM_NEON__)
        float32x4_t v = vmulq_f32(*(float32x4_t *)&vector,
                                  vdupq_n_f32((float32_t)value));
        return *(CCVector4 *)&v;
#else
        CCVector4 v = { { vector.v[0] * value,
            vector.v[1] * value,
            vector.v[2] * value,
            vector.v[3] * value } };
        return v;
#endif
    }
    
    static inline CCVector4 CCVector4DivideScalar(CCVector4 vector, float value)
    {
#if defined(__ARM_NEON__)
        float32x4_t values = vdupq_n_f32((float32_t)value);
        float32x4_t estimate = vrecpeq_f32(values);
        estimate = vmulq_f32(vrecpsq_f32(values, estimate), estimate);
        estimate = vmulq_f32(vrecpsq_f32(values, estimate), estimate);
        float32x4_t v = vmulq_f32(*(float32x4_t *)&vector, estimate);
        return *(CCVector4 *)&v;
#else
        CCVector4 v = { { vector.v[0] / value,
            vector.v[1] / value,
            vector.v[2] / value,
            vector.v[3] / value } };
        return v;
#endif
    }
    
    /*
     Returns a vector whose elements are the larger of the corresponding elements of the vector arguments.
     */
    static inline CCVector4 CCVector4Maximum(CCVector4 vectorLeft, CCVector4 vectorRight)
    {
#if defined(__ARM_NEON__)
        float32x4_t v = vmaxq_f32(*(float32x4_t *)&vectorLeft,
                                  *(float32x4_t *)&vectorRight);
        return *(CCVector4 *)&v;
#else
        CCVector4 max = vectorLeft;
        if (vectorRight.v[0] > vectorLeft.v[0])
            max.v[0] = vectorRight.v[0];
        if (vectorRight.v[1] > vectorLeft.v[1])
            max.v[1] = vectorRight.v[1];
        if (vectorRight.v[2] > vectorLeft.v[2])
            max.v[2] = vectorRight.v[2];
        if (vectorRight.v[3] > vectorLeft.v[3])
            max.v[3] = vectorRight.v[3];
        return max;
#endif
    }
    
    /*
     Returns a vector whose elements are the smaller of the corresponding elements of the vector arguments.
     */
    static inline CCVector4 CCVector4Minimum(CCVector4 vectorLeft, CCVector4 vectorRight)
    {
#if defined(__ARM_NEON__)
        float32x4_t v = vminq_f32(*(float32x4_t *)&vectorLeft,
                                  *(float32x4_t *)&vectorRight);
        return *(CCVector4 *)&v;
#else
        CCVector4 min = vectorLeft;
        if (vectorRight.v[0] < vectorLeft.v[0])
            min.v[0] = vectorRight.v[0];
        if (vectorRight.v[1] < vectorLeft.v[1])
            min.v[1] = vectorRight.v[1];
        if (vectorRight.v[2] < vectorLeft.v[2])
            min.v[2] = vectorRight.v[2];
        if (vectorRight.v[3] < vectorLeft.v[3])
            min.v[3] = vectorRight.v[3];
        return min;
#endif
    }
    
    /*
     Returns true if all of the first vector's elements are equal to all of the second vector's arguments.
     */
    static inline bool CCVector4AllEqualToVector4(CCVector4 vectorLeft, CCVector4 vectorRight)
    {
#if defined(__ARM_NEON_)
        float32x4_t v1 = *(float32x4_t *)&vectorLeft;
        float32x4_t v2 = *(float32x4_t *)&vectorRight;
        uint32x4_t vCmp = vceqq_f32(v1, v2);
        uint32x2_t vAnd = vand_u32(vget_low_u32(vCmp), vget_high_u32(vCmp));
        vAnd = vand_u32(vAnd, vext_u32(vAnd, vAnd, 1));
        vAnd = vand_u32(vAnd, vdup_n_u32(1));
        return (bool)vget_lane_u32(vAnd, 0);
#else
        bool compare = false;
        if (vectorLeft.v[0] == vectorRight.v[0] &&
            vectorLeft.v[1] == vectorRight.v[1] &&
            vectorLeft.v[2] == vectorRight.v[2] &&
            vectorLeft.v[3] == vectorRight.v[3])
            compare = true;
        return compare;
#endif
    }
    
    /*
     Returns true if all of the vector's elements are equal to the provided value.
     */
    static inline bool CCVector4AllEqualToScalar(CCVector4 vector, float value)
    {
#if defined(__ARM_NEON_)
        float32x4_t v1 = *(float32x4_t *)&vector;
        float32x4_t v2 = vdupq_n_f32(value);
        uint32x4_t vCmp = vceqq_f32(v1, v2);
        uint32x2_t vAnd = vand_u32(vget_low_u32(vCmp), vget_high_u32(vCmp));
        vAnd = vand_u32(vAnd, vext_u32(vAnd, vAnd, 1));
        vAnd = vand_u32(vAnd, vdup_n_u32(1));
        return (bool)vget_lane_u32(vAnd, 0);
#else
        bool compare = false;
        if (vector.v[0] == value &&
            vector.v[1] == value &&
            vector.v[2] == value &&
            vector.v[3] == value)
            compare = true;
        return compare;
#endif
    }
    
    /*
     Returns true if all of the first vector's elements are greater than all of the second vector's arguments.
     */
    static inline bool CCVector4AllGreaterThanVector4(CCVector4 vectorLeft, CCVector4 vectorRight)
    {
#if defined(__ARM_NEON_)
        float32x4_t v1 = *(float32x4_t *)&vectorLeft;
        float32x4_t v2 = *(float32x4_t *)&vectorRight;
        uint32x4_t vCmp = vcgtq_f32(v1, v2);
        uint32x2_t vAnd = vand_u32(vget_low_u32(vCmp), vget_high_u32(vCmp));
        vAnd = vand_u32(vAnd, vext_u32(vAnd, vAnd, 1));
        vAnd = vand_u32(vAnd, vdup_n_u32(1));
        return (bool)vget_lane_u32(vAnd, 0);
#else
        bool compare = false;
        if (vectorLeft.v[0] > vectorRight.v[0] &&
            vectorLeft.v[1] > vectorRight.v[1] &&
            vectorLeft.v[2] > vectorRight.v[2] &&
            vectorLeft.v[3] > vectorRight.v[3])
            compare = true;
        return compare;
#endif
    }
    
    /*
     Returns true if all of the vector's elements are greater than the provided value.
     */
    static inline bool CCVector4AllGreaterThanScalar(CCVector4 vector, float value)
    {
#if defined(__ARM_NEON_)
        float32x4_t v1 = *(float32x4_t *)&vector;
        float32x4_t v2 = vdupq_n_f32(value);
        uint32x4_t vCmp = vcgtq_f32(v1, v2);
        uint32x2_t vAnd = vand_u32(vget_low_u32(vCmp), vget_high_u32(vCmp));
        vAnd = vand_u32(vAnd, vext_u32(vAnd, vAnd, 1));
        vAnd = vand_u32(vAnd, vdup_n_u32(1));
        return (bool)vget_lane_u32(vAnd, 0);
#else
        bool compare = false;
        if (vector.v[0] > value &&
            vector.v[1] > value &&
            vector.v[2] > value &&
            vector.v[3] > value)
            compare = true;
        return compare;
#endif
    }
    
    /*
     Returns true if all of the first vector's elements are greater than or equal to all of the second vector's arguments.
     */
    static inline bool CCVector4AllGreaterThanOrEqualToVector4(CCVector4 vectorLeft, CCVector4 vectorRight)
    {
#if defined(__ARM_NEON_)
        float32x4_t v1 = *(float32x4_t *)&vectorLeft;
        float32x4_t v2 = *(float32x4_t *)&vectorRight;
        uint32x4_t vCmp = vcgeq_f32(v1, v2);
        uint32x2_t vAnd = vand_u32(vget_low_u32(vCmp), vget_high_u32(vCmp));
        vAnd = vand_u32(vAnd, vext_u32(vAnd, vAnd, 1));
        vAnd = vand_u32(vAnd, vdup_n_u32(1));
        return (bool)vget_lane_u32(vAnd, 0);
#else
        bool compare = false;
        if (vectorLeft.v[0] >= vectorRight.v[0] &&
            vectorLeft.v[1] >= vectorRight.v[1] &&
            vectorLeft.v[2] >= vectorRight.v[2] &&
            vectorLeft.v[3] >= vectorRight.v[3])
            compare = true;
        return compare;
#endif
    }
    
    /*
     Returns true if all of the vector's elements are greater than or equal to the provided value.
     */
    static inline bool CCVector4AllGreaterThanOrEqualToScalar(CCVector4 vector, float value)
    {
#if defined(__ARM_NEON_)
        float32x4_t v1 = *(float32x4_t *)&vector;
        float32x4_t v2 = vdupq_n_f32(value);
        uint32x4_t vCmp = vcgeq_f32(v1, v2);
        uint32x2_t vAnd = vand_u32(vget_low_u32(vCmp), vget_high_u32(vCmp));
        vAnd = vand_u32(vAnd, vext_u32(vAnd, vAnd, 1));
        vAnd = vand_u32(vAnd, vdup_n_u32(1));
        return (bool)vget_lane_u32(vAnd, 0);
#else
        bool compare = false;
        if (vector.v[0] >= value &&
            vector.v[1] >= value &&
            vector.v[2] >= value &&
            vector.v[3] >= value)
            compare = true;
        return compare;
#endif
    }
    
    static inline float CCVector4Length(CCVector4 vector)
    {
#if defined(__ARM_NEON__)
        float32x4_t v = vmulq_f32(*(float32x4_t *)&vector,
                                  *(float32x4_t *)&vector);
        float32x2_t v2 = vpadd_f32(vget_low_f32(v), vget_high_f32(v));
        v2 = vpadd_f32(v2, v2);
        return sqrt(vget_lane_f32(v2, 0));
#else
        return sqrt(vector.v[0] * vector.v[0] +
                    vector.v[1] * vector.v[1] +
                    vector.v[2] * vector.v[2] +
                    vector.v[3] * vector.v[3]);
#endif
    }
    
    static inline CCVector4 CCVector4Normalize(CCVector4 vector)
    {
        float scale = 1.0f / CCVector4Length(vector);
        CCVector4 v = CCVector4MultiplyScalar(vector, scale);
        return v;
    }
    
    static inline float CCVector4DotProduct(CCVector4 vectorLeft, CCVector4 vectorRight)
    {
#if defined(__ARM_NEON__)
        float32x4_t v = vmulq_f32(*(float32x4_t *)&vectorLeft,
                                  *(float32x4_t *)&vectorRight);
        float32x2_t v2 = vpadd_f32(vget_low_f32(v), vget_high_f32(v));
        v2 = vpadd_f32(v2, v2);
        return vget_lane_f32(v2, 0);
#else
        return vectorLeft.v[0] * vectorRight.v[0] +
        vectorLeft.v[1] * vectorRight.v[1] +
        vectorLeft.v[2] * vectorRight.v[2] +
        vectorLeft.v[3] * vectorRight.v[3];
#endif
    }
    
    static inline float CCVector4Distance(CCVector4 vectorStart, CCVector4 vectorEnd)
    {
        return CCVector4Length(CCVector4Subtract(vectorEnd, vectorStart));
    }
    
    static inline CCVector4 CCVector4Lerp(CCVector4 vectorStart, CCVector4 vectorEnd, float t)
    {
#if defined(__ARM_NEON__)
        float32x4_t vDiff = vsubq_f32(*(float32x4_t *)&vectorEnd,
                                      *(float32x4_t *)&vectorStart);
        vDiff = vmulq_f32(vDiff, vdupq_n_f32((float32_t)t));
        float32x4_t v = vaddq_f32(*(float32x4_t *)&vectorStart, vDiff);
        return *(CCVector4 *)&v;
#else
        CCVector4 v = { { vectorStart.v[0] + ((vectorEnd.v[0] - vectorStart.v[0]) * t),
            vectorStart.v[1] + ((vectorEnd.v[1] - vectorStart.v[1]) * t),
            vectorStart.v[2] + ((vectorEnd.v[2] - vectorStart.v[2]) * t),
            vectorStart.v[3] + ((vectorEnd.v[3] - vectorStart.v[3]) * t) } };
        return v;
#endif
    }
    
    /*
     Performs a 3D cross product. The last component of the resulting cross product will be zeroed out.
     */
    static inline CCVector4 CCVector4CrossProduct(CCVector4 vectorLeft, CCVector4 vectorRight)
    {
        CCVector4 v = { { vectorLeft.v[1] * vectorRight.v[2] - vectorLeft.v[2] * vectorRight.v[1],
            vectorLeft.v[2] * vectorRight.v[0] - vectorLeft.v[0] * vectorRight.v[2],
            vectorLeft.v[0] * vectorRight.v[1] - vectorLeft.v[1] * vectorRight.v[0],
            0.0f } };
        return v;
    }
    
    /*
     Project the vector, vectorToProject, onto the vector, projectionVector.
     */
    static inline CCVector4 CCVector4Project(CCVector4 vectorToProject, CCVector4 projectionVector)
    {
        float scale = CCVector4DotProduct(projectionVector, vectorToProject) / CCVector4DotProduct(projectionVector, projectionVector);
        CCVector4 v = CCVector4MultiplyScalar(projectionVector, scale);
        return v;
    }
    
#ifdef __cplusplus
}
#endif

#define GLKVector4Make CCVector4Make
#define GLKVector4MakeWithArray CCVector4MakeWithArray
#define GLKVector4Negate CCVector4Negate
#define GLKVector4Add CCVector4Add
#define GLKVector4Subtract CCVector4Subtract
#define GLKVector4Multiply CCVector4Multiply
#define GLKVector4Divide CCVector4Divide
#define GLKVector4AddScalar CCVector4AddScalar
#define GLKVector4SubtractScalar CCVector4SubtractScalar
#define GLKVector4MultiplyScalar CCVector4MultiplyScalar
#define GLKVector4DivideScalar CCVector4DivideScalar
#define GLKVector4Maximum CCVector4Maximum
#define GLKVector4Minimum CCVector4Minimum
#define GLKVector4AllEqualToVector2 CCVector4AllEqualToVector2
#define GLKVector4AllEqualToScalar CCVector4AllEqualToScalar
#define GLKVector4AllGreaterThanVector2 CCVector4AllGreaterThanVector2
#define GLKVector4AllGreaterThanScalar CCVector4AllGreaterThanScalar
#define GLKVector4AllGreaterThanOrEqualToVector2 CCVector4AllGreaterThanOrEqualToVector2
#define GLKVector4AllGreaterThanOrEqualToScalar CCVector4AllGreaterThanOrEqualToScalar
#define GLKVector4Length CCVector4Length
#define GLKVector4Normalize CCVector4Normalize
#define GLKVector4DotProduct CCVector4DotProduct
#define GLKVector4Distance GLKVect
#define GLKVector4Lerp CCVector4Lerp
#define GLKVector4Project CCVector4Project
#define GLKVector4CrossProduct CCVector4CrossProduct

#endif /* __CC_VECTOR_4_H */

#endif

