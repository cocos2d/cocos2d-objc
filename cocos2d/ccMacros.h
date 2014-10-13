/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#import <math.h>
#import "ccConfig.h"

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CGPointExtension.h"
#import <Availability.h>


/**
 @file
 cocos2d helper macros
 */

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && !defined(COCOS2D_ANDROID)
#define __CC_PLATFORM_IOS 1
#define __CC_PLATFORM_MAC 0
#define __CC_PLATFORM_ANDROID_FIXME 1
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && !defined(COCOS2D_ANDROID)
#define __CC_PLATFORM_MAC 1
#define __CC_PLATFORM_IOS 0
#endif

#ifdef COCOS2D_ANDROID
#define __CC_PLATFORM_MAC 0
#define __CC_PLATFORM_IOS 0
#define __CC_PLATFORM_ANDROID 1
#define __CC_PLATFORM_ANDROID_FIXME 1
#endif

// Metal is only supported on iOS devices (currently does not include the simulator) and on iOS 8 and greater.
#if __CC_PLATFORM_IOS && defined(__IPHONE_8_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
#define __CC_METAL_SUPPORTED_AND_ENABLED (CC_ENABLE_METAL_RENDERING && !TARGET_IPHONE_SIMULATOR)
#else
#define __CC_METAL_SUPPORTED_AND_ENABLED 0
#endif

/*
 * if COCOS2D_DEBUG is not defined, or if it is 0 then
 *	all CCLOGXXX macros will be disabled
 *
 * if COCOS2D_DEBUG==1 then:
 *		CCLOG() will be enabled
 *		CCLOGWARN() will be enabled
 *		CCLOGINFO()	will be disabled
 *
 * if COCOS2D_DEBUG==2 or higher then:
 *		CCLOG() will be enabled
 *		CCLOGWARN() will be enabled
 *		CCLOGINFO()	will be enabled
 */


#define __CCLOGWITHFUNCTION(s, ...) \
NSLog(@"%s : %@",__FUNCTION__,[NSString stringWithFormat:(s), ##__VA_ARGS__])

#define __CCLOG(s, ...) \
NSLog(@"%@",[NSString stringWithFormat:(s), ##__VA_ARGS__])


#if !defined(COCOS2D_DEBUG) || COCOS2D_DEBUG == 0
#define CCLOG(...) do {} while (0)
#define CCLOGWARN(...) do {} while (0)
#define CCLOGINFO(...) do {} while (0)

#elif COCOS2D_DEBUG == 1
#define CCLOG(...) __CCLOG(__VA_ARGS__)
#define CCLOGWARN(...) __CCLOGWITHFUNCTION(__VA_ARGS__)
#define CCLOGINFO(...) do {} while (0)

#elif COCOS2D_DEBUG > 1
#define CCLOG(...) __CCLOG(__VA_ARGS__)
#define CCLOGWARN(...) __CCLOGWITHFUNCTION(__VA_ARGS__)
#define CCLOGINFO(...) __CCLOG(__VA_ARGS__)
#endif // COCOS2D_DEBUG


/** @def CC_SWAP
simple macro that swaps 2 variables
*/
#define CC_SWAP( x, y )			\
({ __typeof__(x) temp  = (x);		\
		x = y; y = temp;		\
})


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
extern CGFloat __ccContentScaleFactor;

/// Deprecated in favor of using CCDirector.contentScaleFactor or CCTexture2D.contentScale depending on usage.
static inline CGFloat DEPRECATED_ATTRIBUTE
CC_CONTENT_SCALE_FACTOR()
{
	return __ccContentScaleFactor;
}

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

/**********************/
/** Profiling Macros **/
/**********************/
#if CC_ENABLE_PROFILERS

#define CC_PROFILER_DISPLAY_TIMERS() [[CCProfiler sharedProfiler] displayTimers]
#define CC_PROFILER_PURGE_ALL() [[CCProfiler sharedProfiler] releaseAllTimers]

#define CC_PROFILER_START(__name__) CCProfilingBeginTimingBlock(__name__)
#define CC_PROFILER_STOP(__name__) CCProfilingEndTimingBlock(__name__)
#define CC_PROFILER_RESET(__name__) CCProfilingResetTimingBlock(__name__)

#define CC_PROFILER_START_CATEGORY(__cat__, __name__) do{ if(__cat__) CCProfilingBeginTimingBlock(__name__); } while(0)
#define CC_PROFILER_STOP_CATEGORY(__cat__, __name__) do{ if(__cat__) CCProfilingEndTimingBlock(__name__); } while(0)
#define CC_PROFILER_RESET_CATEGORY(__cat__, __name__) do{ if(__cat__) CCProfilingResetTimingBlock(__name__); } while(0)

#define CC_PROFILER_START_INSTANCE(__id__, __name__) do{ CCProfilingBeginTimingBlock( [NSString stringWithFormat:@"%08X - %@", __id__, __name__] ); } while(0)
#define CC_PROFILER_STOP_INSTANCE(__id__, __name__) do{ CCProfilingEndTimingBlock(    [NSString stringWithFormat:@"%08X - %@", __id__, __name__] ); } while(0)
#define CC_PROFILER_RESET_INSTANCE(__id__, __name__) do{ CCProfilingResetTimingBlock( [NSString stringWithFormat:@"%08X - %@", __id__, __name__] ); } while(0)


#else

#define CC_PROFILER_DISPLAY_TIMERS() do {} while (0)
#define CC_PROFILER_PURGE_ALL() do {} while (0)

#define CC_PROFILER_START(__name__)  do {} while (0)
#define CC_PROFILER_STOP(__name__) do {} while (0)
#define CC_PROFILER_RESET(__name__) do {} while (0)

#define CC_PROFILER_START_CATEGORY(__cat__, __name__) do {} while(0)
#define CC_PROFILER_STOP_CATEGORY(__cat__, __name__) do {} while(0)
#define CC_PROFILER_RESET_CATEGORY(__cat__, __name__) do {} while(0)

#define CC_PROFILER_START_INSTANCE(__id__, __name__) do {} while(0)
#define CC_PROFILER_STOP_INSTANCE(__id__, __name__) do {} while(0)
#define CC_PROFILER_RESET_INSTANCE(__id__, __name__) do {} while(0)

#endif

/** @def CC_INCREMENT_GL_DRAWS
 Increments the GL Draws counts by one.
 The number of calls per frame are displayed on the screen when the CCDirector's stats are enabled.
 */
extern NSUInteger __ccNumberOfDraws;
#define CC_INCREMENT_GL_DRAWS(__n__) __ccNumberOfDraws += __n__

/*******************/
/** Notifications **/
/*******************/
/** @def CCAnimationFrameDisplayedNotification
 Notification name when a CCSpriteFrame is displayed
 */
#define CCAnimationFrameDisplayedNotification @"CCAnimationFrameDisplayedNotification"
