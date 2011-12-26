#import "cocos2d.h"
#import "BaseAppController.h"

@interface AppController : BaseAppController
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

@interface SchedulerTimeScale : SchedulerTest
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	UISlider	*sliderCtl;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	NSSlider	*sliderCtl;
	NSWindow	*overlayWindow;
#endif
}
@end

@interface TwoSchedulers : SchedulerTest
{
	CCScheduler *sched1;
	CCScheduler *sched2;
	CCActionManager *actionManager1;
	CCActionManager *actionManager2;
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	UISlider	*sliderCtl1;
	UISlider	*sliderCtl2;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	NSSlider	*sliderCtl1;
	NSSlider	*sliderCtl2;
	NSWindow	*overlayWindow;
#endif
}
@end

