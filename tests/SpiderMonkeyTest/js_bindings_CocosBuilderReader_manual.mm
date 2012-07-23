//
// CocosBuilderReader manually generated bindings
//

#import "js_bindings_config.h"
#import "ScriptingCore.h"

#import "js_bindings_CocosBuilderReader_classes.h"
#import "js_manual_conversions.h"

@interface CCBReaderForwarder : NSObject
{
	JSObject *_jsthis;
	JSContext *_cx;
}

-(id) initWithJSObject:(JSObject*)jsowner context:(JSContext*)cx;
-(NSString*) convertToJSName:(NSString*)nativeName;
@end

@implementation CCBReaderForwarder

-(id) initWithJSObject:(JSObject*)jsowner context:(JSContext*)cx;
{
	if( (self=[super init])) {

		_jsthis = jsowner;
		_cx = cx;
	}
	
	return self;
}

-(void) dealloc
{
	CCLOGINFO(@"deallocing %@", self);
	[super dealloc];
}

-(NSString*) convertToJSName:(NSString*)nativeName
{
	return [nativeName stringByReplacingOccurrencesOfString:@":" withString:@""];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
	// void, self, _cmd, sender
	return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
}

- (void)forwardInvocation:(NSInvocation *)inv
{
	NSString *name = NSStringFromSelector([inv selector] );

	CCLOGINFO(@"Calling JS function: %@", name);
	
	JSBool found;
	const char *functionName = [[self convertToJSName:name] UTF8String];

	JS_HasProperty(_cx, _jsthis, functionName, &found);
	if (found == JS_TRUE) {
		jsval rval, fval;
		jsval *argv = NULL;
		unsigned argc=0;
		
		JS_GetProperty(_cx, _jsthis, functionName, &fval);
		JS_CallFunctionValue(_cx, _jsthis, fval, argc, argv, &rval);
	}
}
@end

// Arguments: NSString*, NSObject*
// Ret value: CCNode* (o)
JSBool JSPROXY_CCBReader_nodeGraphFromFile_owner_parentSize__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc >= 1 && argc<=3 , @"Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	NSString* arg0; JSObject *arg1; CGSize arg2;
	
	ok &= jsval_to_nsstring( cx, *argvp++, &arg0 );
	if( argc >= 2 )
		ok &= JS_ValueToObject(cx, *argvp++, &arg1 );
	if( argc >= 3 )
		ok &= jsval_to_CGSize(cx, *argvp++, &arg2 );
	
	if( ! ok ) return JS_FALSE;
	

	CCNode* ret_val;
	
	if( argc == 1 )
		ret_val = [CCBReader nodeGraphFromFile:(NSString*)arg0];
	else if(argc == 2 ) {
		CCBReaderForwarder *owner = [[[CCBReaderForwarder alloc] initWithJSObject:arg1 context:cx] autorelease];
		ret_val = [CCBReader nodeGraphFromFile:arg0 owner:owner];

		// XXX LEAK
		[owner retain];
	}
	else if(argc == 3 ) {
		CCBReaderForwarder *owner = [[[CCBReaderForwarder alloc] initWithJSObject:arg1 context:cx] autorelease];
		ret_val = [CCBReader nodeGraphFromFile:arg0 owner:owner parentSize:arg2];
		
		// XXX LEAK
		[owner retain];
	}

	
	JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
	return JS_TRUE;
}

// Arguments: NSString*, NSObject*, CGSize
// Ret value: CCScene* (o)
JSBool JSPROXY_CCBReader_sceneWithNodeGraphFromFile_owner_parentSize__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc >= 1 && argc<=3 , @"Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	NSString* arg0; JSObject *arg1; CGSize arg2;
	
	ok &= jsval_to_nsstring( cx, *argvp++, &arg0 );
	if( argc >= 2 )
		ok &= JS_ValueToObject(cx, *argvp++, &arg1 );
	if( argc >= 3 )
		ok &= jsval_to_CGSize(cx, *argvp++, &arg2 );

	if( ! ok ) return JS_FALSE;
	
	CCScene* ret_val;
	
	if( argc == 1 )
		ret_val = [CCBReader sceneWithNodeGraphFromFile:(NSString*)arg0];
	else if( argc == 2 ) {
		CCBReaderForwarder *owner = [[[CCBReaderForwarder alloc] initWithJSObject:arg1 context:cx] autorelease];
		ret_val = [CCBReader sceneWithNodeGraphFromFile:arg0 owner:owner];
		
		// XXX LEAK
		[owner retain];
	}
	else if( argc == 3 ) {
		CCBReaderForwarder *owner = [[[CCBReaderForwarder alloc] initWithJSObject:arg1 context:cx] autorelease];
		ret_val = [CCBReader sceneWithNodeGraphFromFile:arg0 owner:owner parentSize:arg2];
		
		// XXX LEAK
		[owner retain];
	}

	JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
	return JS_TRUE;
}

