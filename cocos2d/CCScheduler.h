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


// cocoa related
#import <UIKit/UIKit.h>

#import "ccTypes.h"

typedef void (*TICK_IMP)(id, SEL, ccTime);

//
// Timer
//
/** Light weight timer */
@interface CCTimer : NSObject
{
	id target;
	SEL selector;
	TICK_IMP impMethod;
	
	ccTime interval;
	ccTime elapsed;
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

//
// Scheduler
//
/** Scheduler is responsible of triggering the scheduled callbacks.
 You should not use NSTimer. Instead use this class.
*/
@interface CCScheduler : NSObject
{
	NSMutableArray	*scheduledMethods;
	NSMutableArray	*methodsToRemove;
	NSMutableArray	*methodsToAdd;
	
	ccTime			timeScale_;
	
	// Optimization
	TICK_IMP		impMethod;
	SEL				fireSelector;
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

/** schedules a Timer.
 It will be fired in every frame.
 */
-(void) scheduleTimer: (CCTimer*) t;

/** unschedules an already scheduled Timer */
-(void) unscheduleTimer: (CCTimer*) t;

/** unschedule all timers.
 You should NEVER call this method, unless you know what you are doing.
 @since v0.8
 */
-(void) unscheduleAllTimers;
@end
