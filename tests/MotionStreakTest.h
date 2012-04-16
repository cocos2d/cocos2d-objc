

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
-(NSString*) subtitle;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end

@interface Test1 : MotionStreakTest
{
	CCNode* root;
	CCNode* target;
}
@end

@interface Test2 : MotionStreakTest
{
	CCNode* root;
	CCNode* target;
}
@end

@interface Issue1358 : MotionStreakTest
{
	CGPoint _center;
	CGFloat _radius;
	CGFloat _angle;
}
@end




