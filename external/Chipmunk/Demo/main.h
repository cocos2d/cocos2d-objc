#import <UIKit/UIKit.h>
#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
	UIWindow	*window;
}
@end

@interface MainLayer : Layer
{
}
@end
