//
// File manually generated.
//


#import "js_bindings_NSObject.h"

#pragma mark - JSPROXY_NSObject


JSClass* JSPROXY_NSObject_class = NULL;
JSObject* JSPROXY_NSObject_object = NULL;
// Constructor
JSBool JSPROXY_NSObject_constructor(JSContext *cx, uint32_t argc, jsval *vp)
{
    JSObject *jsobj = JS_NewObject(cx, JSPROXY_NSObject_class, JSPROXY_NSObject_object, NULL);
	
    JSPROXY_NSObject *proxy = [[JSPROXY_NSObject alloc] initWithJSObject:jsobj];
	
    JS_SetPrivate(jsobj, proxy);
    JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
    /* no callbacks */
    
    return JS_TRUE;
}

// Destructor
void JSPROXY_NSObject_finalize(JSContext *cx, JSObject *obj)
{
	JSPROXY_NSObject *pt = (JSPROXY_NSObject*)JS_GetPrivate(obj);
	if (pt) {
		
		[pt release];
		
		JS_free(cx, pt);
	}
}

// Methods
JSBool JSPROXY_NSObject_init(JSContext *cx, uint32_t argc, jsval *vp) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject* proxy = (JSPROXY_NSObject*) JS_GetPrivate( obj );
	NSCAssert( proxy, @"Invalid Proxy object");
	NSCAssert( ! [proxy realObj], @"Object already initialzied. error");
	
	
	NSObject* real = [[NSObject alloc] init];
	[proxy setRealObj:real];
	[real release];
	
	NSCAssert( real, @"Invalid JS object");
	
	NSCAssert1( argc == 0, @"Invalid number of arguments: %d", argc );
		
	JS_SET_RVAL(cx, vp, JSVAL_TRUE);
	
	return JS_TRUE;
}


@implementation JSPROXY_NSObject

@synthesize jsObj = _jsObj;
@synthesize realObj = _realObj;

+(void) createClassWithContext:(JSContext*)cx object:(JSObject*)globalObj name:(NSString*)name
{
	JSPROXY_NSObject_class = (JSClass *)calloc(1, sizeof(JSClass));
	JSPROXY_NSObject_class->name = [name UTF8String];
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
		{0, 0, 0, 0, 0}
	};
	
	static JSFunctionSpec funcs[] = {
		JS_FN("init", JSPROXY_NSObject_init, 0, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FS_END
	};
	
	static JSFunctionSpec st_funcs[] = {
		JS_FS_END
	};
	
	JSPROXY_NSObject_object = JS_InitClass(cx, globalObj, NULL, JSPROXY_NSObject_class, JSPROXY_NSObject_constructor,0,properties,funcs,NULL,st_funcs);
}

-(id) initWithJSObject:(JSObject*)object
{
	self = [super init];
	if( self )
	{
		_jsObj = object;
	}
	
	return self;
}

-(void) dealloc
{
	// If the compiler gives you an error, you can safely remove the following line
	CCLOGINFO(@"deallocing: %@", self);
	
	[_realObj release];
	
	[super dealloc];
}

@end
