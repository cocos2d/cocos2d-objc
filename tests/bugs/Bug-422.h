#import "cocos2d.h"

@class Menu;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow *window;
}
@end


@interface Layer1 : CCLayer
{
}

-(void) reset;
-(void) check:(CCNode *)target;
-(void) menuCallback:(id) sender;
@end
