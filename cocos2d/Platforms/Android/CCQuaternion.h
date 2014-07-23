//
//  CCQuaternion.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/10/14.
//
//

#ifndef __CC_QUATERNION_H
#define __CC_QUATERNION_H

#include <stddef.h>
#include <math.h>

#import "CCMathTypesAndroid.h"

#if __CC_PLATFORM_ANDROID

#import "CCVector3.h"
#import "CCVector4.h"

#ifdef __cplusplus
extern "C" {
#endif
    
    static const CCQuaternion CCQuaternionIdentity = { .x = 0, .y = 0, .z = 0, .w = 1 };

    CCQuaternion CCQuaternionMakeWithMatrix3(CCMatrix3 matrix);
    /*
     Calculate and return the angle component of the angle and axis form.
     */
    float CCQuaternionAngle(CCQuaternion quaternion);
    
    /*
     Calculate and return the axis component of the angle and axis form.
     */
    CCVector3 CCQuaternionAxis(CCQuaternion quaternion);
    
    CCQuaternion CCQuaternionSlerp(CCQuaternion quaternionStart, CCQuaternion quaternionEnd, float t);
    
    void CCQuaternionRotateVector3Array(CCQuaternion quaternion, CCVector3 *vectors, size_t vectorCount);
    
    CCQuaternion CCQuaternionMakeWithMatrix4(CCMatrix4 matrix);
    
    void CCQuaternionRotateVector4Array(CCQuaternion quaternion, CCVector4 *vectors, size_t vectorCount);
    
    /*
     x, y, and z represent the imaginary values.
     */
    static inline CCQuaternion CCQuaternionMake(float x, float y, float z, float w)
    {
        CCQuaternion q = { {{{x, y, z}}, w}  };
        return q;
    }
    
    /*
     vector represents the imaginary values.
     */
    static inline CCQuaternion CCQuaternionMakeWithVector3(CCVector3 vector, float scalar)
    {
        CCQuaternion q = { { {{vector.v[0], vector.v[1], vector.v[2]}}, scalar } };
        return q;
    }
    
    /*
     values[0], values[1], and values[2] represent the imaginary values.
     */
    static inline CCQuaternion CCQuaternionMakeWithArray(float values[4])
    {
        CCQuaternion q = { { {{values[0], values[1], values[2]}}, values[3] } };
        return q;
    }
    
    /*
     Assumes the axis is already normalized.
     */
    static inline CCQuaternion CCQuaternionMakeWithAngleAndAxis(float radians, float x, float y, float z)
    {
        float halfAngle = radians * 0.5f;
        float scale = sinf(halfAngle);
        CCQuaternion q = { { {{scale * x, scale * y, scale * z}}, cosf(halfAngle) } };
        return q;
    }
    
    /*
     Assumes the axis is already normalized.
     */
    static inline CCQuaternion CCQuaternionMakeWithAngleAndVector3Axis(float radians, CCVector3 axisVector)
    {
        return CCQuaternionMakeWithAngleAndAxis(radians, axisVector.v[0], axisVector.v[1], axisVector.v[2]);
    }
    
    static inline CCQuaternion CCQuaternionAdd(CCQuaternion quaternionLeft, CCQuaternion quaternionRight)
    {
#if defined(__ARM_NEON__)
        float32x4_t v = vaddq_f32(*(float32x4_t *)&quaternionLeft,
                                  *(float32x4_t *)&quaternionRight);
        return *(CCQuaternion *)&v;
#else
        CCQuaternion q = {
            .x = quaternionLeft.q[0] + quaternionRight.q[0],
            .y = quaternionLeft.q[1] + quaternionRight.q[1],
            .z = quaternionLeft.q[2] + quaternionRight.q[2],
            .w = quaternionLeft.q[3] + quaternionRight.q[3]
        };
        return q;
#endif
    }
    
    static inline CCQuaternion CCQuaternionSubtract(CCQuaternion quaternionLeft, CCQuaternion quaternionRight)
    {
#if defined(__ARM_NEON__)
        float32x4_t v = vsubq_f32(*(float32x4_t *)&quaternionLeft,
                                  *(float32x4_t *)&quaternionRight);
        return *(CCQuaternion *)&v;
#else
        CCQuaternion q = {
            .x = quaternionLeft.q[0] - quaternionRight.q[0],
            .y = quaternionLeft.q[1] - quaternionRight.q[1],
            .z = quaternionLeft.q[2] - quaternionRight.q[2],
            .w = quaternionLeft.q[3] - quaternionRight.q[3]
        };
        return q;
#endif
    }
    
    static inline CCQuaternion CCQuaternionMultiply(CCQuaternion quaternionLeft, CCQuaternion quaternionRight)
    {
        CCQuaternion q = {
            .x = quaternionLeft.q[3] * quaternionRight.q[0] +
            quaternionLeft.q[0] * quaternionRight.q[3] +
            quaternionLeft.q[1] * quaternionRight.q[2] -
            quaternionLeft.q[2] * quaternionRight.q[1],
            
            .y = quaternionLeft.q[3] * quaternionRight.q[1] +
            quaternionLeft.q[1] * quaternionRight.q[3] +
            quaternionLeft.q[2] * quaternionRight.q[0] -
            quaternionLeft.q[0] * quaternionRight.q[2],
            
            .z = quaternionLeft.q[3] * quaternionRight.q[2] +
            quaternionLeft.q[2] * quaternionRight.q[3] +
            quaternionLeft.q[0] * quaternionRight.q[1] -
            quaternionLeft.q[1] * quaternionRight.q[0],
            
            .w = quaternionLeft.q[3] * quaternionRight.q[3] -
            quaternionLeft.q[0] * quaternionRight.q[0] -
            quaternionLeft.q[1] * quaternionRight.q[1] -
            quaternionLeft.q[2] * quaternionRight.q[2] };
        return q;
    }
    
    static inline float CCQuaternionLength(CCQuaternion quaternion)
    {
#if defined(__ARM_NEON__)
        float32x4_t v = vmulq_f32(*(float32x4_t *)&quaternion,
                                  *(float32x4_t *)&quaternion);
        float32x2_t v2 = vpadd_f32(vget_low_f32(v), vget_high_f32(v));
        v2 = vpadd_f32(v2, v2);
        return sqrt(vget_lane_f32(v2, 0));
#else
        return sqrt(quaternion.q[0] * quaternion.q[0] +
                    quaternion.q[1] * quaternion.q[1] +
                    quaternion.q[2] * quaternion.q[2] +
                    quaternion.q[3] * quaternion.q[3]);
#endif
    }
    
    static inline CCQuaternion CCQuaternionConjugate(CCQuaternion quaternion)
    {
#if defined(__ARM_NEON__)
        float32x4_t *q = (float32x4_t *)&quaternion;
        
        uint32_t signBit = 0x80000000;
        uint32_t zeroBit = 0x0;
        uint32x4_t mask = vdupq_n_u32(signBit);
        mask = vsetq_lane_u32(zeroBit, mask, 3);
        *q = vreinterpretq_f32_u32(veorq_u32(vreinterpretq_u32_f32(*q), mask));
        
        return *(CCQuaternion *)q;
#else
        CCQuaternion q = {
            .x = -quaternion.q[0],
            .y = -quaternion.q[1],
            .z = -quaternion.q[2],
            .w = quaternion.q[3]
        };
        return q;
#endif
    }
    
    static inline CCQuaternion CCQuaternionInvert(CCQuaternion quaternion)
    {
#if defined(__ARM_NEON__)
        float32x4_t *q = (float32x4_t *)&quaternion;
        float32x4_t v = vmulq_f32(*q, *q);
        float32x2_t v2 = vpadd_f32(vget_low_f32(v), vget_high_f32(v));
        v2 = vpadd_f32(v2, v2);
        float32_t scale = 1.0f / vget_lane_f32(v2, 0);
        v = vmulq_f32(*q, vdupq_n_f32(scale));
        
        uint32_t signBit = 0x80000000;
        uint32_t zeroBit = 0x0;
        uint32x4_t mask = vdupq_n_u32(signBit);
        mask = vsetq_lane_u32(zeroBit, mask, 3);
        v = vreinterpretq_f32_u32(veorq_u32(vreinterpretq_u32_f32(v), mask));
        
        return *(CCQuaternion *)&v;
#else
        float scale = 1.0f / (quaternion.q[0] * quaternion.q[0] +
                              quaternion.q[1] * quaternion.q[1] +
                              quaternion.q[2] * quaternion.q[2] +
                              quaternion.q[3] * quaternion.q[3]);
        CCQuaternion q = {
            .x = -quaternion.q[0] * scale,
            .y = -quaternion.q[1] * scale,
            .z = -quaternion.q[2] * scale,
            .w = quaternion.q[3] * scale
        };
        return q;
#endif
    }
    
    static inline CCQuaternion CCQuaternionNormalize(CCQuaternion quaternion)
    {
        float scale = 1.0f / CCQuaternionLength(quaternion);
#if defined(__ARM_NEON__)
        float32x4_t v = vmulq_f32(*(float32x4_t *)&quaternion,
                                  vdupq_n_f32((float32_t)scale));
        return *(CCQuaternion *)&v;
#else
        CCQuaternion q = {
            .x = quaternion.q[0] * scale,
            .y = quaternion.q[1] * scale,
            .z = quaternion.q[2] * scale,
            .w = quaternion.q[3] * scale
        };
        return q;
#endif
    }
    
    static inline CCVector3 CCQuaternionRotateVector3(CCQuaternion quaternion, CCVector3 vector)
    {
        CCQuaternion rotatedQuaternion = CCQuaternionMake(vector.v[0], vector.v[1], vector.v[2], 0.0f);
        rotatedQuaternion = CCQuaternionMultiply(CCQuaternionMultiply(quaternion, rotatedQuaternion), CCQuaternionInvert(quaternion));
        
        return CCVector3Make(rotatedQuaternion.q[0], rotatedQuaternion.q[1], rotatedQuaternion.q[2]);
    }
    
    /*
     The fourth component of the vector is ignored when calculating the rotation.
     */
    static inline CCVector4 CCQuaternionRotateVector4(CCQuaternion quaternion, CCVector4 vector)
    {
        CCQuaternion rotatedQuaternion = CCQuaternionMake(vector.v[0], vector.v[1], vector.v[2], 0.0f);
        rotatedQuaternion = CCQuaternionMultiply(CCQuaternionMultiply(quaternion, rotatedQuaternion), CCQuaternionInvert(quaternion));
        
        return CCVector4Make(rotatedQuaternion.q[0], rotatedQuaternion.q[1], rotatedQuaternion.q[2], vector.v[3]);
    }
    
#ifdef __cplusplus
}
#endif

#define GLKQuaternionIdentity CCQuaternionIdentity
#define GLKQuaternionMakeWithMatrix3 CCQuaternionMakeWithMatrix3
#define GLKQuaternionAngle CCQuaternionAngle
#define GLKQuaternionAxis CCQuaternionAxis
#define GLKQuaternionSlerp CCQuaternionSlerp
#define GLKQuaternionRotateVector3Array CCQuaternionRotateVector3Array
#define GLKQuaternionMakeWithMatrix4 CCQuaternionMakeWithMatrix4
#define GLKQuaternionRotateVector4Array CCQuaternionRotateVector4Array
#define GLKQuaternionMake CCQuaternionMake
#define GLKQuaternionMakeWithVector3 CCQuaternionMakeWithVector3
#define GLKQuaternionMakeWithArray CCQuaternionMakeWithArray
#define GLKQuaternionMakeWithAngleAndAxis CCQuaternionMakeWithAngleAndAxis
#define GLKQuaternionIdentity CCQuaternionIdentity
#define GLKQuaternionMakeWithAngleAndVector3Axis CCQuaternionMakeWithAngleAndVector3Axis
#define GLKQuaternionAdd CCQuaternionAdd
#define GLKQuaternionSubtract CCQuaternionSubtract
#define GLKQuaternionMultiply CCQuaternionMultiply
#define GLKQuaternionLength CCQuaternionLength
#define GLKQuaternionConjugate CCQuaternionConjugate
#define GLKQuaternionInvert CCQuaternionInvert
#define GLKQuaternionNormalize CCQuaternionNormalize
#define GLKQuaternionRotateVector3 CCQuaternionRotateVector3
#define GLKQuaternionRotateVector4 CCQuaternionRotateVector4

#endif

#endif /* __CC_QUATERNION_H */
