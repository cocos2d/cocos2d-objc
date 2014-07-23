//
//  ccMathUtils.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/10/14.
//
//

#ifndef __CC_MATH_UTILS_H
#define __CC_MATH_UTILS_H

#include <math.h>
#include <stdbool.h>

#import "CCMathTypes.h"

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
    
#ifdef __OBJC__
    NSString *NSStringFromGLKMatrix2(GLKMatrix2 matrix);
    NSString *NSStringFromGLKMatrix3(GLKMatrix3 matrix);
    NSString *NSStringFromGLKMatrix4(GLKMatrix4 matrix);
    
    NSString *NSStringFromGLKVector2(GLKVector2 vector);
    NSString *NSStringFromGLKVector3(GLKVector3 vector);
    NSString *NSStringFromGLKVector4(GLKVector4 vector);
    
    NSString *NSStringFromCCQuaternion(CCQuaternion quaternion);
#endif
    
#ifdef __cplusplus
}
#endif

#endif /* __CC_MATH_UTILS_H */
