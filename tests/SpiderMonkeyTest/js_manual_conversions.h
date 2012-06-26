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

#ifdef __cplusplus
extern "C" {
#endif

typedef void (^js_block)(id sender);
	
/** Creates a JSObject, a ProxyObject and associates them with the real object */
JSObject* create_jsobject_from_realobj( JSContext* context, Class klass, id realObj );

/** Gets or Creates a JSObject, a ProxyObject and associates them with the real object */
JSObject * get_or_create_jsobject_from_realobj( JSContext *cx, id realObj);

/** converts a jsval to a NSString */
NSString *jsval_to_nsstring( JSContext *cx , jsval vp );

/** converts a jsval to a NSObject */
id jsval_to_nsobject( JSContext *cx, jsval vp );

/** converts a jsval to a NSArray */
NSArray* jsval_to_nsarray( JSContext *cx , jsval vp );

/** converts a variadic jsvals to a NSArray */
NSArray* jsvals_variadic_to_nsarray( JSContext *cx, jsval *vp, int argc );
	
	
CGPoint jsval_to_CGPoint( JSContext *cx, jsval vp );
CGSize jsval_to_CGSize( JSContext *cx, jsval vp );
CGRect jsval_to_CGRect( JSContext *cx, jsval vp );
void * jsval_to_opaque( JSContext *cx, jsval vp );
int jsval_to_int( JSContext *cx, jsval vp);
long jsval_to_long( JSContext *cx, jsval vp);
long long jsval_to_longlong( JSContext *cx, jsval vp);	
	
/** converts a jsval to a block */
js_block jsval_to_block( JSContext *cx, jsval vp, JSObject *jsthis );

jsval int_to_jsval( JSContext *cx, int l);
jsval long_to_jsval( JSContext *cx, long l);
jsval longlong_to_jsval( JSContext *cx, long long l);
jsval CGPoint_to_jsval( JSContext *cx, CGPoint p );
jsval CGSize_to_jsval( JSContext *cx, CGSize s);
jsval CGRect_to_jsval( JSContext *cx, CGRect r);
jsval NSArray_to_jsval( JSContext *cx, NSArray *array);
jsval opaque_to_jsval( JSContext *cx, void* opaque);
	
	
#ifdef __cplusplus
}
#endif

#define cpVect_to_jsval CGPoint_to_jsval
#define jsval_to_cpVect jsval_to_CGPoint
