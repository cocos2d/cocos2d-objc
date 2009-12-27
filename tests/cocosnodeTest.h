
@class CCSprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface TestDemo : CCLayer
{
}
-(NSString*) title;
@end

@interface Test2 : TestDemo
{}
@end

@interface Test4 : TestDemo
{}
@end

@interface Test5 : TestDemo
{}
@end

@interface Test6 : TestDemo
{}
@end

@interface StressTest1 : TestDemo
{}
@end

@interface StressTest2 : TestDemo
{}
@end

@interface SchedulerTest1 : TestDemo
{}
@end

@interface SchedulerTest2 : TestDemo
{}
@end
