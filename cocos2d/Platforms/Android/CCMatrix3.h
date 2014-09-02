//
//  CCMatrix3.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/10/14.
//
//
#ifndef __CC_MATRIX_3_H
#define __CC_MATRIX_3_H

#include <stddef.h>
#include <stdbool.h>
#include <math.h>

#if defined(__ARM_NEON__)
#include <arm_neon.h>
#endif

#import "CCMathTypesAndroid.h"
#import "CCVector3.h"
#import "CCQuaternion.h"

#if __CC_PLATFORM_ANDROID

#ifdef __cplusplus
extern "C" {
#endif
    
#pragma mark -
#pragma mark Prototypes
#pragma mark -
    
    static const CCMatrix3 CCMatrix3Identity = { {1, 0, 0,
        0, 1, 0,
        0, 0, 1} };
    
    CCMatrix3 CCMatrix3Invert(CCMatrix3 matrix, bool *isInvertible);
    CCMatrix3 CCMatrix3InvertAndTranspose(CCMatrix3 matrix, bool *isInvertible);
    
#pragma mark -
#pragma mark Implementations
#pragma mark -
    
    static inline CCMatrix3 CCMatrix3Make(float m00, float m01, float m02,
                                                float m10, float m11, float m12,
                                                float m20, float m21, float m22)
    {
        CCMatrix3 m = { { m00, m01, m02,
            m10, m11, m12,
            m20, m21, m22 } };
        return m;
    }
    
    static inline CCMatrix3 CCMatrix3MakeAndTranspose(float m00, float m01, float m02,
                                                            float m10, float m11, float m12,
                                                            float m20, float m21, float m22)
    {
        CCMatrix3 m = { { m00, m10, m20,
            m01, m11, m21,
            m02, m12, m22} };
        return m;
    }
    
    static inline CCMatrix3 CCMatrix3MakeWithArray(float values[9])
    {
        CCMatrix3 m = { { values[0], values[1], values[2],
            values[3], values[4], values[5],
            values[6], values[7], values[8] } };
        return m;
    }
    
    static inline CCMatrix3 CCMatrix3MakeWithArrayAndTranspose(float values[9])
    {
        CCMatrix3 m = { { values[0], values[3], values[6],
            values[1], values[4], values[7],
            values[2], values[5], values[8] } };
        return m;
    }
    
    static inline CCMatrix3 CCMatrix3MakeWithRows(CCVector3 row0,
                                                        CCVector3 row1,
                                                        CCVector3 row2)
    {
        CCMatrix3 m = { { row0.v[0], row1.v[0], row2.v[0],
            row0.v[1], row1.v[1], row2.v[1],
            row0.v[2], row1.v[2], row2.v[2] } };
        return m;
    }
    
    static inline CCMatrix3 CCMatrix3MakeWithColumns(CCVector3 column0,
                                                           CCVector3 column1,
                                                           CCVector3 column2)
    {
        CCMatrix3 m = { { column0.v[0], column0.v[1], column0.v[2],
            column1.v[0], column1.v[1], column1.v[2],
            column2.v[0], column2.v[1], column2.v[2] } };
        return m;
    }
    
    /*
     The quaternion will be normalized before conversion.
     */
    static inline CCMatrix3 CCMatrix3MakeWithQuaternion(CCQuaternion quaternion)
    {
        quaternion = CCQuaternionNormalize(quaternion);
        
        float x = quaternion.q[0];
        float y = quaternion.q[1];
        float z = quaternion.q[2];
        float w = quaternion.q[3];
        
        float _2x = x + x;
        float _2y = y + y;
        float _2z = z + z;
        float _2w = w + w;
        
        CCMatrix3 m = { { 1.0f - _2y * y - _2z * z,
            _2x * y + _2w * z,
            _2x * z - _2w * y,
            
            _2x * y - _2w * z,
            1.0f - _2x * x - _2z * z,
            _2y * z + _2w * x,
            
            _2x * z + _2w * y,
            _2y * z - _2w * x,
            1.0f - _2x * x - _2y * y } };
        
        return m;
    }
    
    static inline CCMatrix3 CCMatrix3MakeScale(float sx, float sy, float sz)
    {
        CCMatrix3 m = CCMatrix3Identity;
        m.m[0] = sx;
        m.m[4] = sy;
        m.m[8] = sz;
        return m;
    }
    
    static inline CCMatrix3 CCMatrix3MakeRotation(float radians, float x, float y, float z)
    {
        CCVector3 v = CCVector3Normalize(CCVector3Make(x, y, z));
        float cos = cosf(radians);
        float cosp = 1.0f - cos;
        float sin = sinf(radians);
        
        CCMatrix3 m = { { cos + cosp * v.v[0] * v.v[0],
            cosp * v.v[0] * v.v[1] + v.v[2] * sin,
            cosp * v.v[0] * v.v[2] - v.v[1] * sin,
            
            cosp * v.v[0] * v.v[1] - v.v[2] * sin,
            cos + cosp * v.v[1] * v.v[1],
            cosp * v.v[1] * v.v[2] + v.v[0] * sin,
            
            cosp * v.v[0] * v.v[2] + v.v[1] * sin,
            cosp * v.v[1] * v.v[2] - v.v[0] * sin,
            cos + cosp * v.v[2] * v.v[2] } };
        
        return m;
    }
    
    static inline CCMatrix3 CCMatrix3MakeXRotation(float radians)
    {
        float cos = cosf(radians);
        float sin = sinf(radians);
        
        CCMatrix3 m = { { 1.0f, 0.0f, 0.0f,
            0.0f, cos, sin,
            0.0f, -sin, cos } };
        
        return m;
    }
    
    static inline CCMatrix3 CCMatrix3MakeYRotation(float radians)
    {
        float cos = cosf(radians);
        float sin = sinf(radians);
        
        CCMatrix3 m = { { cos, 0.0f, -sin,
            0.0f, 1.0f, 0.0f,
            sin, 0.0f, cos } };
        
        return m;
    }
    
    static inline CCMatrix3 CCMatrix3MakeZRotation(float radians)
    {
        float cos = cosf(radians);
        float sin = sinf(radians);
        
        CCMatrix3 m = { { cos, sin, 0.0f,
            -sin, cos, 0.0f,
            0.0f, 0.0f, 1.0f } };
        
        return m;
    }
    
    /*
     Returns the upper left 2x2 portion of the 3x3 matrix.
     */
    static inline CCMatrix2 CCMatrix3GetMatrix2(CCMatrix3 matrix)
    {
        CCMatrix2 m = { { matrix.m[0], matrix.m[1],
            matrix.m[3], matrix.m[4] } };
        return m;
    }
    
    static inline CCVector3 CCMatrix3GetRow(CCMatrix3 matrix, int row)
    {
        CCVector3 v = { { matrix.m[row], matrix.m[3 + row], matrix.m[6 + row] } };
        return v;
    }
    
    static inline CCVector3 CCMatrix3GetColumn(CCMatrix3 matrix, int column)
    {
#if defined(__ARM_NEON__)
        CCVector3 v;
        *((float32x2_t *)&v) = vld1_f32(&(matrix.m[column * 3]));
        v.v[2] = matrix.m[column * 3 + 2];
        return v;
#else
        CCVector3 v = { { matrix.m[column * 3 + 0], matrix.m[column * 3 + 1], matrix.m[column * 3 + 2] } };
        return v;
#endif
    }
    
    static inline CCMatrix3 CCMatrix3SetRow(CCMatrix3 matrix, int row, CCVector3 vector)
    {
        matrix.m[row] = vector.v[0];
        matrix.m[row + 3] = vector.v[1];
        matrix.m[row + 6] = vector.v[2];
        
        return matrix;
    }
    
    static inline CCMatrix3 CCMatrix3SetColumn(CCMatrix3 matrix, int column, CCVector3 vector)
    {
#if defined(__ARM_NEON__)
        float *dst = &(matrix.m[column * 3]);
        vst1_f32(dst, vld1_f32(vector.v));
        dst[2] = vector.v[2];
        return matrix;
#else
        matrix.m[column * 3 + 0] = vector.v[0];
        matrix.m[column * 3 + 1] = vector.v[1];
        matrix.m[column * 3 + 2] = vector.v[2];
        
        return matrix;
#endif
    }
    
    static inline CCMatrix3 CCMatrix3Transpose(CCMatrix3 matrix)
    {
        CCMatrix3 m = { { matrix.m[0], matrix.m[3], matrix.m[6],
            matrix.m[1], matrix.m[4], matrix.m[7],
            matrix.m[2], matrix.m[5], matrix.m[8] } };
        return m;
    }
    
    static inline CCMatrix3 CCMatrix3Multiply(CCMatrix3 matrixLeft, CCMatrix3 matrixRight)
    {
#if defined(__ARM_NEON__)
        CCMatrix3 m;
        float32x4x3_t iMatrixLeft;
        float32x4x3_t iMatrixRight;
        float32x4x3_t mm;
        
        iMatrixLeft.val[0] = *(float32x4_t *)&matrixLeft.m[0]; // 0 1 2 3
        iMatrixLeft.val[1] = *(float32x4_t *)&matrixLeft.m[3]; // 3 4 5 6
        iMatrixLeft.val[2] = *(float32x4_t *)&matrixLeft.m[5]; // 5 6 7 8
        
        iMatrixRight.val[0] = *(float32x4_t *)&matrixRight.m[0];
        iMatrixRight.val[1] = *(float32x4_t *)&matrixRight.m[3];
        iMatrixRight.val[2] = *(float32x4_t *)&matrixRight.m[5];
        
        iMatrixLeft.val[2] = vextq_f32(iMatrixLeft.val[2], iMatrixLeft.val[2], 1); // 6 7 8 x
        
        mm.val[0] = vmulq_n_f32(iMatrixLeft.val[0], vgetq_lane_f32(iMatrixRight.val[0], 0));
        mm.val[1] = vmulq_n_f32(iMatrixLeft.val[0], vgetq_lane_f32(iMatrixRight.val[0], 3));
        mm.val[2] = vmulq_n_f32(iMatrixLeft.val[0], vgetq_lane_f32(iMatrixRight.val[1], 3));
        
        mm.val[0] = vmlaq_n_f32(mm.val[0], iMatrixLeft.val[1], vgetq_lane_f32(iMatrixRight.val[0], 1));
        mm.val[1] = vmlaq_n_f32(mm.val[1], iMatrixLeft.val[1], vgetq_lane_f32(iMatrixRight.val[1], 1));
        mm.val[2] = vmlaq_n_f32(mm.val[2], iMatrixLeft.val[1], vgetq_lane_f32(iMatrixRight.val[2], 2));
        
        mm.val[0] = vmlaq_n_f32(mm.val[0], iMatrixLeft.val[2], vgetq_lane_f32(iMatrixRight.val[0], 2));
        mm.val[1] = vmlaq_n_f32(mm.val[1], iMatrixLeft.val[2], vgetq_lane_f32(iMatrixRight.val[1], 2));
        mm.val[2] = vmlaq_n_f32(mm.val[2], iMatrixLeft.val[2], vgetq_lane_f32(iMatrixRight.val[2], 3));
        
        *(float32x4_t *)&m.m[0] = mm.val[0];
        *(float32x4_t *)&m.m[3] = mm.val[1];
        *(float32x2_t *)&m.m[6] = vget_low_f32(mm.val[2]);
        m.m[8] = vgetq_lane_f32(mm.val[2], 2);
        
        return m;
#else
        CCMatrix3 m;
        
        m.m[0] = matrixLeft.m[0] * matrixRight.m[0] + matrixLeft.m[3] * matrixRight.m[1] + matrixLeft.m[6] * matrixRight.m[2];
        m.m[3] = matrixLeft.m[0] * matrixRight.m[3] + matrixLeft.m[3] * matrixRight.m[4] + matrixLeft.m[6] * matrixRight.m[5];
        m.m[6] = matrixLeft.m[0] * matrixRight.m[6] + matrixLeft.m[3] * matrixRight.m[7] + matrixLeft.m[6] * matrixRight.m[8];
        
        m.m[1] = matrixLeft.m[1] * matrixRight.m[0] + matrixLeft.m[4] * matrixRight.m[1] + matrixLeft.m[7] * matrixRight.m[2];
        m.m[4] = matrixLeft.m[1] * matrixRight.m[3] + matrixLeft.m[4] * matrixRight.m[4] + matrixLeft.m[7] * matrixRight.m[5];
        m.m[7] = matrixLeft.m[1] * matrixRight.m[6] + matrixLeft.m[4] * matrixRight.m[7] + matrixLeft.m[7] * matrixRight.m[8];
        
        m.m[2] = matrixLeft.m[2] * matrixRight.m[0] + matrixLeft.m[5] * matrixRight.m[1] + matrixLeft.m[8] * matrixRight.m[2];
        m.m[5] = matrixLeft.m[2] * matrixRight.m[3] + matrixLeft.m[5] * matrixRight.m[4] + matrixLeft.m[8] * matrixRight.m[5];
        m.m[8] = matrixLeft.m[2] * matrixRight.m[6] + matrixLeft.m[5] * matrixRight.m[7] + matrixLeft.m[8] * matrixRight.m[8];
        
        return m;
#endif
    }
    
    static inline CCMatrix3 CCMatrix3Add(CCMatrix3 matrixLeft, CCMatrix3 matrixRight)
    {
#if defined(__ARM_NEON__)
        CCMatrix3 m;
        
        *(float32x4_t *)&(m.m[0]) = vaddq_f32(*(float32x4_t *)&(matrixLeft.m[0]), *(float32x4_t *)&(matrixRight.m[0]));
        *(float32x4_t *)&(m.m[4]) = vaddq_f32(*(float32x4_t *)&(matrixLeft.m[4]), *(float32x4_t *)&(matrixRight.m[4]));
        m.m[8] = matrixLeft.m[8] + matrixRight.m[8];
        
        return m;
#else
        CCMatrix3 m;
        
        m.m[0] = matrixLeft.m[0] + matrixRight.m[0];
        m.m[1] = matrixLeft.m[1] + matrixRight.m[1];
        m.m[2] = matrixLeft.m[2] + matrixRight.m[2];
        
        m.m[3] = matrixLeft.m[3] + matrixRight.m[3];
        m.m[4] = matrixLeft.m[4] + matrixRight.m[4];
        m.m[5] = matrixLeft.m[5] + matrixRight.m[5];
        
        m.m[6] = matrixLeft.m[6] + matrixRight.m[6];
        m.m[7] = matrixLeft.m[7] + matrixRight.m[7];
        m.m[8] = matrixLeft.m[8] + matrixRight.m[8];
        
        return m;
#endif
    }
    
    static inline CCMatrix3 CCMatrix3Subtract(CCMatrix3 matrixLeft, CCMatrix3 matrixRight)
    {
#if defined(__ARM_NEON__)
        CCMatrix3 m;
        
        *(float32x4_t *)&(m.m[0]) = vsubq_f32(*(float32x4_t *)&(matrixLeft.m[0]), *(float32x4_t *)&(matrixRight.m[0]));
        *(float32x4_t *)&(m.m[4]) = vsubq_f32(*(float32x4_t *)&(matrixLeft.m[4]), *(float32x4_t *)&(matrixRight.m[4]));
        m.m[8] = matrixLeft.m[8] - matrixRight.m[8];
        
        return m;
#else
        CCMatrix3 m;
        
        m.m[0] = matrixLeft.m[0] - matrixRight.m[0];
        m.m[1] = matrixLeft.m[1] - matrixRight.m[1];
        m.m[2] = matrixLeft.m[2] - matrixRight.m[2];
        
        m.m[3] = matrixLeft.m[3] - matrixRight.m[3];
        m.m[4] = matrixLeft.m[4] - matrixRight.m[4];
        m.m[5] = matrixLeft.m[5] - matrixRight.m[5];
        
        m.m[6] = matrixLeft.m[6] - matrixRight.m[6];
        m.m[7] = matrixLeft.m[7] - matrixRight.m[7];
        m.m[8] = matrixLeft.m[8] - matrixRight.m[8];
        
        return m;
#endif
    }
    
    static inline CCMatrix3 CCMatrix3Scale(CCMatrix3 matrix, float sx, float sy, float sz)
    {
        CCMatrix3 m = { { matrix.m[0] * sx, matrix.m[1] * sx, matrix.m[2] * sx,
            matrix.m[3] * sy, matrix.m[4] * sy, matrix.m[5] * sy,
            matrix.m[6] * sz, matrix.m[7] * sz, matrix.m[8] * sz } };
        return m;
    }
    
    static inline CCMatrix3 CCMatrix3ScaleWithVector3(CCMatrix3 matrix, CCVector3 scaleVector)
    {
        CCMatrix3 m = { { matrix.m[0] * scaleVector.v[0], matrix.m[1] * scaleVector.v[0], matrix.m[2] * scaleVector.v[0],
            matrix.m[3] * scaleVector.v[1], matrix.m[4] * scaleVector.v[1], matrix.m[5] * scaleVector.v[1],
            matrix.m[6] * scaleVector.v[2], matrix.m[7] * scaleVector.v[2], matrix.m[8] * scaleVector.v[2] } };
        return m;
    }
    
    /*
     The last component of the CCVector4, scaleVector, is ignored.
     */
    static inline CCMatrix3 CCMatrix3ScaleWithVector4(CCMatrix3 matrix, CCVector4 scaleVector)
    {
        CCMatrix3 m = { { matrix.m[0] * scaleVector.v[0], matrix.m[1] * scaleVector.v[0], matrix.m[2] * scaleVector.v[0],
            matrix.m[3] * scaleVector.v[1], matrix.m[4] * scaleVector.v[1], matrix.m[5] * scaleVector.v[1],
            matrix.m[6] * scaleVector.v[2], matrix.m[7] * scaleVector.v[2], matrix.m[8] * scaleVector.v[2] } };
        return m;
    }
    
    static inline CCMatrix3 CCMatrix3Rotate(CCMatrix3 matrix, float radians, float x, float y, float z)
    {
        CCMatrix3 rm = CCMatrix3MakeRotation(radians, x, y, z);
        return CCMatrix3Multiply(matrix, rm);
    }
    
    static inline CCMatrix3 CCMatrix3RotateWithVector3(CCMatrix3 matrix, float radians, CCVector3 axisVector)
    {
        CCMatrix3 rm = CCMatrix3MakeRotation(radians, axisVector.v[0], axisVector.v[1], axisVector.v[2]);
        return CCMatrix3Multiply(matrix, rm);
    }
    
    /*
     The last component of the CCVector4, axisVector, is ignored.
     */
    static inline CCMatrix3 CCMatrix3RotateWithVector4(CCMatrix3 matrix, float radians, CCVector4 axisVector)
    {
        CCMatrix3 rm = CCMatrix3MakeRotation(radians, axisVector.v[0], axisVector.v[1], axisVector.v[2]);
        return CCMatrix3Multiply(matrix, rm);
    }
    
    static inline CCMatrix3 CCMatrix3RotateX(CCMatrix3 matrix, float radians)
    {
        CCMatrix3 rm = CCMatrix3MakeXRotation(radians);
        return CCMatrix3Multiply(matrix, rm);
    }
    
    static inline CCMatrix3 CCMatrix3RotateY(CCMatrix3 matrix, float radians)
    {
        CCMatrix3 rm = CCMatrix3MakeYRotation(radians);
        return CCMatrix3Multiply(matrix, rm);
    }
    
    static inline CCMatrix3 CCMatrix3RotateZ(CCMatrix3 matrix, float radians)
    {
        CCMatrix3 rm = CCMatrix3MakeZRotation(radians);
        return CCMatrix3Multiply(matrix, rm);
    }
    
    static inline CCVector3 CCMatrix3MultiplyVector3(CCMatrix3 matrixLeft, CCVector3 vectorRight)
    {
        CCVector3 v = { { matrixLeft.m[0] * vectorRight.v[0] + matrixLeft.m[3] * vectorRight.v[1] + matrixLeft.m[6] * vectorRight.v[2],
            matrixLeft.m[1] * vectorRight.v[0] + matrixLeft.m[4] * vectorRight.v[1] + matrixLeft.m[7] * vectorRight.v[2],
            matrixLeft.m[2] * vectorRight.v[0] + matrixLeft.m[5] * vectorRight.v[1] + matrixLeft.m[8] * vectorRight.v[2] } };
        return v;
    }
    
    static inline void CCMatrix3MultiplyVector3Array(CCMatrix3 matrix, CCVector3 *vectors, size_t vectorCount)
    {
        int i;
        for (i=0; i < vectorCount; i++)
            vectors[i] = CCMatrix3MultiplyVector3(matrix, vectors[i]);
    }
    
#ifdef __cplusplus
}
#endif

#define GLKMatrix3Identity CCMatrix3Identity
#define GLKMatrix3Invert CCMatrix3Invert
#define GLKMatrix3InvertAndTranspose CCMatrix3InvertAndTranspose
#define GLKMatrix3Make CCMatrix3Make
#define GLKMatrix3MakeAndTranspose CCMatrix3MakeAndTranspose
#define GLKMatrix3MakeWithArray CCMatrix3MakeWithArray
#define GLKMatrix3MakeWithArrayAndTranspose CCMatrix3MakeWithArrayAndTranspose
#define GLKMatrix3MakeWithRows CCMatrix3MakeWithRows
#define GLKMatrix3MakeWithColumns CCMatrix3MakeWithColumns
#define GLKMatrix3MakeWithQuaternion CCMatrix3MakeWithQuaternion
#define GLKMatrix3MakeScale CCMatrix3MakeScale
#define GLKMatrix3MakeRotation CCMatrix3MakeRotation
#define GLKMatrix3MakeXRotation CCMatrix3MakeXRotation
#define GLKMatrix3MakeYRotation CCMatrix3MakeYRotation
#define GLKMatrix3MakeZRotation CCMatrix3MakeZRotation
#define GLKMatrix3GetMatrix2 CCMatrix3GetMatrix2
#define GLKMatrix3GetRow CCMatrix3GetRow
#define GLKMatrix3GetColumn CCMatrix3GetColumn
#define GLKMatrix3SetRow CCMatrix3SetRow
#define GLKMatrix3SetColumn CCMatrix3SetColumn
#define GLKMatrix3Transpose CCMatrix3Transpose
#define GLKMatrix3Multiply CCMatrix3Multiply
#define GLKMatrix3Add CCMatrix3Add
#define GLKMatrix3Subtract CCMatrix3Subtract
#define GLKMatrix3Scale CCMatrix3Scale
#define GLKMatrix3ScaleWithVector3 CCMatrix3ScaleWithVector3
#define GLKMatrix3ScaleWithVector4 CCMatrix3ScaleWithVector4
#define GLKMatrix3Rotate CCMatrix3Rotate
#define GLKMatrix3RotateWithVector3 CCMatrix3RotateWithVector3
#define GLKMatrix3RotateWithVector4 CCMatrix3RotateWithVector4
#define GLKMatrix3RotateX CCMatrix3RotateX
#define GLKMatrix3RotateY CCMatrix3RotateY
#define GLKMatrix3RotateZ CCMatrix3RotateZ
#define GLKMatrix3MultiplyVector3 CCMatrix3MultiplyVector3
#define GLKMatrix3MultiplyVector3Array CCMatrix3MultiplyVector3Array


#endif

#endif /* __CC_MATRIX_3_H */
