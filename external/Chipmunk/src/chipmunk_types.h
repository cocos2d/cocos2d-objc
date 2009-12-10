// in cocos2d use floats instead of doubles
#if 0 // use doubles by default for higher precision

typedef double cpFloat;
#define cpfsqrt sqrt
#define cpfsin sin
#define cpfcos cos
#define cpfacos acos
#define cpfatan2 atan2
#define cpfmod fmod
#define cpfexp exp
#define cpfpow pow
#define cpffloor floor
#define cpfceil ceil

#else

typedef float cpFloat;
#define cpfsqrt sqrtf
#define cpfsin sinf
#define cpfcos cosf
#define cpfacos acosf
#define cpfatan2 atan2f
#define cpfmod fmodf
#define cpfexp expf
#define cpfpow powf
#define cpffloor floorf
#define cpfceil ceilf

#endif

typedef size_t cpHashValue;
typedef void * cpDataPointer;
typedef unsigned int cpCollisionType;
typedef unsigned int cpLayers;
typedef unsigned int cpGroup;
