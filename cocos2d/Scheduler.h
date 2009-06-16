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
/**Class manages all the schedulers
*/
@interface Scheduler : NSObject
{
	NSMutableArray *scheduledMethods;
	NSMutableArray *methodsToRemove;
	NSMutableArray *methodsToAdd;
}

/** returns a shared instance of the Scheduler */
+(Scheduler *)sharedScheduler;

/** the scheduler is ticked */
-(void) tick: (ccTime) dt;

/** schedule a target/selector */
-(Timer*) scheduleTarget:(id) r selector:(SEL) s;

/** schedule a target/selector with interval */
-(Timer*) scheduleTarget:(id) r selector:(SEL) s interval: (ccTime) i;


/** schedule a Timer */
-(void) scheduleTimer: (Timer*) t;

/** unschedule a timer */
-(void) unscheduleTimer: (Timer*) t;
@end
