//
//  JSCocoa.h
//  JSCocoa
//
//  Created by Patrick Geiller on 09/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#if !TARGET_IPHONE_SIMULATOR && !TARGET_OS_IPHONE
#import <Cocoa/Cocoa.h>
#import <JavaScriptCore/JavaScriptCore.h>
#define MACOSX
#import <ffi/ffi.h>
#endif
#import "BridgeSupportController.h"
#import "JSCocoaPrivateObject.h"
#import "JSCocoaFFIArgument.h"
#import "JSCocoaFFIClosure.h"


// JS context and value container, used by methods to get and return raw Javascript values
//	(No conversion happens)
struct	JSValueRefAndContextRef
{
	JSValueRef		value;
	JSContextRef	ctx;
};
typedef struct	JSValueRefAndContextRef JSValueRefAndContextRef;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import "iPhone/libffi/ffi.h"
#import "iPhone/BurksPool.h"
#endif


//
// JSCocoaController
//
@interface JSCocoaController : NSObject {

	JSGlobalContextRef	ctx;
	BOOL				ownsContext;
    id					_delegate;

	//
	// Split call
	//	Allows calling multi param ObjC messages with a jQuery-like syntax.
	//
	//	obj.do({ this : 'hello', andThat : 'world' })
	//		instead of
	//		obj.dothis_andThat_('hello', 'world')
	//
	BOOL				useSplitCall;

	// JSLint : used for ObjJ syntax, class syntax, return if
	BOOL				useJSLint;
	
	// Auto call zero arg methods : allow NSWorkspace.sharedWorkspace instead of NSWorkspace.sharedWorkspace()
	BOOL				useAutoCall;
	// Allow setting javascript values on boxed objects (which are collected after nulling all references to them)
	BOOL				canSetOnBoxedObjects;
	// Allow calling obj.method(...) instead of obj.method_(...)
	BOOL				callSelectorsMissingTrailingSemicolon;

	// Log all exceptions to NSLog, even if they're caught later by downstream Javascript (in f(g()), log even if f catches after g threw)
	BOOL				logAllExceptions;
	
	//
	// Safe dealloc (For ObjC classes written in Javascript)
	//	- (void)dealloc cannot be overloaded as it is called during JS GC, which forbids new JS code execution.
	//	As the js dealloc method cannot be called, safe dealloc allows it to be executed during the next run loop cycle
	//	NOTE : upon destroying a JSCocoaController, safe dealloc is disabled
	//
	BOOL				useSafeDealloc;

	
	NSMutableDictionary*	boxedObjects;
	
	
}

@property (assign) id delegate;
@property BOOL useSafeDealloc, useSplitCall, useJSLint, useAutoCall, callSelectorsMissingTrailingSemicolon, canSetOnBoxedObjects, logAllExceptions;


- (id)init;
- (id)initWithGlobalContext:(JSGlobalContextRef)ctx;

+ (id)sharedController;
+ (id)controllerFromContext:(JSContextRef)ctx;
+ (BOOL)hasSharedController;
- (JSGlobalContextRef)ctx;
+ (void)hazardReport;
+ (NSString*)runningArchitecture;
+ (void)updateCustomCallPaths;
- (void)accomodateWebKitInspector;

//
// Evaluation
//
- (id)eval:(NSString*)script;
- (id)callFunction:(NSString*)name;
- (id)callFunction:(NSString*)name withArguments:(NSArray*)arguments;
- (BOOL)hasFunction:(NSString*)name;
- (BOOL)isSyntaxValid:(NSString*)script;
- (BOOL)isSyntaxValid:(NSString*)script error:(NSString**)error;

- (BOOL)evalJSFile:(NSString*)path;
- (BOOL)evalJSFile:(NSString*)path toJSValueRef:(JSValueRef*)returnValue;
- (JSValueRef)evalJSString:(NSString*)script;
- (JSValueRef)evalJSString:(NSString*)script withScriptPath:(NSString*)path;
- (JSValueRef)callJSFunction:(JSObjectRef)function withArguments:(NSArray*)arguments;
- (JSValueRef)callJSFunctionNamed:(NSString*)functionName withArguments:arguments, ... NS_REQUIRES_NIL_TERMINATION;
- (JSValueRef)callJSFunctionNamed:(NSString*)functionName withArgumentsArray:(NSArray*)arguments;
- (JSObjectRef)JSFunctionNamed:(NSString*)functionName;
- (BOOL)hasJSFunctionNamed:(NSString*)functionName;

- (JSValueRef)anonEval:(NSString*)script withThis:(JSValueRef)jsThis;
// Arguments are JSValueRefs wrapped in BoxedJSValue
- (JSValueRef)callJSFunction:(JSObjectRef)function withJSValueArray:(NSArray*)args;


- (NSString*)expandJSMacros:(NSString*)script path:(NSString*)path;
- (NSString*)expandJSMacros:(NSString*)script path:(NSString*)path errors:(NSMutableArray*)array;

- (JSObjectRef)setObject:(id)object withName:(NSString*)name;
- (JSObjectRef)setObject:(id)object withName:(NSString*)name attributes:(JSPropertyAttributes)attributes;
- (JSObjectRef)setObjectNoRetain:(id)object withName:(NSString*)name attributes:(JSPropertyAttributes)attributes;
- (id)objectWithName:(NSString*)name;
- (BOOL)removeObjectWithName:(NSString*)name;

// Get ObjC and raw values from Javascript
- (id)unboxJSValueRef:(JSValueRef)jsValue;
- (BOOL)toBool:(JSValueRef)value;
- (double)toDouble:(JSValueRef)value;
- (int)toInt:(JSValueRef)value;
- (NSString*)toString:(JSValueRef)value;
// Wrapper for unboxJSValueRef
- (id)toObject:(JSValueRef)value;

// Convert a native ObjC object (NSNumber, NSString, NSArray, NSDictionary, NSDate) to its JS counterpart
- (JSValueRefAndContextRef)toJS:(id)object;


//
// Framework
//
- (BOOL)loadFrameworkWithName:(NSString*)name;
- (BOOL)loadFrameworkWithName:(NSString*)frameworkName inPath:(NSString*)path;

//
// Garbage collection
//
+ (void)garbageCollect;
- (void)garbageCollect;
- (void)unlinkAllReferences;
+ (void)upJSCocoaPrivateObjectCount;
+ (void)downJSCocoaPrivateObjectCount;
+ (int)JSCocoaPrivateObjectCount;

+ (void)upJSValueProtectCount;
+ (void)downJSValueProtectCount;
+ (int)JSValueProtectCount;

+ (void)logInstanceStats;
- (id)instanceStats;
- (void)logBoxedObjects;

//
// Class inspection (shortcuts to JSCocoaLib)
//
+ (id)rootclasses;
+ (id)classes;
+ (id)protocols;
+ (id)imageNames;
+ (id)methods;
+ (id)runtimeReport;
+ (id)explainMethodEncoding:(id)encoding;

//
// Class handling
//
+ (BOOL)overloadInstanceMethod:(NSString*)methodName class:(Class)class jsFunction:(JSValueRefAndContextRef)valueAndContext;
+ (BOOL)overloadClassMethod:(NSString*)methodName class:(Class)class jsFunction:(JSValueRefAndContextRef)valueAndContext;

+ (BOOL)addClassMethod:(NSString*)methodName class:(Class)class jsFunction:(JSValueRefAndContextRef)valueAndContext encoding:(char*)encoding;
+ (BOOL)addInstanceMethod:(NSString*)methodName class:(Class)class jsFunction:(JSValueRefAndContextRef)valueAndContext encoding:(char*)encoding;

// Tests
- (int)runTests:(NSString*)path;
- (int)runTests:(NSString*)path withSelector:(SEL)sel;

//
// Autorelease pool
//
+ (void)allocAutoreleasePool;
+ (void)deallocAutoreleasePool;

//
// Boxing : each object gets only one box, stored in boxedObjects
//
//+ (JSObjectRef)boxedJSObject:(id)o inContext:(JSContextRef)ctx;
- (JSObjectRef)boxObject:(id)o;
- (BOOL)isObjectBoxed:(id)o;
- (void)deleteBoxOfObject:(id)o;
//+ (void)downBoxedJSObjectCount:(id)o;


//
// Various internals
//
//+ (JSObjectRef)jsCocoaPrivateObjectInContext:(JSContextRef)ctx;
- (JSObjectRef)newPrivateObject;
- (JSObjectRef)newPrivateFunction;
+ (NSMutableArray*)parseObjCMethodEncoding:(const char*)typeEncoding;
+ (NSMutableArray*)parseCFunctionEncoding:(NSString*)xml functionName:(NSString**)functionNamePlaceHolder;

//+ (void)ensureJSValueIsObjectAfterInstanceAutocall:(JSValueRef)value inContext:(JSContextRef)ctx;
- (NSString*)formatJSException:(JSValueRef)exception;
- (id)selectorForJSFunction:(JSObjectRef)function;


- (const char*)typeEncodingOfMethod:(NSString*)methodName class:(NSString*)className;
+ (const char*)typeEncodingOfMethod:(NSString*)methodName class:(NSString*)className;



@end


//
// JSCocoa delegate methods
//

//
// Error reporting
//
@interface NSObject (JSCocoaControllerDelegateMethods)
- (void) JSCocoa:(JSCocoaController*)controller hadError:(NSString*)error onLineNumber:(NSInteger)lineNumber atSourceURL:(id)url;
- (void) safeDealloc;

//
// Getting
//
// Check if getting property is allowed
- (BOOL) JSCocoa:(JSCocoaController*)controller canGetProperty:(NSString*)propertyName ofObject:(id)object inContext:(JSContextRef)ctx exception:(JSValueRef*)exception;
// Custom handler for getting properties
//	Return a custom JSValueRef to bypass JSCocoa
//	Return NULL to let JSCocoa handle getProperty
//	Return JSValueMakeNull() to return a Javascript null
- (JSValueRef) JSCocoa:(JSCocoaController*)controller getProperty:(NSString*)propertyName ofObject:(id)object inContext:(JSContextRef)ctx exception:(JSValueRef*)exception;

//
// Setting
//
// Check if setting property is allowed
- (BOOL) JSCocoa:(JSCocoaController*)controller canSetProperty:(NSString*)propertyName ofObject:(id)object toValue:(JSValueRef)value inContext:(JSContextRef)ctx exception:(JSValueRef*)exception;
// Custom handler for setting properties
//	Return YES to indicate you handled setting
//	Return NO to let JSCocoa handle setProperty
- (BOOL) JSCocoa:(JSCocoaController*)controller setProperty:(NSString*)propertyName ofObject:(id)object toValue:(JSValueRef)value inContext:(JSContextRef)ctx exception:(JSValueRef*)exception;

//
// Calling
//
// Check if calling a C function is allowed
- (BOOL) JSCocoa:(JSCocoaController*)controller canCallFunction:(NSString*)functionName argumentCount:(size_t)argumentCount arguments:(JSValueRef*)arguments inContext:(JSContextRef)ctx exception:(JSValueRef*)exception;
// Check if calling an ObjC method is allowed
- (BOOL) JSCocoa:(JSCocoaController*)controller canCallMethod:(NSString*)methodName ofObject:(id)object argumentCount:(size_t)argumentCount arguments:(JSValueRef*)arguments inContext:(JSContextRef)ctx exception:(JSValueRef*)exception;
// Custom handler for calling
//	Return YES to indicate you handled calling
//	Return NO to let JSCocoa handle calling
- (JSValueRef) JSCocoa:(JSCocoaController*)controller callMethod:(NSString*)methodName ofObject:(id)callee privateObject:(JSCocoaPrivateObject*)thisPrivateObject argumentCount:(size_t)argumentCount arguments:(JSValueRef*)arguments inContext:(JSContextRef)localCtx exception:(JSValueRef*)exception;

//
// Getting global properties (classes, structures, C function names, enums via OSXObject_getProperty)
//
// Check if getting property is allowed
- (BOOL) JSCocoa:(JSCocoaController*)controller canGetGlobalProperty:(NSString*)propertyName inContext:(JSContextRef)ctx exception:(JSValueRef*)exception;
// Custom handler for getting properties
//	Return a custom JSValueRef to bypass JSCocoa
//	Return NULL to let JSCocoa handle getProperty
//	Return JSValueMakeNull() to return a Javascript null
- (JSValueRef) JSCocoa:(JSCocoaController*)controller getGlobalProperty:(NSString*)propertyName inContext:(JSContextRef)ctx exception:(JSValueRef*)exception;

//
// Returning values to Javascript
//
// Called before returning any value to Javascript : return a new value or the original one
//- (JSValueRef) JSCocoa:(JSCocoaController*)controller willReturnValue:(JSValueRef)value inContext:(JSContextRef)ctx exception:(JSValueRef*)exception;

//
// Evaling
//
// Check if file can be loaded
- (BOOL)JSCocoa:(JSCocoaController*)controller canLoadJSFile:(NSString*)path;
// Check if script can be evaluated
- (BOOL)JSCocoa:(JSCocoaController*)controller canEvaluateScript:(NSString*)script;
// Called before evalJSString, used to modify script about to be evaluated
//	Return a custom NSString (eg a macro expanded version of the source)
//	Return NULL to let JSCocoa handle evaluation
- (NSString*)JSCocoa:(JSCocoaController*)controller willEvaluateScript:(NSString*)script;

@end


//
// JSCocoa shorthand
//
@interface JSCocoa : JSCocoaController
@end

//
// Boxed object cache : holds one JSObjectRef for each reference to a pointer to an ObjC object
//
@interface BoxedJSObject : NSObject {
	JSObjectRef	jsObject;
}
- (void)setJSObject:(JSObjectRef)o;
- (JSObjectRef)jsObject;

@end

//
// Boxed value, used for arguments in callJSFunction:withJSValueRefArray:
//
@interface BoxedJSValue : NSObject {
	JSValueRef	jsValue;
}
+ (id)with:(JSValueRef)v;
- (void)setJSValue:(JSValueRef)v;
- (JSValueRef)jsValue;

@end



//
// Helpers
//
id	NSStringFromJSValue(JSContextRef ctx, JSValueRef value);
//void* malloc_autorelease(size_t size);

// Convert values between contexts (eg user context and webkit page context)
JSValueRef valueToExternalContext(JSContextRef ctx, JSValueRef value, JSContextRef externalCtx);

// valueOf() is called by Javascript on objects, eg someObject + ' someString'
JSValueRef	valueOfCallback(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

//
// From PyObjC : when to call objc_msgSend_stret, for structure return
//		Depending on structure size & architecture, structures are returned as function first argument (done transparently by ffi) or via registers
//

#if defined(__ppc__)
#   define SMALL_STRUCT_LIMIT	4
#elif defined(__ppc64__)
#   define SMALL_STRUCT_LIMIT	8
#elif defined(__i386__) 
#   define SMALL_STRUCT_LIMIT 	8
#elif defined(__x86_64__) 
#   define SMALL_STRUCT_LIMIT	16
#elif TARGET_OS_IPHONE
// TOCHECK
#   define SMALL_STRUCT_LIMIT	4
#else
#   error "Unsupported MACOSX platform"
#endif


// Stored in boxedobjects to access a list of methods, properties, ...
#define RuntimeInformationPropertyName		"info"



/*
Some more doc

	__jsHash
	__jsCocoaController
		Instance variables set on ObjC classes written in Javascript.
		These variables enable classes to store Javascript values in them.
	
*/


