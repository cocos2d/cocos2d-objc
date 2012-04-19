/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
#import <Availability.h>

/**
 @file
 cocos2d helper macros
 */

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#define __CC_PLATFORM_IOS 1
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#define __CC_PLATFORM_MAC 1
#endif

/*
 * if COCOS2D_DEBUG is not defined, or if it is 0 then
 *	all CCLOGXXX macros will be disabled
 *
 * if COCOS2D_DEBUG==1 then:
 *		CCLOG() will be enabled
 *		CCLOGERROR() will be enabled
 *		CCLOGINFO()	will be disabled
 *
 * if COCOS2D_DEBUG==2 or higher then:
 *		CCLOG() will be enabled
 *		CCLOGERROR() will be enabled
 *		CCLOGINFO()	will be enabled
 */


#define __CCLOGWITHFUNCTION(s, ...) \
NSLog(@"%s : %@",__FUNCTION__,[NSString stringWithFormat:(s), ##__VA_ARGS__])


#if !defined(COCOS2D_DEBUG) || COCOS2D_DEBUG == 0
#define CCLOG(...) do {} while (0)
#define CCLOGINFO(...) do {} while (0)
#define CCLOGERROR(...) do {} while (0)

#elif COCOS2D_DEBUG == 1
#define CCLOG(...) __CCLOGWITHFUNCTION(__VA_ARGS__)
#define CCLOGERROR(...) __CCLOGWITHFUNCTION(__VA_ARGS__)
#define CCLOGINFO(...) do {} while (0)

#elif COCOS2D_DEBUG > 1
#define CCLOG(...) __CCLOGWITHFUNCTION(__VA_ARGS__)
#define CCLOGERROR(...) __CCLOGWITHFUNCTION(__VA_ARGS__)
#define CCLOGINFO(...) __CCLOGWITHFUNCTION(__VA_ARGS__)
#endif // COCOS2D_DEBUG


/** @def CC_SWAP
simple macro that swaps 2 variables
*/
#define CC_SWAP( x, y )			\
({ __typeof__(x) temp  = (x);		\
		x = y; y = temp;		\
})


/** @def CCRANDOM_MINUS1_1
 returns a random float between -1 and 1
 */
#define CCRANDOM_MINUS1_1() ((random() / (float)0x3fffffff )-1.0f)

/** @def CCRANDOM_0_1
 returns a random float between 0 and 1
 */
#define CCRANDOM_0_1() ((random() / (float)0x7fffffff ))

/** @def CC_DEGREES_TO_RADIANS
 converts degrees to radians
 */
#define CC_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180

/** @def CC_RADIANS_TO_DEGREES
 converts radians to degrees
 */
#define CC_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180

#define kCCRepeatForever UINT_MAX -1
/** @def CC_BLEND_SRC
default gl blend src function. Compatible with premultiplied alpha images.
*/
#define CC_BLEND_SRC GL_ONE
#define CC_BLEND_DST GL_ONE_MINUS_SRC_ALPHA

/** @def CC_DIRECTOR_INIT
	- Initializes an CCGLView with 0-bit depth format, and RGB565 render buffer.
	- The CCGLView view will have multiple touches disabled.
	- It will create a UIWindow and it will assign it the 'window_' ivar. 'window_' must be declared before calling this marcro.
    - It will create a UINavigationController and it will assign it the 'navigationController_' ivar. 'navController_' must be declared before using this macro.
    - The director_ will be the root view controller of the navController.
	- It will connect the CCGLView to the Director
	- It will connect the UINavController view to the UIWindow.
	- It will try to run at 60 FPS.
	- It will connect the director with the CCGLView.

 IMPORTANT: If you want to use another type of render buffer (eg: RGBA8)
 or if you want to use a 16-bit or 24-bit depth buffer, you should NOT
 use this macro. Instead, you should create the CCGLView manually.

 @since v0.99.4
 */

#ifdef __CC_PLATFORM_IOS

#define CC_DIRECTOR_INIT()																		\
do	{																							\
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];					\
	director_ = (CCDirectorIOS*)[CCDirector sharedDirector];									\
	[director_ setDisplayStats:NO];																\
	[director_ setAnimationInterval:1.0/60];													\
	CCGLView *__glView = [CCGLView viewWithFrame:[window_ bounds]								\
									pixelFormat:kEAGLColorFormatRGB565							\
									depthFormat:0 /* GL_DEPTH_COMPONENT24_OES */				\
							 preserveBackbuffer:NO												\
									 sharegroup:nil												\
								  multiSampling:NO												\
								numberOfSamples:0												\
													];											\
	[director_ setView:__glView];																\
	[director_ setDelegate:self];																\
	director_.wantsFullScreenLayout = YES;														\
	if( ! [director_ enableRetinaDisplay:YES] )													\
		CCLOG(@"Retina Display Not supported");													\
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];		\
	navController_.navigationBarHidden = YES;													\
	[window_ addSubview:navController_.view];													\
	[window_ makeKeyAndVisible];																\
} while(0)


#elif __CC_PLATFORM_MAC

#define CC_DIRECTOR_INIT(__WINSIZE__)															\
do	{																							\
	NSRect frameRect = NSMakeRect(0, 0, (__WINSIZE__).width, (__WINSIZE__).height);				\
	window_ = [[CCWindow alloc] initWithFrame:frameRect fullscreen:NO];						\
	glView_ = [[CCGLView alloc] initWithFrame:frameRect shareContext:nil];						\
	[self.window setContentView:self.glView];													\
	director_ = (CCDirectorMac*) [CCDirector sharedDirector];									\
	[director_ setDisplayStats:NO];																\
	[director_ setView:self.glView];															\
	[director_ setOriginalWinSize:__WINSIZE__];													\
	[self.window makeMainWindow];																\
	[self.window makeKeyAndOrderFront:self];													\
	[self.window center];																		\
} while(0)

#endif

/** @def CC_NODE_DRAW_SETUP
 Helpful macro that setups the GL server state, the correct GL program and sets the Model View Projection matrix
 @since v2.0
 */
#define CC_NODE_DRAW_SETUP()																	\
do {																							\
	ccGLEnable( glServerState_ );																\
    NSAssert(shaderProgram_, @"No shader program set for node: %@", self);                      \
	[shaderProgram_ use];																		\
	[shaderProgram_ setUniformForModelViewProjectionMatrix];									\
} while(0)


 /** @def CC_DIRECTOR_END
  Stops and removes the director from memory.
  Removes the CCGLView from its parent

  @since v0.99.4
  */
#define CC_DIRECTOR_END()										\
do {															\
	CCDirector *__director = [CCDirector sharedDirector];		\
	[__director end];											\
} while(0)




#if __CC_PLATFORM_IOS

/****************************/
/** RETINA DISPLAY ENABLED **/
/****************************/

/** @def CC_CONTENT_SCALE_FACTOR
 On Mac it returns 1;
 On iPhone it returns 2 if RetinaDisplay is On. Otherwise it returns 1
 */
extern float __ccContentScaleFactor;
#define CC_CONTENT_SCALE_FACTOR() __ccContentScaleFactor


/** @def CC_RECT_PIXELS_TO_POINTS
 Converts a rect in pixels to points
 */
#define CC_RECT_PIXELS_TO_POINTS(__rect_in_pixels__)																		\
	CGRectMake( (__rect_in_pixels__).origin.x / CC_CONTENT_SCALE_FACTOR(), (__rect_in_pixels__).origin.y / CC_CONTENT_SCALE_FACTOR(),	\
			(__rect_in_pixels__).size.width / CC_CONTENT_SCALE_FACTOR(), (__rect_in_pixels__).size.height / CC_CONTENT_SCALE_FACTOR() )

/** @def CC_RECT_POINTS_TO_PIXELS
 Converts a rect in points to pixels
 */
#define CC_RECT_POINTS_TO_PIXELS(__rect_in_points_points__)																		\
	CGRectMake( (__rect_in_points_points__).origin.x * CC_CONTENT_SCALE_FACTOR(), (__rect_in_points_points__).origin.y * CC_CONTENT_SCALE_FACTOR(),	\
			(__rect_in_points_points__).size.width * CC_CONTENT_SCALE_FACTOR(), (__rect_in_points_points__).size.height * CC_CONTENT_SCALE_FACTOR() )

/** @def CC_POINT_PIXELS_TO_POINTS
 Converts a rect in pixels to points
 */
#define CC_POINT_PIXELS_TO_POINTS(__pixels__)																		\
CGPointMake( (__pixels__).x / CC_CONTENT_SCALE_FACTOR(), (__pixels__).y / CC_CONTENT_SCALE_FACTOR())

/** @def CC_POINT_POINTS_TO_PIXELS
 Converts a rect in points to pixels
 */
#define CC_POINT_POINTS_TO_PIXELS(__points__)																		\
CGPointMake( (__points__).x * CC_CONTENT_SCALE_FACTOR(), (__points__).y * CC_CONTENT_SCALE_FACTOR())

/** @def CC_POINT_PIXELS_TO_POINTS
 Converts a rect in pixels to points
 */
#define CC_SIZE_PIXELS_TO_POINTS(__size_in_pixels__)																		\
CGSizeMake( (__size_in_pixels__).width / CC_CONTENT_SCALE_FACTOR(), (__size_in_pixels__).height / CC_CONTENT_SCALE_FACTOR())

/** @def CC_POINT_POINTS_TO_PIXELS
 Converts a rect in points to pixels
 */
#define CC_SIZE_POINTS_TO_PIXELS(__size_in_points__)																		\
CGSizeMake( (__size_in_points__).width * CC_CONTENT_SCALE_FACTOR(), (__size_in_points__).height * CC_CONTENT_SCALE_FACTOR())


#elif defined(__CC_PLATFORM_MAC)

/*****************************/
/** RETINA DISPLAY DISABLED **/
/*****************************/

#define CC_CONTENT_SCALE_FACTOR() 1
#define CC_RECT_PIXELS_TO_POINTS(__pixels__) __pixels__
#define CC_RECT_POINTS_TO_PIXELS(__points__) __points__
#define CC_SIZE_PIXELS_TO_POINTS(__pixels__) __pixels__
#define CC_SIZE_POINTS_TO_PIXELS(__points__) __points__
#define CC_POINT_PIXELS_TO_POINTS(__pixels__) __pixels__
#define CC_POINT_POINTS_TO_PIXELS(__points__) __points__


#endif // __CC_PLATFORM_MAC


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

/*****************/
/** ARC Macros  **/
/*****************/
#if defined(__has_feature) && __has_feature(objc_arc)
// ARC (used for inline functions)
#define CC_ARC_RETAIN(value)	value
#define CC_ARC_RELEASE(value)	value = 0
#define CC_ARC_UNSAFE_RETAINED	__unsafe_unretained

#else
// No ARC
#define CC_ARC_RETAIN(value)	[value retain]
#define CC_ARC_RELEASE(value)	[value release]
#define CC_ARC_UNSAFE_RETAINED
#endif

/** @def CC_INCREMENT_GL_DRAWS_BY_ONE
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
