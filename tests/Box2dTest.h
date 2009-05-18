//
// cocos2d
//

#import "cocos2d.h"
#import "Box2D.h"
#import "iPhoneTest.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface Box2DTestLayer : Layer {
	
	Test* currentTest;	
}
@end
