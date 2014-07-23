#import "CCQuaternion.h"
#import "CCMatrix4.h"

#if __CC_PLATFORM_ANDROID

#define kCCEpsilon 0.0001f

CCQuaternion CCQuaternionMakeWithMatrix3(CCMatrix3 matrix)
{
    CCQuaternion quat;
    quat.y = sqrtf(((1.0f - matrix.m[0]) / 2.0f  - (1.0f - matrix.m[4]) / 2.0f + (1.0f - matrix.m[8]) / 2.0f) / 2.0f);
    quat.x = sqrtf((1.0f - matrix.m[8]) / 2.0f - quat.y * quat.y);
    quat.z = sqrtf((1.0f - matrix.m[4]) / 2.0f - quat.x * quat.x);
    quat.w = (quat.x * quat.y - matrix.m[1] / 2.0f) / quat.z;
    return quat;
}

float CCQuaternionAngle(CCQuaternion quaternion)
{
    float angle = acosf(quaternion.w);
    float scale = sqrtf(quaternion.x * quaternion.x + quaternion.y * quaternion.y + quaternion.z * quaternion.z);
    
    if (((scale > -kCCEpsilon) && scale < kCCEpsilon)
        || (scale < 2.0f * M_PI + kCCEpsilon && scale > 2.0f * M_PI - kCCEpsilon))
    {
        return 0.0f;
    }
    else
    {
        return angle * 2.0f;
    }
}

CCVector3 CCQuaternionAxis(CCQuaternion quaternion)
{
    float angle = acosf(quaternion.w);
    float scale = sqrtf(quaternion.x * quaternion.x + quaternion.y * quaternion.y + quaternion.z * quaternion.z);
    
    if (((scale > -kCCEpsilon) && scale < kCCEpsilon)
        || (scale < 2.0f * M_PI + kCCEpsilon && scale > 2.0f * M_PI - kCCEpsilon))
    {
        return CCVector3Make(0.0f, 0.0f, 1.0f);
    }
    else
    {
        return CCVector3Make(quaternion.x / scale, quaternion.y / scale, quaternion.z / scale);
    }
}


static inline float CCQuaternionDot(CCQuaternion q1, CCQuaternion q2) {
    return (q1.w * q2.w +
            q1.x * q2.x +
            q1.y * q2.y +
            q1.z * q2.z);
}

static inline CCQuaternion CCQuaternionScale(CCQuaternion q1, float s)
{
    CCQuaternion q;
    q.x = q1.x * s;
    q.y = q1.y * s;
    q.z = q1.z * s;
    q.w = q1.w * s;
    return q;
}

CCQuaternion CCQuaternionSlerp(CCQuaternion q1, CCQuaternion q2, float t)
{
    CCQuaternion q;
    
    if (q1.x == q2.x &&
        q1.y == q2.y &&
        q1.z == q2.z &&
        q1.w == q2.w)
    {
        
        q.x = q.x;
        q.y = q.y;
        q.z = q.z;
        q.w = q.w;
        
        return q;
    }
    
    float ct = CCQuaternionDot(q1, q2);
    float theta = acosf(ct);
    float st = sqrtf(1.0 - (ct * ct));
    float stt = sinf(t * theta) / st;
    float somt = sinf((1.0 - t) * theta) / st;
    
    CCQuaternion temp, temp2;
    
    temp = CCQuaternionScale(q1, somt);
    temp2 = CCQuaternionScale(q2, stt);
    q = CCQuaternionAdd(temp, temp2);
    
    return q;
}

void CCQuaternionRotateVector3Array(CCQuaternion quaternion, CCVector3 *vectors, size_t vectorCount)
{
    for (int idx = 0; idx < vectorCount; idx++)
    {
        CCQuaternionRotateVector3(quaternion, vectors[idx]);
    }
}

CCQuaternion CCQuaternionMakeWithMatrix4(CCMatrix4 matrix)
{
    return CCQuaternionMakeWithMatrix3(CCMatrix4GetMatrix3(matrix));
}

void CCQuaternionRotateVector4Array(CCQuaternion quaternion, CCVector4 *vectors, size_t vectorCount)
{
    for (int idx = 0; idx < vectorCount; idx++)
    {
        CCQuaternionRotateVector4(quaternion, vectors[idx]);
    }
}

#endif


