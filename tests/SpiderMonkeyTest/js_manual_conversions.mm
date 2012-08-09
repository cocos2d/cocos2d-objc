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
#import "jsfriendapi.h"
#import "ScriptingCore.h"
#import "js_bindings_config.h"
#import "js_bindings_NS_manual.h"
#import "js_bindings_config.h"


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
	JSB_PRECONDITION( jsstr, "invalid string" );
	
	// root it
	vp = STRING_TO_JSVAL(jsstr);

	char *ptr = JS_EncodeString(cx, jsstr);
	if( ! ptr )
		return JS_FALSE;
	
	NSString *tmp = [NSString stringWithUTF8String: ptr];
	if( ! tmp )
		return JS_FALSE;
	
	*ret = tmp;
	JS_free( cx, ptr );

	return JS_TRUE;
}

JSBool jsval_to_nsobject( JSContext *cx, jsval vp, NSObject **ret )
{
	JSObject *jsobj;
	if( ! JS_ValueToObject( cx, vp, &jsobj ) )
		return JS_FALSE;
	
	// root it
	vp = OBJECT_TO_JSVAL(jsobj);
	
	JSPROXY_NSObject* proxy = get_proxy_for_jsobject(jsobj);
	if( ! proxy )
		return JS_FALSE;

	*ret = [proxy realObj];
	
	return JS_TRUE;
}

JSBool jsval_to_nsarray( JSContext *cx, jsval vp, NSArray**ret )
{
	// Parsing sequence
	JSObject *jsobj;
	if( ! JS_ValueToObject( cx, vp, &jsobj ) )
		return JS_FALSE;
	
	JSB_PRECONDITION( jsobj && JS_IsArrayObject( cx, jsobj),  "Object must be an array");

	
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
	
	JSB_PRECONDITION( jsobj && JS_IsArrayObject( cx, jsobj), "Object must be an array");

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
		JSBool ok = JS_FALSE;
		
		// Native Object ?
		ok = jsval_to_nsobject( cx, *vp, &obj );

		// Number ?
		if( ! ok ) {
			double num;
			ok = JS_ValueToNumber(cx, *vp, &num );
			
			if( ok ) {
				obj = [NSNumber numberWithDouble:num];
			}
		}
		
		// String ?
		if( ! ok )
			ok = jsval_to_nsstring(cx, *vp, (NSString**)&obj );
		
		if( ! ok )
			return JS_FALSE;

		// next
		vp++;
		
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
#if JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES

	JSObject *jsobj;
	if( ! JS_ValueToObject( cx, vp, &jsobj ) )
		return JS_FALSE;
	
	JSB_PRECONDITION( jsobj, "Not a valid JS object");

	jsval valx, valy;
	JSBool ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "x", &valx);
	ok &= JS_GetProperty(cx, jsobj, "y", &valy);

	if( ! ok )
		return JS_FALSE;
	
	double x, y;
	ok &= JS_ValueToNumber(cx, valx, &x);
	ok &= JS_ValueToNumber(cx, valy, &y);
	
	if( ! ok )
		return JS_FALSE;
	
	ret->x = x;
	ret->y = y;

	return JS_TRUE;

#else // #! JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES

	JSObject *tmp_arg;
	if( ! JS_ValueToObject( cx, vp, &tmp_arg ) )
		return JS_FALSE;
	
	JSB_PRECONDITION( tmp_arg && JS_IsTypedArrayObject( tmp_arg, cx ), "Not a TypedArray object");
	
	JSB_PRECONDITION( JS_GetTypedArrayByteLength( tmp_arg, cx ) == sizeof(CGPoint), "Invalid length");
	
	*ret = *(CGPoint*)JS_GetArrayBufferViewData( tmp_arg, cx );
	
	return JS_TRUE;
#endif // #! JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES
}

JSBool jsval_to_CGSize( JSContext *cx, jsval vp, CGSize *ret )
{
#if JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES
	
	JSObject *jsobj;
	if( ! JS_ValueToObject( cx, vp, &jsobj ) )
		return JS_FALSE;
	
	JSB_PRECONDITION( jsobj, "Not a valid JS object");
	
	jsval valw, valh;
	JSBool ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "width", &valw);
	ok &= JS_GetProperty(cx, jsobj, "height", &valh);
	
	if( ! ok )
		return JS_FALSE;
	
	double w, h;
	ok &= JS_ValueToNumber(cx, valw, &w);
	ok &= JS_ValueToNumber(cx, valh, &h);
	
	if( ! ok )
		return JS_FALSE;
	
	ret->width = w;
	ret->height = h;
	
	return JS_TRUE;
	
#else // #! JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES

	JSObject *tmp_arg;
	if( ! JS_ValueToObject( cx, vp, &tmp_arg ) )
		return JS_FALSE;

	JSB_PRECONDITION( tmp_arg && JS_IsTypedArrayObject( tmp_arg, cx ), "Not a TypedArray object");

	JSB_PRECONDITION( JS_GetTypedArrayByteLength( tmp_arg, cx ) == sizeof(CGSize), "Invalid length" );
	
	*ret = *(CGSize*)JS_GetArrayBufferViewData( tmp_arg, cx );
	return JS_TRUE;

#endif // #! JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES
}

JSBool jsval_to_CGRect( JSContext *cx, jsval vp, CGRect *ret )
{
#if JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES
	
	JSObject *jsobj;
	if( ! JS_ValueToObject( cx, vp, &jsobj ) )
		return JS_FALSE;
	
	JSB_PRECONDITION( jsobj, "Not a valid JS object");
	
	jsval valx, valy, valw, valh;
	JSBool ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "x", &valx);
	ok &= JS_GetProperty(cx, jsobj, "y", &valy);
	ok &= JS_GetProperty(cx, jsobj, "width", &valw);
	ok &= JS_GetProperty(cx, jsobj, "height", &valh);
	
	if( ! ok )
		return JS_FALSE;
	
	double x, y, w, h;
	ok &= JS_ValueToNumber(cx, valx, &x);
	ok &= JS_ValueToNumber(cx, valy, &y);
	ok &= JS_ValueToNumber(cx, valw, &w);
	ok &= JS_ValueToNumber(cx, valh, &h);
	
	if( ! ok )
		return JS_FALSE;
	
	ret->origin.x = x;
	ret->origin.y = y;
	ret->size.width = w;
	ret->size.height = h;
	
	return JS_TRUE;
	
#else // #! JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES

	JSObject *tmp_arg;
	if( ! JS_ValueToObject( cx, vp, &tmp_arg ) )
		return JS_FALSE;

	JSB_PRECONDITION( tmp_arg && JS_IsTypedArrayObject( tmp_arg, cx ), "Not a TypedArray object");

	JSB_PRECONDITION( JS_GetTypedArrayByteLength( tmp_arg, cx ) == sizeof(CGRect), "Invalid length");
	
	*ret = *(CGRect*)JS_GetArrayBufferViewData( tmp_arg, cx );

	return JS_TRUE;

#endif // #! JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES
}

JSBool jsval_to_opaque( JSContext *cx, jsval vp, void **r)
{
#ifdef __LP64__
	JSObject *tmp_arg;
	if( ! JS_ValueToObject( cx, vp, &tmp_arg ) )
		return JS_FALSE;

	JSB_PRECONDITION( tmp_arg && JS_IsTypedArrayObject( tmp_arg, cx ), "Not a TypedArray object");

	JSB_PRECONDITION( JS_GetTypedArrayByteLength( tmp_arg, cx ) == sizeof(void*), "Invalid Typed Array lenght");
	
	int32_t* arg_array = (int32_t*)JS_GetArrayBufferViewData( tmp_arg, cx );
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

	JSB_PRECONDITION( tmp_arg && JS_IsTypedArrayObject( tmp_arg, cx ), "Not a TypedArray object");

	JSB_PRECONDITION( JS_GetTypedArrayByteLength( tmp_arg, cx ) == sizeof(long), "Invalid Typed Array lenght");
	
	int32_t* arg_array = (int32_t*)JS_GetArrayBufferViewData( tmp_arg, cx );
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
	
	JSB_PRECONDITION( tmp_arg && JS_IsTypedArrayObject( tmp_arg, cx ), "Not a TypedArray object");

	JSB_PRECONDITION( JS_GetTypedArrayByteLength( tmp_arg, cx ) == sizeof(long long), "Invalid Typed Array lenght");
	
	int32_t* arg_array = (int32_t*)JS_GetArrayBufferViewData( tmp_arg, cx );
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
	
#if JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES

	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;

	if (!JS_DefineProperty(cx, object, "x", DOUBLE_TO_JSVAL(p.x), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "y", DOUBLE_TO_JSVAL(p.y), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;
	
	return OBJECT_TO_JSVAL(object);

#else // JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES
	
#ifdef __LP64__
	JSObject *typedArray = JS_NewFloat64Array( cx, 2 );
#else
	JSObject *typedArray = JS_NewFloat32Array( cx, 2 );
#endif

	CGPoint *buffer = (CGPoint*)JS_GetArrayBufferViewData(typedArray, cx );
	*buffer = p;
	return OBJECT_TO_JSVAL(typedArray);
#endif // ! JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES
}

jsval CGSize_to_jsval( JSContext *cx, CGSize s)
{
#if JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES
	
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;
	
	if (!JS_DefineProperty(cx, object, "width", DOUBLE_TO_JSVAL(s.width), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "height", DOUBLE_TO_JSVAL(s.height), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;
	
	return OBJECT_TO_JSVAL(object);
	
#else // JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES

#ifdef __LP64__
	JSObject *typedArray = JS_NewFloat64Array( cx, 2 );
#else
	JSObject *typedArray = JS_NewFloat32Array( cx, 2 );
#endif
	CGSize *buffer = (CGSize*)JS_GetArrayBufferViewData(typedArray, cx);
	*buffer = s;
	return OBJECT_TO_JSVAL(typedArray);
	
#endif // ! JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES
}

jsval CGRect_to_jsval( JSContext *cx, CGRect rect)
{
#if JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES
	
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;
	
	if (!JS_DefineProperty(cx, object, "x", DOUBLE_TO_JSVAL(rect.origin.x), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "y", DOUBLE_TO_JSVAL(rect.origin.y), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "width", DOUBLE_TO_JSVAL(rect.size.width), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "height", DOUBLE_TO_JSVAL(rect.size.height), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;
	
	return OBJECT_TO_JSVAL(object);
	
#else // JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES

#ifdef __LP64__
	JSObject *typedArray = JS_NewFloat64Array( cx, 4 );
#else
	JSObject *typedArray = JS_NewFloat32Array( cx, 4 );
#endif

	CGRect *buffer = (CGRect*)JS_GetArrayBufferViewData(typedArray, cx);
	*buffer = rect;
	return OBJECT_TO_JSVAL(typedArray);
	
#endif // ! JSB_COMPATIBLE_WITH_COCOS2D_HTML5_BASIC_TYPES
}

jsval opaque_to_jsval( JSContext *cx, void *opaque )
{
#ifdef __LP64__
	uint64_t number = (uint64_t)opaque;
	JSObject *typedArray = JS_NewUint32Array( cx, 2 );
	int32_t *buffer = (int32_t*)JS_GetArrayBufferViewData(typedArray, cx);
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

	JSObject *typedArray = JS_NewUint32Array( cx, 2 );
	int32_t *buffer = (int32_t*)JS_GetArrayBufferViewData(typedArray, cx);
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
	JSObject *typedArray = JS_NewUint32Array( cx, 2 );
	int32_t *buffer = (int32_t*)JS_GetArrayBufferViewData(typedArray, cx);
	buffer[0] = number >> 32;
	buffer[1] = number & 0xffffffff;
	return OBJECT_TO_JSVAL(typedArray);		
}

#pragma mark - cocos2d related stuff

#ifdef JSB_USE_COCOS2D
jsval ccGridSize_to_jsval( JSContext *cx, ccGridSize p)
{
	JSObject *typedArray = JS_NewInt32Array( cx, 2 );
	int32_t *buffer = (int32_t*)JS_GetArrayBufferViewData(typedArray, cx);
	buffer[0] = p.x;
	buffer[1] = p.y;
	return OBJECT_TO_JSVAL(typedArray);
}

JSBool jsval_to_ccGridSize( JSContext *cx, jsval vp, ccGridSize *ret )
{
	JSObject *tmp_arg;
	if( ! JS_ValueToObject( cx, vp, &tmp_arg ) )
		return JS_FALSE;
	
	JSB_PRECONDITION( JS_IsTypedArrayObject( tmp_arg, cx ), "Not a TypedArray object");
	
	JSB_PRECONDITION( JS_GetTypedArrayByteLength( tmp_arg, cx ) == sizeof(int32_t)*2, "Invalid length");
	
#ifdef __LP64__
	int32_t* arg_array = (int32_t*)JS_GetArrayBufferViewData( tmp_arg, cx );
	*ret = ccg(arg_array[0], arg_array[1] );	
#else
	*ret = *(ccGridSize*)JS_GetArrayBufferViewData( tmp_arg, cx);
#endif
	return JS_TRUE;
}

JSBool jsval_to_ccColor3B( JSContext *cx, jsval vp, ccColor3B *ret )
{
	JSObject *jsobj;
	if( ! JS_ValueToObject( cx, vp, &jsobj ) )
		return JS_FALSE;
	
	JSB_PRECONDITION( jsobj, "Not a valid JS object");
	
	jsval valr, valg, valb;
	JSBool ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "r", &valr);
	ok &= JS_GetProperty(cx, jsobj, "g", &valg);
	ok &= JS_GetProperty(cx, jsobj, "b", &valb);
	
	if( ! ok )
		return JS_FALSE;
	
	uint16_t r,g,b;
	ok &= JS_ValueToUint16(cx, valr, &r);
	ok &= JS_ValueToUint16(cx, valg, &g);
	ok &= JS_ValueToUint16(cx, valb, &b);
	
	if( ! ok )
		return JS_FALSE;
	
	ret->r = r;
	ret->g = g;
	ret->b = b;
	
	return JS_TRUE;	
}

JSBool jsval_to_ccColor4B( JSContext *cx, jsval vp, ccColor4B *ret )
{
	JSObject *jsobj;
	if( ! JS_ValueToObject( cx, vp, &jsobj ) )
		return JS_FALSE;
	
	JSB_PRECONDITION( jsobj, "Not a valid JS object");
	
	jsval valr, valg, valb, vala;
	JSBool ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "r", &valr);
	ok &= JS_GetProperty(cx, jsobj, "g", &valg);
	ok &= JS_GetProperty(cx, jsobj, "b", &valb);
	ok &= JS_GetProperty(cx, jsobj, "a", &vala);
	
	if( ! ok )
		return JS_FALSE;
	
	uint16_t r,g,b,a;
	ok &= JS_ValueToUint16(cx, valr, &r);
	ok &= JS_ValueToUint16(cx, valg, &g);
	ok &= JS_ValueToUint16(cx, valb, &b);
	ok &= JS_ValueToUint16(cx, vala, &a);
	
	if( ! ok )
		return JS_FALSE;
	
	ret->r = r;
	ret->g = g;
	ret->b = b;
	ret->a = a;
	
	return JS_TRUE;
}

JSBool jsval_to_ccColor4F( JSContext *cx, jsval vp, ccColor4F *ret )
{
	JSObject *jsobj;
	if( ! JS_ValueToObject( cx, vp, &jsobj ) )
		return JS_FALSE;
	
	JSB_PRECONDITION( jsobj, "Not a valid JS object");
	
	jsval valr, valg, valb, vala;
	JSBool ok = JS_TRUE;
	ok &= JS_GetProperty(cx, jsobj, "r", &valr);
	ok &= JS_GetProperty(cx, jsobj, "g", &valg);
	ok &= JS_GetProperty(cx, jsobj, "b", &valb);
	ok &= JS_GetProperty(cx, jsobj, "a", &vala);
	
	if( ! ok )
		return JS_FALSE;
	
	double r,g,b,a;
	ok &= JS_ValueToNumber(cx, valr, &r);
	ok &= JS_ValueToNumber(cx, valg, &g);
	ok &= JS_ValueToNumber(cx, valb, &b);
	ok &= JS_ValueToNumber(cx, vala, &a);
	
	if( ! ok )
		return JS_FALSE;
	
	ret->r = r;
	ret->g = g;
	ret->b = b;
	ret->a = a;
	
	return JS_TRUE;	
}

jsval ccColor3B_to_jsval( JSContext *cx, ccColor3B p )
{
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;
	
	if (!JS_DefineProperty(cx, object, "r", UINT_TO_JSVAL(p.r), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "g", UINT_TO_JSVAL(p.g), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "b", UINT_TO_JSVAL(p.b), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;
	
	return OBJECT_TO_JSVAL(object);	
}

jsval ccColor4B_to_jsval( JSContext *cx, ccColor4B p )
{
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;
	
	if (!JS_DefineProperty(cx, object, "r", UINT_TO_JSVAL(p.r), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "g", UINT_TO_JSVAL(p.g), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "b", UINT_TO_JSVAL(p.g), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "a", UINT_TO_JSVAL(p.b), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;
	
	return OBJECT_TO_JSVAL(object);		
}

jsval ccColor4F_to_jsval( JSContext *cx, ccColor4F p )
{
	JSObject *object = JS_NewObject(cx, NULL, NULL, NULL );
	if (!object)
		return JSVAL_VOID;
	
	if (!JS_DefineProperty(cx, object, "r", DOUBLE_TO_JSVAL(p.r), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "g", DOUBLE_TO_JSVAL(p.g), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "b", DOUBLE_TO_JSVAL(p.g), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) ||
		!JS_DefineProperty(cx, object, "a", DOUBLE_TO_JSVAL(p.b), NULL, NULL, JSPROP_ENUMERATE | JSPROP_PERMANENT) )
		return JSVAL_VOID;
	
	return OBJECT_TO_JSVAL(object);		
}

#endif // JSB_USE_COCOS2D


#ifdef JSB_USE_CHIPMUNK

JSBool jsval_to_cpBB( JSContext *cx, jsval vp, cpBB *ret )
{
	JSObject *tmp_arg;
	if( ! JS_ValueToObject( cx, vp, &tmp_arg ) )
		return JS_FALSE;
	
	JSB_PRECONDITION( JS_IsTypedArrayObject( tmp_arg, cx ), "Not a TypedArray object");
	
	JSB_PRECONDITION( JS_GetTypedArrayByteLength( tmp_arg, cx ) == sizeof(cpFloat)*4, "Invalid length");
	
	*ret = *(cpBB*)JS_GetArrayBufferViewData( tmp_arg, cx);

	return JS_TRUE;	
}

jsval cpBB_to_jsval(JSContext *cx, cpBB bb )
{
#ifdef __LP64__
	JSObject *typedArray = JS_NewFloat64Array( cx, 4 );
#else
	JSObject *typedArray = JS_NewFloat32Array( cx, 4 );
#endif
	cpBB *buffer = (cpBB*)JS_GetArrayBufferViewData(typedArray, cx);
	
	*buffer = bb;
	return OBJECT_TO_JSVAL(typedArray);
}

#endif // JSB_USE_CHIPMUNK
