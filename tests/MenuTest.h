#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class Menu;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow *window;
}
@end


@interface Layer1 : Layer
{
	MenuItem *disabledItem;
}

-(void) menuCallback:(id) sender;
-(void) menuCallback2:(id) sender;
-(void) onQuit:(id) sender;
@end

@interface Layer2 : Layer
{
}
-(void) menuCallbackBack: (id) sender;
-(void) menuCallbackH: (id) sender;
-(void) menuCallbackV: (id) sender;
@end

@interface Layer3 : Layer
{
}
-(void) menuCallback: (id) sender;
-(void) menuCallback2: (id) sender;
@end
