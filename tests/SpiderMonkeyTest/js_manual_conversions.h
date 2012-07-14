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

#import <Foundation/Foundation.h>
#import "js_bindings_config.h"

#ifdef JSB_USE_COCOS2D
#import "cocos2d.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef void (^js_block)(id sender);
	
/** Creates a JSObject, a ProxyObject and associates them with the real object */
JSObject* create_jsobject_from_realobj( JSContext* context, Class klass, id realObj );

/** Gets or Creates a JSObject, a ProxyObject and associates them with the real object */
JSObject * get_or_create_jsobject_from_realobj( JSContext *cx, id realObj);

/** converts a jsval to a NSString */
JSBool jsval_to_nsstring( JSContext *cx , jsval vp, NSString **out );

/** converts a jsval to a NSObject */
JSBool jsval_to_nsobject( JSContext *cx, jsval vp, NSObject **out );

/** converts a jsval to a NSArray */
JSBool jsval_to_nsarray( JSContext *cx , jsval vp, NSArray **out );

/** converts a jsval to a NSSet */
JSBool jsval_to_nsset( JSContext *cx , jsval vp, NSSet** out );

/** converts a variadic jsvals to a NSArray */
JSBool jsvals_variadic_to_nsarray( JSContext *cx, jsval *vp, int argc, NSArray** out );
	
JSBool jsval_to_CGPoint( JSContext *cx, jsval vp, CGPoint *out );
JSBool jsval_to_CGSize( JSContext *cx, jsval vp, CGSize *out );
JSBool jsval_to_CGRect( JSContext *cx, jsval vp, CGRect *out );
JSBool jsval_to_opaque( JSContext *cx, jsval vp, void **out );
JSBool jsval_to_int( JSContext *cx, jsval vp, int *out);
JSBool jsval_to_long( JSContext *cx, jsval vp, long *out);
JSBool jsval_to_longlong( JSContext *cx, jsval vp, long long *out);	
	
/** converts a jsval to a block (1 == receives 1 argument (sender) ) */
JSBool jsval_to_block_1( JSContext *cx, jsval vp, JSObject *jsthis, js_block *out  );

/** converts a jsval to a block (2 == receives 2 argument (sender + custom) ) */
JSBool jsval_to_block_2( JSContext *cx, jsval vp, JSObject *jsthis, jsval arg, js_block *out  );

	
jsval int_to_jsval( JSContext *cx, int l);
jsval long_to_jsval( JSContext *cx, long l);
jsval longlong_to_jsval( JSContext *cx, long long l);
jsval CGPoint_to_jsval( JSContext *cx, CGPoint p );
jsval CGSize_to_jsval( JSContext *cx, CGSize s);
jsval CGRect_to_jsval( JSContext *cx, CGRect r);
jsval NSArray_to_jsval( JSContext *cx, NSArray *array);
jsval NSSet_to_jsval( JSContext *cx, NSSet *set);
jsval opaque_to_jsval( JSContext *cx, void* opaque);

#ifdef JSB_USE_COCOS2D
JSBool jsval_to_ccGridSize( JSContext *cx, jsval vp, ccGridSize *ret );
jsval ccGridSize_to_jsval( JSContext *cx, ccGridSize p );
#endif // JSB_USE_COCOS2D

	
#ifdef __cplusplus
}
#endif

#define cpVect_to_jsval CGPoint_to_jsval
#define jsval_to_cpVect jsval_to_CGPoint
