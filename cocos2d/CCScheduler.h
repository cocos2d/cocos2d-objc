/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2015 Cocos2D Authors
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


#define CCTimerRepeatForever NSUIntegerMax

@class CCAction;

// Targets are things that can have update: and fixedUpdate: methods called by the scheduler.
// Scheduled blocks (CCTimers) can be associated with a target to inherit their priority and paused state.
@protocol CCSchedulableTarget<NSObject>

// Used to break ties for scheduled blocks, updated: and fixedUpdate: methods.
// Targets are sorted by priority so lower priorities are called first.
// The priority value for a given object should be constant.
@property(nonatomic, readonly) NSInteger priority;

@optional

-(void) update:(CCTime)delta;

-(void) fixedUpdate:(CCTime)delta;

@end

/**
 CCScheduler is responsible for triggering scheduled callbacks. All scheduled and timed events should use this class, rather than NSTimer.
 Generally, you interface with the scheduler by using the "schedule"/"scheduleBlock" methods in CCNode. You may need to access CCScheduler
 in order to access read-only time properties or to adjust the time scale.
 
 @since v4.0
 */
@interface CCScheduler : NSObject

/* Modifies the time of all scheduled callbacks.
 You can use this property to create a 'slow motion' or 'fast forward' effect.
 Default is 1.0. To create a 'slow motion' effect, use values below 1.0.
 To create a 'fast forward' effect, use values higher than 1.0.
 @warning It will affect EVERY scheduled selector / action.
 */
@property (nonatomic, readwrite) CCTime timeScale;

/**
 Current time the scheduler is calling a block for.
 */
@property(nonatomic, readonly) CCTime currentTime;

/**
 Time of the most recent update: calls.
 */
@property(nonatomic, readonly) CCTime lastUpdateTime;

/**
 Time of the most recent fixedUpdate: calls.
*/
@property(nonatomic, readonly) CCTime lastFixedUpdateTime;

/**
 Maximum allowed time step.
 If the CPU can't keep up with the game, time will slow down.
 */
@property(nonatomic, assign) CCTime maxTimeStep;

/**
 The time between fixedUpdate: calls.
 */
@property(nonatomic, assign) CCTime fixedUpdateInterval;

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


//-----------------

/**
 *  Adds an action to a target
 *  If the target is already present, then the action will be added to the existing target.
 *  If the target is not present, a new instance of this target will be created either paused or paused, and the action will be added to the newly created target.
 *  When the target is paused, the queued actions won't be 'ticked'.
 *
 *  @param action The action to add.
 *  @param target The target to add the action to.
 *  @param paused Defines if action will start paused.
 */
-(void)addAction:(CCAction*)action target:(id)target paused:(BOOL)paused;

/** Removes all actions from all the targets. */
-(void)removeAllActions;

/**
 *  Removes all actions from a certain target.
 *  All the actions that belongs to the target will be removed.
 *
 *  @param target The target to remove action from.
 */
-(void)removeAllActionsFromTarget:(id)target;

/**
 *  Removes an action given an action reference.
 *
 *  @param action Action to remove.
 */
-(void)removeAction:(CCAction*) action;

/**
 *  Removes an action given its tag and the target.
 *
 *  @param tag    Tag of the action to remove.
 *  @param target Target top remove action from.
 */
-(void)removeActionByTag:(NSInteger)tag target:(id)target;

/**
 *  Gets an action given its tag an a target.
 *
 *  @param tag    Tag of the action to retrieve
 *  @param target Target to retrieve action from.
 *
 *  @return The Action the with the given tag.
 */
-(CCAction*)getActionByTag:(NSInteger) tag target:(id)target;

/**
 *  Returns the numbers of actions that are running in a certain target.
 *  Composable actions are counted as 1 action.
 *  Example:
 *  - If you are running 1 Sequence of 7 actions, it will return 1.
 *  - If you are running 7 Sequences of 2 actions, it will return 7.
 *
 *  @param target Target to return number of running action from.
 *
 *  @return Number of running actions.
 */
-(NSUInteger)numberOfRunningActionsInTarget:(id)target;

/**
 *  Pauses the target: all running actions and newly added actions will be paused.
 *
 *  @param target Target to pause all actions on.
 */
-(void)pauseTarget:(id)target;

/**
 *  Resumes the target. All queued actions will be resumed.
 *
 *  @param target Target to resume all action on.
 */
-(void)resumeTarget:(id)target;

/**
 *  Pauses all running actions, returning a list of targets whose actions were paused.
 *
 *  @return Set of targets which were paused.
 */
-(NSSet *)pauseAllRunningActions;

/**
 *  Resume a set of targets (convenience function to reverse a pauseAllRunningActions call).
 *
 *  @param targetsToResume Set of target to resume.
 */
-(void)resumeTargets:(NSSet *)targetsToResume;


@end

// Block type to use with CCScheduler.
typedef void (^CCTimerBlock)(CCTimer *timer);




