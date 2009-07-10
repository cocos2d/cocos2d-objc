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
}

-(void) reset;
-(void) check:(CocosNode *)target;
-(void) menuCallback:(id) sender;
@end
