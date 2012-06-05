//
//  ScriptingCore.h
//

#import <objc/runtime.h>
#import "jsapi.h"

#import "cocos2d.h"

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
-(void) runScript:(NSString*)filename;

@end


#ifdef __cplusplus
extern "C" {
#endif

/** Creates a JSObject, a ProxyObject and associates them with the real object */
extern JSObject* create_jsobject_from_realobj( Class klass,id realObj, JSContext* context );

/** Gets or Creates a JSObject, a ProxyObject and associates them with the real object */
extern JSObject * get_or_create_jsobject_from_realobj( id realObj, JSContext *cx );

NSString *js_argv_to_nsstring(jsval vp, JSContext *cx );

id js_argv_to_object( jsval vp, JSContext *cx );

NSMutableArray* js_argv_to_nsarray( jsval vp, JSContext *cx );
	
#ifdef __cplusplus
}
#endif
