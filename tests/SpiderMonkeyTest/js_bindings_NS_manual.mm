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


#import "jsapi.h"
#import "js_bindings_NS_manual.h"
#import "js_bindings_config.h"
#import "js_manual_conversions.h"
#import "js_bindings_config.h"


#pragma mark - JSPROXY_NSObject

enum {
	kJSPropertyNativeObject = 1,
};

#pragma mark - NSObject

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
	CCLOGINFO(@"spidermonkey: finalizing JS object %p (NSObject)", obj);

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
	NSCAssert( proxy && [proxy realObj], @"Object no initialzied. error");
	

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

JSBool JSPROXY_NSObject_retain(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);
	NSCAssert( proxy && [proxy realObj], @"Object not initialzied. error");
	
	id real = (NSObject*) [proxy realObj];
	[real retain];
	
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(obj) );
	return JS_TRUE;
}

JSBool JSPROXY_NSObject_release(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);
	NSCAssert( proxy && [proxy realObj], @"Object not initialzied. error");
	
	id real = (NSObject*) [proxy realObj];
	[real release];
	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
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
	JSPROXY_NSObject_class->flags = 0; //JSCLASS_HAS_PRIVATE;
	
	static JSPropertySpec properties[] = {
//		{"__nativeObject", kJSPropertyNativeObject, JSPROP_PERMANENT | JSPROP_ENUMERATE | JSPROP_SHARED, JSPROXY_NSObject_getProperty, JSPROXY_NSObject_setProperty},
		{0, 0, 0, 0, 0}
	};

	
	static JSFunctionSpec funcs[] = {
		JS_FN("init", JSPROXY_NSObject_init, 0, JSPROP_PERMANENT | JSPROP_SHARED | JSPROP_ENUMERATE),
		JS_FN("copy", JSPROXY_NSObject_copy, 0, JSPROP_PERMANENT | JSPROP_SHARED | JSPROP_ENUMERATE),
		JS_FN("retain", JSPROXY_NSObject_retain, 0, JSPROP_PERMANENT | JSPROP_SHARED | JSPROP_ENUMERATE),
		JS_FN("release", JSPROXY_NSObject_release, 0, JSPROP_PERMANENT | JSPROP_SHARED | JSPROP_ENUMERATE),
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


#ifdef __CC_PLATFORM_MAC

#pragma mark - NSEvent

JSClass* JSPROXY_NSEvent_class = NULL;
JSObject* JSPROXY_NSEvent_object = NULL;

// Constructor
JSBool JSPROXY_NSEvent_constructor(JSContext *cx, uint32_t argc, jsval *vp)
{
    JSObject *jsobj = JS_NewObject(cx, JSPROXY_NSEvent_class, JSPROXY_NSEvent_object, NULL);
	
    JSPROXY_NSEvent *proxy = [[JSPROXY_NSEvent alloc] initWithJSObject:jsobj class:[NSEvent class]];
	
	set_proxy_for_jsobject(proxy, jsobj);
    JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
    /* no callbacks */
    
    return JS_TRUE;
}

// Methods
JSBool JSPROXY_NSEvent_getLocation(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);
	NSCAssert( proxy && [proxy realObj], @"Object already initialzied. error");
	
	JSB_PRECONDITION( argc == 0, @"Invalid number of arguments" );
	
	NSEvent* event = (NSEvent*) [proxy realObj];
	
#ifdef JSB_USE_COCOS2D
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];
#else
	CGPoint location = [event locationInWindow];
#endif
	
	JS_SET_RVAL(cx, vp, CGPoint_to_jsval(cx, location ) );
	return JS_TRUE;
}

JSBool JSPROXY_NSEvent_getDelta(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);
	NSCAssert( proxy && [proxy realObj], @"Object already initialzied. error");
	
	JSB_PRECONDITION( argc == 0, @"Invalid number of arguments" );
	
	NSEvent* real = (NSEvent*) [proxy realObj];
	CGFloat x = [real deltaX];
	
#ifdef JSB_USE_COCOS2D
	// Negate Y: Needed for OpenGL coordinates
	CGFloat y = -[real deltaY];
#else
	CGFloat y = [real deltaY];
#endif
	
	JS_SET_RVAL(cx, vp, CGPoint_to_jsval(cx, CGPointMake(x,y) ) );
	return JS_TRUE;
}


// Destructor
void JSPROXY_NSEvent_finalize(JSContext *cx, JSObject *obj)
{
	CCLOGINFO(@"spidermonkey: finalizing JS object %p (NSEvent)", obj);
}

void JSPROXY_NSEvent_createClass(JSContext* cx, JSObject* globalObj, const char *name )
{
	JSPROXY_NSEvent_class = (JSClass *)calloc(1, sizeof(JSClass));
	JSPROXY_NSEvent_class->name = name;
	JSPROXY_NSEvent_class->addProperty = JS_PropertyStub;
	JSPROXY_NSEvent_class->delProperty = JS_PropertyStub;
	JSPROXY_NSEvent_class->getProperty = JS_PropertyStub;
	JSPROXY_NSEvent_class->setProperty = JS_StrictPropertyStub;
	JSPROXY_NSEvent_class->enumerate = JS_EnumerateStub;
	JSPROXY_NSEvent_class->resolve = JS_ResolveStub;
	JSPROXY_NSEvent_class->convert = JS_ConvertStub;
	JSPROXY_NSEvent_class->finalize = JSPROXY_NSEvent_finalize;
	JSPROXY_NSEvent_class->flags = 0; //JSCLASS_HAS_PRIVATE;
	
	static JSPropertySpec properties[] = {
//		{"__nativeObject", kJSPropertyNativeObject, JSPROP_PERMANENT | JSPROP_ENUMERATE | JSPROP_SHARED, JSPROXY_NSEvent_getProperty, JSPROXY_NSEvent_setProperty},
		{0, 0, 0, 0, 0}
	};
	
	
	static JSFunctionSpec funcs[] = {
		JS_FN("getLocation", JSPROXY_NSEvent_getLocation, 0, JSPROP_PERMANENT | JSPROP_SHARED | JSPROP_ENUMERATE),
		JS_FN("getDelta", JSPROXY_NSEvent_getDelta, 0, JSPROP_PERMANENT | JSPROP_SHARED | JSPROP_ENUMERATE),
		JS_FS_END
	};
	
	static JSFunctionSpec st_funcs[] = {
		JS_FS_END
	};
	
	JSPROXY_NSEvent_object = JS_InitClass(cx, globalObj, JSPROXY_NSObject_object, JSPROXY_NSEvent_class, JSPROXY_NSEvent_constructor,0,properties,funcs,NULL,st_funcs);
}

@implementation JSPROXY_NSEvent

+(JSObject*) createJSObjectWithRealObject:(id)realObj context:(JSContext*)cx
{
	JSObject *jsobj = JS_NewObject(cx, JSPROXY_NSEvent_class, JSPROXY_NSEvent_object, NULL);
    JSPROXY_NSEvent *proxy = [[JSPROXY_NSEvent alloc] initWithJSObject:jsobj class:[NSEvent class]];
	
	
	[proxy setRealObj:realObj];
	if( realObj ) {
		objc_setAssociatedObject(realObj, &JSPROXY_association_proxy_key, proxy, OBJC_ASSOCIATION_RETAIN);
		[proxy release];
	}
	
	[self swizzleMethods];
	
	return jsobj;
}
@end

#elif defined(__CC_PLATFORM_IOS)

#pragma mark - UITouch

JSClass* JSPROXY_UITouch_class = NULL;
JSObject* JSPROXY_UITouch_object = NULL;

// Constructor
JSBool JSPROXY_UITouch_constructor(JSContext *cx, uint32_t argc, jsval *vp)
{
    JSObject *jsobj = JS_NewObject(cx, JSPROXY_UITouch_class, JSPROXY_UITouch_object, NULL);
	
    JSPROXY_UITouch *proxy = [[JSPROXY_UITouch alloc] initWithJSObject:jsobj class:[UITouch class]];
	
	set_proxy_for_jsobject(proxy, jsobj);
    JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
    /* no callbacks */
    
    return JS_TRUE;
}

// Methods
JSBool JSPROXY_UITouch_location(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);
	NSCAssert( proxy && [proxy realObj], @"Object already initialzied. error");
	
	JSB_PRECONDITION( argc == 0, @"Invalid number of arguments" );
	
	UITouch* real = (UITouch*) [proxy realObj];
	
#ifdef JSB_USE_COCOS2D
	CGPoint location = [[CCDirector sharedDirector] convertTouchToGL:real];
#else
	CGPoint location = [real locationInView: [real view]];
#endif
	
	JS_SET_RVAL(cx, vp, CGPoint_to_jsval(cx, location) );
	return JS_TRUE;
}

JSBool JSPROXY_UITouch_delta(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);
	NSCAssert( proxy && [proxy realObj], @"Object already initialzied. error");
	
	JSB_PRECONDITION( argc == 0, @"Invalid number of arguments" );
	
	UITouch* real = (UITouch*) [proxy realObj];
	UIView *view = [real view];
	CGPoint now = [real locationInView: view];
	CGPoint prev = [real previousLocationInView: view];
	
#ifdef JSB_USE_COCOS2D
	// Negate Y: Needed for OpenGL coordinates
	CGPoint delta = CGPointMake(now.x-prev.x, prev.y-now.y);
#else
	CGPoint delta = CGPointMake(now.x-prev.x, now.y-prev.y);
#endif

	JS_SET_RVAL(cx, vp, CGPoint_to_jsval(cx, delta ) );
	return JS_TRUE;
}

// Destructor
void JSPROXY_UITouch_finalize(JSContext *cx, JSObject *obj)
{
	CCLOGINFO(@"spidermonkey: finalizing JS object %p (UITouch)", obj);
}

void JSPROXY_UITouch_createClass(JSContext* cx, JSObject* globalObj, const char *name )
{
	JSPROXY_UITouch_class = (JSClass *)calloc(1, sizeof(JSClass));
	JSPROXY_UITouch_class->name = name;
	JSPROXY_UITouch_class->addProperty = JS_PropertyStub;
	JSPROXY_UITouch_class->delProperty = JS_PropertyStub;
	JSPROXY_UITouch_class->getProperty = JS_PropertyStub;
	JSPROXY_UITouch_class->setProperty = JS_StrictPropertyStub;
	JSPROXY_UITouch_class->enumerate = JS_EnumerateStub;
	JSPROXY_UITouch_class->resolve = JS_ResolveStub;
	JSPROXY_UITouch_class->convert = JS_ConvertStub;
	JSPROXY_UITouch_class->finalize = JSPROXY_UITouch_finalize;
	JSPROXY_UITouch_class->flags = 0; //JSCLASS_HAS_PRIVATE;
	
	static JSPropertySpec properties[] = {
//		{"__nativeObject", kJSPropertyNativeObject, JSPROP_PERMANENT | JSPROP_ENUMERATE | JSPROP_SHARED, JSPROXY_UITouch_getProperty, JSPROXY_UITouch_setProperty},
		{0, 0, 0, 0, 0}
	};
	
	
	static JSFunctionSpec funcs[] = {
		JS_FN("getLocation", JSPROXY_UITouch_location, 0, JSPROP_PERMANENT | JSPROP_SHARED | JSPROP_ENUMERATE),
		JS_FN("getDelta", JSPROXY_UITouch_delta, 0, JSPROP_PERMANENT | JSPROP_SHARED | JSPROP_ENUMERATE),
		JS_FS_END
	};
	
	static JSFunctionSpec st_funcs[] = {
		JS_FS_END
	};
	
	JSPROXY_UITouch_object = JS_InitClass(cx, globalObj, JSPROXY_NSObject_object, JSPROXY_UITouch_class, JSPROXY_UITouch_constructor,0,properties,funcs,NULL,st_funcs);
}

@implementation JSPROXY_UITouch

+(JSObject*) createJSObjectWithRealObject:(id)realObj context:(JSContext*)cx
{
	JSObject *jsobj = JS_NewObject(cx, JSPROXY_UITouch_class, JSPROXY_UITouch_object, NULL);
    JSPROXY_UITouch *proxy = [[JSPROXY_UITouch alloc] initWithJSObject:jsobj class:[UITouch class]];
	
	
	[proxy setRealObj:realObj];
	if( realObj ) {
		objc_setAssociatedObject(realObj, &JSPROXY_association_proxy_key, proxy, OBJC_ASSOCIATION_RETAIN);
		[proxy release];
	}
	
	[self swizzleMethods];
	
	return jsobj;
}
@end

#pragma mark - JSAccelerometer
@interface JSAccelerometer : NSObject<UIAccelerometerDelegate> 
{
	JSContext	*_cx;
	JSObject	*_js_this;
	jsval		_js_function_value;
}

+(JSAccelerometer*) sharedInstance;
-(void) setTarget:(JSObject*)target functionValue:(jsval)function context:(JSContext*)context;
@end

@implementation JSAccelerometer

+(JSAccelerometer*) sharedInstance
{
	static dispatch_once_t pred;
	static JSAccelerometer *instance = nil;
	dispatch_once(&pred, ^{
		instance = [[self alloc] init];
	});
	return instance;
}

-(void) setTarget:(JSObject *)target functionValue:(jsval)function context:(JSContext*)cx
{
	_cx = cx;
	_js_this = target;
	_js_function_value = function;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	if( _js_this && _cx ) {
		NSTimeInterval time = acceleration.timestamp;
		UIAccelerationValue x = acceleration.x;
		UIAccelerationValue y = acceleration.y;
		UIAccelerationValue z = acceleration.z;
		
		jsval vals[4];
		vals[0] = DOUBLE_TO_JSVAL(x);
		vals[1] = DOUBLE_TO_JSVAL(y);
		vals[2] = DOUBLE_TO_JSVAL(z);
		vals[3] = DOUBLE_TO_JSVAL(time);
		
		jsval rval;
		JS_CallFunctionValue(_cx, _js_this, _js_function_value, 4, vals, &rval);
	}
}

@end

#pragma mark - UIAccelerometer

JSClass* JSPROXY_UIAccelerometer_class = NULL;
JSObject* JSPROXY_UIAccelerometer_object = NULL;

// Constructor
JSBool JSPROXY_UIAccelerometer_constructor(JSContext *cx, uint32_t argc, jsval *vp)
{
    JSObject *jsobj = [JSPROXY_UIAccelerometer createJSObjectWithRealObject:nil context:cx];
    JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
    return JS_TRUE;
}

// Destructor
void JSPROXY_UIAccelerometer_finalize(JSContext *cx, JSObject *obj)
{
	CCLOGINFO(@"spidermonkey: finalizing JS object %p (CCDirector)", obj);
}

// Arguments: 
// Ret value: UIAccelerometer (o)
JSBool JSPROXY_UIAccelerometer_sharedAccelerometer_static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc == 0, @"Invalid number of arguments" );
	UIAccelerometer* ret_val;
	
	ret_val = [UIAccelerometer sharedAccelerometer];
	
	JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
	return JS_TRUE;
}

// Methods
JSBool JSPROXY_UIAccelerometer_getUpdateInterval(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);
	NSCAssert( proxy && [proxy realObj], @"Object already initialzied. error");
	
	JSB_PRECONDITION( argc == 0, @"Invalid number of arguments" );
	
	UIAccelerometer* real = (UIAccelerometer*) [proxy realObj];
	
	CGFloat interval = [real updateInterval];
	
	JS_SET_RVAL(cx, vp, DOUBLE_TO_JSVAL(interval) );
	return JS_TRUE;
}

JSBool JSPROXY_UIAccelerometer_setUpdateInterval(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);
	NSCAssert( proxy && [proxy realObj], @"Object already initialzied. error");
	
	JSB_PRECONDITION( argc == 1, @"Invalid number of arguments" );
	
	jsval *argvp = JS_ARGV(cx,vp);
	double interval;
	if( ! JS_ValueToNumber(cx, *argvp++, &interval) )
		return JS_FALSE;
	
	UIAccelerometer* real = (UIAccelerometer*) [proxy realObj];
	[real setUpdateInterval:interval];
	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}


JSBool JSPROXY_UIAccelerometer_setDelegate(JSContext *cx, uint32_t argc, jsval *vp) {
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);
	NSCAssert( proxy && [proxy realObj], @"Object already initialzied. error");
	
	JSB_PRECONDITION( argc == 2, @"Invalid number of arguments" );

	UIAccelerometer* real = (UIAccelerometer*) [proxy realObj];

	jsval *argvp = JS_ARGV(cx,vp);
	JSObject *js_this;
	jsval js_function;

	js_this= JSVAL_TO_OBJECT( *argvp++ );

	if( ! js_this  ) {
		[real setDelegate:nil];
		return JS_TRUE;
	}

	if( ! JS_ValueToFunction(cx, *argvp ) )
		return JS_FALSE;

	js_function = *argvp++;
	
	JSAccelerometer *jsaccel = [JSAccelerometer sharedInstance];
	[real setDelegate: jsaccel];
	[jsaccel setTarget:js_this functionValue:js_function context:cx];
	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;	
}

// Destructor

void JSPROXY_UIAccelerometer_createClass(JSContext* cx, JSObject* globalObj, const char *name )
{
	JSPROXY_UIAccelerometer_class = (JSClass *)calloc(1, sizeof(JSClass));
	JSPROXY_UIAccelerometer_class->name = name;
	JSPROXY_UIAccelerometer_class->addProperty = JS_PropertyStub;
	JSPROXY_UIAccelerometer_class->delProperty = JS_PropertyStub;
	JSPROXY_UIAccelerometer_class->getProperty = JS_PropertyStub;
	JSPROXY_UIAccelerometer_class->setProperty = JS_StrictPropertyStub;
	JSPROXY_UIAccelerometer_class->enumerate = JS_EnumerateStub;
	JSPROXY_UIAccelerometer_class->resolve = JS_ResolveStub;
	JSPROXY_UIAccelerometer_class->convert = JS_ConvertStub;
	JSPROXY_UIAccelerometer_class->finalize = JSPROXY_UIAccelerometer_finalize;
	JSPROXY_UIAccelerometer_class->flags = 0; //JSCLASS_HAS_PRIVATE;
	
	static JSPropertySpec properties[] = {
		{0, 0, 0, 0, 0}
	};
	
	
	static JSFunctionSpec funcs[] = {
		JS_FN("setCallback", JSPROXY_UIAccelerometer_setDelegate, 2, JSPROP_PERMANENT | JSPROP_SHARED | JSPROP_ENUMERATE),
		JS_FN("setUpdateInterval", JSPROXY_UIAccelerometer_setUpdateInterval, 1, JSPROP_PERMANENT | JSPROP_SHARED | JSPROP_ENUMERATE),
		JS_FN("getUpdateInterval", JSPROXY_UIAccelerometer_getUpdateInterval, 0, JSPROP_PERMANENT | JSPROP_SHARED | JSPROP_ENUMERATE),
		JS_FS_END
	};
	
	static JSFunctionSpec st_funcs[] = {
		JS_FN("getInstance", JSPROXY_UIAccelerometer_sharedAccelerometer_static, 0, JSPROP_PERMANENT | JSPROP_SHARED | JSPROP_ENUMERATE),
		JS_FS_END
	};
	
	JSPROXY_UIAccelerometer_object = JS_InitClass(cx, globalObj, JSPROXY_NSObject_object, JSPROXY_UIAccelerometer_class, JSPROXY_UIAccelerometer_constructor,0,properties,funcs,NULL,st_funcs);
}

@implementation JSPROXY_UIAccelerometer

+(JSObject*) createJSObjectWithRealObject:(id)realObj context:(JSContext*)cx
{
	JSObject *jsobj = JS_NewObject(cx, JSPROXY_UIAccelerometer_class, JSPROXY_UIAccelerometer_object, NULL);
    JSPROXY_UIAccelerometer *proxy = [[JSPROXY_UIAccelerometer alloc] initWithJSObject:jsobj class:[UIAccelerometer class]];
	
	
	[proxy setRealObj:realObj];
	if( realObj ) {
		objc_setAssociatedObject(realObj, &JSPROXY_association_proxy_key, proxy, OBJC_ASSOCIATION_RETAIN);
		[proxy release];
	}
	
	[self swizzleMethods];
	
	return jsobj;
}
@end

#endif // __CC_PLATFORM_IOS
