//
//  CCVector3.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 6/10/14.
//
//

#ifndef __CC_VECTOR_3_H
#define __CC_VECTOR_3_H

#include <stdbool.h>
#include <math.h>

#import "CCMathTypes.h"

#ifdef __cplusplus
extern "C" {
#endif
    
    static inline CCVector3 CCVector3Make(float x, float y, float z)
    {
        CCVector3 v = { { x, y, z } };
        return v;
    }
    
    static inline CCVector3 CCVector3MakeWithArray(float values[3])
    {
        CCVector3 v = { { values[0], values[1], values[2] } };
        return v;
    }
    
    static inline CCVector3 CCVector3Negate(CCVector3 vector)
    {
        CCVector3 v = { { -vector.v[0], -vector.v[1], -vector.v[2] } };
        return v;
    }
    
    static inline CCVector3 CCVector3Add(CCVector3 vectorLeft, CCVector3 vectorRight)
    {
        CCVector3 v = { { vectorLeft.v[0] + vectorRight.v[0],
            vectorLeft.v[1] + vectorRight.v[1],
            vectorLeft.v[2] + vectorRight.v[2] } };
        return v;
    }
    
    static inline CCVector3 CCVector3Subtract(CCVector3 vectorLeft, CCVector3 vectorRight)
    {
        CCVector3 v = { { vectorLeft.v[0] - vectorRight.v[0],
            vectorLeft.v[1] - vectorRight.v[1],
            vectorLeft.v[2] - vectorRight.v[2] } };
        return v;
    }
    
    static inline CCVector3 CCVector3Multiply(CCVector3 vectorLeft, CCVector3 vectorRight)
    {
        CCVector3 v = { { vectorLeft.v[0] * vectorRight.v[0],
            vectorLeft.v[1] * vectorRight.v[1],
            vectorLeft.v[2] * vectorRight.v[2] } };
        return v;
    }
    
    static inline CCVector3 CCVector3Divide(CCVector3 vectorLeft, CCVector3 vectorRight)
    {
        CCVector3 v = { { vectorLeft.v[0] / vectorRight.v[0],
            vectorLeft.v[1] / vectorRight.v[1],
            vectorLeft.v[2] / vectorRight.v[2] } };
        return v;
    }
    
    static inline CCVector3 CCVector3AddScalar(CCVector3 vector, float value)
    {
        CCVector3 v = { { vector.v[0] + value,
            vector.v[1] + value,
            vector.v[2] + value } };
        return v;
    }
    
    static inline CCVector3 CCVector3SubtractScalar(CCVector3 vector, float value)
    {
        CCVector3 v = { { vector.v[0] - value,
            vector.v[1] - value,
            vector.v[2] - value } };
        return v;
    }
    
    static inline CCVector3 CCVector3MultiplyScalar(CCVector3 vector, float value)
    {
        CCVector3 v = { { vector.v[0] * value,
            vector.v[1] * value,
            vector.v[2] * value } };
        return v;
    }
    
    static inline CCVector3 CCVector3DivideScalar(CCVector3 vector, float value)
    {
        CCVector3 v = { { vector.v[0] / value,
            vector.v[1] / value,
            vector.v[2] / value } };
        return v;
    }
    
    /*
     Returns a vector whose elements are the larger of the corresponding elements of the vector arguments.
     */
    static inline CCVector3 CCVector3Maximum(CCVector3 vectorLeft, CCVector3 vectorRight)
    {
        CCVector3 max = vectorLeft;
        if (vectorRight.v[0] > vectorLeft.v[0])
            max.v[0] = vectorRight.v[0];
        if (vectorRight.v[1] > vectorLeft.v[1])
            max.v[1] = vectorRight.v[1];
        if (vectorRight.v[2] > vectorLeft.v[2])
            max.v[2] = vectorRight.v[2];
        return max;
    }
    
    /*
     Returns a vector whose elements are the smaller of the corresponding elements of the vector arguments.
     */
    static inline CCVector3 CCVector3Minimum(CCVector3 vectorLeft, CCVector3 vectorRight)
    {
        CCVector3 min = vectorLeft;
        if (vectorRight.v[0] < vectorLeft.v[0])
            min.v[0] = vectorRight.v[0];
        if (vectorRight.v[1] < vectorLeft.v[1])
            min.v[1] = vectorRight.v[1];
        if (vectorRight.v[2] < vectorLeft.v[2])
            min.v[2] = vectorRight.v[2];
        return min;
    }
    
    /*
     Returns true if all of the first vector's elements are equal to all of the second vector's arguments.
     */
    static inline bool CCVector3AllEqualToVector3(CCVector3 vectorLeft, CCVector3 vectorRight)
    {
        bool compare = false;
        if (vectorLeft.v[0] == vectorRight.v[0] &&
            vectorLeft.v[1] == vectorRight.v[1] &&
            vectorLeft.v[2] == vectorRight.v[2])
            compare = true;
        return compare;
    }
    
    /*
     Returns true if all of the vector's elements are equal to the provided value.
     */
    static inline bool CCVector3AllEqualToScalar(CCVector3 vector, float value)
    {
        bool compare = false;
        if (vector.v[0] == value &&
            vector.v[1] == value &&
            vector.v[2] == value)
            compare = true;
        return compare;
    }
    
    /*
     Returns true if all of the first vector's elements are greater than all of the second vector's arguments.
     */
    static inline bool CCVector3AllGreaterThanVector3(CCVector3 vectorLeft, CCVector3 vectorRight)
    {
        bool compare = false;
        if (vectorLeft.v[0] > vectorRight.v[0] &&
            vectorLeft.v[1] > vectorRight.v[1] &&
            vectorLeft.v[2] > vectorRight.v[2])
            compare = true;
        return compare;
    }
    
    /*
     Returns true if all of the vector's elements are greater than the provided value.
     */
    static inline bool CCVector3AllGreaterThanScalar(CCVector3 vector, float value)
    {
        bool compare = false;
        if (vector.v[0] > value &&
            vector.v[1] > value &&
            vector.v[2] > value)
            compare = true;
        return compare;
    }
    
    /*
     Returns true if all of the first vector's elements are greater than or equal to all of the second vector's arguments.
     */
    static inline bool CCVector3AllGreaterThanOrEqualToVector3(CCVector3 vectorLeft, CCVector3 vectorRight)
    {
        bool compare = false;
        if (vectorLeft.v[0] >= vectorRight.v[0] &&
            vectorLeft.v[1] >= vectorRight.v[1] &&
            vectorLeft.v[2] >= vectorRight.v[2])
            compare = true;
        return compare;
    }
    
    /*
     Returns true if all of the vector's elements are greater than or equal to the provided value.
     */
    static inline bool CCVector3AllGreaterThanOrEqualToScalar(CCVector3 vector, float value)
    {
        bool compare = false;
        if (vector.v[0] >= value &&
            vector.v[1] >= value &&
            vector.v[2] >= value)
            compare = true;
        return compare;
    }
    
    static inline float CCVector3Length(CCVector3 vector)
    {
        return sqrtf(vector.v[0] * vector.v[0] + vector.v[1] * vector.v[1] + vector.v[2] * vector.v[2]);
    }
    
    static inline CCVector3 CCVector3Normalize(CCVector3 vector)
    {
        float scale = 1.0f / CCVector3Length(vector);
        CCVector3 v = { { vector.v[0] * scale, vector.v[1] * scale, vector.v[2] * scale } };
        return v;
    }
    
    static inline float CCVector3DotProduct(CCVector3 vectorLeft, CCVector3 vectorRight)
    {
        return vectorLeft.v[0] * vectorRight.v[0] + vectorLeft.v[1] * vectorRight.v[1] + vectorLeft.v[2] * vectorRight.v[2];
    }
    
    static inline float CCVector3Distance(CCVector3 vectorStart, CCVector3 vectorEnd)
    {
        return CCVector3Length(CCVector3Subtract(vectorEnd, vectorStart));
    }
    
    static inline CCVector3 CCVector3Lerp(CCVector3 vectorStart, CCVector3 vectorEnd, float t)
    {
        CCVector3 v = { { vectorStart.v[0] + ((vectorEnd.v[0] - vectorStart.v[0]) * t),
            vectorStart.v[1] + ((vectorEnd.v[1] - vectorStart.v[1]) * t),
            vectorStart.v[2] + ((vectorEnd.v[2] - vectorStart.v[2]) * t) } };
        return v;
    }
    
    static inline CCVector3 CCVector3CrossProduct(CCVector3 vectorLeft, CCVector3 vectorRight)
    {
        CCVector3 v = { { vectorLeft.v[1] * vectorRight.v[2] - vectorLeft.v[2] * vectorRight.v[1],
            vectorLeft.v[2] * vectorRight.v[0] - vectorLeft.v[0] * vectorRight.v[2],
            vectorLeft.v[0] * vectorRight.v[1] - vectorLeft.v[1] * vectorRight.v[0] } };
        return v;
    }
    
    /*
     Project the vector, vectorToProject, onto the vector, projectionVector.
     */
    static inline CCVector3 CCVector3Project(CCVector3 vectorToProject, CCVector3 projectionVector)
    {
        float scale = CCVector3DotProduct(projectionVector, vectorToProject) / CCVector3DotProduct(projectionVector, projectionVector);
        CCVector3 v = CCVector3MultiplyScalar(projectionVector, scale);
        return v;
    }
    
#ifdef __cplusplus
}
#endif

#endif /* __CC_VECTOR_3_H */

