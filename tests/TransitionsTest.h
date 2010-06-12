#import "cocos2d.h"

@class CCLabel;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}

@property (nonatomic, readonly) UIWindow *window;
@end


@interface TextLayer: CCLayer
{
}
@end


@interface TextLayer2: CCLayer
{
}
@end

