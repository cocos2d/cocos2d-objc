//
//  CCMathTypesAndroid.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/10/14.
//
//

#ifndef __CC_MATH_TYPES_H
#define __CC_MATH_TYPES_H

#import "ccMacros.h"

#if __CC_PLATFORM_ANDROID

#if defined(__STRICT_ANSI__)
struct _CCMatrix2
{
    float m[4];
};
typedef struct _CCMatrix2 CCMatrix2;
#else
union _CCMatrix2
{
    struct
    {
        float m00, m01;
        float m10, m11;
    };
    float m2[2][2];
    float m[4];
};
typedef union _CCMatrix2 CCMatrix2;
#endif

#if defined(__STRICT_ANSI__)
struct _CCMatrix3
{
    float m[9];
};
typedef struct _CCMatrix3 CCMatrix3;
#else
union _CCMatrix3
{
    struct
    {
        float m00, m01, m02;
        float m10, m11, m12;
        float m20, m21, m22;
    };
    float m[9];
};
typedef union _CCMatrix3 CCMatrix3;
#endif

/*
 m30, m31, and m32 correspond to the translation values tx, ty, and tz, respectively.
 m[12], m[13], and m[14] correspond to the translation values tx, ty, and tz, respectively.
 */
#if defined(__STRICT_ANSI__)
struct _CCMatrix4
{
    float m[16];
} __attribute__((aligned(16)));
typedef struct _CCMatrix4 CCMatrix4;
#else
union _CCMatrix4
{
    struct
    {
        float m00, m01, m02, m03;
        float m10, m11, m12, m13;
        float m20, m21, m22, m23;
        float m30, m31, m32, m33;
    };
    float m[16];
} __attribute__((aligned(16)));
typedef union _CCMatrix4 CCMatrix4;
#endif

#if defined(__STRICT_ANSI__)
struct _CCVector2
{
    float v[2];
};
typedef struct _CCVector2 CCVector2;
#else
union _CCVector2
{
    struct { float x, y; };
    struct { float s, t; };
    float v[2];
};
typedef union _CCVector2 CCVector2;
#endif

#if defined(__STRICT_ANSI__)
struct _CCVector3
{
    float v[3];
};
typedef struct _CCVector3 CCVector3;
#else
union _CCVector3
{
    struct { float x, y, z; };
    struct { float r, g, b; };
    struct { float s, t, p; };
    float v[3];
};
typedef union _CCVector3 CCVector3;
#endif

#if defined(__STRICT_ANSI__)
struct _CCVector4
{
    float v[4];
} __attribute__((aligned(16)));
typedef struct _CCVector4 CCVector4;
#else
union _CCVector4
{
    struct { float x, y, z, w; };
    struct { float r, g, b, a; };
    struct { float s, t, p, q; };
    float v[4];
} __attribute__((aligned(16)));
typedef union _CCVector4 CCVector4;
#endif

/*
 x, y, and z represent the imaginary values.
 Vector v represents the imaginary values.
 q[0], q[1], and q[2] represent the imaginary values.
 */
#if defined(__STRICT_ANSI__)
struct _CCQuaternion
{
    float q[4];
} __attribute__((aligned(16)));
typedef struct _CCQuaternion CCQuaternion;
#else
union _CCQuaternion
{
    struct { CCVector3 v; float s; };
    struct { float x, y, z, w; };
    float q[4];
} __attribute__((aligned(16)));
typedef union _CCQuaternion CCQuaternion;
#endif

//#ifdef __cplusplus
//}
//#endif

#define GLKMatrix4 CCMatrix4
#define GLKMatrix3 CCMatrix3
#define GLKMatrix2 CCMatrix2
#define GLKVector2 CCVector2
#define GLKVector3 CCVector3
#define GLKVector4 CCVector4
#define CCQuaternion CCQuaternion

#endif

#endif // __CC_MATH_TYPES_H

