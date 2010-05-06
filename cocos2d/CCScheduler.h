/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009,2010 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <Foundation/Foundation.h>
#import "Support/uthash.h"
#import "Support/ccArray.h"

#import "ccTypes.h"

typedef void (*TICK_IMP)(id, SEL, ccTime);


//
// CCTimer
//
/** Light weight timer */
@interface CCTimer : NSObject
{
	id target;
	TICK_IMP impMethod;
	
	ccTime interval;
	ccTime elapsed;

@public					// optimization
	SEL selector;
}

/** interval in seconds */
@property (nonatomic,readwrite,assign) ccTime interval;

/** Allocates a timer with a target and a selector.
*/
+(id) timerWithTarget:(id) t selector:(SEL)s;

/** Allocates a timer with a target, a selector and an interval in seconds.
*/
+(id) timerWithTarget:(id) t selector:(SEL)s interval:(ccTime)seconds;

/** Initializes a timer with a target and a selector.
*/
 -(id) initWithTarget:(id) t selector:(SEL)s;

/** Initializes a timer with a target, a selector and an interval in seconds.
*/
-(id) initWithTarget:(id) t selector:(SEL)s interval:(ccTime)seconds;


/** triggers the timer */
-(void) fire: (ccTime) dt;
@end

// Hash Element
typedef struct _CCSchedHashElement
{
	struct ccArray	*timers;
	id				target;		// hash key
	unsigned int	timerIndex;
	CCTimer			*currentTimer;
	BOOL			currentTimerSalvaged;
	BOOL			paused;
	UT_hash_handle  hh;
} tCCSchedHashElement;


//
// CCScheduler
//
/** Scheduler is responsible of triggering the scheduled callbacks.
 You should not use NSTimer. Instead use this class.
*/
@interface CCScheduler : NSObject
{	
	ccTime				timeScale_;
	
	tCCSchedHashElement	*targets;
	tCCSchedHashElement	* currentTarget;
	BOOL				currentTargetSalvaged;
	
	// Optimization
	TICK_IMP			impMethod;
	SEL					fireSelector;
}

/** Modifies the time of all scheduled callbacks.
 You can use this property to create a 'slow motion' or 'fast fordward' effect.
 Default is 1.0. To create a 'slow motion' effect, use values below 1.0.
 To create a 'fast fordward' effect, use values higher than 1.0.
 @since v0.8
 @warning It will affect EVERY scheduled selector / action.
 */
@property (nonatomic,readwrite) ccTime	timeScale;

/** returns a shared instance of the Scheduler */
+(CCScheduler *)sharedScheduler;

/** purges the shared scheduler. It releases the retained instance.
 @since v0.99.0
 */
+(void)purgeSharedScheduler;

/** 'tick' the scheduler.
 You should NEVER call this method, unless you know what you are doing.
 */
-(void) tick:(ccTime)dt;

/** The scheduled method will be called every 'interval' seconds. If 'interva' is 0, it will be called every frame.
 If paused is YES, then it won't be called until it is resumed
 
 @since v0.99.3
 */
-(void) scheduleSelector:(SEL)selector forTarget:(id)target interval:(float)interval paused:(BOOL)paused;

/** Unshedules a selector for a given target
 
 @since v0.99.3
 */
-(void) unscheduleSelector:(SEL)selector forTarget:(id)target;

/** Unschedules all selectors for a given target
 
 @since v0.99.3
 */
-(void) unscheduleAllSelectorsForTarget:(id)target;

/** Unschedules all selectors from all targets.
 You should NEVER call this method, unless you know what you are doing.

 @since v0.99.3
 */
-(void) unscheduleAllSelectors;

/** Pause all scheduled selectors for a given target
 @since v0.99.3
 */
-(void) pauseAllSelectorsForTarget:(id)target;

/** Resumes all scheduled selectors for a given target
 @since v0.99.3
 */
-(void) resumeAllSelectorsForTarget:(id)target;


/** schedules a Timer.
 It will be fired in every frame.
 
 @deprecated Use scheduleSelector:forTarget:interval:paused instead. Will be removed in 1.0
 */
-(void) scheduleTimer: (CCTimer*) timer __attribute__((deprecated));

/** unschedules an already scheduled Timer
 
 @deprecated Use unscheduleSelector:forTarget. Will be removed in v1.0
 */
-(void) unscheduleTimer: (CCTimer*) timer __attribute__((deprecated));

/** unschedule all timers.
 You should NEVER call this method, unless you know what you are doing.
 
 @deprecated Use scheduleAllSelectors instead. Will be removed in 1.0
 @since v0.8
 */
-(void) unscheduleAllTimers __attribute__ ((deprecated));
@end
