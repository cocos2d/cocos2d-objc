
#import "BaseAppController.h"
#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : BaseAppController
@end

@interface MultithreadDemo: CCLayer
{
}
-(NSString*) title;
-(NSString*) subtitle;
@end


@interface MultithreadTest1 : MultithreadDemo
{
	CCNode	*node1_;
	CCNode	*node2_;
	CCNode	*node3_;
}
@end
