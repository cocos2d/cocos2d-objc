//
// cocos2d manually generated bindings
//

#import "js_bindings_config.h"
#import "ScriptingCore.h"

#import "js_bindings_cocos2d_classes.h"
#import "js_manual_conversions.h"


JSBool JSPROXY_CCMenuItemImage_itemWithNormalImage_selectedImage_disabledImage_block__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc >=2 && argc <= 6, @"Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	NSString *normal, *selected, *disabled;
	js_block js_func;
	JSObject *js_this;
	
	ok &= jsval_to_nsstring( cx, *argvp++, &normal );
	
	if( argc >= 2 )
		ok &= jsval_to_nsstring( cx, *argvp++, &selected );

	if( argc == 3 )
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
