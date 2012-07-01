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
#import "js_manual_conversions.h"

@interface JSPROXY_NSObject : NSObject
{
	JSObject	*_jsObj;
	id			_realObj;  // weak ref
	Class		_klass;
}

@property (nonatomic, readwrite, assign) JSObject *jsObj;
@property (nonatomic, readwrite, assign) id	realObj;
@property (nonatomic, readonly) Class klass;

-(id) initWithJSObject:(JSObject*)object class:(Class)klass;
+(JSObject*) createJSObjectWithRealObject:(id)realObj context:(JSContext*)JSContext;
+(void) swizzleMethods;
@end



#ifdef __cplusplus
extern "C" {
#endif
	
void JSPROXY_NSObject_createClass(JSContext* cx, JSObject* globalObj, const char * name );
extern JSObject* JSPROXY_NSObject_object;
extern JSClass* JSPROXY_NSObject_class;

#ifdef __cplusplus
}
#endif

