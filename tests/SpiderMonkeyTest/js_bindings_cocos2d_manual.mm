//
// cocos2d manually generated bindings
//

#import "jsfriendapi.h"

#import "js_bindings_config.h"
#import "ScriptingCore.h"

#import "js_bindings_cocos2d_classes.h"
#import "js_manual_conversions.h"


// "setCallback" in JS
JSBool JSPROXY_CCMenuItem_setBlock_( JSContext *cx, uint32_t argc, jsval *vp ) {
	
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);
	
	NSCAssert( proxy && [proxy realObj], @"Invalid Proxy object");
	JSB_PRECONDITION( argc == 2, "Invalid number of arguments. Expecting 2 args" );
	jsval *argvp = JS_ARGV(cx,vp);
	js_block js_func;
	JSObject *js_this;
	JSBool ok;

	ok &= JS_ValueToObject(cx, *argvp++, &js_this);
	ok &= jsval_to_block_1( cx, *argvp++, js_this, &js_func );
	
	if( ! ok )
		return JS_FALSE;

	CCMenuItem *real = (CCMenuItem*) [proxy realObj];

	[real setBlock:(void(^)(id sender))js_func];
	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);

	return JS_TRUE;
}

// "create" in JS
JSBool JSPROXY_CCMenuItemFont_itemWithString_block__static(JSContext *cx, uint32_t argc, jsval *vp) {
	JSB_PRECONDITION( argc ==1 || argc == 3, "Invalid number of arguments. Expecting 1 or 3 args" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	NSString *normal;
	js_block js_func;
	JSObject *js_this;
	
	ok &= jsval_to_nsstring( cx, *argvp++, &normal );
		
	// cannot merge with previous if() since argvp needs to be incremented
	if( argc ==3 ) {
		// this
		ok &= JS_ValueToObject(cx, *argvp++, &js_this);
		
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
	JSB_PRECONDITION( argc ==1 || argc == 3, "Invalid number of arguments. Expecting 1 or 3 args" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	CCNode<CCLabelProtocol, CCRGBAProtocol> *label;
	js_block js_func;
	JSObject *js_this;
	
	ok &= jsval_to_nsobject( cx, *argvp++, &label );
	
	// cannot merge with previous if() since argvp needs to be incremented
	if( argc ==3 ) {
		// this
		ok &= JS_ValueToObject(cx, *argvp++, &js_this);
		
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
	JSB_PRECONDITION( argc >=2 && argc <= 5, "Invalid number of arguments. Expecting: 2 <= args <= 5" );
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
		ok &= JS_ValueToObject(cx, *argvp++, &js_this);

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
	JSB_PRECONDITION( argc >=2 && argc <= 5 && argc != 3, "Invalid number of arguments. 2 <= args <= 5 but not 3" );
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
		ok &= JS_ValueToObject(cx, *argvp++, &js_this);
		
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
	JSB_PRECONDITION( argc == 2 || argc == 3,  "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	js_block js_func;
	JSObject *js_this;
	
	// this
	ok &= JS_ValueToObject(cx, *argvp++, &js_this);
	
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

JSBool JSPROXY_CCTexture2D_setTexParameters_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);
	
	NSCAssert( proxy && [proxy realObj], @"Invalid Proxy object");
	JSB_PRECONDITION( argc == 4, "Invalid number of arguments. Expecting 4 args" );

	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;

	GLint arg0, arg1, arg2, arg3;
	
	ok &= JS_ValueToInt32(cx, *argvp++, &arg0);
	ok &= JS_ValueToInt32(cx, *argvp++, &arg1);
	ok &= JS_ValueToInt32(cx, *argvp++, &arg2);
	ok &= JS_ValueToInt32(cx, *argvp++, &arg3);
	
	if( ! ok )
		return JS_FALSE;
	
	ccTexParams param = { arg0, arg1, arg2, arg3 };

	CCTexture2D *real = (CCTexture2D*) [proxy realObj];
	[real setTexParameters:&param];

	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	
	return JS_TRUE;		
}

// Arguments: Array of points, fill color (ccc4f), width(float), border color (ccc4f)
// Ret value: void
JSBool JSPROXY_CCDrawNode_drawPolyWithVerts_count_fillColor_borderWidth_borderColor_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(obj);
	
	NSCAssert( proxy && [proxy realObj], @"Invalid Proxy object");
	JSB_PRECONDITION( argc == 4, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	JSObject *argArray; ccColor4F argFillColor; double argWidth; ccColor4F argBorderColor; 
	
	ok &= JS_ValueToObject(cx, *argvp++, &argArray);
	if( ! (argArray && JS_IsArrayObject(cx, argArray) ) )
	   return JS_FALSE;
	
	JSObject *tmp_arg;
	ok &= JS_ValueToObject( cx, *argvp++, &tmp_arg );
	argFillColor = *(ccColor4F*)JS_GetArrayBufferViewData( tmp_arg, cx );

	ok &= JS_ValueToNumber( cx, *argvp++, &argWidth );
	
	ok &= JS_ValueToObject( cx, *argvp++, &tmp_arg );
	argBorderColor = *(ccColor4F*)JS_GetArrayBufferViewData( tmp_arg, cx );

	if( ! ok )
		return JS_FALSE;
	
	{
		uint32_t l;
		if( ! JS_GetArrayLength(cx, argArray, &l) )
			return JS_FALSE;
		
		CGPoint verts[ l ];
		CGPoint p;

		for( int i=0; i<l; i++ ) {
			jsval pointvp;
			if( ! JS_GetElement(cx, argArray, i, &pointvp) )
				return JS_FALSE;
			if( ! jsval_to_CGPoint(cx, pointvp, &p) )
				continue;
			
			verts[i] = p;
		}
		
		CCDrawNode *real = (CCDrawNode*) [proxy realObj];
		[real drawPolyWithVerts:verts count:l fillColor:argFillColor borderWidth:argWidth borderColor:argBorderColor];
	}
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;	
}

// this, func, [interval], [repeat], [delay]
JSBool JSPROXY_CCNode_schedule_interval_repeat_delay_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(jsthis);
	
	NSCAssert( proxy && [proxy realObj], @"Invalid Proxy object");
	JSB_PRECONDITION( argc >=1 && argc <=4, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);

	CCNode *real = (CCNode*) [proxy realObj];
	CCScheduler *scheduler = [real scheduler];
	
	//
	// "function"
	//
	jsval funcval = *argvp++;
	JSFunction *func = JS_ValueToFunction(cx, funcval);
	if(!func)
		return JS_FALSE;

	NSString *key = nil;
	JSString *funcname = JS_GetFunctionId(func);

	// named function
	if( funcname ) {
		char *key_c = JS_EncodeString(cx, funcname);
		key = [NSString stringWithUTF8String:key_c];
	} else {
		// anonymous function
		key = [NSString stringWithFormat:@"anonfunc at %p", func];
	}
	
	void (^block)(ccTime dt) = ^(ccTime dt) {
			
		jsval rval;
		jsval jsdt = DOUBLE_TO_JSVAL(dt);
		
		JS_CallFunctionValue(cx, jsthis, funcval, 1, &jsdt, &rval);
	};
	
	//
	// Interval
	//
	double interval;
	if( argc >= 2 ) {
		if( ! JS_ValueToNumber(cx, *argvp++, &interval ) )
		   return JS_FALSE;
	}

	//
	// repeat
	//
	double repeat;
	if( argc >= 3 ) {
		if( ! JS_ValueToNumber(cx, *argvp++, &repeat ) )
			return JS_FALSE;
	}

	//
	// delay
	//
	double delay;
	if( argc >= 4 ) {
		if( ! JS_ValueToNumber(cx, *argvp++, &delay ) )
			return JS_FALSE;
	}


	if( argc==1)
		[scheduler scheduleBlockForKey:key target:real interval:0 paused:![real isRunning] repeat:kCCRepeatForever delay:0 block:block];
		
	else if (argc == 2 )
		[scheduler scheduleBlockForKey:key target:real interval:interval paused:![real isRunning] repeat:kCCRepeatForever delay:0 block:block];		

	else if (argc == 3 )
		[scheduler scheduleBlockForKey:key target:real interval:interval paused:![real isRunning] repeat:repeat delay:0 block:block];		

	else if( argc == 4 )
		[scheduler scheduleBlockForKey:key target:real interval:interval paused:![real isRunning] repeat:repeat delay:delay block:block];
	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

#pragma mark - setBlendFunc friends
// setBlendFunc
JSBool JSPROXY_CCParticleSystem_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSObject* jsthis = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = get_proxy_for_jsobject(jsthis);
	
	NSCAssert( proxy && [proxy realObj], @"Invalid Proxy object");
	JSB_PRECONDITION( argc==2, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	
	id real = (id) [proxy realObj];
	JSBool ok = JS_TRUE;

	GLenum src, dst;
	
	ok &= JS_ValueToInt32(cx, *argvp++, (int32_t*)&src);
	ok &= JS_ValueToInt32(cx, *argvp++, (int32_t*)&dst);
	
	if( ! ok )
		return JS_FALSE;

	[real setBlendFunc:(ccBlendFunc){src, dst}];
	
	JS_SET_RVAL(cx, vp, JSVAL_VOID);
	return JS_TRUE;
}

JSBool JSPROXY_CCSprite_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSPROXY_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSPROXY_CCSpriteBatchNode_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSPROXY_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSPROXY_CCMotionStreak_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSPROXY_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSPROXY_CCDrawNode_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSPROXY_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSPROXY_CCAtlasNode_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSPROXY_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}

JSBool JSPROXY_CCParticleBatchNode_setBlendFunc_(JSContext *cx, uint32_t argc, jsval *vp)
{
	return JSPROXY_CCParticleSystem_setBlendFunc_(cx, argc, vp);
}
