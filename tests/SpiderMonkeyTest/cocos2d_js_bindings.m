#import "cocos2d_js_bindings.h"

@implementation JS_NSObject

+(void) createClassWithContext:(JSContext*)cx object:(JSObject*)globalObj name:(NSString*)name
{
}

-(id) initWithObject:(JSObject*)object
{
	self = [super init];
	if( self )
	{
		_jsobj = object;
	}
	
	return self;
}

@end

@implementation JS_CCNode

JSClass* CCNode_jsClass = NULL;
JSObject* CCNode_jsObject = NULL;

void CCNode_jsFinalize(JSContext *cx, JSObject *obj)
{
	JS_CCNode *pt = (JS_CCNode*)JS_GetPrivate(obj);
	if (pt) {
		[pt release];
		JS_free(cx, pt);
	}
}

JSBool CCNode_jsConstructor(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject *obj = JS_NewObject(cx, CCNode_jsClass, CCNode_jsObject, NULL);
	JS_CCNode *native = [[JS_CCNode alloc] initWithObject:obj];

	JS_SetPrivate(obj, native);
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(obj));
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
	
//	static JSFunctionSpec funcs[] = {
//		JS_FN("initWithAnimation", S_CCAnimate::jsinitWithAnimation, 1, JSPROP_PERMANENT | JSPROP_SHARED),
//		JS_FN("initWithDuration", S_CCAnimate::jsinitWithDuration, 3, JSPROP_PERMANENT | JSPROP_SHARED),
//		JS_FN("startWithTarget", S_CCAnimate::jsstartWithTarget, 1, JSPROP_PERMANENT | JSPROP_SHARED),
//		JS_FN("stop", S_CCAnimate::jsstop, 0, JSPROP_PERMANENT | JSPROP_SHARED),
//		JS_FN("reverse", S_CCAnimate::jsreverse, 0, JSPROP_PERMANENT | JSPROP_SHARED),
//		JS_FS_END
//	};
	
//	static JSFunctionSpec st_funcs[] = {
//		JS_FN("actionWithAnimation", S_CCAnimate::jsactionWithAnimation, 1, JSPROP_PERMANENT | JSPROP_SHARED),
//		JS_FN("actionWithDuration", S_CCAnimate::jsactionWithDuration, 3, JSPROP_PERMANENT | JSPROP_SHARED),
//		JS_FS_END
//	};
	
	CCNode_jsObject = JS_InitClass(cx, globalObj, NULL, CCNode_jsClass, CCNode_jsConstructor,0,NULL,NULL,NULL,NULL);
}

@end

