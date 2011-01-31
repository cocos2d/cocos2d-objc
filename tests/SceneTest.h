#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end


@interface Layer1 : CCLayerColor
{
}
-(void) onPushScene: (id) sender;
-(void) onPushSceneTran: (id) sender;
-(void) onVoid: (id) sender;
-(void) onQuit: (id) sender;
@end

@interface Layer2 : CCLayerColor
{
	float	timeCounter;
}
-(void) onGoBack: (id) sender;
-(void) onReplaceScene: (id) sender;
-(void) onReplaceSceneTran: (id) sender;
@end

@interface Layer3: CCLayerColor
{
}
@end

