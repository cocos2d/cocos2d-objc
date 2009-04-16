
//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface TestDemo : Layer
{
}
-(NSString*) title;
@end

@interface Test1 : TestDemo
{}
@end
