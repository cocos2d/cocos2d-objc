//
// cocos2d
//

#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface Layer1 : Layer
{
	Label *label1;
	Label *label2;
	Label *label3;
	
	ccTime time1, time2, time3;
}

-(void) step1: (ccTime) dt;
-(void) step2: (ccTime) dt;
-(void) step3: (ccTime) dt;

@end
