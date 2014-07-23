//
//  CCVector2.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/10/14.
//
//

#ifndef __CC_VECTOR_2_H
#define __CC_VECTOR_2_H

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
    
    static inline CCVector2 CCVector2Make(float x, float y)
    {
        CCVector2 v = { { x, y } };
        return v;
    }
    
    static inline CCVector2 CCVector2MakeWithArray(float values[2])
    {
#if defined(__ARM_NEON__)
        float32x2_t v = vld1_f32(values);
        return *(CCVector2 *)&v;
#else
        CCVector2 v = { { values[0], values[1] } };
        return v;
#endif
    }
    
    static inline CCVector2 CCVector2Negate(CCVector2 vector)
    {
#if defined(__ARM_NEON__)
        float32x2_t v = vneg_f32(*(float32x2_t *)&vector);
        return *(CCVector2 *)&v;
#else
        CCVector2 v = { { -vector.v[0] , -vector.v[1] } };
        return v;
#endif
    }
    
    static inline CCVector2 CCVector2Add(CCVector2 vectorLeft, CCVector2 vectorRight)
    {
#if defined(__ARM_NEON__)
        float32x2_t v = vadd_f32(*(float32x2_t *)&vectorLeft,
                                 *(float32x2_t *)&vectorRight);
        return *(CCVector2 *)&v;
#else
        CCVector2 v = { { vectorLeft.v[0] + vectorRight.v[0],
            vectorLeft.v[1] + vectorRight.v[1] } };
        return v;
#endif
    }
    
    static inline CCVector2 CCVector2Subtract(CCVector2 vectorLeft, CCVector2 vectorRight)
    {
#if defined(__ARM_NEON__)
        float32x2_t v = vsub_f32(*(float32x2_t *)&vectorLeft,
                                 *(float32x2_t *)&vectorRight);
        return *(CCVector2 *)&v;
#else
        CCVector2 v = { { vectorLeft.v[0] - vectorRight.v[0],
            vectorLeft.v[1] - vectorRight.v[1] } };
        return v;
#endif
    }
    
    static inline CCVector2 CCVector2Multiply(CCVector2 vectorLeft, CCVector2 vectorRight)
    {
#if defined(__ARM_NEON__)
        float32x2_t v = vmul_f32(*(float32x2_t *)&vectorLeft,
                                 *(float32x2_t *)&vectorRight);
        return *(CCVector2 *)&v;
#else
        CCVector2 v = { { vectorLeft.v[0] * vectorRight.v[0],
            vectorLeft.v[1] * vectorRight.v[1] } };
        return v;
#endif
    }
    
    static inline CCVector2 CCVector2Divide(CCVector2 vectorLeft, CCVector2 vectorRight)
    {
#if defined(__ARM_NEON__)
        float32x2_t *vLeft = (float32x2_t *)&vectorLeft;
        float32x2_t *vRight = (float32x2_t *)&vectorRight;
        float32x2_t estimate = vrecpe_f32(*vRight);
        estimate = vmul_f32(vrecps_f32(*vRight, estimate), estimate);
        estimate = vmul_f32(vrecps_f32(*vRight, estimate), estimate);
        float32x2_t v = vmul_f32(*vLeft, estimate);
        return *(CCVector2 *)&v;
#else
        CCVector2 v = { { vectorLeft.v[0] / vectorRight.v[0],
            vectorLeft.v[1] / vectorRight.v[1] } };
        return v;
#endif
    }
    
    static inline CCVector2 CCVector2AddScalar(CCVector2 vector, float value)
    {
#if defined(__ARM_NEON__)
        float32x2_t v = vadd_f32(*(float32x2_t *)&vector,
                                 vdup_n_f32((float32_t)value));
        return *(CCVector2 *)&v;
#else
        CCVector2 v = { { vector.v[0] + value,
            vector.v[1] + value } };
        return v;
#endif
    }
    
    static inline CCVector2 CCVector2SubtractScalar(CCVector2 vector, float value)
    {
#if defined(__ARM_NEON__)
        float32x2_t v = vsub_f32(*(float32x2_t *)&vector,
                                 vdup_n_f32((float32_t)value));
        return *(CCVector2 *)&v;
#else
        CCVector2 v = { { vector.v[0] - value,
            vector.v[1] - value } };
        return v;
#endif
    }
    
    static inline CCVector2 CCVector2MultiplyScalar(CCVector2 vector, float value)
    {
#if defined(__ARM_NEON__)
        float32x2_t v = vmul_f32(*(float32x2_t *)&vector,
                                 vdup_n_f32((float32_t)value));
        return *(CCVector2 *)&v;
#else
        CCVector2 v = { { vector.v[0] * value,
            vector.v[1] * value } };
        return v;
#endif
    }
    
    static inline CCVector2 CCVector2DivideScalar(CCVector2 vector, float value)
    {
#if defined(__ARM_NEON__)
        float32x2_t values = vdup_n_f32((float32_t)value);
        float32x2_t estimate = vrecpe_f32(values);
        estimate = vmul_f32(vrecps_f32(values, estimate), estimate);
        estimate = vmul_f32(vrecps_f32(values, estimate), estimate);
        float32x2_t v = vmul_f32(*(float32x2_t *)&vector, estimate);
        return *(CCVector2 *)&v;
#else
        CCVector2 v = { { vector.v[0] / value,
            vector.v[1] / value } };
        return v;
#endif
    }
    
    /*
     Returns a vector whose elements are the larger of the corresponding elements of the vector arguments.
     */
    static inline CCVector2 CCVector2Maximum(CCVector2 vectorLeft, CCVector2 vectorRight)
    {
#if defined(__ARM_NEON__)
        float32x2_t v = vmax_f32(*(float32x2_t *)&vectorLeft,
                                 *(float32x2_t *)&vectorRight);
        return *(CCVector2 *)&v;
#else
        CCVector2 max = vectorLeft;
        if (vectorRight.v[0] > vectorLeft.v[0])
            max.v[0] = vectorRight.v[0];
        if (vectorRight.v[1] > vectorLeft.v[1])
            max.v[1] = vectorRight.v[1];
        return max;
#endif
    }
    
    /*
     Returns a vector whose elements are the smaller of the corresponding elements of the vector arguments.
     */
    static inline CCVector2 CCVector2Minimum(CCVector2 vectorLeft, CCVector2 vectorRight)
    {
#if defined(__ARM_NEON__)
        float32x2_t v = vmin_f32(*(float32x2_t *)&vectorLeft,
                                 *(float32x2_t *)&vectorRight);
        return *(CCVector2 *)&v;
#else
        CCVector2 min = vectorLeft;
        if (vectorRight.v[0] < vectorLeft.v[0])
            min.v[0] = vectorRight.v[0];
        if (vectorRight.v[1] < vectorLeft.v[1])
            min.v[1] = vectorRight.v[1];
        return min;
#endif
    }
    
    /*
     Returns true if all of the first vector's elements are equal to all of the second vector's arguments.
     */
    static inline bool CCVector2AllEqualToVector2(CCVector2 vectorLeft, CCVector2 vectorRight)
    {
#if defined(__ARM_NEON_)
        float32x2_t v1 = *(float32x2_t *)&vectorLeft;
        float32x2_t v2 = *(float32x2_t *)&vectorRight;
        uint32x2_t vCmp = vceq_f32(v1, v2);
        uint32x2_t vAnd = vand_u32(vCmp, vext_u32(vCmp, vCmp, 1));
        vAnd = vand_u32(vAnd, vdup_n_u32(1));
        return (bool)vget_lane_u32(vAnd, 0);
#else
        bool compare = false;
        if (vectorLeft.v[0] == vectorRight.v[0] &&
            vectorLeft.v[1] == vectorRight.v[1])
            compare = true;
        return compare;
#endif
    }
    
    /*
     Returns true if all of the vector's elements are equal to the provided value.
     */
    static inline bool CCVector2AllEqualToScalar(CCVector2 vector, float value)
    {
#if defined(__ARM_NEON_)
        float32x2_t v1 = *(float32x2_t *)&vector;
        float32x2_t v2 = vdup_n_f32(value);
        uint32x2_t vCmp = vceq_f32(v1, v2);
        uint32x2_t vAnd = vand_u32(vCmp, vext_u32(vCmp, vCmp, 1));
        vAnd = vand_u32(vAnd, vdup_n_u32(1));
        return (bool)vget_lane_u32(vAnd, 0);
#else
        bool compare = false;
        if (vector.v[0] == value &&
            vector.v[1] == value)
            compare = true;
        return compare;
#endif
    }
    
    /*
     Returns true if all of the first vector's elements are greater than all of the second vector's arguments.
     */
    static inline bool CCVector2AllGreaterThanVector2(CCVector2 vectorLeft, CCVector2 vectorRight)
    {
#if defined(__ARM_NEON_)
        float32x2_t v1 = *(float32x2_t *)&vectorLeft;
        float32x2_t v2 = *(float32x2_t *)&vectorRight;
        uint32x2_t vCmp = vcgt_f32(v1, v2);
        uint32x2_t vAnd = vand_u32(vCmp, vext_u32(vCmp, vCmp, 1));
        vAnd = vand_u32(vAnd, vdup_n_u32(1));
        return (bool)vget_lane_u32(vAnd, 0);
#else
        bool compare = false;
        if (vectorLeft.v[0] > vectorRight.v[0] &&
            vectorLeft.v[1] > vectorRight.v[1])
            compare = true;
        return compare;
#endif
    }
    
    /*
     Returns true if all of the vector's elements are greater than the provided value.
     */
    static inline bool CCVector2AllGreaterThanScalar(CCVector2 vector, float value)
    {
#if defined(__ARM_NEON_)
        float32x2_t v1 = *(float32x2_t *)&vector;
        float32x2_t v2 = vdup_n_f32(value);
        uint32x2_t vCmp = vcgt_f32(v1, v2);
        uint32x2_t vAnd = vand_u32(vCmp, vext_u32(vCmp, vCmp, 1));
        vAnd = vand_u32(vAnd, vdup_n_u32(1));
        return (bool)vget_lane_u32(vAnd, 0);
#else
        bool compare = false;
        if (vector.v[0] > value &&
            vector.v[1] > value)
            compare = true;
        return compare;
#endif
    }
    
    /*
     Returns true if all of the first vector's elements are greater than or equal to all of the second vector's arguments.
     */
    static inline bool CCVector2AllGreaterThanOrEqualToVector2(CCVector2 vectorLeft, CCVector2 vectorRight)
    {
#if defined(__ARM_NEON_)
        float32x2_t v1 = *(float32x2_t *)&vectorLeft;
        float32x2_t v2 = *(float32x2_t *)&vectorRight;
        uint32x2_t vCmp = vcge_f32(v1, v2);
        uint32x2_t vAnd = vand_u32(vCmp, vext_u32(vCmp, vCmp, 1));
        vAnd = vand_u32(vAnd, vdup_n_u32(1));
        return (bool)vget_lane_u32(vAnd, 0);
#else
        bool compare = false;
        if (vectorLeft.v[0] >= vectorRight.v[0] &&
            vectorLeft.v[1] >= vectorRight.v[1])
            compare = true;
        return compare;
#endif
    }
    
    /*
     Returns true if all of the vector's elements are greater than or equal to the provided value.
     */
    static inline bool CCVector2AllGreaterThanOrEqualToScalar(CCVector2 vector, float value)
    {
#if defined(__ARM_NEON_)
        float32x2_t v1 = *(float32x2_t *)&vector;
        float32x2_t v2 = vdup_n_f32(value);
        uint32x2_t vCmp = vcge_f32(v1, v2);
        uint32x2_t vAnd = vand_u32(vCmp, vext_u32(vCmp, vCmp, 1));
        vAnd = vand_u32(vAnd, vdup_n_u32(1));
        return (bool)vget_lane_u32(vAnd, 0);
#else
        bool compare = false;
        if (vector.v[0] >= value &&
            vector.v[1] >= value)
            compare = true;
        return compare;
#endif
    }
    
    static inline float CCVector2Length(CCVector2 vector)
    {
#if defined(__ARM_NEON__)
        float32x2_t v = vmul_f32(*(float32x2_t *)&vector,
                                 *(float32x2_t *)&vector);
        v = vpadd_f32(v, v);
        return sqrt(vget_lane_f32(v, 0));
#else
        return sqrt(vector.v[0] * vector.v[0] + vector.v[1] * vector.v[1]);
#endif
    }
    
    static inline CCVector2 CCVector2Normalize(CCVector2 vector)
    {
        float scale = 1.0f / CCVector2Length(vector);
        CCVector2 v = CCVector2MultiplyScalar(vector, scale);
        return v;
    }
    
    static inline float CCVector2DotProduct(CCVector2 vectorLeft, CCVector2 vectorRight)
    {
#if defined(__ARM_NEON__)
        float32x2_t v = vmul_f32(*(float32x2_t *)&vectorLeft,
                                 *(float32x2_t *)&vectorRight);
        v = vpadd_f32(v, v);
        return vget_lane_f32(v, 0);
#else
        return vectorLeft.v[0] * vectorRight.v[0] + vectorLeft.v[1] * vectorRight.v[1];
#endif
    }
    
    static inline float CCVector2Distance(CCVector2 vectorStart, CCVector2 vectorEnd)
    {
        return CCVector2Length(CCVector2Subtract(vectorEnd, vectorStart));
    }
    
    static inline CCVector2 CCVector2Lerp(CCVector2 vectorStart, CCVector2 vectorEnd, float t)
    {
#if defined(__ARM_NEON__)
        float32x2_t vDiff = vsub_f32(*(float32x2_t *)&vectorEnd,
                                     *(float32x2_t *)&vectorStart);
        vDiff = vmul_f32(vDiff, vdup_n_f32((float32_t)t));
        float32x2_t v = vadd_f32(*(float32x2_t *)&vectorStart, vDiff);
        return *(CCVector2 *)&v;
#else
        CCVector2 v = { { vectorStart.v[0] + ((vectorEnd.v[0] - vectorStart.v[0]) * t),
            vectorStart.v[1] + ((vectorEnd.v[1] - vectorStart.v[1]) * t) } };
        return v;
#endif
    }
    
    /*
     Project the vector, vectorToProject, onto the vector, projectionVector.
     */
    static inline CCVector2 CCVector2Project(CCVector2 vectorToProject, CCVector2 projectionVector)
    {
        float scale = CCVector2DotProduct(projectionVector, vectorToProject) / CCVector2DotProduct(projectionVector, projectionVector);
        CCVector2 v = CCVector2MultiplyScalar(projectionVector, scale);
        return v;
    }
    
#ifdef __cplusplus
}
#endif

#define GLKVector2Make CCVector2Make
#define GLKVector2MakeWithArray CCVector2MakeWithArray
#define GLKVector2Negate CCVector2Negate
#define GLKVector2Add CCVector2Add
#define GLKVector2Subtract CCVector2Subtract
#define GLKVector2Multiply CCVector2Multiply
#define GLKVector2Divide CCVector2Divide
#define GLKVector2AddScalar CCVector2AddScalar
#define GLKVector2SubtractScalar CCVector2SubtractScalar
#define GLKVector2MultiplyScalar CCVector2MultiplyScalar
#define GLKVector2DivideScalar CCVector2DivideScalar
#define GLKVector2Maximum CCVector2Maximum
#define GLKVector2Minimum CCVector2Minimum
#define GLKVector2AllEqualToVector2 CCVector2AllEqualToVector2
#define GLKVector2AllEqualToScalar CCVector2AllEqualToScalar
#define GLKVector2AllGreaterThanVector2 CCVector2AllGreaterThanVector2
#define GLKVector2AllGreaterThanScalar CCVector2AllGreaterThanScalar
#define GLKVector2AllGreaterThanOrEqualToVector2 CCVector2AllGreaterThanOrEqualToVector2
#define GLKVector2AllGreaterThanOrEqualToScalar CCVector2AllGreaterThanOrEqualToScalar
#define GLKVector2Length CCVector2Length
#define GLKVector2Normalize CCVector2Normalize
#define GLKVector2DotProduct CCVector2DotProduct
#define GLKVector2Distance CCVector2Distance
#define GLKVector2Lerp CCVector2Lerp
#define GLKVector2Project CCVector2Project

#endif

#endif /* __CC_VECTOR_2_H */


