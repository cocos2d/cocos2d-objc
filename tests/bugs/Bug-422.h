#import "cocos2d.h"

@class Menu;

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow	*window_;
	UIViewController *viewController_;
}
@end


@interface Layer1 : CCLayer
{
}

-(void) reset;
-(void) check:(CCNode *)target;
-(void) menuCallback:(id) sender;
@end
