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

#import "cocos2d.h"
#import "ScriptingCore.h"
#import "js_bindings_config.h"

#import "js_bindings_NS_manual.h"

#import "js_bindings_cocos2d_classes.h"
#import "js_bindings_cocos2d_functions.h"
#ifdef __CC_PLATFORM_IOS
#import "js_bindings_cocos2d_ios_classes.h"
#import "js_bindings_cocos2d_ios_functions.h"
#elif defined(__CC_PLATFORM_MAC)
#import "js_bindings_cocos2d_mac_classes.h"
#import "js_bindings_cocos2d_mac_functions.h"
#endif
#import "js_bindings_chipmunk_functions.h"
#import "js_bindings_chipmunk_manual.h"
#import "js_bindings_CocosDenshion_classes.h"
#import "js_bindings_CocosBuilderReader_classes.h"

// Globals
char * JSPROXY_association_proxy_key = NULL;

static void
its_finalize(JSFreeOp *fop, JSObject *obj)
{
	CCLOGINFO(@"Finalizing global class");
}

static JSClass global_class = {
	"__global", JSCLASS_GLOBAL_FLAGS,
	JS_PropertyStub, JS_PropertyStub,
	JS_PropertyStub, JS_StrictPropertyStub,
	JS_EnumerateStub, JS_ResolveStub,
	JS_ConvertStub, its_finalize,
	JSCLASS_NO_OPTIONAL_MEMBERS
};

#pragma mark ScriptingCore - Helper free functions
static void reportError(JSContext *cx, const char *message, JSErrorReport *report)
{
	fprintf(stderr, "%s:%u:%s\n",  
			report->filename ? report->filename : "<no filename=\"filename\">",  
			(unsigned int) report->lineno,  
			message);
};

#pragma mark ScriptingCore - Free JS functions

JSBool ScriptingCore_log(JSContext *cx, uint32_t argc, jsval *vp)
{
	if (argc > 0) {
		JSString *string = NULL;
		JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "S", &string);
		if (string) {
			char *cstr = JS_EncodeString(cx, string);
			printf("%s\n", cstr);
		}
		
		return JS_TRUE;
	}
	return JS_FALSE;
};

JSBool ScriptingCore_executeScript(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSBool ok = JS_FALSE;
	if (argc == 1) {
		JSString *string;
		if (JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "S", &string) == JS_TRUE) {
			ok = [[ScriptingCore sharedInstance] runScript: [NSString stringWithCString:JS_EncodeString(cx, string) encoding:NSUTF8StringEncoding] ];
		}
	}
	
	return ok;
};

JSBool ScriptingCore_associateObjectWithNative(JSContext *cx, uint32_t argc, jsval *vp)
{
	if (argc == 2) {
		
		jsval *argvp = JS_ARGV(cx,vp);
		JSObject *pureJSObj;
		JSObject *nativeJSObj;
		JSBool ok = JS_TRUE;
		ok &= JS_ValueToObject( cx, *argvp++, &pureJSObj );
		ok &= JS_ValueToObject( cx, *argvp++, &nativeJSObj );
		
		if( ! (ok && pureJSObj && nativeJSObj) )
			return JS_FALSE;
		
		JSPROXY_NSObject *proxy = get_proxy_for_jsobject( nativeJSObj );
		set_proxy_for_jsobject( proxy, pureJSObj );
		[proxy setJsObj:pureJSObj];
		
		return JS_TRUE;
	}
	
	return JS_FALSE;
};

JSBool ScriptingCore_getAssociatedNative(JSContext *cx, uint32_t argc, jsval *vp)
{
	if (argc == 1) {
		
		jsval *argvp = JS_ARGV(cx,vp);
		JSObject *pureJSObj;
		JS_ValueToObject( cx, *argvp++, &pureJSObj );
		
		JSPROXY_NSObject *proxy = get_proxy_for_jsobject( pureJSObj );
		id native = [proxy realObj];
		
		JSObject * obj = get_or_create_jsobject_from_realobj(cx, native);
		JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(obj) );
		
		return JS_TRUE;
	}
	
	return JS_FALSE;
};

JSBool ScriptingCore_address(JSContext *cx, uint32_t argc, jsval *vp)
{
	if (argc==1 || argc==2) {
		
		JSObject* jsThis = (JSObject *)JS_THIS_OBJECT(cx, vp);

		jsval *argvp = JS_ARGV(cx,vp);
		JSObject *jsObj;
		JS_ValueToObject( cx, *argvp++, &jsObj);

		NSString *str = @"-";
		if( argc == 2 ) {
			NSString *tmp;
			jsval_to_nsstring( cx, *argvp++, &tmp );
		}
		NSLog(@"Address this:%p arg:%p - %@", jsThis, jsObj, str);

		return JS_TRUE;
	}

	return JS_FALSE;
};

JSBool ScriptingCore_platform(JSContext *cx, uint32_t argc, jsval *vp)
{
	if (argc != 0 )
		return JS_FALSE;

	JSString * platform;

// iOS is always 32 bits
#ifdef __CC_PLATFORM_IOS
	platform = JS_InternString(cx, "mobile/iOS/32");

// Mac can be 32 or 64 bits
#elif defined(__CC_PLATFORM_MAC)

#ifdef __LP64__
	platform = JS_InternString(cx, "desktop/OSX/64");
#else
	platform = JS_InternString(cx, "desktop/OSX/32");
#endif // 32 or 64

#else // unknown platform
#error "Unsupported platform"
#endif
	jsval ret = STRING_TO_JSVAL(platform);
	
	JS_SET_RVAL(cx, vp, ret);

	return JS_TRUE;
};



/* Register an object as a member of the GC's root set, preventing them from being GC'ed */
JSBool ScriptingCore_addRootJS(JSContext *cx, uint32_t argc, jsval *vp)
{
	if (argc == 1) {
		JSObject *o = NULL;
		if (JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "o", &o) == JS_TRUE) {
			if (JS_AddObjectRoot(cx, &o) == JS_FALSE) {
				CCLOGWARN(@"something went wrong when setting an object to the root");
			}
		}
		
		return JS_TRUE;
	}
	return JS_FALSE;
};

/*
 * removes an object from the GC's root, allowing them to be GC'ed if no
 * longer referenced.
 */
JSBool ScriptingCore_removeRootJS(JSContext *cx, uint32_t argc, jsval *vp)
{
	if (argc == 1) {
		JSObject *o = NULL;
		if (JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "o", &o) == JS_TRUE) {
			JS_RemoveObjectRoot(cx, &o);
		}
		return JS_TRUE;
	}
	return JS_FALSE;
};

/*
 * Dumps GC
 */
static void dumpNamedRoot(const char *name, void *addr,  JSGCRootType type, void *data)
{
    printf("There is a root named '%s' at %p\n", name, addr);
}
JSBool ScriptingCore_dumpRoot(JSContext *cx, uint32_t argc, jsval *vp)
{
	// JS_DumpNamedRoots is only available on DEBUG versions of SpiderMonkey.
	// Mac and Simulator versions were compiled with DEBUG.
#if DEBUG && (defined(__CC_PLATFORM_MAC) || TARGET_IPHONE_SIMULATOR )
	JSRuntime *rt = [[ScriptingCore sharedInstance] runtime];
	JS_DumpNamedRoots(rt, dumpNamedRoot, NULL);
#endif
	return JS_TRUE;
};

/*
 * Force a cycle of GC
 */
JSBool ScriptingCore_forceGC(JSContext *cx, uint32_t argc, jsval *vp)
{
	JS_GC( [[ScriptingCore sharedInstance] runtime] );
	return JS_TRUE;
};



@implementation ScriptingCore

@synthesize globalObject = _object;
@synthesize globalContext = _cx;
@synthesize runtime = _rt;

+ (id)sharedInstance
{
	static dispatch_once_t pred;
	static ScriptingCore *instance = nil;
	dispatch_once(&pred, ^{
		instance = [[self alloc] init];
	});
	return instance;
}

-(id) init
{
	self = [super init];
	if( self ) {

		_rt = JS_NewRuntime(8 * 1024 * 1024);
		_cx = JS_NewContext( _rt, 8192);
		JS_SetOptions(_cx, JSOPTION_VAROBJFIX);
		JS_SetVersion(_cx, JSVERSION_LATEST);
		JS_SetErrorReporter(_cx, reportError);
		_object = JS_NewCompartmentAndGlobalObject( _cx, &global_class, NULL);
		if (!JS_InitStandardClasses( _cx, _object)) {
			CCLOGWARN(@"js error");
		}
		
		
		//
		// globals
		//
		JS_DefineFunction(_cx, _object, "require", ScriptingCore_executeScript, 1, JSPROP_READONLY | JSPROP_PERMANENT);
		JS_DefineFunction(_cx, _object, "__associateObjWithNative", ScriptingCore_associateObjectWithNative, 2, JSPROP_READONLY | JSPROP_PERMANENT);
		JS_DefineFunction(_cx, _object, "__getAssociatedNative", ScriptingCore_getAssociatedNative, 2, JSPROP_READONLY | JSPROP_PERMANENT);
		JS_DefineFunction(_cx, _object, "__address", ScriptingCore_address, 2, JSPROP_READONLY | JSPROP_PERMANENT);
		JS_DefineFunction(_cx, _object, "__getPlatform", ScriptingCore_platform, 0, JSPROP_READONLY | JSPROP_PERMANENT);

		// 
		// Javascript controller (__jsc__)
		//
		JSObject *jsc = JS_NewObject( _cx, NULL, NULL, NULL);
		jsval jscVal = OBJECT_TO_JSVAL(jsc);
		JS_SetProperty(_cx, _object, "__jsc__", &jscVal);

		JS_DefineFunction(_cx, jsc, "garbageCollect", ScriptingCore_forceGC, 0, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
		JS_DefineFunction(_cx, jsc, "dumpRoot", ScriptingCore_dumpRoot, 0, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
		JS_DefineFunction(_cx, jsc, "addGCRootObject", ScriptingCore_addRootJS, 1, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
		JS_DefineFunction(_cx, jsc, "removeGCRootObject", ScriptingCore_removeRootJS, 1, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
		JS_DefineFunction(_cx, jsc, "executeScript", ScriptingCore_executeScript, 1, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );

		//
		// cocos2d
		//
		JSObject *cocos2d = JS_NewObject( _cx, NULL, NULL, NULL);
		jsval cocosVal = OBJECT_TO_JSVAL(cocos2d);
		JS_SetProperty(_cx, _object, "cc", &cocosVal);
		
		// Config Object
		JSObject *ccconfig = JS_NewObject(_cx, NULL, NULL, NULL);
		// config.os: The Operating system
		// osx, ios, android, windows, linux, etc..
#ifdef __CC_PLATFORM_MAC
		JSString *str = JS_InternString(_cx, "osx");
#elif defined(__CC_PLATFORM_IOS)
		JSString *str = JS_InternString(_cx, "ios");
#endif
		JS_DefineProperty(_cx, ccconfig, "os", STRING_TO_JSVAL(str), NULL, NULL, JSPROP_ENUMERATE | JSPROP_READONLY | JSPROP_PERMANENT);

		// config.deviceType: Device Type
		// 'mobile' for any kind of mobile devices, 'desktop' for PCs, 'browser' for Web Browsers
#ifdef __CC_PLATFORM_MAC
		str = JS_InternString(_cx, "desktop");
#elif defined(__CC_PLATFORM_IOS)
		str = JS_InternString(_cx, "mobile");
#endif
		JS_DefineProperty(_cx, ccconfig, "deviceType", STRING_TO_JSVAL(str), NULL, NULL, JSPROP_ENUMERATE | JSPROP_READONLY | JSPROP_PERMANENT);

		// config.engine: Type of renderer
		// 'cocos2d', 'cocos2d-x', 'cocos2d-html5/canvas', 'cocos2d-html5/webgl', etc..
		str = JS_InternString(_cx, "cocos2d");
		JS_DefineProperty(_cx, ccconfig, "engine", STRING_TO_JSVAL(str), NULL, NULL, JSPROP_ENUMERATE | JSPROP_READONLY | JSPROP_PERMANENT);
		
		// config.arch: CPU Architecture
		// i386, ARM, x86_64, web
#ifdef __LP64__
		str = JS_InternString(_cx, "x86_64");
#elif defined(__arm__) || defined(__ARM_NEON__)
		str = JS_InternString(_cx, "arm");
#else
		str = JS_InternString(_cx, "i386");
#endif
		JS_DefineProperty(_cx, ccconfig, "arch", STRING_TO_JSVAL(str), NULL, NULL, JSPROP_ENUMERATE | JSPROP_READONLY | JSPROP_PERMANENT);

		// config.version: Version of cocos2d + renderer
		str = JS_InternString(_cx, [cocos2dVersion() UTF8String] );
		JS_DefineProperty(_cx, ccconfig, "version", STRING_TO_JSVAL(str), NULL, NULL, JSPROP_ENUMERATE | JSPROP_READONLY | JSPROP_PERMANENT);

		// config.usesTypedArrays
#if JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES
		JSBool b = JS_FALSE;
#else
		JSBool b = JS_TRUE;
#endif
		JS_DefineProperty(_cx, ccconfig, "usesTypedArrays", BOOLEAN_TO_JSVAL(b), NULL, NULL, JSPROP_ENUMERATE | JSPROP_READONLY | JSPROP_PERMANENT);
		
		// config.debug: Debug build ?
#ifdef DEBUG
		b = JS_TRUE;
#else
		b = JS_FALSE;
#endif
		JS_DefineProperty(_cx, ccconfig, "debug", BOOLEAN_TO_JSVAL(b), NULL, NULL, JSPROP_ENUMERATE | JSPROP_READONLY | JSPROP_PERMANENT);

		
		// Add "config" to "cc"
		JS_DefineProperty(_cx, cocos2d, "config", OBJECT_TO_JSVAL(ccconfig), NULL, NULL, JSPROP_ENUMERATE | JSPROP_READONLY | JSPROP_PERMANENT);


		JS_DefineFunction(_cx, cocos2d, "log", ScriptingCore_log, 0, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );

		JSPROXY_NSObject_createClass(_cx, cocos2d, "Object");
#ifdef __CC_PLATFORM_MAC
		JSPROXY_NSEvent_createClass(_cx, cocos2d, "Event");
#elif defined(__CC_PLATFORM_IOS)
		JSPROXY_UITouch_createClass(_cx, cocos2d, "Touch");
		JSPROXY_UIAccelerometer_createClass(_cx, cocos2d, "Accelerometer");
#endif

		// Register classes: base classes should be registered first

#import "js_bindings_cocos2d_classes_registration.h"
#import "js_bindings_cocos2d_functions_registration.h"

#ifdef __CC_PLATFORM_IOS
		JSObject *cocos2d_ios = cocos2d;
#import "js_bindings_cocos2d_ios_classes_registration.h"
#import "js_bindings_cocos2d_ios_functions_registration.h"
#elif defined(__CC_PLATFORM_MAC)
		JSObject *cocos2d_mac = cocos2d;
#import "js_bindings_cocos2d_mac_classes_registration.h"
#import "js_bindings_cocos2d_mac_functions_registration.h"
#endif
		
		//
		// CocosDenshion
		//
		// Reuse "cc" namespace for CocosDenshion
		JSObject *CocosDenshion = cocos2d;
#import "js_bindings_CocosDenshion_classes_registration.h"

		//
		// CocosBuilderReader
		//
		// Reuse "cc" namespace for CocosBuilderReader
		JSObject *CocosBuilderReader = cocos2d;
#import "js_bindings_CocosBuilderReader_classes_registration.h"

		//
		// Chipmunk
		//
		JSObject *chipmunk = JS_NewObject( _cx, NULL, NULL, NULL);
		jsval chipmunkVal = OBJECT_TO_JSVAL(chipmunk);
		JS_SetProperty(_cx, _object, "cp", &chipmunkVal);
#import "js_bindings_chipmunk_functions_registration.h"
		
		// manual
		JS_DefineFunction(_cx, chipmunk, "spaceAddCollisionHandler", JSPROXY_cpSpaceAddCollisionHandler, 8, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
		JS_DefineFunction(_cx, chipmunk, "spaceRemoveCollisionHandler", JSPROXY_cpSpaceRemoveCollisionHandler, 3, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
		JS_DefineFunction(_cx, chipmunk, "arbiterGetBodies", JSPROXY_cpArbiterGetBodies, 1, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
		JS_DefineFunction(_cx, chipmunk, "arbiterGetShapes", JSPROXY_cpArbiterGetShapes, 1, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
		JS_DefineFunction(_cx, chipmunk, "bodyGetUserData", JSPROXY_cpBodyGetUserData, 1, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
		JS_DefineFunction(_cx, chipmunk, "bodySetUserData", JSPROXY_cpBodySetUserData, 2, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
	}
	
	return self;
}

+(void) reportErrorWithContext:(JSContext*)cx message:(NSString*)message report:(JSErrorReport*)report
{
	
}

+(JSBool) logWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp
{
	return JS_TRUE;	
}

+(JSBool) executeScriptWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp
{
	return JS_TRUE;	
}

+(JSBool) addRootJSWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp
{
	return JS_TRUE;
}

+(JSBool) removeRootJSWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp
{
	return JS_TRUE;	
}

+(JSBool) forceGCWithContext:(JSContext*)cx argc:(uint32_t)argc vp:(jsval*)vp
{
	return JS_TRUE;
}

-(BOOL) evalString:(NSString*)string outVal:(jsval*)outVal
{
	jsval rval;
	JSString *str;
	JSBool ok;
	const char *filename = "noname";
	uint32_t lineno = 0;
	if (outVal == NULL) {
		outVal = &rval;
	}
	const char *cstr = [string UTF8String];
	ok = JS_EvaluateScript( _cx, _object, cstr, (unsigned)strlen(cstr), filename, lineno, outVal);
	if (ok == JS_FALSE) {
		CCLOGWARN(@"error evaluating script:%@", string);
	}
	str = JS_ValueToString( _cx, rval);
	return ok;
}

-(JSBool) runScript2:(NSString*)filename
{
	JSBool ok = JS_FALSE;

	CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];
	NSString *fullpath = [fileUtils fullPathFromRelativePath:filename];

	unsigned char *content = NULL;
	size_t contentSize = ccLoadFileIntoMemory([fullpath UTF8String], &content);
	if (content && contentSize) {
		jsval rval;
		ok = JS_EvaluateScript( _cx, _object, (char *)content, (unsigned)contentSize, [filename UTF8String], 1, &rval);
		free(content);
		
		if (ok == JS_FALSE)
			CCLOGWARN(@"error evaluating script: %@", filename);
	}
	
	return ok;
}

/*
 * Compile a script and execute it. It roots the script
 */
-(JSBool) runScript:(NSString*)filename
{
	JSBool ok = JS_FALSE;

	static JSScript *script;
	
	CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];
	NSString *fullpath = [fileUtils fullPathFromRelativePath:filename];

	script = JS_CompileUTF8File(_cx, _object, [fullpath UTF8String] );

    if (script == NULL)
        return JS_FALSE;   /* compilation error */
		
	const char * name = [[NSString stringWithFormat:@"script %@", filename] UTF8String];
	char *static_name = (char*) malloc(strlen(name)+1);
	strcpy(static_name, name );

    if (!JS_AddNamedScriptRoot(_cx, &script, static_name ) )
        return JS_FALSE;
	
	jsval result;	
	ok = JS_ExecuteScript(_cx, _object, script, &result);
	
	if( ! ok )
		NSLog(@"Failed to execute script");
	
    JS_RemoveScriptRoot(_cx, &script);  /* scriptObj becomes unreachable
										   and will eventually be collected. */
	free( static_name);

    return ok;
}

-(void) dealloc
{
	[super dealloc];

	JS_DestroyContext(_cx);
	JS_DestroyRuntime(_rt);
	JS_ShutDown();
}
@end


typedef struct _hashJSObject
{
	JSObject			*jsObject;
	JSPROXY_NSObject	*proxy;
	UT_hash_handle		hh;
} tHashJSObject;

static tHashJSObject *hash = NULL;

JSPROXY_NSObject* get_proxy_for_jsobject(JSObject *obj)
{
	tHashJSObject *element = NULL;
	HASH_FIND_INT(hash, &obj, element);
	
	if( element )
		return element->proxy;
	return nil;
}

void set_proxy_for_jsobject(JSPROXY_NSObject *proxy, JSObject *obj)
{
	NSCAssert( !get_proxy_for_jsobject(obj), @"Already added. abort");
	
//	printf("Setting proxy for: %p - %p (%s)\n", obj, proxy, [[proxy description] UTF8String] );
	
	tHashJSObject *element = (tHashJSObject*) malloc( sizeof( *element ) );

	// XXX: Do not retain it here.
//	[proxy retain];
	element->proxy = proxy;
	element->jsObject = obj;

	HASH_ADD_INT( hash, jsObject, element );
}

void del_proxy_for_jsobject(JSObject *obj)
{
	tHashJSObject *element = NULL;
	HASH_FIND_INT(hash, &obj, element);
	if( element ) {
		
//		printf("Deleting proxy for: %p - %p (%s)\n", obj, element->proxy, [[element->proxy description] UTF8String] );
//		[element->proxy release];

		HASH_DEL(hash, element);
		free(element);
	}
}

JSBool set_reserved_slot(JSObject *obj, uint32_t idx, jsval value)
{
	JSClass *klass = JS_GetClass(obj);
	NSUInteger slots = JSCLASS_RESERVED_SLOTS(klass);
	if( idx >= slots )
		return JS_FALSE;
	
	JS_SetReservedSlot(obj, idx, value);
	
	return JS_TRUE;
}
