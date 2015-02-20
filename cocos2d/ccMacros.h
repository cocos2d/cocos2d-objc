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


#import <Availability.h>

#import "ccConfig.h"

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
