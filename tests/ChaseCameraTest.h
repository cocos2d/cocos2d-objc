
@class CCSprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface TestDemo : CCLayer
{}
-(NSString*) title;
-(NSString*) subtitle;
@end

@interface ChaseCameraTest1 : TestDemo
{}
@end
