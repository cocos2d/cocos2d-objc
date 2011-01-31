#import "cocos2d.h"

@class CCLabel;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
	UIWindow	*window;
}
@end

@interface TextLayer: CCLayerColor
{
}
@end

