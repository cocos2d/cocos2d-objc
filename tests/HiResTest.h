#import "cocos2d.h"

//CLASS INTERFACE
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


