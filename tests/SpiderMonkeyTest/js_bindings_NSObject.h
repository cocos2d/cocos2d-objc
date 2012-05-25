//
// File manually generated.
//
#include "ScriptingCore.h"

extern JSObject* JSPROXY_NSObject_object;

@interface JSPROXY_NSObject : NSObject
{
	JSObject	*_jsObj;
	id			_realObj;
}

@property (readonly) JSObject *jsObj;
@property (nonatomic, readwrite, retain) id	realObj;

-(id) initWithJSObject:(JSObject*)object;
+(void) createClassWithContext:(JSContext*)cx object:(JSObject*)globalObj name:(NSString*)name;
@end

