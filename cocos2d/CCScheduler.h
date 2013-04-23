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

// Priority level reserved for system services.
#define kCCPrioritySystem INT_MIN

// Minimum priority level for user scheduling.
#define kCCPriorityNonSystemMin (kCCPrioritySystem+1)

typedef void (*TICK_IMP)(id, SEL, ccTime);

//
// CCTimer
//
/** Light weight timer */
@interface CCTimer : NSObject
{
	ccTime		_interval;
	ccTime		_elapsed;
	BOOL		_runForever;
	BOOL		_useDelay;
	uint		_nTimesExecuted;
	uint		_repeat; //0 = once, 1 is 2 x executed
	ccTime		_delay;
}

/** interval in seconds */
@property (nonatomic,readwrite,assign) ccTime interval;


/** triggers the timer */
-(void) update: (ccTime) dt;
@end

@interface CCTimerTargetSelector : CCTimer
{
	id			_target;
	SEL			_selector;
	TICK_IMP	_impMethod;
}

/** selector */
@property (nonatomic,readonly)	SEL selector;

/** Allocates a timer with a target and a selector. */
+(id) timerWithTarget:(id) t selector:(SEL)s;

/** Allocates a timer with a target, a selector and an interval in seconds. */
+(id) timerWithTarget:(id) t selector:(SEL)s interval:(ccTime)seconds;

/** Initializes a timer with a target and a selector. */
-(id) initWithTarget:(id) t selector:(SEL)s;

/** Initializes a timer with a target, a selector, an interval in seconds, repeat in number of times to repeat, delay in seconds */
-(id) initWithTarget:(id)t selector:(SEL)s interval:(ccTime) seconds repeat:(uint) r delay:(ccTime) d;
@end


@interface CCTimerBlock : CCTimer
{
	void (^_block)(ccTime delta);
	NSString	*_key;
	id			_target;
}

/** unique identifier of the block */
@property (nonatomic, readonly) NSString *key;

/** owner of the timer */
@property (nonatomic, readonly, assign) id target;

/** Allocates a timer with a target, interval in seconds, a key and a block */
+(id) timerWithTarget:(id)owner interval:(ccTime)seconds key:(NSString*)key block:(void(^)(ccTime delta)) block;

/** Initializes a timer with a target(owner), interval in seconds, repeat in number of times to repeat, delay in seconds and a block */
-(id) initWithTarget:(id)owner interval:(ccTime) seconds repeat:(uint) r delay:(ccTime)d key:(NSString*)key block:(void(^)(ccTime delta))block;
@end


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

struct _listEntry;
struct _hashSelectorEntry;
struct _hashUpdateEntry;

@interface CCScheduler : NSObject
{
	ccTime				_timeScale;

	//
	// "updates with priority" stuff
	//
	struct _listEntry			*updatesNeg;	// list of priority < 0
	struct _listEntry			*updates0;		// list priority == 0
	struct _listEntry			*updatesPos;	// list priority > 0
	struct _hashUpdateEntry		*hashForUpdates;	// hash used to fetch quickly the list entries for pause,delete,etc.

	// Used for "selectors with interval"
	struct _hashSelectorEntry	*hashForTimers;
	struct _hashSelectorEntry	*currentTarget;
	BOOL						currentTargetSalvaged;

	// Optimization
	TICK_IMP			impMethod;
	SEL					updateSelector;

    BOOL updateHashLocked; // If true unschedule will not remove anything from a hash. Elements will only be marked for deletion.

	BOOL				_paused;
}

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
@property (nonatomic,readonly,getter=isPaused) BOOL paused;

/** 'update' the scheduler.
 You should NEVER call this method, unless you know what you are doing.
 */
-(void) update:(ccTime)dt;

/** The scheduled method will be called every 'interval' seconds.
 If paused is YES, then it won't be called until it is resumed.
 If 'interval' is 0, it will be called every frame, but if so, it recommended to use 'scheduleUpdateForTarget:' instead.
 If the selector is already scheduled, then only the interval parameter will be updated without re-scheduling it again.
 repeat lets the action be repeated repeat + 1 times, use kCCRepeatForever to let the action run continuously
 delay is the amount of time the action will wait before it'll start

 @since v0.99.3, repeat and delay added in v1.1
 */
-(void) scheduleSelector:(SEL)selector forTarget:(id)target interval:(ccTime)interval repeat:(uint)repeat delay:(ccTime)delay paused:(BOOL)paused;

/** calls scheduleSelector with kCCRepeatForever and a 0 delay */
-(void) scheduleSelector:(SEL)selector forTarget:(id)target interval:(ccTime)interval paused:(BOOL)paused;

/** Schedules the 'update' selector for a given target with a given priority.
 The 'update' selector will be called every frame.
 The lower the priority, the earlier it is called.
 @since v0.99.3
 */
-(void) scheduleUpdateForTarget:(id)target priority:(NSInteger)priority paused:(BOOL)paused;

/** The scheduled block will be called every 'interval' seconds.
 'key' is a unique identifier of the block. Needed to unschedule the block or update its interval.
 'target' is needed for all the method related to "target" like "pause" and "unschedule"
 If 'interval' is 0, it will be called every frame, but if so, it recommended to use 'scheduleUpdateForTarget:' instead.
 'repeat' lets the action be repeated repeat + 1 times, use kCCRepeatForever to let the action run continuously.
 'delay' is the amount of time the action will wait before it'll start.
  If paused is YES, then it won't be called until it is resumed.
 If the block is already scheduled, then only the interval parameter will be updated without re-scheduling it again.
 @since v2.1
 */
-(void) scheduleBlockForKey:(NSString*)key target:(id)target interval:(ccTime)interval repeat:(uint)repeat delay:(ccTime)delay paused:(BOOL)paused block:(void(^)(ccTime dt))block;

/** Unshedules a selector for a given target.
 If you want to unschedule the "update", use unscheudleUpdateForTarget.
 @since v0.99.3
 */
-(void) unscheduleSelector:(SEL)selector forTarget:(id)target;

/** Unshedules a block for a given key / target pair.
 If you want to unschedule the "update", use unscheudleUpdateForTarget.
 @since v2.1
 */
-(void) unscheduleBlockForKey:(NSString*)key target:(id)target;

/** Unschedules the update selector for a given target
 @since v0.99.3
 */
-(void) unscheduleUpdateForTarget:(id)target;

/** Unschedules all selectors and blocks for a given target.
 This also includes the "update" selector.
 @since v0.99.3
 */
-(void) unscheduleAllForTarget:(id)target;

/** Unschedules all selectors and blocks from all targets.
 You should NEVER call this method, unless you know what you are doing.

 @since v0.99.3
 */
-(void) unscheduleAll;

/** Unschedules all selectors and blocks from all targets with a minimum priority.
  You should only call this with kCCPriorityNonSystemMin or higher.
  @since v2.0.0
  */
-(void) unscheduleAllWithMinPriority:(NSInteger)minPriority;

/** Pauses the target.
 All scheduled selectors/update for a given target won't be 'ticked' until the target is resumed.
 If the target is not present, nothing happens.
 @since v0.99.3
 */
-(void) pauseTarget:(id)target;

/** Resumes the target.
 The 'target' will be unpaused, so all schedule selectors/update will be 'ticked' again.
 If the target is not present, nothing happens.
 @since v0.99.3
 */
-(void) resumeTarget:(id)target;

/** Returns whether or not the target is paused
 @since v1.0.0
 */
-(BOOL) isTargetPaused:(id)target;

/** Pause all selectors and blocks from all targets.
  You should NEVER call this method, unless you know what you are doing.
 @since v2.0.0
  */
-(NSSet*) pauseAllTargets;

/** Pause all selectors and blocks from all targets with a minimum priority.
  You should only call this with kCCPriorityNonSystemMin or higher.
  @since v2.0.0
  */
-(NSSet*) pauseAllTargetsWithMinPriority:(NSInteger)minPriority;

/** Resume selectors on a set of targets.
 This can be useful for undoing a call to pauseAllSelectors.
 @since v2.0.0
  */
-(void) resumeTargets:(NSSet *)targetsToResume;

@end
