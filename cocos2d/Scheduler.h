/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
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
@interface Timer : NSObject
{
	id target;
	SEL selector;
	TICK_IMP impMethod;
	
	ccTime interval;
	ccTime elapsed;
}

/** interval in seconds */
@property (readwrite,assign) ccTime interval;

/** constructor for timer */
+(id) timerWithTarget:(id) t selector:(SEL)s;

/** constructor for timer with interval */
+(id) timerWithTarget:(id) t selector:(SEL)s interval:(ccTime) i;

/** init for Timer */
-(id) initWithTarget:(id) t selector:(SEL)s;

/** init for Timer with interval */
-(id) initWithTarget:(id) t selector:(SEL)s interval:(ccTime) i;


/** triggers the timer */
-(void) fire: (ccTime) dt;
@end

//
// Scheduler
//
/** Scheduler is a singleton.
 It is responsible of triggering the scheduled callbacks.
 You should not use NSTimer. Instead use this class.
*/
@interface Scheduler : NSObject
{
	NSMutableArray	*scheduledMethods;
	NSMutableArray	*methodsToRemove;
	NSMutableArray	*methodsToAdd;
	
	ccTime			timeScale_;
}

/** Modifies the time of all scheduled callbacks.
 You can use this property to create a 'slow motion' or 'fast fordward' effect.
 Default is 1.0. To create a 'slow motion' effect, use values below 1.0.
 To create a 'fast fordward' effect, use values higher than 1.0.
 @since v0.8
 */
@property (readwrite) ccTime	timeScale;

/** returns a shared instance of the Scheduler */
+(Scheduler *)sharedScheduler;

/** 'tick' the scheduler.
 You should not call this method NEVER.
 */
-(void) tick: (ccTime) dt;

/** schedules a target/selector */
-(Timer*) scheduleTarget:(id) r selector:(SEL) s;

/** schedules a target/selector with interval */
-(Timer*) scheduleTarget:(id) r selector:(SEL) s interval: (ccTime) i;


/** schedules a Timer */
-(void) scheduleTimer: (Timer*) t;

/** unschedules a timer */
-(void) unscheduleTimer: (Timer*) t;
@end
