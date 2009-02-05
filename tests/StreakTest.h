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

@interface StreakTest : Layer
{
	CocosNode* root;
  CocosNode* target;
  MotionStreak* streak;
}
-(NSString*) title;
@end


