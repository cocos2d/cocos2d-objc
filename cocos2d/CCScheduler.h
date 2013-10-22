/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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



#import "Support/uthash.h"
#import "ccTypes.h"

/// Targets are things that can have update: and fixedUpdate: methods called by the scheduler.
/// Scheduled blocks (CCTimers) can be associated with a target to inherit their priority and paused state.
@protocol CCSchedulerTarget<NSObject>

/// Used to break ties for scheduled blocks, updated: and fixedUpdate: methods.
/// Targets are sorted by priority so lower priorities are called first.
@property(nonatomic, readonly) NSInteger priority;

@optional

/// update: will be called automatically every frame if implemented, and the node is "live".
-(void) update:(ccTime)delta;

/// fixedUpdate: will be called automatically every tick if implemented, and the node is "live".
-(void) fixedUpdate:(ccTime)delta;

@end


/// Wraps a block scheduled with a CCScheduler.
@interface CCTimer : NSObject

/// Number of times to repeat call the block.
@property(nonatomic, assign) NSUInteger repeatCount;

/// Amount of time to wait between calls of the block.
/// Defaults to the initial delay value.
@property(nonatomic, assign) ccTime repeatInterval;

/// Is the timer paused or not.
@property(nonatomic, assign) BOOL paused;

/// Elapsed time since the last invocation.
@property(nonatomic, readonly) ccTime deltaTime;

/// Absolute time the timer will invoke at.
@property(nonatomic, readonly) ccTime invokeTime;

/// Set the timer to repeat once with the given interval.
/// Can be used from a timer block to make the timer run again.
-(void)repeatOnceWithInterval:(ccTime)interval;

/// Cancel the timer.
-(void)invalidate;

@end


/// Block type to use with CCScheduler.
typedef void (^CCTimerBlock)(CCTimer *timer);


#define CCTimerRepeatForever NSUIntegerMax


//
// CCScheduler
//
/** CCScheduler is responsible of triggering the scheduled callbacks.
 You should not use NSTimer. Instead use this class.

 There are 2 different types of callbacks (selectors):

	- update selector: the 'update' selector will be called every frame. You can customize the priority.
	- custom selector: A custom selector will be called every frame, or with a custom interval of time

 The 'custom selectors' should be avoided when possible. It is faster, and consumes less memory to use the 'update selector'.

*/

@interface CCScheduler : NSObject

/** Modifies the time of all scheduled callbacks.
 You can use this property to create a 'slow motion' or 'fast forward' effect.
 Default is 1.0. To create a 'slow motion' effect, use values below 1.0.
 To create a 'fast forward' effect, use values higher than 1.0.
 @since v0.8
 @warning It will affect EVERY scheduled selector / action.
 */
@property (nonatomic,readwrite) ccTime	timeScale;


/** Will pause / resume the CCScheduler.
 It won't dispatch any message to any target/selector, block if it is paused.

 The difference between `pauseAllTargets` and `pause, is that `setPaused` will pause the CCScheduler,
 while `pauseAllTargets` will pause all the targets, one by one.
 `setPaused` will pause the whole Scheduler, meaning that calls to `resumeTargets:`, `resumeTarget:` won't affect it.

 @since v2.1.0
 */
@property (nonatomic, assign) BOOL paused;

/// Current time the scheduler is calling a block for.
@property(nonatomic, readonly) ccTime currentTime;

/// Time of the most recent update: calls.
@property(nonatomic, readonly) ccTime lastUpdateTime;

/// Time of the most recent fixedUpdate: calls.
@property(nonatomic, readonly) ccTime lastFixedUpdateTime;

/// Maximum allowed time step.
/// If the CPU can't keep up with the game, time will slow down.
@property(nonatomic, assign) ccTime maxTimeStep;

/// The time between fixedUpdate: calls.
@property(nonatomic, assign) ccTime fixedTimeStep;

/** 'update' the scheduler.
 You should NEVER call this method, unless you know what you are doing.
 */
-(void) update:(ccTime)dt;

-(CCTimer *)scheduleBlock:(CCTimerBlock)block forTarget:(NSObject<CCSchedulerTarget> *)target withDelay:(ccTime)delay;

-(void) scheduleTarget:(NSObject<CCSchedulerTarget> *)target;

/** Unschedules all selectors and blocks for a given target.
 This also includes the "update" selector.
 @since v0.99.3
 */
-(void) unscheduleTarget:(NSObject<CCSchedulerTarget> *)target;

/** Pauses the target.
 All scheduled selectors/update for a given target won't be 'ticked' until the target is resumed.
 If the target is not present, nothing happens.
 @since v0.99.3
 */
-(void) pauseTarget:(NSObject<CCSchedulerTarget> *)target;

/** Returns whether or not the target is paused
 @since v1.0.0
 */
-(BOOL) isTargetPaused:(NSObject<CCSchedulerTarget> *)target;

@end
