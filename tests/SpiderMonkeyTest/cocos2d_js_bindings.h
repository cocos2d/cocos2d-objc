#include "ScriptingCore.h"

@interface JS_NSObject : NSObject
{
	JSObject *_jsobj;
}
-(id) initWithObject:(JSObject*)object;
+(void) createClassWithContext:(JSContext*)cx object:(JSObject*)globalObj name:(NSString*)name;
@end

@interface JS_CCNode : JS_NSObject
{
	JSClass *jsClass;
	JSObject *jsObject;
}

@end
