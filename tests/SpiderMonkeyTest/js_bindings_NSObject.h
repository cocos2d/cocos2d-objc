//
// File manually generated.
//
#include "ScriptingCore.h"

extern JSObject* JSPROXY_NSObject_object;
extern JSClass* JSPROXY_NSObject_class;

@interface JSPROXY_NSObject : NSObject
{
	JSObject	*_jsObj;
	id			_realObj;
}

@property (readonly) JSObject *jsObj;
@property (nonatomic, readwrite, retain) id	realObj;

-(id) initWithJSObject:(JSObject*)object;
+(JSObject*) createJSObjectWithRealObject:(id)realObj context:(JSContext*)JSContext;
@end

