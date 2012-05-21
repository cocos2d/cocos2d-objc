#include "ScriptingCore.h"

@interface JS_NSObject : NSObject
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

@interface JS_CCNode : JS_NSObject
{
}

// callbacks
-(void) onEnter;
-(void) onExit;

@end

@interface CCNode (SpiderMonkey)

-(void) onEnter_JS;
-(void) onExit_JS;

@end
