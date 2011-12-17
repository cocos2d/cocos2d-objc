
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// Application Delegate class
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;
	
	UIViewController *viewController_;		// weak ref
	UINavigationController *navigationController_;	// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UIViewController *viewController;
@property (readonly) UINavigationController *navigationController;
@end

// HelloActions Layer
@interface ActionsWithBlocks : CCLayer
{
}
@end
