#import <UIKit/UIKit.h>
#import "CocosNode.h"
#import "MotionStreak.h"

@class Sprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface MotionStreakTest : Layer
{}

-(NSString*) title;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end

@interface Test1 : MotionStreakTest
{
	CocosNode* root;
	CocosNode* target;
	MotionStreak* streak;
}
@end

@interface Test2 : MotionStreakTest
{
	CocosNode* root;
	CocosNode* target;
	MotionStreak* streak;
}
@end


