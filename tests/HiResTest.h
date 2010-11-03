#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface HiResDemo: CCLayer
{
	BOOL	hiRes_;
}
-(NSString*) title;
-(NSString*) subtitle;
@end


@interface Test1 : HiResDemo
{}
@end

@interface Test2 : HiResDemo
{}
@end


