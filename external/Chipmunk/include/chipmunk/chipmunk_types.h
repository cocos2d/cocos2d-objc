#ifdef __APPLE__
   #import "TargetConditionals.h"
#endif

#ifndef CP_USE_DOUBLES
  // Use single precision floats on the iPhone.
  #if TARGET_OS_IPHONE
    #define CP_USE_DOUBLES 0
  #else
    // use doubles by default for higher precision
    #define CP_USE_DOUBLES 1
  #endif
#endif

#if CP_USE_DOUBLES
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

static inline cpFloat
cpfmax(cpFloat a, cpFloat b)
{
	return (a > b) ? a : b;
}

static inline cpFloat
cpfmin(cpFloat a, cpFloat b)
{
	return (a < b) ? a : b;
}

static inline cpFloat
cpfabs(cpFloat n)
{
	return (n < 0) ? -n : n;
}

static inline cpFloat
cpfclamp(cpFloat f, cpFloat min, cpFloat max)
{
	return cpfmin(cpfmax(f, min), max);
}

static inline cpFloat
cpflerp(cpFloat f1, cpFloat f2, cpFloat t)
{
	return f1*(1.0f - t) + f2*t;
}

static inline cpFloat
cpflerpconst(cpFloat f1, cpFloat f2, cpFloat d)
{
	return f1 + cpfclamp(f2 - f1, -d, d);
}

#if TARGET_OS_IPHONE
	// CGPoints are structurally the same, and allow
	// easy interoperability with other iPhone libraries
	#import <CoreGraphics/CGGeometry.h>
	typedef CGPoint cpVect;
#else
	typedef struct cpVect{cpFloat x,y;} cpVect;
#endif

typedef unsigned int cpHashValue;

// Oh C, how we love to define our own boolean types to get compiler compatibility
#ifdef CP_BOOL_TYPE
	typedef CP_BOOL_TYPE cpBool;
#else
	typedef int cpBool;
#endif

#ifndef cpTrue
	#define cpTrue 1
#endif

#ifndef cpFalse
	#define cpFalse 0
#endif

#ifdef CP_DATA_POINTER_TYPE
	typedef CP_DATA_POINTER_TYPE cpDataPointer;
#else
	typedef void * cpDataPointer;
#endif

#ifdef CP_COLLISION_TYPE_TYPE
	typedef CP_COLLISION_TYPE_TYPE cpCollisionType;
#else
	typedef unsigned int cpCollisionType;
#endif

#ifdef CP_GROUP_TYPE
	typedef CP_GROUP_TYPE cpGroup;
#else
	typedef unsigned int cpGroup;
#endif

#ifdef CP_LAYERS_TYPE
	typedef CP_GROUP_TYPE cpLayers;
#else
	typedef unsigned int cpLayers;
#endif

#ifdef CP_TIMESTAMP_TYPE
	typedef CP_TIMESTAMP_TYPE cpTimestamp;
#else
	typedef unsigned int cpTimestamp;
#endif

#ifndef CP_NO_GROUP
	#define CP_NO_GROUP ((cpGroup)0)
#endif

#ifndef CP_ALL_LAYERS
	#define CP_ALL_LAYERS (~(cpLayers)0)
#endif
