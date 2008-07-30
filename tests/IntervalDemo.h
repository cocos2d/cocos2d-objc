//
// cocos2d
//

#import <UIKit/UIKit.h>

#import "Layer.h"
#import "Label.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAlertViewDelegate, UITextFieldDelegate>
{
}
@end

@interface Layer1 : Layer
{
	Label *label1;
	Label *label2;
	Label *label3;
	
	float time1, time2, time3;
}

-(void) step1: (float) dt;
-(void) step2: (float) dt;
-(void) step3: (float) dt;

@end
