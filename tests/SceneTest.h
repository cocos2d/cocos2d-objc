#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class Menu;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end


@interface Layer1 : Layer
{
}
-(void) onOptions: (id) sender;
-(void) onVoid: (id) sender;
-(void) onQuit: (id) sender;
@end

@interface Layer2 : Layer
{
}
-(void) onGoBack: (id) sender;
-(void) onFullscreen: (id) sender;
@end

@interface Layer3: ColorLayer
{
}
@end

