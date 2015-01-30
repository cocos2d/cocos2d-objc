/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 */

#import "CGPointExtension.h"
#import <stdlib.h>

#ifndef __CC_UTILS_H
#define __CC_UTILS_H

#ifdef __cplusplus
extern "C" {
#endif
    
#if __CC_PLATFORM_ANDROID
//
//#import <AndroidKit/AndroidBase64.h>
    
#endif

/** @file ccUtils.h
 Misc free functions
 */

/** @def CCRANDOM_MINUS1_1
 Returns a random float between -1 and 1.
 */
static inline float CCRANDOM_MINUS1_1(){ return (random() / (float)0x3fffffff ) - 1.0f; }

/** @def CCRANDOM_0_1
 Returns a random float between 0 and 1.
 */
static inline float CCRANDOM_0_1(){ return random() / (float)0x7fffffff;}

/** @def CCRANDOM_IN_UNIT_CIRCLE
 Returns a random CGPoint with a length less than 1.0.
 */
static inline CGPoint
CCRANDOM_IN_UNIT_CIRCLE()
{
	while(TRUE){
		CGPoint p = ccp(CCRANDOM_MINUS1_1(), CCRANDOM_MINUS1_1());
		if(ccpLengthSQ(p) < 1.0) return p;
	}
}

/** @def CCRANDOM_ON_UNIT_CIRCLE
 Returns a random CGPoint with a length equal to 1.0.
 */
static inline CGPoint
CCRANDOM_ON_UNIT_CIRCLE()
{
	while(TRUE){
		CGPoint p = ccp(CCRANDOM_MINUS1_1(), CCRANDOM_MINUS1_1());
		CGFloat lsq = ccpLengthSQ(p);
		if(0.1 < lsq && lsq < 1.0) return ccpMult(p, (CGFloat)(1.0/sqrt(lsq)));
	}
}

/** @def CC_DEGREES_TO_RADIANS
 converts degrees to radians
 */
static inline float
CC_DEGREES_TO_RADIANS(const float angle)
{
	return angle*0.01745329252f;
} 

/** @def CC_RADIANS_TO_DEGREES
 converts radians to degrees
 */
static inline float
CC_RADIANS_TO_DEGREES(const float angle)
{
	return angle*57.29577951f;
} 

/** @def CC_CONTENT_SCALE_FACTOR
 Factor relating pixel to point coordinates.
 */
extern float __ccContentScaleFactor;

// Util functions for rescaling CGRects and CGSize, use ccpMult() for CGPoints.

static inline CGRect CC_RECT_SCALE(CGRect rect, CGFloat scale){
	return CGRectMake(
		rect.origin.x * scale,
		rect.origin.y * scale,
		rect.size.width * scale,
		rect.size.height * scale
	);
}

static inline CGSize CC_SIZE_SCALE(CGSize size, CGFloat scale){
	return CGSizeMake(size.width * scale, size.height * scale);
}

    
static inline NSData* CC_DECODE_BASE64(NSString* base64){
        NSData* result;
#if __CC_PLATFORM_IOS || __CC_PLATFORM_MAC
        result = [[NSData alloc] initWithBase64Encoding:base64];
#elif __CC_PLATFORM_ANDROID
//        result = [NSData decodeWithStr:base64 flags:0];
#endif
        return result;
    
}
    
/** returns the Next Power of Two value.

 Examples:
	- If "value" is 15, it will return 16.
	- If "value" is 16, it will return 16.
	- If "value" is 17, it will return 32.

 */
static inline unsigned long
CCNextPOT(unsigned long x)
{
    x = x - 1;
    x = x | (x >> 1);
    x = x | (x >> 2);
    x = x | (x >> 4);
    x = x | (x >> 8);
    x = x | (x >>16);
    return x + 1;
}

/**
 Check if a size has power of two dimensions.
*/
static inline bool
CCSizeIsPOT(CGSize size)
{
    return (size.width == CCNextPOT(size.width) && size.height == CCNextPOT(size.height));
}

/** @def CC_SWAP
simple macro that swaps 2 variables
*/
#define CC_SWAP( x, y )			\
({ __typeof__(x) temp  = (x);		\
		x = y; y = temp;		\
})


#ifdef __cplusplus
}
#endif

#endif // ! __CC_UTILS_H
