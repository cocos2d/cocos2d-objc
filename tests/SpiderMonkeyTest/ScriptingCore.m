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


// Globals
char * JSPROXY_association_proxy_key = NULL;

static JSClass global_class = {
	"global", JSCLASS_GLOBAL_FLAGS,
	JS_PropertyStub, JS_PropertyStub, JS_PropertyStub, JS_StrictPropertyStub,
	JS_EnumerateStub, JS_ResolveStub, JS_ConvertStub, JS_FinalizeStub,
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
			CCLOG(@"%s", cstr);
		}
		
		return JS_TRUE;
	}
	return JS_FALSE;
};

JSBool ScriptingCore_executeScript(JSContext *cx, uint32_t argc, jsval *vp)
{
	if (argc == 1) {
		JSString *string;
		if (JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "S", &string) == JS_TRUE) {
			[[ScriptingCore sharedInstance]	runScript: [NSString stringWithCString:JS_EncodeString(cx, string) encoding:NSUTF8StringEncoding] ];
		}
		
		return JS_TRUE;
	}
	
	return JS_FALSE;
};

JSBool ScriptingCore_associateObjectWithNative(JSContext *cx, uint32_t argc, jsval *vp)
{
	if (argc == 2) {
		
		jsval *argvp = JS_ARGV(cx,vp);
		JSObject *pureJSObj;
		JSObject *nativeJSObj;
		JS_ValueToObject( cx, *argvp++, &pureJSObj );
		JS_ValueToObject( cx, *argvp++, &nativeJSObj );
		
		JSPROXY_NSObject *proxy = get_proxy_for_jsobject( nativeJSObj );
//		JSPROXY_NSObject *proxy = JS_GetPrivate( nativeJSObj );
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
#ifdef __CC_PLATFORM_IOS
	platform = JS_InternString(cx, "mobile/iOS");
#elif defined(__CC_PLATFORM_MAC)
	platform = JS_InternString(cx, "desktop/OSX");
#else
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
 * Force a cycle of GC
 */
JSBool ScriptingCore_forceGC(JSContext *cx, uint32_t argc, jsval *vp)
{
	JS_GC(cx);
	return JS_TRUE;
};

/*
 * Force a cycle of GC
 */
static void dumpNamedRoot(const char *name, void *addr,  JSGCRootType type, void *data)
{
    printf("There is a root named '%s' at %p\n", name, addr);
}
JSBool ScriptingCore_dumpRoot(JSContext *cx, uint32_t argc, jsval *vp)
{
//	JSRuntime *rt = [[ScriptingCore sharedInstance] runtime];
//	JS_DumpNamedRoots(rt, dumpNamedRoot, NULL);
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

		JS_DefineFunction(_cx, cocos2d, "log", ScriptingCore_log, 0, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );

		JSPROXY_NSObject_createClass(_cx, cocos2d, "Object");
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
		//		JSObject *CocosDenshion = JS_NewObject( _cx, NULL, NULL, NULL);
		//		jsval denshionVal = OBJECT_TO_JSVAL(CocosDenshion);
		//		JS_SetProperty(_cx, _object, "cd", &denshionVal);
		
		// Reuse "cc" namespace for CocosDenshion
		JSObject *CocosDenshion = cocos2d;
#import "js_bindings_CocosDenshion_classes_registration.h"

		//
		// Chipmunk
		//
		JSObject *chipmunk = JS_NewObject( _cx, NULL, NULL, NULL);
		jsval chipmunkVal = OBJECT_TO_JSVAL(chipmunk);
		JS_SetProperty(_cx, _object, "cp", &chipmunkVal);
#import "js_bindings_chipmunk_functions_registration.h"
		
		// manual
		JS_DefineFunction(_cx, chipmunk, "spaceAddCollisionHandler", JSPROXY_cpSpaceAddCollisionHandler, 8, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
		JS_DefineFunction(_cx, chipmunk, "spaceRemoveCollisionHandler", JSPROXY_cpSpaceRemoveCollisionHandler, 8, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
		JS_DefineFunction(_cx, chipmunk, "arbiterGetBodies", JSPROXY_cpArbiterGetBodies, 1, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
		JS_DefineFunction(_cx, chipmunk, "arbiterGetShapes", JSPROXY_cpArbiterGetShapes, 1, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
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
	ok = JS_EvaluateScript( _cx, _object, cstr, strlen(cstr), filename, lineno, outVal);
	if (ok == JS_FALSE) {
		CCLOGWARN(@"error evaluating script:%@", string);
	}
	str = JS_ValueToString( _cx, rval);
	return ok;
}

-(BOOL) runScript2:(NSString*)filename
{
	CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];
#ifdef DEBUG
	/**
	 * dpath should point to the parent directory of the "JS" folder. If this is
	 * set to "" (as it is now) then it will take the scripts from the app bundle.
	 * By setting the absolute path you can iterate the development only by
	 * modifying those scripts and reloading from the simulator (no recompiling/
	 * relaunching)
	 */
//	std::string dpath("/Users/rabarca/Desktop/testjs/testjs/");
//	std::string dpath("");
//	dpath += path;
	NSString *fullpath = [fileUtils fullPathFromRelativePath:filename];
#else
	NSString *fullpath = [fileUtils fullPathFromRelativePath:filename];
#endif
	unsigned char *content = NULL;
	size_t contentSize = ccLoadFileIntoMemory([fullpath UTF8String], &content);
	if (content && contentSize) {
		JSBool ok;
		jsval rval;
		ok = JS_EvaluateScript( _cx, _object, (char *)content, contentSize, [filename UTF8String], 1, &rval);
		if (ok == JS_FALSE) {
			CCLOGWARN(@"error evaluating script: %@", filename);
		}
		free(content);
	}
	
	return YES;
}

/*
 * Compile a script and execute it. It roots the script
 */
-(BOOL) runScript:(NSString*)filename
{
    JSScript *script;
	
	CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];
	NSString *fullpath = [fileUtils fullPathFromRelativePath:filename];

	script = JS_CompileUTF8File(_cx, _object, [fullpath UTF8String] );

    if (script == NULL)
        return NO;   /* compilation error */
		
    if (!JS_AddNamedScriptRoot(_cx, &script, "compiled script"))
        return NO;
	
	jsval result;	
	if (!JS_ExecuteScript(_cx, _object, script, &result)) {
		NSLog(@"Failed to execute script");
    }
	
//    JS_RemoveScriptRoot(_cx, &script);  /* scriptObj becomes unreachable
//										   and will eventually be collected. */
    return YES;
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
	
	tHashJSObject *element = malloc( sizeof( *element ) );

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

