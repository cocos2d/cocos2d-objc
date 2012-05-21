
#import "cocos2d_js_bindings.h"
#import <objc/runtime.h>
#import "JRSwizzle.h"


#pragma mark - JS_NSObject

@implementation JS_NSObject

@synthesize jsObj = _jsObj;
@synthesize realObj = _realObj;
@synthesize initialized = _initialized;

+(void) createClassWithContext:(JSContext*)cx object:(JSObject*)globalObj name:(NSString*)name
{
}

-(id) initWithJSObject:(JSObject*)object andRealObject:(id)realObject
{
	self = [super init];
	if( self )
	{
		_jsObj = object;
		_realObj = [realObject retain];
		_initialized = NO;
	}
	
	return self;
}

-(void) dealloc
{
	CCLOGINFO(@"deallocing: %@", self);
	
	[_realObj release];
	
	[super dealloc];
}

@end


#pragma mark - CCNode Swizzle

@implementation CCNode (SpiderMonkey)

static char CCNode_JS_proxy_key;
-(void) onEnter_JS
{
	JS_CCNode *proxy = objc_getAssociatedObject(self, &CCNode_JS_proxy_key);
	if( proxy )
		[proxy onEnter];
	
	[self onEnter_JS];
}

-(void) onExit_JS
{
	JS_CCNode *proxy = objc_getAssociatedObject(self, &CCNode_JS_proxy_key);
	if( proxy )
		[proxy onExit];
	
	[self onExit_JS];
}
@end

#pragma mark - JS_CCNode

@implementation JS_CCNode

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

	JS_CCNode *proxy = [[JS_CCNode alloc] initWithJSObject:jsobj andRealObject:realObj];

	[realObj release];

	// Weak reference
	objc_setAssociatedObject(realObj, &CCNode_JS_proxy_key, proxy, OBJC_ASSOCIATION_ASSIGN);
	
	JS_SetPrivate(jsobj, proxy);
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	return JS_TRUE;
}

// Destructor
void CCNode_jsFinalize(JSContext *cx, JSObject *obj)
{
	JS_CCNode *pt = (JS_CCNode*)JS_GetPrivate(obj);
	if (pt) {
		id real = [pt realObj];
		
		objc_setAssociatedObject(real, &CCNode_JS_proxy_key, nil, OBJC_ASSOCIATION_ASSIGN);

		[real release];
	
		[pt release];

		JS_free(cx, pt);
	}
}

// Methods
JSBool CCNode_jsinit(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JS_CCNode* proxy = JS_GetPrivate( obj );
	NSCAssert( proxy, @"Invalid Proxy object");
	NSCAssert( ! [proxy isInitialized], @"Object already initialzied. error");

	proxy.initialized = YES;
	
	CCNode* real = (CCNode*)[proxy realObj];
	NSCAssert( real, @"Invalid JS object");

	NSCAssert1( argc == 0, @"Invalid number of arguments: %d", argc );

	[real init];

	JS_SET_RVAL(cx, vp, JSVAL_TRUE);

	return JS_TRUE;
}

JSBool CCNode_jsaddChild(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JS_CCNode* proxy = JS_GetPrivate( obj );
	NSCAssert( proxy, @"Invalid Proxy object");
	NSCAssert( [proxy isInitialized], @"Object not initialzied. error");

	CCNode* real = (CCNode*)[proxy realObj];
	NSCAssert( real, @"Invalid JS object");

	if (argc >= 1) {
		JSObject *arg0;
		int zorder = 0;
		int tag = 0;
		JS_ConvertArguments(cx, 1, JS_ARGV(cx, vp), "o/ii", &arg0, &zorder, &tag);
		
		JS_CCNode *arg0_proxy = JS_GetPrivate( arg0 );
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
		JS_FN("addChild", CCNode_jsaddChild, 1, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FN("init", CCNode_jsinit, 1, JSPROP_PERMANENT | JSPROP_SHARED),
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

