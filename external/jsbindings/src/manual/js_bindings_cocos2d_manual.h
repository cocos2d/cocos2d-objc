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

#ifdef JSB_INCLUDE_COCOS2D
#import "cocos2d.h"

JSBool jsval_to_ccGridSize( JSContext *cx, jsval vp, ccGridSize *ret );
jsval ccGridSize_to_jsval( JSContext *cx, ccGridSize p );
JSBool jsval_to_ccColor3B( JSContext *cx, jsval vp, ccColor3B *ret );
JSBool jsval_to_ccColor4B( JSContext *cx, jsval vp, ccColor4B *ret );
JSBool jsval_to_ccColor4F( JSContext *cx, jsval vp, ccColor4F *ret );
jsval ccColor3B_to_jsval( JSContext *cx, ccColor3B p );
jsval ccColor4B_to_jsval( JSContext *cx, ccColor4B p );
jsval ccColor4F_to_jsval( JSContext *cx, ccColor4F p );

#endif // JSB_INCLUDE_COCOS2D
