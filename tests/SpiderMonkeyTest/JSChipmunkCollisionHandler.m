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


#import "JSChipmunkCollisionHandler.h"
#import "jsapi.h"
#import "js_manual_conversions.h"

struct collision_data {
	cpCollisionType		typeA;
	cpCollisionType		typeB;
	jsval				begin;
	jsval				pre;
	jsval				post;
	jsval				separate;
	jsval				data;
	JSObject			*this;
	JSContext			*cx;
};


static cpBool myCollisionBegin(cpArbiter *arb, cpSpace *space, void *data)
{
	struct collision_data *handler = (struct collision_data*) data;
	
	jsval args[3];
	args[0] = opaque_to_jsval( handler->cx, arb);
	args[1] = opaque_to_jsval( handler->cx, space );
	args[2] = handler->data;
	
	jsval rval;
	JS_CallFunctionValue( handler->cx, handler->this, handler->begin, 3, args, &rval);
	
	JSBool ret = JSVAL_TO_BOOLEAN(rval);

	return (cpBool)ret;
}

static cpBool myCollisionPre(cpArbiter *arb, cpSpace *space, void *data)
{
	return cpTrue;
}

static void myCollisionPost(cpArbiter *arb, cpSpace *space, void *data)
{
}

static void myCollisionSeparate(cpArbiter *arb, cpSpace *space, void *data)
{
}

JSBool JSPROXY_cpSpaceAddCollisionHandler(JSContext *cx, uint32_t argc, jsval *vp)
{
	if( argc < 7 || argc > 8 )
		return JS_FALSE;

	jsval *argvp = JS_ARGV(cx,vp);

	struct collision_data *handler = malloc( sizeof(*handler) );
	if( ! handler )
		return JS_FALSE;
	

	// args
	cpSpace* space = (cpSpace*) jsval_to_opaque( cx, *argvp++ );
	handler->typeA = (cpCollisionType) JSVAL_TO_INT( *argvp++ );
	handler->typeB = (cpCollisionType) JSVAL_TO_INT( *argvp++ );
	handler->begin =  *argvp++;
	handler->pre = *argvp++;
	handler->post = *argvp++;
	handler->separate = *argvp++;
	
	if( argc == 8 )
		handler->data = *argvp++;
	else
		handler->data = JSVAL_VOID;
	
	handler->this = JS_THIS_OBJECT(cx, vp);
	handler->cx = cx;
	
	cpSpaceAddCollisionHandler(space, handler->typeA, handler->typeB,
							   JSVAL_IS_NULL(handler->begin) ? NULL : &myCollisionBegin,
							   JSVAL_IS_NULL(handler->pre) ? NULL : &myCollisionPre,
							   JSVAL_IS_NULL(handler->post) ? NULL : &myCollisionPost,
							   JSVAL_IS_NULL(handler->separate) ? NULL : &myCollisionSeparate,
							   handler );
	JS_SET_RVAL(cx, vp, JSVAL_VOID);

	return JS_TRUE;
}

JSBool JSPROXY_cpSpaceRemoveCollisionHandler(JSContext *cx, uint32_t argc, jsval *vp)
{
	if( argc != 3 )
		return  JS_FALSE;
	
	jsval *argvp = JS_ARGV(cx,vp);

	cpSpace* space = (cpSpace*) jsval_to_opaque( cx, *argvp++ );
	cpCollisionType typeA = (cpCollisionType) JSVAL_TO_INT( *argvp++ );
	cpCollisionType typeB = (cpCollisionType) JSVAL_TO_INT( *argvp++ );

	cpSpaceRemoveCollisionHandler(space, typeA, typeB );
	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);

	return JS_TRUE;
}

