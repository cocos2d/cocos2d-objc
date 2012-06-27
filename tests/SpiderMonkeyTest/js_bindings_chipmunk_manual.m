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


#import "js_bindings_chipmunk_manual.h"
#import "jsapi.h"
#import "js_manual_conversions.h"

#pragma mark - Collision Handler

struct collision_data {
	cpCollisionType		typeA;
	cpCollisionType		typeB;
	jsval				begin;
	jsval				pre;
	jsval				post;
	jsval				separate;
	JSObject			*this;
	JSContext			*cx;
};


static cpBool myCollisionBegin(cpArbiter *arb, cpSpace *space, void *data)
{
	struct collision_data *handler = (struct collision_data*) data;
	
	jsval args[2];
	args[0] = opaque_to_jsval( handler->cx, arb);
	args[1] = opaque_to_jsval( handler->cx, space );
	
	jsval rval;
	JS_CallFunctionValue( handler->cx, handler->this, handler->begin, 2, args, &rval);
	
	if( JSVAL_IS_BOOLEAN(rval) ) {
		JSBool ret = JSVAL_TO_BOOLEAN(rval);
		return (cpBool)ret;
	}
	return cpTrue;	
}

static cpBool myCollisionPre(cpArbiter *arb, cpSpace *space, void *data)
{
	struct collision_data *handler = (struct collision_data*) data;
	
	jsval args[2];
	args[0] = opaque_to_jsval( handler->cx, arb);
	args[1] = opaque_to_jsval( handler->cx, space );
	
	jsval rval;
	JS_CallFunctionValue( handler->cx, handler->this, handler->pre, 2, args, &rval);
	
	if( JSVAL_IS_BOOLEAN(rval) ) {
		JSBool ret = JSVAL_TO_BOOLEAN(rval);
		return (cpBool)ret;
	}
	return cpTrue;	
}

static void myCollisionPost(cpArbiter *arb, cpSpace *space, void *data)
{
	struct collision_data *handler = (struct collision_data*) data;
	
	jsval args[2];
	args[0] = opaque_to_jsval( handler->cx, arb);
	args[1] = opaque_to_jsval( handler->cx, space );
	
	jsval ignore;
	JS_CallFunctionValue( handler->cx, handler->this, handler->post, 2, args, &ignore);
}

static void myCollisionSeparate(cpArbiter *arb, cpSpace *space, void *data)
{
	struct collision_data *handler = (struct collision_data*) data;
	
	jsval args[2];
	args[0] = opaque_to_jsval( handler->cx, arb);
	args[1] = opaque_to_jsval( handler->cx, space );
	
	jsval ignore;
	JS_CallFunctionValue( handler->cx, handler->this, handler->separate, 2, args, &ignore);
}

JSBool JSPROXY_cpSpaceAddCollisionHandler(JSContext *cx, uint32_t argc, jsval *vp)
{
	if( argc != 8 )
		return JS_FALSE;

	jsval *argvp = JS_ARGV(cx,vp);

	//
	// XXX MEMORY LEAK
	//
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
	handler->this = JSVAL_TO_OBJECT(*argvp++);
		
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

#pragma mark - Arbiter

JSBool JSPROXY_cpArbiterGetBodies(JSContext *cx, uint32_t argc, jsval *vp)
{
	if( argc != 1 )
		return  JS_FALSE;
	
	jsval *argvp = JS_ARGV(cx,vp);
	
	cpArbiter* arbiter = (cpArbiter*) jsval_to_opaque( cx, *argvp++ );

	cpBody *bodyA;
	cpBody *bodyB;
	cpArbiterGetBodies(arbiter, &bodyA, &bodyB);
	jsval valA = opaque_to_jsval(cx, bodyA);
	jsval valB = opaque_to_jsval(cx, bodyB);
	
	JSObject *jsobj = JS_NewArrayObject(cx, 2, NULL);
	JS_SetElement(cx, jsobj, 0, &valA);
	JS_SetElement(cx, jsobj, 1, &valB);

	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
	return JS_TRUE;
	
}

JSBool JSPROXY_cpArbiterGetShapes(JSContext *cx, uint32_t argc, jsval *vp)
{
	if( argc != 1 )
		return  JS_FALSE;
	
	jsval *argvp = JS_ARGV(cx,vp);
	
	cpArbiter* arbiter = (cpArbiter*) jsval_to_opaque( cx, *argvp++ );
	
	cpShape *shapeA;
	cpShape *shapeB;
	cpArbiterGetShapes(arbiter, &shapeA, &shapeB);
	jsval valA = opaque_to_jsval(cx, shapeA);
	jsval valB = opaque_to_jsval(cx, shapeB);
	
	JSObject *jsobj = JS_NewArrayObject(cx, 2, NULL);
	JS_SetElement(cx, jsobj, 0, &valA);
	JS_SetElement(cx, jsobj, 1, &valB);
	
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
	return JS_TRUE;
}


