#import "cocos2d.h"
#import "BaseAppController.h"

@interface AppController : BaseAppController
@end

@interface BaseLayer : CCNode
{
}
-(NSString*) title;
-(NSString*) subtitle;
@end

@interface TestDrawingPrimitives : BaseLayer
{}
@end

@interface TestDrawNode : BaseLayer
{}
@end
