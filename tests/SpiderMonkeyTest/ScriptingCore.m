//
//  ScriptingCore.cpp
//  testmonkey
//
//  Created by Rolando Abarca on 3/14/12.
//  Copyright (c) 2012 Zynga Inc. All rights reserved.
//

#include "cocos2d.h"
#include "ScriptingCore.h"

static JSClass global_class = {
	"global", JSCLASS_GLOBAL_FLAGS,
	JS_PropertyStub, JS_PropertyStub, JS_PropertyStub, JS_StrictPropertyStub,
	JS_EnumerateStub, JS_ResolveStub, JS_ConvertStub, JS_FinalizeStub,
	JSCLASS_NO_OPTIONAL_MEMBERS
};

#pragma mark ScriptingCore - Helper free functions
static void reportError(JSContext *cx, const char *message, JSErrorReport *report)
{
	fprintf(stderr, "%s:%u:%s\n",  
			report->filename ? report->filename : "<no filename=\"filename\">",  
			(unsigned int) report->lineno,  
			message);
};

#pragma mark ScriptingCore - Free JS functions

static JSBool log(JSContext *cx, uint32_t argc, jsval *vp)
{
	if (argc > 0) {
		JSString *string = NULL;
		JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "S", &string);
		if (string) {
			char *cstr = JS_EncodeString(cx, string);
			cocos2d::CCLog(cstr);
		}
	}
	return JS_TRUE;
};

static JSBool executeScript(JSContext *cx, uint32_t argc, jsval *vp)
{
	if (argc == 1) {
		JSString *string;
		if (JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "S", &string) == JS_TRUE) {
			ScriptingCore::getInstance().runScript(JS_EncodeString(cx, string));
		}
	}
	return JS_TRUE;
};


@implementation ScriptingCore

-(id) init
{
	self = [super init];
	if( self ) {

		_rt = JS_NewRuntime(8 * 1024 * 1024);
		_cx = JS_NewContext( _rt, 8192);
		JS_SetOptions(_cx, JSOPTION_VAROBJFIX);
		JS_SetVersion(_cx, JSVERSION_LATEST);
		JS_SetErrorReporter(_cx, reportError);
		_object = JS_NewCompartmentAndGlobalObject( _cx, &global_class, NULL);
		if (!JS_InitStandardClasses( _cx, _object)) {
			CCLOGWARN(@"js error");
		}
		// create the cocos namespace
		JSObject *cocos = JS_NewObject( _cx, NULL, NULL, NULL);
		jsval cocosVal = OBJECT_TO_JSVAL(cocos);
		JS_SetProperty(_cx, _object, "cocos", &cocosVal);
					  
					  
	  // register some global functions
	  JS_DefineFunction(_cx, cocos, "log", log, 0, JSPROP_READONLY | JSPROP_PERMANENT);
	  JS_DefineFunction(_cx, cocos, "executeScript", executeScript, 1, JSPROP_READONLY | JSPROP_PERMANENT);
	  JS_DefineFunction(_cx, cocos, "addGCRootObject", ScriptingCore::addRootJS, 1, JSPROP_READONLY | JSPROP_PERMANENT);
	  JS_DefineFunction(_cx, cocos, "removeGCRootObject", ScriptingCore::removeRootJS, 1, JSPROP_READONLY | JSPROP_PERMANENT);
	  JS_DefineFunction(_cx, cocos, "forceGC", ScriptingCore::forceGC, 0, JSPROP_READONLY | JSPROP_PERMANENT);
	}
	
	return self;
}



-(BOOL) evalString(NSString*)string outval:(jsval*)outVal
{
	jsval rval;
	JSString *str;
	JSBool ok;
	const char *filename = "noname";
	uint32_t lineno = 0;
	if (outVal == NULL) {
		outVal = &rval;
	}
	ok = JS_EvaluateScript( _cx, _object, [string UTF8Char], strlen([string UTF8Char]), filename, lineno, outVal);
	if (ok == JS_FALSE) {
		CCLog("error evaluating script:\n%s", string);
	}
	str = JS_ValueToString(cx, rval);
	return ok;
}

-(void) runScript:(NSString*)filename
{
#ifdef DEBUG
	/**
	 * dpath should point to the parent directory of the "JS" folder. If this is
	 * set to "" (as it is now) then it will take the scripts from the app bundle.
	 * By setting the absolute path you can iterate the development only by
	 * modifying those scripts and reloading from the simulator (no recompiling/
	 * relaunching)
	 */
//	std::string dpath("/Users/rabarca/Desktop/testjs/testjs/");
//	std::string dpath("");
//	dpath += path;
	NSString fullpath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename];
#else
	NSString fullpath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename];
#endif
	unsigned char *content = NULL;
	size_t contentSize = CCFileUtils::ccLoadFileIntoMemory(realPath, &content);
	if (content && contentSize) {
		JSBool ok;
		jsval rval;
		ok = JS_EvaluateScript(this->cx, this->global, (char *)content, contentSize, path, 1, &rval);
		if (ok == JS_FALSE) {
			CCLog("error evaluating script:\n%s", content);
		}
		free(content);
	}
}

-(void) dealloc
{
	[super dealloc];

	JS_DestroyContext(_cx);
	JS_DestroyRuntime(_rt);
	JS_ShutDown();
}
