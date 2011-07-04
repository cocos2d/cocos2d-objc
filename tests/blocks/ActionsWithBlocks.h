
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// Application Delegate class
@interface AppController : NSObject <UIApplicationDelegate>
{
	// main UIWindow
	// The OpenGL view will be a attached to this UIWindow
    UIWindow *window_;
	UIViewController *viewController_;
}

@end

// HelloActions Layer
@interface ActionsWithBlocks : CCLayer
{
}
@end
