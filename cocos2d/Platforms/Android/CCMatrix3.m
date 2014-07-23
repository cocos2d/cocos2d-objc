#import "CCMatrix3.h"

#if __CC_PLATFORM_ANDROID

static inline float CCMatrixDeterminant(CCMatrix3 matrix) {
    float det = 0.0f;
    
    det += matrix.m[0] * matrix.m[4] * matrix.m[8];
    det += matrix.m[1] * matrix.m[5] * matrix.m[6];
    det += matrix.m[2] * matrix.m[3] * matrix.m[7];
    det -= matrix.m[2] * matrix.m[4] * matrix.m[6];
    det -= matrix.m[0] * matrix.m[5] * matrix.m[7];
    det -= matrix.m[1] * matrix.m[3] * matrix.m[8];
    
    return det;
}

static inline CCMatrix3 CCMatrixAdjugate(CCMatrix3 matrix) {
    CCMatrix3 adjugate;
    
    adjugate.m[0] = matrix.m[4] * matrix.m[8] - matrix.m[5] * matrix.m[7];
    adjugate.m[1] = matrix.m[2] * matrix.m[7] - matrix.m[1] * matrix.m[8];
    adjugate.m[2] = matrix.m[1] * matrix.m[5] - matrix.m[2] * matrix.m[4];
    adjugate.m[3] = matrix.m[5] * matrix.m[6] - matrix.m[3] * matrix.m[8];
    adjugate.m[4] = matrix.m[0] * matrix.m[8] - matrix.m[2] * matrix.m[6];
    adjugate.m[5] = matrix.m[2] * matrix.m[3] - matrix.m[0] * matrix.m[5];
    adjugate.m[6] = matrix.m[3] * matrix.m[7] - matrix.m[4] * matrix.m[6];
    adjugate.m[7] = matrix.m[1] * matrix.m[6] - matrix.m[0] * matrix.m[7];
    adjugate.m[8] = matrix.m[0] * matrix.m[4] - matrix.m[1] * matrix.m[3];
        
    return adjugate;
}



CCMatrix3 CCMatrix3Invert(CCMatrix3 matrix, bool *isInvertible) {
    float det = CCMatrixDeterminant(matrix);
    if (det == 0.0f) {
        return CCMatrix3Identity;
    }
    
    float detInv = 1.0 / det;
    CCMatrix3 adjugate = CCMatrixAdjugate(matrix);
    return CCMatrix3Multiply(adjugate, matrix);
}

CCMatrix3 CCMatrix3InvertAndTranspose(CCMatrix3 matrix, bool *isInvertible) {
    float det = CCMatrixDeterminant(matrix);
    if (det == 0.0f) {
        return CCMatrix3Identity;
    }
    
    float detInv = 1.0 / det;
    CCMatrix3 adjugate = CCMatrixAdjugate(matrix);
    return CCMatrix3Transpose(CCMatrix3Multiply(adjugate, matrix));
}

#endif
