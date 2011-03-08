/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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

typedef void (*TICK_IMP)(id, SEL, ccTime);

//
// CCTimer
//
/** Light weight timer */
@interface CCTimer : NSObject
{
	id target;
	TICK_IMP impMethod;
	
	ccTime elapsed;

@public					// optimization
	ccTime interval;
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
-(void) update: (ccTime) dt;
@end



//
// CCScheduler
//
/** Scheduler is responsible of triggering the scheduled callbacks.
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
	ccTime				timeScale_;
	
	//
	// "updates with priority" stuff
	//
	struct _listEntry			*updatesNeg;	// list of priority < 0
	struct _listEntry			*updates0;		// list priority == 0
	struct _listEntry			*updatesPos;	// list priority > 0
	struct _hashUpdateEntry		*hashForUpdates;	// hash used to fetch quickly the list entries for pause,delete,etc.
		
	// Used for "selectors with interval"
	struct _hashSelectorEntry	*hashForSelectors;
	struct _hashSelectorEntry	*currentTarget;
	BOOL						currentTargetSalvaged;
	
	// Optimization
	TICK_IMP			impMethod;
	SEL					updateSelector;
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

/** The scheduled method will be called every 'interval' seconds.
 If paused is YES, then it won't be called until it is resumed.
 If 'interval' is 0, it will be called every frame, but if so, it recommened to use 'scheduleUpdateForTarget:' instead.
 If the selector is already scheduled, then only the interval parameter will be updated without re-scheduling it again.

 @since v0.99.3
 */
-(void) scheduleSelector:(SEL)selector forTarget:(id)target interval:(ccTime)interval paused:(BOOL)paused;

/** Schedules the 'update' selector for a given target with a given priority.
 The 'update' selector will be called every frame.
 The lower the priority, the earlier it is called.
 @since v0.99.3
 */
-(void) scheduleUpdateForTarget:(id)target priority:(int)priority paused:(BOOL)paused;

/** Unshedules a selector for a given target.
 If you want to unschedule the "update", use unscheudleUpdateForTarget.
 @since v0.99.3
 */
-(void) unscheduleSelector:(SEL)selector forTarget:(id)target;

/** Unschedules the update selector for a given target
 @since v0.99.3
 */
-(void) unscheduleUpdateForTarget:(id)target;

/** Unschedules all selectors for a given target.
 This also includes the "update" selector.
 @since v0.99.3
 */
-(void) unscheduleAllSelectorsForTarget:(id)target;

/** Unschedules all selectors from all targets.
 You should NEVER call this method, unless you know what you are doing.

 @since v0.99.3
 */
-(void) unscheduleAllSelectors;

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

@end
