#import "cocos2d.h"
#import "BaseAppController.h"

@interface AppController : BaseAppController
@end

@interface BaseLayer : CCLayer
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
