//
// attach Demo
// a cocos2d example
//

#import <UIKit/UIKit.h>

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
	IBOutlet UIWindow				*window;
	IBOutlet UIView					*mainView;
	IBOutlet UINavigationBar		*myNavigation;

	CCDirector						*director;
	int	state;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UIView *mainView;

// segment delegate
- (void)segmentAction:(id)sender;

@end
