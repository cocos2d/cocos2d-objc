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

#ifndef __js_bindings_chipmunk_manual
#define __js_bindings_chipmunk_manual

#import "js_bindings_config.h"
#ifdef JSB_INCLUDE_CHIPMUNK

#include "chipmunk.h"
#include "jsapi.h"

JSBool JSB_cpSpaceAddCollisionHandler(JSContext *cx, uint32_t argc, jsval *vp);
JSBool JSB_cpSpaceRemoveCollisionHandler(JSContext *cx, uint32_t argc, jsval *vp);

JSBool JSB_cpArbiterGetBodies(JSContext *cx, uint32_t argc, jsval *vp);
JSBool JSB_cpArbiterGetShapes(JSContext *cx, uint32_t argc, jsval *vp);

JSBool JSB_cpBodyGetUserData(JSContext *cx, uint32_t argc, jsval *vp);
JSBool JSB_cpBodySetUserData(JSContext *cx, uint32_t argc, jsval *vp);


// convertions

JSBool jsval_to_cpBB( JSContext *cx, jsval vp, cpBB *ret );
jsval cpBB_to_jsval(JSContext *cx, cpBB bb );

// requires cocos2d
#define cpVect_to_jsval CGPoint_to_jsval
#define jsval_to_cpVect jsval_to_CGPoint

#endif // JSB_INCLUDE_CHIPMUNK

#endif // __js_bindings_chipmunk_manual
