/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2012 Zynga Inc.
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


#ifndef __JS_BINDINGS_CONFIG_H
#define __JS_BINDINGS_CONFIG_H


/** @def JSB_ASSERT_ON_FAIL
 */
#ifndef JSB_ASSERT_ON_FAIL
#define JSB_ASSERT_ON_FAIL 0
#endif


#if JSB_ASSERT_ON_FAIL
#define JSB_PRECONDITION( condition, error_msg) do { NSCAssert( condition, error_msg ) } while(0)
#else
#define JSB_PRECONDITION( condition, error_msg) do {							\
	if( ! (condition) ) {														\
		CCLOG(@"jsb: ERROR in %s: %@", __FUNCTION__, error_msg);				\
		return JS_FALSE;														\
	}																			\
} while(0)
#endif

#endif // __JS_BINDINGS_CONFIG_H


/** @def JSB_USE_COCOS2D
 Whether or not it should assume that cocos2d is being used.
 Useful, for example, to send the touches/events in cocos2d format
*/
#ifndef JSB_USE_COCOS2D
#define JSB_USE_COCOS2D 1
#endif // JSB_USE_COCOS2D
