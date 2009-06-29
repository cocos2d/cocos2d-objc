
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// Application Delegate class
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	// main UIWindow
	// The OpenGL view will be a attached to this UIWindow
    UIWindow *window;
}

// Make the main UIWindow a property
@property (nonatomic, retain) UIWindow *window;
@end

// HelloActions Layer
@interface HelloActions : Layer
{
}
@end
