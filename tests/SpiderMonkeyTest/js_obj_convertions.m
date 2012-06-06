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

#import "ScriptingCore.h"
#import "js_bindings_NSObject.h"


JSObject* create_jsobject_from_realobj( Class klass,id realObj, JSContext* context )
{
	NSString *proxied_class = [NSString stringWithFormat:@"JSPROXY_%@", klass];
	Class class = NSClassFromString(proxied_class);
	if( class )
		return [class createJSObjectWithRealObject:realObj context:context];

	CCLOGWARN(@"Proxied class not found: %@. Trying with parent class", proxied_class );
	return create_jsobject_from_realobj([klass superclass], realObj, context );
}

JSObject * get_or_create_jsobject_from_realobj( id realObj, JSContext *cx )
{
	JSPROXY_NSObject *proxy = objc_getAssociatedObject(realObj, &JSPROXY_association_proxy_key );
	if( proxy )
		return [proxy jsObj];
	
	return create_jsobject_from_realobj( [realObj class], realObj, cx );
}


// Convert function
NSString *jsval_to_nsstring(jsval vp, JSContext *cx )
{
	JSString *jsstr = JS_ValueToString( cx, vp );
	return [NSString stringWithUTF8String: JS_EncodeString(cx, jsstr)];
}

id jsval_to_nsobject( jsval vp, JSContext *cx )
{
	JSObject *jsobj;
	JS_ValueToObject( cx, vp, &jsobj );
	JSPROXY_NSObject* proxy = (JSPROXY_NSObject*) JS_GetPrivate( jsobj ); 
	return [proxy realObj];
}

NSMutableArray* jsval_to_nsarray( jsval vp, JSContext *cx )
{
	// Parsing sequence
	JSObject *jsobj;
	JS_ValueToObject( cx, vp, &jsobj );
	
	NSCAssert( JS_IsArrayObject( cx, jsobj), @"Invalid argument. It is not an array" );
	uint32_t len;
	JS_GetArrayLength(cx, jsobj,&len);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:len];
	for( uint32_t i=0; i< len;i++ ) {		
		jsval valarg;
		JS_GetElement(cx, jsobj, i, &valarg);
		
		// XXX: forcing them to be objects, but they could also be NSString, NSDictionary or NSArray
		id real_obj = jsval_to_nsobject( valarg, cx);
		
		[array addObject:real_obj];
	}
	return array;
}
