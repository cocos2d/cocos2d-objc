#import <UIKit/UIKit.h>
#import "CCNode.h"
#import "CCMotionStreak.h"

@class CCSprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface MotionStreakTest : CCLayer
{}

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


