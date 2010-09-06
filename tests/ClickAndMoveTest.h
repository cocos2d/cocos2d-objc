#import "cocos2d.h"

@class CCLabel;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end


@interface MainLayer : CCLayer
{}
@end
