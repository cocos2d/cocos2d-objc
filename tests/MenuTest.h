#import "cocos2d.h"

@class CCMenu;
#import "BaseAppController.h"

@interface AppController : BaseAppController
@end

@interface LayerMainMenu : CCNode
{
	CCMenuItem	*disabledItem;
}
@end

@interface Layer2 : CCNode
{
	CGPoint	centeredMenu;
	BOOL alignedH;
}
-(void) menuCallbackBack: (id) sender;
-(void) menuCallbackOpacity: (id) sender;
-(void) menuCallbackAlign: (id) sender;
@end

@interface Layer3 : CCNode
{
	CCMenuItem	*disabledItem;
}
-(void) menuCallback: (id) sender;
-(void) menuCallback2: (id) sender;
@end

@interface Layer4 : CCNode
{
}
-(void) menuCallback: (id) sender;
-(void) backCallback: (id) sender;
@end

@interface LayerPriorityTest : CCNode
{
}
@end

@interface BugsTest : CCNode
{
}
@end

@interface TouchAreaTest : CCNode
{
}
@end
