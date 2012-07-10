//
// cocos2d manually generated bindings
//

#import "js_bindings_config.h"
#import "ScriptingCore.h"

#import "js_bindings_cocos2d_classes.h"
#import "js_manual_conversions.h"


// "setCallback" in JS
JSBool JSPROXY_CCMenuItem_setBlock_( JSContext *cx, uint32_t argc, jsval *vp ) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);
	
	NSCAssert( proxy && [proxy realObj], @"Invalid Proxy object");
	JSB_PRECONDITION( argc == 2, @"Invalid number of arguments. Expecting 2 args" );
	jsval *argvp = JS_ARGV(cx,vp);
	js_block js_func;
	JSObject *js_this;
	JSBool ok;

	js_this= JSVAL_TO_OBJECT( *argvp++);	
	ok = jsval_to_block_1( cx, *argvp++, js_this, &js_func );
	
	if( ! ok )
		return JS_FALSE;

	CCMenuItem *real = (CCMenuItem*) [proxy realObj];

	[real setBlock:(void(^)(id sender))js_func];
	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);

	return JS_TRUE;
}

// "create" in JS
JSBool JSPROXY_CCMenuItemFont_itemWithString_block__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc ==1 || argc == 3, @"Invalid number of arguments. Expecting 1 or 3 args" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	NSString *normal;
	js_block js_func;
	JSObject *js_this;
	
	ok &= jsval_to_nsstring( cx, *argvp++, &normal );
		
	// cannot merge with previous if() since argvp needs to be incremented
	if( argc ==3 ) {
		// this
		js_this= JSVAL_TO_OBJECT( *argvp++);
		
		// function
		ok &= jsval_to_block_1( cx, *argvp++, js_this, &js_func );
	}
	
	CCMenuItemFont *ret_val;
	
	if( argc == 1 )
		ret_val = [CCMenuItemFont itemWithString:normal];
	else if (argc ==3 )
		ret_val = [CCMenuItemFont itemWithString:normal block:(void(^)(id sender))js_func];
	
	JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
	return JS_TRUE;
}

// "create" in JS
JSBool JSPROXY_CCMenuItemLabel_itemWithLabel_block__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc ==1 || argc == 3, @"Invalid number of arguments. Expecting 1 or 3 args" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	CCNode<CCLabelProtocol, CCRGBAProtocol> *label;
	js_block js_func;
	JSObject *js_this;
	
	ok &= jsval_to_nsobject( cx, *argvp++, &label );
	
	// cannot merge with previous if() since argvp needs to be incremented
	if( argc ==3 ) {
		// this
		js_this= JSVAL_TO_OBJECT( *argvp++);
		
		// function
		ok &= jsval_to_block_1( cx, *argvp++, js_this, &js_func );
	}
	
	CCMenuItemLabel *ret_val;
	
	if( argc == 1 )
		ret_val = [CCMenuItemLabel itemWithLabel:label];
	else if (argc ==3 )
		ret_val = [CCMenuItemLabel itemWithLabel:label block:(void(^)(id sender))js_func];
	
	JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
	return JS_TRUE;
}

// "create" in JS
JSBool JSPROXY_CCMenuItemImage_itemWithNormalImage_selectedImage_disabledImage_block__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc >=2 && argc <= 5, @"Invalid number of arguments. Expecting: 2 <= args <= 5" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	NSString *normal, *selected, *disabled;
	js_block js_func;
	JSObject *js_this;
	
	ok &= jsval_to_nsstring( cx, *argvp++, &normal );
	
	if( argc >= 2 )
		ok &= jsval_to_nsstring( cx, *argvp++, &selected );

	if( argc == 3 || argc == 5)
		ok &= jsval_to_nsstring( cx, *argvp++, &disabled );


	// cannot merge with previous if() since argvp needs to be incremented
	if( argc >=4 ) {
		// this
		js_this= JSVAL_TO_OBJECT( *argvp++);

		// function
		ok &= jsval_to_block_1( cx, *argvp++, js_this, &js_func );
	}

	CCMenuItemImage *ret_val;
		
	if( argc == 2 )
		ret_val = [CCMenuItemImage itemWithNormalImage:normal selectedImage:selected];
	else if (argc ==3 )
		ret_val = [CCMenuItemImage itemWithNormalImage:normal selectedImage:selected disabledImage:disabled];
	else if (argc == 4 )
		ret_val = [CCMenuItemImage itemWithNormalImage:normal selectedImage:selected block:(void(^)(id sender))js_func];
	else if (argc == 5 )
		ret_val = [CCMenuItemImage itemWithNormalImage:normal selectedImage:selected disabledImage:disabled block:(void(^)(id sender))js_func];

	JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
	return JS_TRUE;
}

// "create" in JS
JSBool JSPROXY_CCMenuItemSprite_itemWithNormalSprite_selectedSprite_disabledSprite_block__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc >=2 && argc <= 5 && argc != 3, @"Invalid number of arguments. 2 <= args <= 5 but not 3" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	CCSprite *normal, *selected, *disabled;
	js_block js_func;
	JSObject *js_this;
	
	ok &= jsval_to_nsobject( cx, *argvp++, &normal );
	
	if( argc >= 2 )
		ok &= jsval_to_nsobject( cx, *argvp++, &selected );
	
	if( argc == 5 )
		ok &= jsval_to_nsobject( cx, *argvp++, &disabled );
	
	
	// cannot merge with previous if() since argvp needs to be incremented
	if( argc >=4 ) {
		// this
		js_this= JSVAL_TO_OBJECT( *argvp++);
		
		// function
		ok &= jsval_to_block_1( cx, *argvp++, js_this, &js_func );
	}
	
	CCMenuItemImage *ret_val;
	
	if( argc == 2 )
		ret_val = [CCMenuItemSprite itemWithNormalSprite:normal selectedSprite:selected];
	else if (argc == 4 )
		ret_val = [CCMenuItemSprite itemWithNormalSprite:normal selectedSprite:selected block:(void(^)(id sender))js_func];
	else if (argc == 5 )
		ret_val = [CCMenuItemSprite itemWithNormalSprite:normal selectedSprite:selected disabledSprite:disabled block:(void(^)(id sender))js_func];
	
	JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
	return JS_TRUE;
}

JSBool JSPROXY_CCCallBlockN_actionWithBlock__static(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION( argc == 2 || argc == 3,  @"Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	js_block js_func;
	JSObject *js_this;
	
	// this
	js_this= JSVAL_TO_OBJECT( *argvp++);
	
	NSObject *ret_val;
	if( argc == 2 ) {
		// function
		ok &= jsval_to_block_1( cx, *argvp++, js_this, &js_func );
		if( ! ok )
			return JS_FALSE;
	
		ret_val = [CCCallBlockN actionWithBlock:js_func];
	} else if( argc == 3 ) {

		jsval func = *argvp++;
		jsval arg = *argvp++;
		ok &= jsval_to_block_2( cx, func, js_this, arg, &js_func );
		if( ! ok )
			return JS_FALSE;

		ret_val = [CCCallBlockN actionWithBlock:js_func];
	}
		
	JSObject *jsobj = get_or_create_jsobject_from_realobj( cx, ret_val );
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));
	
	return JS_TRUE;	
}
