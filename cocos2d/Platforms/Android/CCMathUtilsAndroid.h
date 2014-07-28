//
//  CCMathUtilsAndroid
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/10/14.
//
//

#ifndef __CC_MATH_UTILS_H
#define __CC_MATH_UTILS_H

#include <math.h>
#include <stdbool.h>

#import "CCMathTypesAndroid.h"

#if __CC_PLATFORM_ANDROID

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif
    
    static inline float CCMathDegreesToRadians(float degrees) { return degrees * (M_PI / 180); };
    static inline float CCMathRadiansToDegrees(float radians) { return radians * (180 / M_PI); };
    
    GLKVector3 CCMathProject(GLKVector3 object, GLKMatrix4 model, GLKMatrix4 projection, int *viewport);
    GLKVector3 CCMathUnproject(GLKVector3 window, GLKMatrix4 model, GLKMatrix4 projection, int *viewport, bool *success);
    
#if defined(__OBJC__)  && __CC_PLATFORM_ANDROID
    NSString *NSStringFromCCMatrix2(GLKMatrix2 matrix);
    NSString *NSStringFromCCMatrix3(GLKMatrix3 matrix);
    NSString *NSStringFromCCMatrix4(GLKMatrix4 matrix);
    
    NSString *NSStringFromCCVector2(GLKVector2 vector);
    NSString *NSStringFromCCVector3(GLKVector3 vector);
    NSString *NSStringFromCCVector4(GLKVector4 vector);
    
    #define NSStringFromGLKVector2 NSStringFromCCVector2
    #define NSStringFromGLKVector3 NSStringFromCCVector3
    #define NSStringFromGLKVector4 NSStringFromCCVector4
    
    #define NSStringFromGLKMatrix2 NSStringFromCCMatrix2
    #define NSStringFromGLKMatrix3 NSStringFromCCMatrix3
    #define NSStringFromGLKMatrix4 NSStringFromCCMatrix4
    
#endif
    
#ifdef __cplusplus
}
#endif

#endif 

#endif /* __CC_MATH_UTILS_H */
