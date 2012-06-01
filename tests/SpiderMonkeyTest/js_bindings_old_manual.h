#import "js_bindings_NSObject.h"

#import "cocos2d.h"


#pragma mark - With Proxy

@interface ProxyJS_CCNode : JSPROXY_NSObject
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



#pragma mark - Subclass

@interface JSExt_CCNode : CCNode
{
	JSObject	*jsObject_;
}

@property (nonatomic, readwrite) JSObject *jsObject;

+(void) js_createClassWithContext:(JSContext*)cx object:(JSObject*)globalObj name:(NSString*)name;


@end
