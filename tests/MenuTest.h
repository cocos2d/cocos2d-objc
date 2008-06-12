#import <UIKit/UIKit.h>
#import "Layer.h"

@class Menu;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
}
@end


@interface Layer1 : Layer
{
	Menu * menu;
}
-(void) menuCallback;
-(void) menuCallback2;
@end

@interface Layer2 : Layer
{
	Menu * menu;
}
-(void) menuCallback;
-(void) menuCallback2;
@end
