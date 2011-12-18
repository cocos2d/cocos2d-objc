#import "cocos2d.h"
#import "BaseAppController.h"

@class CCMenu;

//CLASS INTERFACE
@interface AppController : BaseAppController
@end


@interface Layer1 : CCLayer
{
	CCMenuItem	*disabledItem;
}

@end

@interface Layer2 : CCLayer
{
	CGPoint	centeredMenu;
	BOOL alignedH;
}
@end

@interface Layer3 : CCLayer
{
	CCMenuItem	*disabledItem;
}
-(void) menuCallback: (id) sender;
-(void) menuCallback2: (id) sender;
@end

@interface Layer4 : CCLayer
{
}
-(void) menuCallback: (id) sender;
-(void) backCallback: (id) sender;
@end
