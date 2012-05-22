#import "js_bindings_NSObject.h"


@interface ProxyJS_CCNode : ProxyJS_NSObject
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
