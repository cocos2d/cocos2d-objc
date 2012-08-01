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


#import <objc/runtime.h>
#import "jsapi.h"

#import "cocos2d.h"
#import "chipmunk.h"
#import "ChipmunkSprite.h"
#import "ChipmunkDebugNode.h"
#import "SimpleAudioEngine.h"

// Globals
// one shared key for associations
extern char * JSPROXY_association_proxy_key;

/**
 */
@interface ScriptingCore : NSObject
{
	JSRuntime	*_rt;
	JSContext	*_cx;
	JSObject	*_object;
}

/** return the global context */
@property (nonatomic, readonly) JSRuntime* runtime;

/** return the global context */
@property (nonatomic, readonly) JSContext* globalContext;

/** return the global context */
@property (nonatomic, readonly) JSObject* globalObject;


/** returns the shared instance */
+(ScriptingCore*) sharedInstance;

/**
 * @param cx
 * @param message
 * @param report
 */
+(void) reportErrorWithContext:(JSContext*)cx message:(NSString*)message report:(JSErrorReport*)report;

/**
 * Log something using CCLog
 * @param cx
 * @param argc
 * @param vp
 */
+(JSBool) logWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp;

/**
 * run a script from script :)
 */
+(JSBool) executeScriptWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp;

/**
 * Register an object as a member of the GC's root set, preventing
 * them from being GC'ed
 */
+(JSBool) addRootJSWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp;

/**
 * removes an object from the GC's root, allowing them to be GC'ed if no
 * longer referenced.
 */
+(JSBool) removeRootJSWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp;

/**
 * Force a cycle of GC
 * @param cx
 * @param argc
 * @param vp
 */
+(JSBool) forceGCWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp;

/**
 * will eval the specified string
 * @param string The string with the javascript code to be evaluated
 * @param outVal The jsval that will hold the return value of the evaluation.
 * Can be NULL.
 */
-(BOOL) evalString:(NSString*)string outVal:(jsval*)outVal;

/**
 * will run the specified string
 * @param string The path of the script to be run
 */
-(JSBool) runScript:(NSString*)filename;

@end

#ifdef __cplusplus
extern "C" {
#endif
	@class JSPROXY_NSObject;
	JSPROXY_NSObject* get_proxy_for_jsobject(JSObject *jsobj);
	void set_proxy_for_jsobject(JSPROXY_NSObject* proxy, JSObject *jsobj);
	void del_proxy_for_jsobject(JSObject *jsobj);
	
	JSBool set_reserved_slot(JSObject *obj, NSUInteger idx, jsval value);
	
#ifdef __cplusplus
}
#endif

