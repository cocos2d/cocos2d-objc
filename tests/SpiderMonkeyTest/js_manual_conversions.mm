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
#import "jstypedarray.h"
#import "ScriptingCore.h"
#import "js_bindings_config.h"
#import "js_bindings_NS_manual.h"


#pragma mark - helpers

JSObject* create_jsobject_from_realobj( JSContext* context, Class klass, id realObj )
{
	NSString *proxied_class = [NSString stringWithFormat:@"JSPROXY_%@", klass];
	Class newKlass = NSClassFromString(proxied_class);
	if( newKlass )
		return [newKlass createJSObjectWithRealObject:realObj context:context];

	CCLOGWARN(@"Proxied class not found: %@. Trying with parent class", proxied_class );
	return create_jsobject_from_realobj( context, [klass superclass], realObj  );
}

JSObject * get_or_create_jsobject_from_realobj( JSContext *cx, id realObj )
{
	if( ! realObj )
		return NULL;
		
	JSPROXY_NSObject *proxy = objc_getAssociatedObject(realObj, &JSPROXY_association_proxy_key );
	if( proxy )
		return [proxy jsObj];
	
	return create_jsobject_from_realobj( cx, [realObj class], realObj );
}


#pragma mark - jsval to native

// Convert function
JSBool jsval_to_nsstring( JSContext *cx, jsval vp, NSString **ret )
{
	JSString *jsstr = JS_ValueToString( cx, vp );
	JSB_PRECONDITION( jsstr, @"invalid string" );
	
	// root it
	vp = STRING_TO_JSVAL(jsstr);

	*ret = [NSString stringWithUTF8String: JS_EncodeString(cx, jsstr)];
	
	return JS_TRUE;
}

JSBool jsval_to_nsobject( JSContext *cx, jsval vp, NSObject **ret )
{
	JSObject *jsobj;
	if( ! JS_ValueToObject( cx, vp, &jsobj ) )
		return JS_FALSE;
	
	// root it
	vp = OBJECT_TO_JSVAL(jsobj);
	
//	JSPROXY_NSObject* proxy = (JSPROXY_NSObject*) JS_GetPrivate( jsobj ); 
	JSPROXY_NSObject* proxy = get_proxy_for_jsobject(jsobj);

	*ret = [proxy realObj];
	
	return JS_TRUE;
}

JSBool jsval_to_nsarray( JSContext *cx, jsval vp, NSArray**ret )
{
	// Parsing sequence
	JSObject *jsobj;
	if( ! JS_ValueToObject( cx, vp, &jsobj ) )
		return JS_FALSE;
	
	JSB_PRECONDITION( JS_IsArrayObject( cx, jsobj),  @"Object must be an array");

	
	uint32_t len;
	JS_GetArrayLength(cx, jsobj,&len);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:len];
	for( uint32_t i=0; i< len;i++ ) {		
		jsval valarg;
		JS_GetElement(cx, jsobj, i, &valarg);
		
		// XXX: forcing them to be objects, but they could also be NSString, NSDictionary or NSArray
		id real_obj;
		if( ! jsval_to_nsobject( cx, valarg, &real_obj ) )
			return JS_FALSE;
		
		[array addObject:real_obj];
	}
	*ret = array;

	return JS_TRUE;
}

JSBool jsval_to_nsset( JSContext *cx, jsval vp, NSSet** ret)
{
	// Parsing sequence
	JSObject *jsobj;
	if( ! JS_ValueToObject( cx, vp, &jsobj ) )
		return JS_FALSE;
	
	JSB_PRECONDITION( JS_IsArrayObject( cx, jsobj),  @"Object must be an array");

	uint32_t len;
	JS_GetArrayLength(cx, jsobj,&len);
	NSMutableSet *set = [NSMutableArray arrayWithCapacity:len];
	for( uint32_t i=0; i< len;i++ ) {		
		jsval valarg;
		JS_GetElement(cx, jsobj, i, &valarg);
		
		// XXX: forcing them to be objects, but they could also be NSString, NSDictionary or NSArray
		id real_obj;
		if( ! jsval_to_nsobject( cx, valarg, &real_obj ) )
			return JS_FALSE;
		
		[set addObject:real_obj];
	}
	*ret = set;
	return JS_TRUE;
}

JSBool jsvals_variadic_to_nsarray( JSContext *cx, jsval *vp, int argc, NSArray**ret )
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:argc];
	
	for( int i=0; i < argc; i++ )
	{
		id obj;
		if( ! jsval_to_nsobject( cx, *vp++, &obj ) )
			return JS_FALSE;

		[array addObject:obj];
	}
	*ret = array;
	return JS_TRUE;
}

JSBool jsval_to_block_1( JSContext *cx, jsval vp, JSObject *jsthis, js_block *ret)
{
	if( ! JS_ValueToFunction(cx, vp ) )
		return JS_FALSE;

	js_block block = ^(id sender) {

		jsval rval;
		
		JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, sender );
		jsval val = OBJECT_TO_JSVAL(jsobj);

		JS_CallFunctionValue(cx, jsthis, vp, 1, &val, &rval);
	};
	
	*ret = [[block copy] autorelease];
	return JS_TRUE;
}

JSBool jsval_to_block_2( JSContext *cx, jsval vp, JSObject *jsthis, jsval arg, js_block *ret)
{
	if( ! JS_ValueToFunction(cx, vp ) )
		return JS_FALSE;
	
	js_block block = ^(id sender) {
		
		jsval rval;
		
		JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, sender );
		
		jsval vals[2];
		vals[0] = OBJECT_TO_JSVAL(jsobj);
		
		// arg NEEDS TO BE ROOTED! Potential crash
		vals[1] = arg;
		
		JS_CallFunctionValue(cx, jsthis, vp, 2, vals, &rval);
	};
	
	*ret = [[block copy] autorelease];
	return JS_TRUE;
}

JSBool jsval_to_CGPoint( JSContext *cx, jsval vp, CGPoint *ret )
{
	JSObject *tmp_arg;
	if( ! JS_ValueToObject( cx, vp, &tmp_arg ) )
		return JS_FALSE;
	
	JSB_PRECONDITION( js_IsTypedArray( tmp_arg ), @"jsb: Not a TypedArray object");

	JSB_PRECONDITION( JS_GetTypedArrayByteLength( tmp_arg ) == sizeof(float)*2, @"jsb: Invalid length");
	
#ifdef __LP64__
	float* arg_array = (float*)JS_GetTypedArrayData( tmp_arg );
	*ret = ccp(arg_array[0], arg_array[1] );	
#else
	*ret = *(CGPoint*)JS_GetTypedArrayData( tmp_arg );
#endif
	return JS_TRUE;
}

JSBool jsval_to_CGSize( JSContext *cx, jsval vp, CGSize *ret )
{
	JSObject *tmp_arg;
	if( ! JS_ValueToObject( cx, vp, &tmp_arg ) )
		return JS_FALSE;

	JSB_PRECONDITION( js_IsTypedArray( tmp_arg ), @"jsb: Not a TypedArray object");

	JSB_PRECONDITION( JS_GetTypedArrayByteLength( tmp_arg ) == sizeof(float)*2, @"jsb: Invalid length" );
	
#ifdef __LP64__
	float* arg_array = (float*)JS_GetTypedArrayData( tmp_arg );
	*ret = CGSizeMake( arg_array[0], arg_array[1] );
#else
	*ret = *(CGSize*)JS_GetTypedArrayData( tmp_arg );
#endif
	return JS_TRUE;
}

JSBool jsval_to_CGRect( JSContext *cx, jsval vp, CGRect *ret )
{
	JSObject *tmp_arg;
	if( ! JS_ValueToObject( cx, vp, &tmp_arg ) )
		return JS_FALSE;

	JSB_PRECONDITION( js_IsTypedArray( tmp_arg ), @"jsb: Not a TypedArray object");

	JSB_PRECONDITION( JS_GetTypedArrayByteLength( tmp_arg ) == sizeof(float)*4, @"jsb: Invalid length");
	
#ifdef __LP64__
	float* arg_array = (float*)JS_GetTypedArrayData( tmp_arg );
	*ret = CGRectMake( arg_array[0], arg_array[1], arg_array[2], arg_array[3] );

#else
	*ret = *(CGRect*)JS_GetTypedArrayData( tmp_arg );
#endif
	return JS_TRUE;
}

JSBool jsval_to_opaque( JSContext *cx, jsval vp, void **r)
{
#ifdef __LP64__
	JSObject *tmp_arg;
	if( ! JS_ValueToObject( cx, vp, &tmp_arg ) )
		return JS_FALSE;

	JSB_PRECONDITION( js_IsTypedArray( tmp_arg ), @"jsb: Not a TypedArray object");

	JSB_PRECONDITION( JS_GetTypedArrayByteLength( tmp_arg ) == sizeof(void*), @"jsb: Invalid Typed Array lenght");
	
	int32_t* arg_array = (int32_t*)JS_GetTypedArrayData( tmp_arg );
	uint64 ret =  arg_array[0];
	ret = ret << 32;
	ret |= arg_array[1];
	
#else
	NSCAssert( sizeof(int)==4, @"fatal!");
	int32_t ret;
	if( ! JS_ValueToInt32(cx, vp, &ret ) )
	   return JS_FALSE;
#endif
	*r = (void*)ret;
	return JS_TRUE;
}

JSBool jsval_to_int( JSContext *cx, jsval vp, int *ret )
{
	// Since this is called to cast uint64 to uint32,
	// it is needed to initialize the value to 0 first
#ifdef __LP64__
	long *tmp = (long*)ret;
	*tmp = 0;
#endif
	return JS_ValueToInt32(cx, vp, (int32_t*)ret);
}

// XXX: sizeof(long) == 8 in 64 bits on OS X... apparently on Windows it is 32 bits (???)
JSBool jsval_to_long( JSContext *cx, jsval vp, long *r )
{
#ifdef __LP64__
	// compatibility check
	NSCAssert( sizeof(long)==8, @"fatal! Compiler error ?");
	JSObject *tmp_arg;
	if( ! JS_ValueToObject( cx, vp, &tmp_arg ) )
		return JS_FALSE;

	JSB_PRECONDITION( js_IsTypedArray( tmp_arg ), @"jsb: Not a TypedArray object");

	JSB_PRECONDITION( JS_GetTypedArrayByteLength( tmp_arg ) == sizeof(long), @"jsb: Invalid Typed Array lenght");
	
	int32_t* arg_array = (int32_t*)JS_GetTypedArrayData( tmp_arg );
	long ret =  arg_array[0];
	ret = ret << 32;
	ret |= arg_array[1];
	
#else
	// compatibility check
	NSCAssert( sizeof(int)==4, @"fatal!, Compiler error ?");
	long ret = JSVAL_TO_INT(vp);
#endif
	
	*r = ret;
	return JS_TRUE;
}

JSBool jsval_to_longlong( JSContext *cx, jsval vp, long long *r )
{
	JSObject *tmp_arg;
	if( ! JS_ValueToObject( cx, vp, &tmp_arg ) )
		return JS_FALSE;
	
	JSB_PRECONDITION( js_IsTypedArray( tmp_arg ), @"jsb: Not a TypedArray object");

	JSB_PRECONDITION( JS_GetTypedArrayByteLength( tmp_arg ) == sizeof(long long), @"jsb: Invalid Typed Array lenght");
	
	int32_t* arg_array = (int32_t*)JS_GetTypedArrayData( tmp_arg );
	long long ret =  arg_array[0];
	ret = ret << 32;
	ret |= arg_array[1];
	
	*r = ret;
	return JS_TRUE;
}


#pragma mark - native to jsval

jsval NSArray_to_jsval( JSContext *cx, NSArray *array)
{
	JSObject *jsobj = JS_NewArrayObject(cx, 0, NULL);
	uint32_t index = 0;
	for( id obj in array ) {
		JSObject *s = get_or_create_jsobject_from_realobj( cx, obj );
		jsval val = OBJECT_TO_JSVAL(s);
		JS_SetElement(cx, jsobj, index++, &val);
	}
	
	return OBJECT_TO_JSVAL(jsobj);
}

jsval NSSet_to_jsval( JSContext *cx, NSSet *set)
{
	JSObject *jsobj = JS_NewArrayObject(cx, 0, NULL);
	uint32_t index = 0;
	for( id obj in set ) {
		JSObject *s = get_or_create_jsobject_from_realobj( cx, obj );
		jsval val = OBJECT_TO_JSVAL(s);
		JS_SetElement(cx, jsobj, index++, &val);
	}

	return OBJECT_TO_JSVAL(jsobj);
}

jsval CGPoint_to_jsval( JSContext *cx, CGPoint p)
{
	JSObject *typedArray = js_CreateTypedArray(cx, js::TypedArray::TYPE_FLOAT32, 2 );
	float *buffer = (float*)JS_GetTypedArrayData(typedArray);
	buffer[0] = p.x;
	buffer[1] = p.y;
	return OBJECT_TO_JSVAL(typedArray);
}

jsval CGSize_to_jsval( JSContext *cx, CGSize s)
{
	JSObject *typedArray = js_CreateTypedArray(cx, js::TypedArray::TYPE_FLOAT32, 2 );
	float *buffer = (float*)JS_GetTypedArrayData(typedArray);
	buffer[0] = s.width;
	buffer[1] = s.height;
	return OBJECT_TO_JSVAL(typedArray);
}

jsval CGRect_to_jsval( JSContext *cx, CGRect s)
{
	JSObject *typedArray = js_CreateTypedArray(cx, js::TypedArray::TYPE_FLOAT32, 4 );
	float *buffer = (float*)JS_GetTypedArrayData(typedArray);
	buffer[0] = s.origin.x;
	buffer[1] = s.origin.y;
	buffer[2] = s.size.width;
	buffer[3] = s.size.height;
	return OBJECT_TO_JSVAL(typedArray);
}

jsval opaque_to_jsval( JSContext *cx, void *opaque )
{
#ifdef __LP64__
	uint64_t number = (uint64_t)opaque;
	JSObject *typedArray = js_CreateTypedArray(cx, js::TypedArray::TYPE_UINT32, 2);
	int32_t *buffer = (int32_t*)JS_GetTypedArrayData(typedArray);
	buffer[0] = number >> 32;
	buffer[1] = number & 0xffffffff;
	return OBJECT_TO_JSVAL(typedArray);		
#else
	NSCAssert( sizeof(int)==4, @"Error!");
	int32_t number = (int32_t) opaque;
	return INT_TO_JSVAL(number);
#endif
}

jsval int_to_jsval( JSContext *cx, int number )
{
	return INT_TO_JSVAL(number);
}

jsval long_to_jsval( JSContext *cx, long number )
{
#ifdef __LP64__
	NSCAssert( sizeof(long)==8, @"Error!");

	JSObject *typedArray = js_CreateTypedArray(cx, js::TypedArray::TYPE_UINT32, 2);
	int32_t *buffer = (int32_t*)JS_GetTypedArrayData(typedArray);
	buffer[0] = number >> 32;
	buffer[1] = number & 0xffffffff;
	return OBJECT_TO_JSVAL(typedArray);		
#else
	NSCAssert( sizeof(int)==4, @"Error!");
	return INT_TO_JSVAL(number);
#endif
}

jsval longlong_to_jsval( JSContext *cx, long long number )
{
	NSCAssert( sizeof(long long)==8, @"Error!");
	JSObject *typedArray = js_CreateTypedArray(cx, js::TypedArray::TYPE_UINT32, 2);
	int32_t *buffer = (int32_t*)JS_GetTypedArrayData(typedArray);
	buffer[0] = number >> 32;
	buffer[1] = number & 0xffffffff;
	return OBJECT_TO_JSVAL(typedArray);		
}

#pragma mark - cocos2d related stuff

#ifdef JSB_USE_COCOS2D
jsval ccGridSize_to_jsval( JSContext *cx, ccGridSize p)
{
	JSObject *typedArray = js_CreateTypedArray(cx, js::TypedArray::TYPE_INT32, 2 );
	float *buffer = (float*)JS_GetTypedArrayData(typedArray);
	buffer[0] = p.x;
	buffer[1] = p.y;
	return OBJECT_TO_JSVAL(typedArray);
}

JSBool jsval_to_ccGridSize( JSContext *cx, jsval vp, ccGridSize *ret )
{
	JSObject *tmp_arg;
	if( ! JS_ValueToObject( cx, vp, &tmp_arg ) )
		return JS_FALSE;
	
	JSB_PRECONDITION( js_IsTypedArray( tmp_arg ), @"jsb: Not a TypedArray object");
	
	JSB_PRECONDITION( JS_GetTypedArrayByteLength( tmp_arg ) == sizeof(float)*2, @"jsb: Invalid length");
	
#ifdef __LP64__
	int32_t* arg_array = (int32_t*)JS_GetTypedArrayData( tmp_arg );
	*ret = ccg(arg_array[0], arg_array[1] );	
#else
	*ret = *(ccGridSize*)JS_GetTypedArrayData( tmp_arg );
#endif
	return JS_TRUE;
}
#endif // JSB_USE_COCOS2D


