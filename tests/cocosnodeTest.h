
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

@interface SchedulerTest3 : TestDemo
{}
@end

@interface SchedulerTest4 : TestDemo
{}
@end

@interface SchedulerTest5 : TestDemo
{}
@end

@interface SchedulerScaleTest : TestDemo
{
	UISlider	*sliderCtl;
	CCLabel *label1;
	CCLabel *label2;
	CCLabel *label3;
	
	ccTime time1, time2, time3;	
}
@end


@interface NodeToWorld : TestDemo
{}
@end

@interface CameraOrbitTest : TestDemo
{}
@end

@interface CameraZoomTest : TestDemo
{}
@end

@interface TimerScaleTest : TestDemo
{}
@end

@interface TimerScaleWithChildrenTest : TestDemo
{}
@end

@interface PerFrameUpdateTest : TestDemo
{}
@end
