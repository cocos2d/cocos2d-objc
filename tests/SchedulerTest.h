#import "cocos2d.h"


//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface SchedulerTest : CCLayer
{
}
-(NSString*) title;
-(NSString*) subtitle;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end

@interface SchedulerAutoremove : SchedulerTest
{
	ccTime accum;
}
@end

@interface SchedulerPauseResume : SchedulerTest
{}
@end

@interface SchedulerUnscheduleAll : SchedulerTest
{}
@end

@interface SchedulerUnscheduleAllHard : SchedulerTest
{}
@end

@interface SchedulerSchedulesAndRemove : SchedulerTest
{}
@end

@interface SchedulerUpdate : SchedulerTest
{}
@end

@interface SchedulerUpdateAndCustom : SchedulerTest
{}
@end

@interface SchedulerUpdateFromCustom : SchedulerTest
{}
@end

@interface RescheduleSelector : SchedulerTest
{
	float interval;
	int ticks;
}
@end

@interface SchedulerDelayAndRepeat : SchedulerTest
{}
@end




