//
//  ScriptingCore.m
//  testmonkey
//


#import "cocos2d.h"
#import "ScriptingCore.h"
#import "js_bindings_NSObject.h"
#import "js_bindings_cocos2d.h"

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
	}
	return JS_TRUE;
};

JSBool ScriptingCore_executeScript(JSContext *cx, uint32_t argc, jsval *vp)
{
	if (argc == 1) {
		JSString *string;
		if (JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "S", &string) == JS_TRUE) {
			[[ScriptingCore sharedInstance]	runScript: [NSString stringWithCString:JS_EncodeString(cx, string) encoding:NSUTF8StringEncoding] ];
		}
	}
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
	}
	return JS_TRUE;
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
	}
	return JS_TRUE;
};

/*
 * Force a cycle of GC
 */
JSBool ScriptingCore_forceGC(JSContext *cx, uint32_t argc, jsval *vp)
{
	JS_GC(cx);
	return JS_TRUE;
};

JSBool ScriptingCore_addToRunningScene(JSContext *cx, uint32_t argc, jsval *vp)
{
	if (argc == 1) {
		JSObject *o = NULL;
		if (JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "o", &o) == JS_TRUE) {
			JSPROXY_CCNode *proxy = JS_GetPrivate(o);
			CCNode *node = [proxy realObj];

			CCDirector *director = [CCDirector sharedDirector];
			
			[[director runningScene] walkSceneGraph:0];
			[[director runningScene] addChild:node];
			[[director runningScene] walkSceneGraph:0];
		}
	}
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
		// create the cocos namespace
		JSObject *cocos2d = JS_NewObject( _cx, NULL, NULL, NULL);
		jsval cocosVal = OBJECT_TO_JSVAL(cocos2d);
		JS_SetProperty(_cx, _object, "cc", &cocosVal);

		// register some global functions
		JS_DefineFunction(_cx, cocos2d, "log", ScriptingCore_log, 0, JSPROP_READONLY | JSPROP_PERMANENT);
		JS_DefineFunction(_cx, cocos2d, "executeScript", ScriptingCore_executeScript, 1, JSPROP_READONLY | JSPROP_PERMANENT);
		JS_DefineFunction(_cx, cocos2d, "addGCRootObject", ScriptingCore_addRootJS, 1, JSPROP_READONLY | JSPROP_PERMANENT);
		JS_DefineFunction(_cx, cocos2d, "removeGCRootObject", ScriptingCore_removeRootJS, 1, JSPROP_READONLY | JSPROP_PERMANENT);
		JS_DefineFunction(_cx, cocos2d, "forceGC", ScriptingCore_forceGC, 0, JSPROP_READONLY | JSPROP_PERMANENT);
		JS_DefineFunction(_cx, cocos2d, "addToRunningScene", ScriptingCore_addToRunningScene, 1, JSPROP_READONLY | JSPROP_PERMANENT);

				
		// Register classes: base classes should be registered first
#import "js_bindings_class_registration_cocos2d.h"		
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

-(void) runScript:(NSString*)filename
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
}

-(void) dealloc
{
	[super dealloc];

	JS_DestroyContext(_cx);
	JS_DestroyRuntime(_rt);
	JS_ShutDown();
}
@end

JSObject* create_jsobject_from_realobj( Class klass,id realObj, JSContext* context )
{
	NSString *proxied_class = [NSString stringWithFormat:@"JSPROXY_%@", klass];
	Class class = NSClassFromString(proxied_class);
	if( class )
		return [class createJSObjectWithRealObject:realObj context:context];

	CCLOGWARN(@"Proxied class not found: %@. Trying with parent class", proxied_class );
	return create_jsobject_from_realobj([klass superclass], realObj, context );
}

JSObject * get_or_create_jsobject_from_realobj( id realObj, JSContext *cx )
{
	JSPROXY_NSObject *proxy = objc_getAssociatedObject(realObj, &JSPROXY_association_proxy_key );
	if( proxy )
		return [proxy jsObj];
	
	return create_jsobject_from_realobj( [realObj class], realObj, cx );
}


// Convert function
NSString *jsval_to_nsstring(jsval vp, JSContext *cx )
{
	JSString *jsstr = JS_ValueToString( cx, vp );
	return [NSString stringWithUTF8String: JS_EncodeString(cx, jsstr)];
}

id jsval_to_nsobject( jsval vp, JSContext *cx )
{
	JSObject *jsobj;
	JS_ValueToObject( cx, vp, &jsobj );
	JSPROXY_NSObject* proxy = (JSPROXY_NSObject*) JS_GetPrivate( jsobj ); 
	return [proxy realObj];
}

NSMutableArray* jsval_to_nsarray( jsval vp, JSContext *cx )
{
	// Parsing sequence
	JSObject *jsobj;
	JS_ValueToObject( cx, vp, &jsobj );
	
	NSCAssert( JS_IsArrayObject( cx, jsobj), @"Invalid argument. It is not an array" );
	uint32_t len;
	JS_GetArrayLength(cx, jsobj,&len);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:len];
	for( uint32_t i=0; i< len;i++ ) {		
		jsval valarg;
		JS_GetElement(cx, jsobj, i, &valarg);
		
		// XXX: forcing them to be objects, but they could also be NSString, NSDictionary or NSArray
		id real_obj = jsval_to_nsobject( valarg, cx);
		
		[array addObject:real_obj];
	}
	return array;
}
