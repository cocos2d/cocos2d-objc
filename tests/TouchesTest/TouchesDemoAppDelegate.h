/* TouchesTest (c) Valentin Milea 2009
 */
#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;
	
	UIViewController *viewController_;				// weak ref
	UINavigationController *navigationController_;	// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UIViewController *viewController;
@property (readonly) UINavigationController *navigationController;

@end
