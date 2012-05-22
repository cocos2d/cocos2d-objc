#include "ScriptingCore.h"

@interface ProxyJS_NSObject : NSObject
{
	JSObject	*_jsObj;
	id			_realObj;
	BOOL		_initialized;
}

@property (readonly) JSObject *jsObj;
@property (readonly) id	realObj;
@property (nonatomic, readwrite, getter = isInitialized) BOOL initialized;

-(id) initWithJSObject:(JSObject*)object andRealObject:(id)realObject;
+(void) createClassWithContext:(JSContext*)cx object:(JSObject*)globalObj name:(NSString*)name;
@end
