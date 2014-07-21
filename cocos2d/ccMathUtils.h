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
    
    CCVector3 CCMathProject(CCVector3 object, CCMatrix4 model, CCMatrix4 projection, int *viewport);
    CCVector3 CCMathUnproject(CCVector3 window, CCMatrix4 model, CCMatrix4 projection, int *viewport, bool *success);
    
#ifdef __OBJC__
    NSString *NSStringFromCCMatrix2(CCMatrix2 matrix);
    NSString *NSStringFromCCMatrix3(CCMatrix3 matrix);
    NSString *NSStringFromCCMatrix4(CCMatrix4 matrix);
    
    NSString *NSStringFromCCVector2(CCVector2 vector);
    NSString *NSStringFromCCVector3(CCVector3 vector);
    NSString *NSStringFromCCVector4(CCVector4 vector);
    
    NSString *NSStringFromCCQuaternion(CCQuaternion quaternion);
#endif
    
#ifdef __cplusplus
}
#endif

#endif /* __CC_MATH_UTILS_H */
