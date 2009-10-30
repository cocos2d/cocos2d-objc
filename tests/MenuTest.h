#import "cocos2d.h"

@class CCMenu;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow *window;
}
@end


@interface Layer1 : CCLayer
{
	CCMenuItem	*disabledItem;
}

-(void) menuCallback:(id) sender;
-(void) menuCallback2:(id) sender;
-(void) onQuit:(id) sender;
@end

@interface Layer2 : CCLayer
{
	CGPoint	centeredMenu;
	BOOL alignedH;
}
-(void) menuCallbackBack: (id) sender;
-(void) menuCallbackOpacity: (id) sender;
-(void) menuCallbackAlign: (id) sender;
@end

@interface Layer3 : CCLayer
{
	CCMenuItem	*disabledItem;
}
-(void) menuCallback: (id) sender;
-(void) menuCallback2: (id) sender;
@end

@interface Layer4 : CCLayer
{
}
-(void) menuCallback: (id) sender;
-(void) backCallback: (id) sender;
@end
