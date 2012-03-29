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

@interface SchedulerPauseResumeAll : SchedulerTest
{
    NSSet* pausedTargets_;
}
@property(readwrite,retain) NSSet* pausedTargets;
@end

@interface SchedulerPauseResumeAllUser : SchedulerTest
{
    NSSet* pausedTargets_;
}
@property(readwrite,retain) NSSet* pausedTargets;
@end

@interface SchedulerUnscheduleAll : SchedulerTest
{}
@end

@interface SchedulerUnscheduleAllHard : SchedulerTest
{
    BOOL actionManagerActive;
}
@end

@interface SchedulerUnscheduleAllUserLevel : SchedulerTest
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
#ifdef __CC_PLATFORM_IOS
	UISlider	*sliderCtl;
#elif defined(__CC_PLATFORM_MAC)
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

#ifdef __CC_PLATFORM_IOS
	UISlider	*sliderCtl1;
	UISlider	*sliderCtl2;
#elif defined(__CC_PLATFORM_MAC)
	NSSlider	*sliderCtl1;
	NSSlider	*sliderCtl2;
	NSWindow	*overlayWindow;
#endif
}
@end

