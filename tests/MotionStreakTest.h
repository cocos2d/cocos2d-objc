
#import <UIKit/UIKit.h>
#import "BaseAppController.h"

@class CCSprite;

//CLASS INTERFACE
@interface AppController : BaseAppController
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


