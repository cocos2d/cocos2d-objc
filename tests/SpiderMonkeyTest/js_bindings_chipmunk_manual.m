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
#import "uthash.h"

#pragma mark - Collision Handler

struct collision_handler {
	cpCollisionType		typeA;
	cpCollisionType		typeB;
	jsval				begin;
	jsval				pre;
	jsval				post;
	jsval				separate;
	JSObject			*this;
	JSContext			*cx;

	unsigned long		hash_key;
	UT_hash_handle  hh;
};

// hash
struct collision_handler* collision_handler_hash = NULL;

// helper pair
static unsigned long pair_ints( unsigned long A, unsigned long B )
{
	// order is not important
	unsigned long k1 = MIN(A, B );
	unsigned long k2 = MAX(A, B );
	
	return (k1 + k2) * (k1 + k2 + 1) /2 + k2;
}

static cpBool myCollisionBegin(cpArbiter *arb, cpSpace *space, void *data)
{
	struct collision_handler *handler = (struct collision_handler*) data;
	
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
	struct collision_handler *handler = (struct collision_handler*) data;
	
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
	struct collision_handler *handler = (struct collision_handler*) data;
	
	jsval args[2];
	args[0] = opaque_to_jsval( handler->cx, arb);
	args[1] = opaque_to_jsval( handler->cx, space );
	
	jsval ignore;
	JS_CallFunctionValue( handler->cx, handler->this, handler->post, 2, args, &ignore);
}

static void myCollisionSeparate(cpArbiter *arb, cpSpace *space, void *data)
{
	struct collision_handler *handler = (struct collision_handler*) data;
	
	jsval args[2];
	args[0] = opaque_to_jsval( handler->cx, arb);
	args[1] = opaque_to_jsval( handler->cx, space );
	
	jsval ignore;
	JS_CallFunctionValue( handler->cx, handler->this, handler->separate, 2, args, &ignore);
}

JSBool JSPROXY_cpSpaceAddCollisionHandler(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION( argc==8, "Invalid number of arguments");

	jsval *argvp = JS_ARGV(cx,vp);

	struct collision_handler *handler = malloc( sizeof(*handler) );
	if( ! handler )
		return JS_FALSE;
	
	JSBool ok = JS_TRUE;

	// args
	cpSpace *space;
	ok &= jsval_to_opaque( cx, *argvp++, (void**)&space);
	ok &= jsval_to_int(cx, *argvp++, (int32_t*) &handler->typeA );
	ok &= jsval_to_int(cx, *argvp++, (int32_t*) &handler->typeB );
	

	ok &= JS_ValueToObject(cx, *argvp++, &handler->this );

	handler->begin =  *argvp++;
	handler->pre = *argvp++;
	handler->post = *argvp++;
	handler->separate = *argvp++;

	if( ! ok )
		return JS_FALSE;
		
	handler->cx = cx;
	
	cpSpaceAddCollisionHandler(space, handler->typeA, handler->typeB,
							   JSVAL_IS_NULL(handler->begin) ? NULL : &myCollisionBegin,
							   JSVAL_IS_NULL(handler->pre) ? NULL : &myCollisionPre,
							   JSVAL_IS_NULL(handler->post) ? NULL : &myCollisionPost,
							   JSVAL_IS_NULL(handler->separate) ? NULL : &myCollisionSeparate,
							   handler );
	

	//
	// Already added ? If so, remove it.
	// Then add new entry
	//
	struct collision_handler *hashElement = NULL;
	unsigned long paired_key = pair_ints(handler->typeA, handler->typeB );
	HASH_FIND_INT(collision_handler_hash, &paired_key, hashElement);
    if( hashElement ) {
		HASH_DEL( collision_handler_hash, hashElement );
		free( hashElement );
	}

	handler->hash_key = paired_key;
	HASH_ADD_INT( collision_handler_hash, hash_key, handler );

		
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

JSBool JSPROXY_cpSpaceRemoveCollisionHandler(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION( argc==3, "Invalid number of arguments");
	
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	
	cpSpace* space;
	cpCollisionType typeA;
	cpCollisionType typeB;
	ok &= jsval_to_opaque( cx, *argvp++, (void**)&space);
	ok &= jsval_to_int(cx, *argvp++, (int32_t*) &typeA );
	ok &= jsval_to_int(cx, *argvp++, (int32_t*) &typeB );
	
	if( ! ok )
		return JS_FALSE;

	cpSpaceRemoveCollisionHandler(space, typeA, typeB );
	
	// Remove it
	struct collision_handler *hashElement = NULL;
	unsigned long key = pair_ints(typeA, typeB );
	HASH_FIND_INT(collision_handler_hash, &key, hashElement);
    if( hashElement ) {
		HASH_DEL( collision_handler_hash, hashElement );
		free( hashElement );
	}
	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

#pragma mark - Arbiter

JSBool JSPROXY_cpArbiterGetBodies(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION( argc==1, "Invalid number of arguments");
	
	jsval *argvp = JS_ARGV(cx,vp);
	
	cpArbiter* arbiter;
	if( ! jsval_to_opaque( cx, *argvp++, (void*)&arbiter ) )
		return JS_FALSE;

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
	JSB_PRECONDITION( argc==1, "Invalid number of arguments");
	
	jsval *argvp = JS_ARGV(cx,vp);
	
	cpArbiter* arbiter;
	if( ! jsval_to_opaque( cx, *argvp++, (void**) &arbiter ) )
	   return JS_FALSE;
	
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

JSBool JSPROXY_cpBodyGetUserData(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION( argc==1, "Invalid number of arguments");

	jsval *argvp = JS_ARGV(cx,vp);
	cpBody *body;
	if( ! jsval_to_opaque( cx, *argvp++, (void**) &body ) )
		return JS_FALSE;

	JSObject *data = (JSObject*) cpBodyGetUserData(body);
	
	
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(data));
	
	return JS_TRUE;
}

JSBool JSPROXY_cpBodySetUserData(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION( argc==2, "Invalid number of arguments");

	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	
	cpBody *body;
	JSObject *jsobj;
	
	ok &=jsval_to_opaque( cx, *argvp++, (void**) &body );
	ok &=JS_ValueToObject(cx, *argvp++, &jsobj);
	
	if( ! ok )
		return JS_FALSE;
	
	cpBodySetUserData(body, jsobj );
	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	
	return JS_TRUE;
}
