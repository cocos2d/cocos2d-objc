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
#import "Support/ccArray.h"
#import "Support/ccHashSet.h"

@protocol CCPerFrameUpdateProtocol;



typedef void (*TICK_IMP)(id, SEL, ccTime);

#define CCTIMER_REPEAT_FOREVER -1

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
	
	// XXX: optimization. Don't use as a property
	// XXX: performance is improved in about 10%
@public
	int		 ticksUntilAutoExpire; // -1 = infinite
	float	 timeScale; // defaults to 1.0.  0.5 would be running half as fast, 2.0 would be running twice as fast
	BOOL	 paused;
	
}

/** interval in seconds */
@property (nonatomic,readwrite,assign) ccTime interval;
@property (nonatomic,readonly) int ticksUntilAutoExpire;
@property (nonatomic,readonly) id target;
@property (nonatomic,readonly) SEL selector;
@property (nonatomic,readwrite) float timeScale;
@property (nonatomic,readwrite) BOOL paused;


/** Allocates a timer with a target, a selector, an interval in seconds, number of repetitions, and a pause condition.
 */
+(id) timerWithTarget:(id) t selector:(SEL)s interval:(ccTime)seconds repeat:(int)times paused:(BOOL)paused;

/** Initializes a timer with a target, a selector, an interval in seconds, number of repetitions and a pause condition.
 */
-(id) initWithTarget:(id) t selector:(SEL)s interval:(ccTime)seconds repeat:(int)times paused:(BOOL)paused;



/** triggers the timer */
-(void) fire: (ccTime) dt;
@end


//
// CCUpdateBucket
//
/** Maintains a list of CCNodes that have requested update
 */
@interface CCUpdateBucket : NSObject {
	NSInteger					priority;
	NSMutableArray*		updateRequests;
}

@property (nonatomic,readwrite) NSInteger priority;

-(id) initWithPriority:(NSInteger) aPriority;
-(void) requestUpdatesFor:(id <CCPerFrameUpdateProtocol>) aNode;
-(BOOL) cancelUpdatesFor:(id <CCPerFrameUpdateProtocol>) aNode;
-(void) update:(ccTime) dt;

@end

//
// Scheduler
//
/** Scheduler is responsible of triggering the scheduled callbacks.
 You should not use NSTimer. Instead use this class.
*/
@interface CCScheduler : NSObject
{
	NSMutableSet					*scheduledMethods;
	NSMutableSet					*methodsToRemove;
	NSMutableSet					*methodsToAdd;

	NSMutableDictionary				*targets;
	
	
	float							timeScale;
	
	// PerFrame Update
	
	NSMutableArray*	buckets;	
	NSUInteger	perFrameCount;
	
}

@property (readonly) NSUInteger perFrameCount;

/** Modifies the time of all scheduled callbacks.
 You can use this property to create a 'slow motion' or 'fast fordward' effect.
 Default is 1.0. To create a 'slow motion' effect, use values below 1.0.
 To create a 'fast fordward' effect, use values higher than 1.0.
 @since v0.8
 @warning It will affect EVERY scheduled selector / action. 
 */
@property (nonatomic,readwrite) float	timeScale;

/** returns a shared instance of the Scheduler */
+(CCScheduler *)sharedScheduler;

/** purges the shared scheduler. It releases the retained instance.
 @since v0.9.0
 */
+(void)purgeSharedScheduler;

/** 'tick' the scheduler.
 You should NEVER call this method, unless you know what you are doing.
 */
-(void) tick:(ccTime)dt;

/** schedules a CCTimer.
 It will be fired in every frame, but the CCTimer will fire the target/selector according to its interval,repeats and pause state; 
 */
-(void) addTimer:(CCTimer*)t;

/** unschedules an already scheduled CCTimer */
-(void) removeTimer:(CCTimer*)t;

/** unschedule all timers.
 You should NEVER call this method, unless you know what you are doing.
 @since v0.8
 */
-(void) unscheduleAllTimers;

/** Unschedule a selector for a given target
 */
-(void) unscheduleSelector:(SEL)selector target:(id)target;

/** removes all timers from a given target
 */
-(void) removeAllTimersFromTarget:(id)target;

/** pauses all timers for a given target
 */
-(void) pauseAllTimersForTarget:(id)target;

/** unpauses all timers for a given target
 */
-(void) resumeAllTimersForTarget:(id)target;

/** scales the timefactor for all timers of a given target
 */
-(void) scaleAllTimersForTarget:(id)target scaleFactor:(float)scaleFactor;



/** Schedules a target to get per-frame updates with a given priority.  It is not legal
 to add the same node twice.  Remove it first (cancelUpdateForTarget:).  This method does
 not check for performance reasons.
 
 Higher Priority buckets are processed first.  Data structures performance assumes
 a modest number priority buckets at most, though there is no hard limit.  This is
 the expected and general use-case.
 */
-(void) requestPerFrameUpdatesForTarget:(id <CCPerFrameUpdateProtocol>)target priority:(NSInteger)priority;

/** Removes a target from having per-frame udpates
 */
-(void) cancelPerFrameUpdatesForTarget:(id <CCPerFrameUpdateProtocol>)target;




@end
