
#import "jstypedarray.h"

#import "js_bindings_old_manual.h"
#import <objc/runtime.h>
#import "JRSwizzle.h"
#import "ScriptingCore.h"


#pragma mark - CCNode Swizzle

@implementation CCNode (SpiderMonkey)

static char *CCNode_JS_proxy_key;
-(void) onEnter_JS
{
	ProxyJS_CCNode *proxy = objc_getAssociatedObject(self, &CCNode_JS_proxy_key);
	if( proxy )
		[proxy onEnter];
	
	[self onEnter_JS];
}

-(void) onExit_JS
{
	ProxyJS_CCNode *proxy = objc_getAssociatedObject(self, &CCNode_JS_proxy_key);
	if( proxy )
		[proxy onExit];
	
	[self onExit_JS];
}
@end

#pragma mark - ProxyJS_CCNode

@implementation ProxyJS_CCNode

JSClass* CCNode_jsClass = NULL;
JSObject* CCNode_jsObject = NULL;

// Constructor
JSBool CCNode_jsConstructor(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject *jsobj = JS_NewObject(cx, CCNode_jsClass, CCNode_jsObject, NULL);
	CCNode *realObj = [CCNode alloc];
	
	NSError *error;
	if( ! [CCNode jr_swizzleMethod:@selector(onEnter) withMethod:@selector(onEnter_JS) error:&error] ) 
		NSLog(@"Error swizzling %@", error);
	if( ! [CCNode jr_swizzleMethod:@selector(onExit) withMethod:@selector(onExit_JS) error:&error] )
		NSLog(@"Error swizzling %@", error);

	ProxyJS_CCNode *proxy = [[ProxyJS_CCNode alloc] initWithJSObject:jsobj class:[CCNode class]];

	// Weak reference
	objc_setAssociatedObject(realObj, &CCNode_JS_proxy_key, proxy, OBJC_ASSOCIATION_ASSIGN);
	
	JS_SetPrivate(jsobj, proxy);
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	return JS_TRUE;
}

// Destructor
void CCNode_jsFinalize(JSContext *cx, JSObject *obj)
{
	ProxyJS_CCNode *pt = (ProxyJS_CCNode*)JS_GetPrivate(obj);
	if (pt) {
		id real = [pt realObj];
		
		objc_setAssociatedObject(real, &CCNode_JS_proxy_key, nil, OBJC_ASSOCIATION_ASSIGN);

		[real release];
	
		[pt release];

		JS_free(cx, pt);
	}
}

// Methods
JSBool CCNode_init(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	ProxyJS_CCNode* proxy = (ProxyJS_CCNode*) JS_GetPrivate( obj );
	NSCAssert( proxy, @"Invalid Proxy object");
	NSCAssert( ! [proxy realObj], @"Object already initialzied. error");

	CCNode* real = (CCNode*)[proxy realObj];
	NSCAssert( real, @"Invalid JS object");

	NSCAssert1( argc == 0, @"Invalid number of arguments: %d", argc );

	[real init];

	JS_SET_RVAL(cx, vp, JSVAL_TRUE);

	return JS_TRUE;
}

JSBool CCNode_addChild(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	ProxyJS_CCNode* proxy = (ProxyJS_CCNode*) JS_GetPrivate( obj );
	NSCAssert( proxy, @"Invalid Proxy object");
	NSCAssert( [proxy realObj], @"Object not initialzied. error");

	CCNode* real = (CCNode*)[proxy realObj];
	NSCAssert( real, @"Invalid JS object");

	if (argc >= 1) {
		JSObject *arg0;
		int zorder = 0;
		int tag = 0;
		JS_ConvertArguments(cx, 1, JS_ARGV(cx, vp), "o/ii", &arg0, &zorder, &tag);
		
		ProxyJS_CCNode *arg0_proxy = (ProxyJS_CCNode*) JS_GetPrivate( arg0 );
		CCNode *arg0_real = (CCNode*) [arg0_proxy realObj];
		
		// if no zorder / tag, then just get the values from the node
		
		NSCAssert1( argc <= 3, @"Invalid number of arguments: %d", argc );
	
		if (argc <= 1)
			[real addChild:arg0_real];

		else if (argc <= 2)
			[real addChild:arg0_real z:zorder];
		else 
			[real addChild:arg0_real z:zorder tag:tag];

		
		JS_SET_RVAL(cx, vp, JSVAL_TRUE);
		return JS_TRUE;
	}
	JS_SET_RVAL(cx, vp, JSVAL_TRUE);
	return JS_TRUE;
}


JSBool CCNode_setPosition(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	ProxyJS_CCNode* proxy = (ProxyJS_CCNode*) JS_GetPrivate( obj );
	NSCAssert( proxy, @"Invalid Proxy object");
	NSCAssert( [proxy realObj], @"Object not initialzied. error");
	
	CCNode* real = (CCNode*)[proxy realObj];
	NSCAssert( real, @"Invalid JS object");

	NSCAssert1( argc == 1, @"Invalid number of arguments: %d", argc );

	JSObject *arg0;
	if (JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "o", &arg0) == JS_TRUE) {
		
		NSCAssert( JS_GetTypedArrayByteLength( arg0 ) == 8, @"Invalid length");
		float *buffer = (float*)JS_GetTypedArrayData(arg0);
		
		[real setPosition:ccp(buffer[0], buffer[1])];
		
	}
	return JS_TRUE;
}

JSBool CCNode_getPosition(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	ProxyJS_CCNode* proxy = (ProxyJS_CCNode*) JS_GetPrivate( obj );
	NSCAssert( proxy, @"Invalid Proxy object");
	NSCAssert( [proxy realObj], @"Object not initialzied. error");
	
	CCNode* real = (CCNode*)[proxy realObj];
	NSCAssert( real, @"Invalid JS object");
	
	NSCAssert1( argc == 0, @"Invalid number of arguments: %d", argc );
	
	JSObject *typedArray = js_CreateTypedArray(cx, js::TypedArray::TYPE_FLOAT32, 2 );
	float *buffer = (float*)JS_GetTypedArrayData(typedArray);
	CGPoint p = [real position];
	buffer[0] = p.x;
	buffer[1] = p.y;
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(typedArray));

//	jsval width;
//	JS_NewNumberValue(cx, buffer[0], &width );
//	JS_SetProperty(cx, typedArray, "width", &width );

	return JS_TRUE;
}


+(void) createClassWithContext:(JSContext*)cx object:(JSObject*)globalObj name:(NSString*)name
{
	CCNode_jsClass = (JSClass *)calloc(1, sizeof(JSClass));
	CCNode_jsClass->name = [name UTF8String];
	CCNode_jsClass->addProperty = JS_PropertyStub;
	CCNode_jsClass->delProperty = JS_PropertyStub;
	CCNode_jsClass->getProperty = JS_PropertyStub;
	CCNode_jsClass->setProperty = JS_StrictPropertyStub;
	CCNode_jsClass->enumerate = JS_EnumerateStub;
	CCNode_jsClass->resolve = JS_ResolveStub;
	CCNode_jsClass->convert = JS_ConvertStub;
	CCNode_jsClass->finalize = CCNode_jsFinalize;
	CCNode_jsClass->flags = JSCLASS_HAS_PRIVATE;
//	static JSPropertySpec properties[] = {
//		{"animation", kAnimation, JSPROP_PERMANENT | JSPROP_SHARED, S_CCAnimate::jsPropertyGet, S_CCAnimate::jsPropertySet},
//		{"origFrame", kOrigFrame, JSPROP_PERMANENT | JSPROP_SHARED, S_CCAnimate::jsPropertyGet, S_CCAnimate::jsPropertySet},
//		{"restoreOriginalFrame", kRestoreOriginalFrame, JSPROP_PERMANENT | JSPROP_SHARED, S_CCAnimate::jsPropertyGet, S_CCAnimate::jsPropertySet},
//		{0, 0, 0, 0, 0}
//	};
	
	static JSFunctionSpec funcs[] = {
		JS_FN("addChild", CCNode_addChild, 1, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FN("init", CCNode_init, 1, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FN("setPosition", CCNode_setPosition, 1, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FN("getPosition", CCNode_getPosition, 0, JSPROP_PERMANENT | JSPROP_SHARED),

//		JS_FN("initWithDuration", S_CCAnimate::jsinitWithDuration, 3, JSPROP_PERMANENT | JSPROP_SHARED),
//		JS_FN("startWithTarget", S_CCAnimate::jsstartWithTarget, 1, JSPROP_PERMANENT | JSPROP_SHARED),
//		JS_FN("stop", S_CCAnimate::jsstop, 0, JSPROP_PERMANENT | JSPROP_SHARED),
//		JS_FN("reverse", S_CCAnimate::jsreverse, 0, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FS_END
	};
	
//	static JSFunctionSpec st_funcs[] = {
//		JS_FN("actionWithAnimation", S_CCAnimate::jsactionWithAnimation, 1, JSPROP_PERMANENT | JSPROP_SHARED),
//		JS_FN("actionWithDuration", S_CCAnimate::jsactionWithDuration, 3, JSPROP_PERMANENT | JSPROP_SHARED),
//		JS_FS_END
//	};
	
	CCNode_jsObject = JS_InitClass(cx, globalObj, NULL, CCNode_jsClass, CCNode_jsConstructor,0,NULL,funcs,NULL,NULL);
}

-(void) onEnter
{
	if (_jsObj) {
		JSContext* cx = [[ScriptingCore sharedInstance] globalContext];
		JSBool found;
		JS_HasProperty(cx, _jsObj, "onEnter", &found);
		if (found == JS_TRUE) {
			jsval rval, fval;
			JS_GetProperty(cx, _jsObj, "onEnter", &fval);
			JS_CallFunctionValue(cx, _jsObj, fval, 0, 0, &rval);
		}
	}	
}

-(void) onExit
{
	if (_jsObj) {
		JSContext* cx = [[ScriptingCore sharedInstance] globalContext];
		JSBool found;
		JS_HasProperty(cx, _jsObj, "onExit", &found);
		if (found == JS_TRUE) {
			jsval rval, fval;
			JS_GetProperty(cx, _jsObj, "onExit", &fval);
			JS_CallFunctionValue(cx, _jsObj, fval, 0, 0, &rval);
		}
	}		
}
@end


#pragma mark - Subclass

JSClass* JSExt_CCNode_class = NULL;
JSObject* JSExt_CCNode_object = NULL;

// Constructor
JSBool JSExt_CCNode_constructor(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject *jsobj = JS_NewObject(cx, JSExt_CCNode_class, JSExt_CCNode_object, NULL);	
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	return JS_TRUE;
}

// Destructor
void JSExt_CCNode_finalize(JSContext *cx, JSObject *obj)
{
	JSExt_CCNode *real = (JSExt_CCNode*)JS_GetPrivate(obj);
	if( real )
		[real release];
}

// Methods
JSBool JSExt_CCNode_init(JSContext *cx, uint32_t argc, jsval *vp)
{	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSExt_CCNode* real = (JSExt_CCNode*) JS_GetPrivate( obj );
	NSCAssert( !real, @"Invalid Proxy object");	
	
	NSCAssert1( argc == 0, @"Invalid number of arguments: %d", argc );
	
	real = [[JSExt_CCNode alloc] init];
	[real setJsObject:obj];
	JS_SetPrivate(obj, real);
	
	JS_SET_RVAL(cx, vp, JSVAL_TRUE);
	
	return JS_TRUE;
}

JSBool JSExt_CCNode_addChild(JSContext *cx, uint32_t argc, jsval *vp)
{	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSExt_CCNode* real = (JSExt_CCNode*) JS_GetPrivate( obj );
	NSCAssert( real, @"Invalid Proxy object");
	
	if (argc >= 1) {
		JSObject *arg0;
		int zorder = 0;
		int tag = 0;
		JS_ConvertArguments(cx, 1, JS_ARGV(cx, vp), "o/ii", &arg0, &zorder, &tag);
		
		JSExt_CCNode *arg0_real = (JSExt_CCNode*) JS_GetPrivate( arg0 );
		
		// if no zorder / tag, then just get the values from the node
		
		NSCAssert1( argc <= 3, @"Invalid number of arguments: %d", argc );
		
		if (argc <= 1)
			[real addChild:arg0_real];
		
		else if (argc <= 2)
			[real addChild:arg0_real z:zorder];
		else 
			[real addChild:arg0_real z:zorder tag:tag];
		
		
		JS_SET_RVAL(cx, vp, JSVAL_TRUE);
		return JS_TRUE;
	}
	JS_SET_RVAL(cx, vp, JSVAL_TRUE);
	return JS_TRUE;
}


JSBool JSExt_CCNode_setPosition(JSContext *cx, uint32_t argc, jsval *vp)
{	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	ProxyJS_CCNode* proxy = (ProxyJS_CCNode*) JS_GetPrivate( obj );
	NSCAssert( proxy, @"Invalid Proxy object");
	NSCAssert( [proxy realObj], @"Object not initialzied. error");
	
	CCNode* real = (CCNode*)[proxy realObj];
	NSCAssert( real, @"Invalid JS object");
	
	NSCAssert1( argc == 1, @"Invalid number of arguments: %d", argc );
	
	JSObject *arg0;
	if (JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "o", &arg0) == JS_TRUE) {
		
		NSCAssert( JS_GetTypedArrayByteLength( arg0 ) == 8, @"Invalid length");
		float *buffer = (float*)JS_GetTypedArrayData(arg0);
		
		[real setPosition:ccp(buffer[0], buffer[1])];
		
	}
	return JS_TRUE;
}

JSBool JSExt_CCNode_getPosition(JSContext *cx, uint32_t argc, jsval *vp)
{	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	ProxyJS_CCNode* proxy = (ProxyJS_CCNode*) JS_GetPrivate( obj );
	NSCAssert( proxy, @"Invalid Proxy object");
	NSCAssert( [proxy realObj], @"Object not initialzied. error");
	
	CCNode* real = (CCNode*)[proxy realObj];
	NSCAssert( real, @"Invalid JS object");
	
	NSCAssert1( argc == 0, @"Invalid number of arguments: %d", argc );
	
	JSObject *typedArray = js_CreateTypedArray(cx, js::TypedArray::TYPE_FLOAT32, 2 );
	float *buffer = (float*)JS_GetTypedArrayData(typedArray);
	CGPoint p = [real position];
	buffer[0] = p.x;
	buffer[1] = p.y;
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(typedArray));
	
	//	jsval width;
	//	JS_NewNumberValue(cx, buffer[0], &width );
	//	JS_SetProperty(cx, typedArray, "width", &width );
	
	return JS_TRUE;
}

@implementation JSExt_CCNode

@synthesize jsObject = jsObject_;

+(void) js_createClassWithContext:(JSContext*)cx object:(JSObject*)globalObj name:(NSString*)name
{
	JSExt_CCNode_class = (JSClass *)calloc(1, sizeof(JSClass));
	JSExt_CCNode_class->name = [name UTF8String];
	JSExt_CCNode_class->addProperty = JS_PropertyStub;
	JSExt_CCNode_class->delProperty = JS_PropertyStub;
	JSExt_CCNode_class->getProperty = JS_PropertyStub;
	JSExt_CCNode_class->setProperty = JS_StrictPropertyStub;
	JSExt_CCNode_class->enumerate = JS_EnumerateStub;
	JSExt_CCNode_class->resolve = JS_ResolveStub;
	JSExt_CCNode_class->convert = JS_ConvertStub;
	JSExt_CCNode_class->finalize = JSExt_CCNode_finalize;
	JSExt_CCNode_class->flags = JSCLASS_HAS_PRIVATE;
	//	static JSPropertySpec properties[] = {
	//		{"animation", kAnimation, JSPROP_PERMANENT | JSPROP_SHARED, S_CCAnimate::jsPropertyGet, S_CCAnimate::jsPropertySet},
	//		{"origFrame", kOrigFrame, JSPROP_PERMANENT | JSPROP_SHARED, S_CCAnimate::jsPropertyGet, S_CCAnimate::jsPropertySet},
	//		{"restoreOriginalFrame", kRestoreOriginalFrame, JSPROP_PERMANENT | JSPROP_SHARED, S_CCAnimate::jsPropertyGet, S_CCAnimate::jsPropertySet},
	//		{0, 0, 0, 0, 0}
	//	};
	
	static JSFunctionSpec funcs[] = {
		JS_FN("addChild", JSExt_CCNode_addChild, 1, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FN("init", JSExt_CCNode_init, 1, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FN("setPosition", JSExt_CCNode_setPosition, 1, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FN("getPosition", JSExt_CCNode_getPosition, 0, JSPROP_PERMANENT | JSPROP_SHARED),
		
		//		JS_FN("initWithDuration", S_CCAnimate::jsinitWithDuration, 3, JSPROP_PERMANENT | JSPROP_SHARED),
		//		JS_FN("startWithTarget", S_CCAnimate::jsstartWithTarget, 1, JSPROP_PERMANENT | JSPROP_SHARED),
		//		JS_FN("stop", S_CCAnimate::jsstop, 0, JSPROP_PERMANENT | JSPROP_SHARED),
		//		JS_FN("reverse", S_CCAnimate::jsreverse, 0, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FS_END
	};
	
	//	static JSFunctionSpec st_funcs[] = {
	//		JS_FN("actionWithAnimation", S_CCAnimate::jsactionWithAnimation, 1, JSPROP_PERMANENT | JSPROP_SHARED),
	//		JS_FN("actionWithDuration", S_CCAnimate::jsactionWithDuration, 3, JSPROP_PERMANENT | JSPROP_SHARED),
	//		JS_FS_END
	//	};
	
	JSExt_CCNode_object = JS_InitClass(cx, globalObj, NULL, JSExt_CCNode_class, JSExt_CCNode_constructor,0,NULL,funcs,NULL,NULL);
}

-(void) onEnter
{
	if (jsObject_) {
		JSContext* cx = [[ScriptingCore sharedInstance] globalContext];
		JSBool found;
		JS_HasProperty(cx, jsObject_, "onEnter", &found);
		if (found == JS_TRUE) {
			jsval rval, fval;
			JS_GetProperty(cx, jsObject_, "onEnter", &fval);
			JS_CallFunctionValue(cx, jsObject_, fval, 0, 0, &rval);
		}
	}	

	[super onEnter];
}

-(void) onExit
{
	if (jsObject_) {
		JSContext* cx = [[ScriptingCore sharedInstance] globalContext];
		JSBool found;
		JS_HasProperty(cx, jsObject_, "onExit", &found);
		if (found == JS_TRUE) {
			jsval rval, fval;
			JS_GetProperty(cx, jsObject_, "onExit", &fval);
			JS_CallFunctionValue(cx, jsObject_, fval, 0, 0, &rval);
		}
	}
	
	[super onExit];
}

@end


