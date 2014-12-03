/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */



#import "ccTypes.h"

@class CCScheduler;

// Targets are things that can have update: and fixedUpdate: methods called by the scheduler.
// Scheduled blocks (CCTimers) can be associated with a target to inherit their priority and paused state.
@protocol CCSchedulerTarget<NSObject>

// Used to break ties for scheduled blocks, updated: and fixedUpdate: methods.
// Targets are sorted by priority so lower priorities are called first.
// The priority value for a given object should be constant.
@property(nonatomic, readonly) NSInteger priority;

@optional

-(void) update:(CCTime)delta;

-(void) fixedUpdate:(CCTime)delta;

@end


/** Contains information about a scheduled selector. Returned by [CCNode schedule:interval:] and related methods.

 @note New CCTimer objects can only be created with the schedule methods. CCTimer should not be subclassed.
 */
@interface CCTimer : NSObject

/** @name Interval and Repeat Count */

/** Number of times to run the selector again. First run does not count as a repeat. */
@property(nonatomic, assign) NSUInteger repeatCount;

/** Amount of time to wait between selector calls. Defaults to the initial delay value.
 
 `CCTime` is a typedef for `double`. */
@property(nonatomic, assign) CCTime repeatInterval;

/** @name Time Info */

/** Elapsed time since the last invocation.
 
 `CCTime` is a typedef for `double`. */
@property(nonatomic, readonly) CCTime deltaTime;

/** Absolute time the timer will invoke at.
 
 `CCTime` is a typedef for `double`. */
@property(nonatomic, readonly) CCTime invokeTime;

// purposefully undocumented: CCScheduler is a private, undocumented class
// CCScheduler this timer was invoked from. Useful if you need to schedule more timers, or access lastUpdate times, etc.
@property(nonatomic, readonly) CCScheduler *scheduler;

// purposefully undocumented
/* Track an object along with the timer. [CCNode schedule:interval:] methods use this to store the selector name. */
@property(nonatomic, strong) id userData;

// purposefully undocumented: same as setting repeatCount and repeatInterval
// Set the timer to repeat once with the given interval.
// Can be used from a timer block to make the timer run again.
-(void)repeatOnceWithInterval:(CCTime)interval;

/** @name Pausing and Stopping Timer */

/** Whether the timer is paused. */
@property(nonatomic, assign) BOOL paused;

/** Returns YES if the timer is no longer scheduled. */
@property(nonatomic, readonly) BOOL invalid;

/** Cancel the timer. */
-(void)invalidate;

@end


// Block type to use with CCScheduler.
typedef void (^CCTimerBlock)(CCTimer *timer);


#define CCTimerRepeatForever NSUIntegerMax


// purposefully left undocumented: CCScheduler is a private/internal class

//
// CCScheduler
//
/* CCScheduler is responsible of triggering the scheduled callbacks.
 You should not use NSTimer. Instead use this class.
*/

@interface CCScheduler : NSObject

/* Modifies the time of all scheduled callbacks.
 You can use this property to create a 'slow motion' or 'fast forward' effect.
 Default is 1.0. To create a 'slow motion' effect, use values below 1.0.
 To create a 'fast forward' effect, use values higher than 1.0.
 @warning It will affect EVERY scheduled selector / action.
 */
@property (nonatomic,readwrite) CCTime	timeScale;

@property (nonatomic, assign) BOOL paused;

// Current time the scheduler is calling a block for.
@property(nonatomic, readonly) CCTime currentTime;

// Time of the most recent update: calls.
@property(nonatomic, readonly) CCTime lastUpdateTime;

// Time of the most recent fixedUpdate: calls.
@property(nonatomic, readonly) CCTime lastFixedUpdateTime;

// Maximum allowed time step.
// If the CPU can't keep up with the game, time will slow down.
@property(nonatomic, assign) CCTime maxTimeStep;

// The time between fixedUpdate: calls.
@property(nonatomic, assign) CCTime fixedUpdateInterval;

/* 'update' the scheduler.
 You should NEVER call this method, unless you know what you are doing.
 */
-(void) update:(CCTime)dt;

-(CCTimer *)scheduleBlock:(CCTimerBlock)block forTarget:(NSObject<CCSchedulerTarget> *)target withDelay:(CCTime)delay;

-(void) scheduleTarget:(NSObject<CCSchedulerTarget> *)target;

/* Unschedules all selectors and blocks for a given target.
 This also includes the "update" selector.
 */
-(void) unscheduleTarget:(NSObject<CCSchedulerTarget> *)target;

// TODO This is no longer needed and should maybe be removed or made a testing only method.
-(BOOL) isTargetScheduled:(NSObject<CCSchedulerTarget> *)target;

-(void)setPaused:(BOOL)paused target:(NSObject<CCSchedulerTarget> *)target;

-(BOOL) isTargetPaused:(NSObject<CCSchedulerTarget> *)target;

-(NSArray *)timersForTarget:(NSObject<CCSchedulerTarget> *)target;

@end
