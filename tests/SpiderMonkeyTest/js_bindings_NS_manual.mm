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


#import "js_bindings_NS_manual.h"

#pragma mark - JSPROXY_NSObject

enum {
	kJSPropertyNativeObject = 1,
};

JSClass* JSPROXY_NSObject_class = NULL;
JSObject* JSPROXY_NSObject_object = NULL;

// Constructor
JSBool JSPROXY_NSObject_constructor(JSContext *cx, uint32_t argc, jsval *vp)
{
    JSObject *jsobj = JS_NewObject(cx, JSPROXY_NSObject_class, JSPROXY_NSObject_object, NULL);
	
    JSPROXY_NSObject *proxy = [[JSPROXY_NSObject alloc] initWithJSObject:jsobj class:[NSObject class]];
	
	set_proxy_for_jsobject(proxy, jsobj);
//    JS_SetPrivate(jsobj, proxy);
    JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
    /* no callbacks */
    
    return JS_TRUE;
}

// Destructor
void JSPROXY_NSObject_finalize(JSContext *cx, JSObject *obj)
{
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);
	
	if (proxy) {
		del_proxy_for_jsobject( obj );
		
		[proxy release];		
	}
}

// Methods
JSBool JSPROXY_NSObject_init(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);
	NSCAssert( proxy && ![proxy realObj], @"Object already initialzied. error" );
	
	
	NSObject* real = [[NSObject alloc] init];
	[proxy setRealObj:real];
	objc_setAssociatedObject(real, &JSPROXY_association_proxy_key, proxy, OBJC_ASSOCIATION_RETAIN);
	[proxy release];
	[real autorelease];
	
	NSCAssert( real, @"Invalid JS object");
	
	NSCAssert1( argc == 0, @"Invalid number of arguments: %d", argc );
		
	JS_SET_RVAL(cx, vp, JSVAL_TRUE);
	
	return JS_TRUE;
}

// Methods
JSBool JSPROXY_NSObject_copy(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);
	NSCAssert( proxy && [proxy realObj], @"Object already initialzied. error");
	

	JSObject *obj_copy;

	id real = (NSObject*) [proxy realObj];
	if( [real conformsToProtocol:@protocol(NSCopying) ] ) {
		id native_copy = [[real copy] autorelease];
		
		obj_copy = create_jsobject_from_realobj(cx, [native_copy class], native_copy);

	} else {
		JS_SET_RVAL(cx, vp, JSVAL_VOID);
		return JS_FALSE;
	}

	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(obj_copy) );
	return JS_TRUE;
}


void JSPROXY_NSObject_createClass(JSContext* cx, JSObject* globalObj, const char *name )
{
	JSPROXY_NSObject_class = (JSClass *)calloc(1, sizeof(JSClass));
	JSPROXY_NSObject_class->name = name;
	JSPROXY_NSObject_class->addProperty = JS_PropertyStub;
	JSPROXY_NSObject_class->delProperty = JS_PropertyStub;
	JSPROXY_NSObject_class->getProperty = JS_PropertyStub;
	JSPROXY_NSObject_class->setProperty = JS_StrictPropertyStub;
	JSPROXY_NSObject_class->enumerate = JS_EnumerateStub;
	JSPROXY_NSObject_class->resolve = JS_ResolveStub;
	JSPROXY_NSObject_class->convert = JS_ConvertStub;
	JSPROXY_NSObject_class->finalize = JSPROXY_NSObject_finalize;
	JSPROXY_NSObject_class->flags = JSCLASS_HAS_PRIVATE;
	
	static JSPropertySpec properties[] = {
//		{"__nativeObject", kJSPropertyNativeObject, JSPROP_PERMANENT | JSPROP_ENUMERATE | JSPROP_SHARED, JSPROXY_NSObject_getProperty, JSPROXY_NSObject_setProperty},
		{0, 0, 0, 0, 0}
	};

	
	static JSFunctionSpec funcs[] = {
		JS_FN("init", JSPROXY_NSObject_init, 0, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FN("copy", JSPROXY_NSObject_copy, 0, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FS_END
	};
	
	static JSFunctionSpec st_funcs[] = {
		JS_FS_END
	};
	
	JSPROXY_NSObject_object = JS_InitClass(cx, globalObj, NULL, JSPROXY_NSObject_class, JSPROXY_NSObject_constructor,0,properties,funcs,NULL,st_funcs);
}

@implementation JSPROXY_NSObject

@synthesize jsObj = _jsObj;
@synthesize realObj = _realObj;
@synthesize klass = _klass;

+(JSObject*) createJSObjectWithRealObject:(id)realObj context:(JSContext*)cx
{
	JSObject *jsobj = JS_NewObject(cx, JSPROXY_NSObject_class, JSPROXY_NSObject_object, NULL);
    JSPROXY_NSObject *proxy = [[JSPROXY_NSObject alloc] initWithJSObject:jsobj class:[NSObject class]];

	
	[proxy setRealObj:realObj];
	if( realObj ) {
		objc_setAssociatedObject(realObj, &JSPROXY_association_proxy_key, proxy, OBJC_ASSOCIATION_RETAIN);
		[proxy release];
	}
	
	[self swizzleMethods];

	return jsobj;
}

+(void) swizzleMethods
{
	// override
}

-(id) initWithJSObject:(JSObject*)object class:(Class)klass
{
	self = [super init];
	if( self )
	{
		_jsObj = object;
		_klass = klass;
		
//		JS_SetPrivate(jsobj, self);
		set_proxy_for_jsobject(self, _jsObj);

		JS_AddNamedObjectRoot( [[ScriptingCore sharedInstance] globalContext], &_jsObj, [[self description] UTF8String] );
	}
	
	return self;
}

-(void) dealloc
{
	// If the compiler gives you an error, you can safely remove the following line
	CCLOGINFO(@"spidermonkey: deallocing %@", self);

	del_proxy_for_jsobject(_jsObj);

	JS_RemoveObjectRoot( [[ScriptingCore sharedInstance] globalContext], &_jsObj);

	
	[super dealloc];
}

@end
