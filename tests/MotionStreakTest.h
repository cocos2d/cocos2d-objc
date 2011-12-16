#import <UIKit/UIKit.h>
#import "CCNode.h"
#import "CCMotionStreak.h"

@class CCSprite;

//CLASS INTERFACE
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
@interface MotionStreakTest : CCLayer
{
	CCMotionStreak *streak_;
}

-(NSString*) title;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end

@interface Test1 : MotionStreakTest
{
	CCNode* root;
	CCNode* target;
	CCMotionStreak* streak;
}
@end

@interface Test2 : MotionStreakTest
{
	CCNode* root;
	CCNode* target;
	CCMotionStreak* streak;
}
@end


