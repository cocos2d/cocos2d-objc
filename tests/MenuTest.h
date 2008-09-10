#import <UIKit/UIKit.h>
#import "cocos2d.h"

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
-(void) menuCallback:(id) sender;
-(void) menuCallback2:(id) sender;
-(void) onQuit:(id) sender;
@end

@interface Layer2 : Layer
{
	Menu * menu;
}
-(void) menuCallback: (id) sender;
-(void) menuCallback2: (id) sender;
@end

@interface Layer3 : Layer
{
	Menu * menu;
}
-(void) menuCallback: (id) sender;
-(void) menuCallback2: (id) sender;
@end
