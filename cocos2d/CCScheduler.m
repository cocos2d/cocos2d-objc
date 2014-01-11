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


/*
	Possible improvements:
	1) Binary search in PrioritySearch().
	2) Dirty flags on the method lists, filter during the next iteration.
	3) Doubly link timers to avoid O(n) removal cost.
*/


// cocos2d imports
#import "CCScheduler.h"
#import <objc/message.h>


#define FOREACH_TIMER(__scheduledTarget__, __timerVar__) for(CCTimer *__timerVar__ = __scheduledTarget__->_timers; __timerVar__; __timerVar__ = __timerVar__.next)


@interface CCScheduledTarget : NSObject

@property(nonatomic, readonly) NSObject<CCSchedulerTarget> *target;

@property(nonatomic, strong) CCTimer *timers;
@property(nonatomic, readonly) BOOL empty;
@property(nonatomic, assign) BOOL paused;
@property(nonatomic, assign) BOOL enableUpdates;

@end


@interface CCTimer (Private)

@property(nonatomic, readwrite) CCTime deltaTime;
@property(nonatomic, readonly) CCTimerBlock block;
@property(nonatomic, readonly) CCScheduledTarget *scheduledTarget;

// May differ from invoke time due to pausing.
@property(nonatomic, assign) CCTime invokeTimeInternal;
// Timers form a linked list per target.
@property(nonatomic, strong) CCTimer *next;
// Positive value when timer is paused or completing a pause,
// The minim amount of time remaining on the timer after the next invocation.
@property(nonatomic, readonly) CCTime pauseDelay;

@end


@interface CCScheduler (Private) <CCSchedulerTarget>
@end


@implementation CCScheduledTarget {
	__unsafe_unretained NSObject<CCSchedulerTarget> *_target;
	CCTimer *_timers;
}

static void
InvokeMethods(NSArray *methods, SEL selector, CCTime dt)
{
	for(CCScheduledTarget *scheduledTarget in [methods copy]){
		if(!scheduledTarget->_paused) objc_msgSend(scheduledTarget->_target, selector, dt);
	}
}

-(id)initWithTarget:(NSObject<CCSchedulerTarget> *)target
{
	if((self = [super init])){
		_target = target;
	}
	
	return self;
}

static CCTimer *
RemoveRecursive(CCTimer *timer, CCTimer *skip)
{
	if(timer == skip){
		return timer.next;
	} else {
		timer.next = RemoveRecursive(timer.next, skip);
		return timer;
	}
}

-(void)removeTimer:(CCTimer *)timer
{
	_timers = RemoveRecursive(_timers, timer);
}

-(void)invalidateTimers
{
	FOREACH_TIMER(self, timer) [timer invalidate];
}


-(BOOL)empty
{
	return (_timers == nil && !_enableUpdates);
}

-(void)setPaused:(BOOL)paused
{
	if(paused != _paused){
		FOREACH_TIMER(self, timer) timer.paused = paused;
		_paused = paused;
	}
}

@end


@interface NSNull(CCSchedulerTarget)<CCSchedulerTarget>
@end


@implementation NSNull(CCSchedulerTarget)
-(NSInteger)priority {return NSIntegerMax;}
@end


@implementation CCTimer {
	CCTimerBlock _block;
	CCTimer *_next;
	
	CCTime _invokeTimeInternal;
	CCTime _pauseDelay;
	
	__weak CCScheduler *_scheduler;
	__weak CCScheduledTarget *_scheduledTarget;
}

-(CCTime)invokeTime
{
	return (self.paused ? INFINITY : _invokeTimeInternal + _pauseDelay);
}

-(void)setPaused:(BOOL)paused
{
	if(paused){
		_pauseDelay = self.invokeTime - _scheduler.currentTime;
	} else {
		// Subtract off the delay to the next invoke time.
		_pauseDelay -= MAX(_invokeTimeInternal - _scheduler.currentTime, 0.0);
	}
	
	_paused = paused;
}

// A valid block that does nothing.
static CCTimerBlock INVALIDATED_BLOCK = ^(CCTimer *timer){};

-(void)repeatOnceWithInterval:(CCTime)interval
{
	self.repeatCount = 1;
	self.repeatInterval = interval;
}

-(void)invalidate
{
	_block = INVALIDATED_BLOCK;
	_scheduledTarget = nil;
	_repeatCount = 0;
}

-(BOOL)invalid {return (_block == INVALIDATED_BLOCK);}

@end


@implementation CCTimer(Private)

-(id)initWithDelay:(CCTime)delay scheduler:(CCScheduler *)scheduler scheduledTarget:(CCScheduledTarget *)scheduledTarget block:(CCTimerBlock)block;
{
	if((self = [super init])){
		_deltaTime = delay;
		_invokeTimeInternal = scheduler.currentTime + delay;
		_repeatInterval = delay;
		_scheduler = scheduler;
		_scheduledTarget = scheduledTarget;
		_block = [block copy];
	}
	
	return self;
}

-(CCTime)pauseDelay {return _pauseDelay;}

-(CCTime)invokeTimeInternal {return _invokeTimeInternal;}
-(void)setInvokeTimeInternal:(CCTime)invokeTimeInternal {_invokeTimeInternal = invokeTimeInternal;}

-(CCTimerBlock)block {return _block;}
-(CCScheduledTarget *)scheduledTarget {return _scheduledTarget;}

-(CCTimer *)next {return _next;}
-(void)setNext:(CCTimer *)next {_next = next;}

-(void)setDeltaTime:(CCTime)deltaTime {_deltaTime = deltaTime;}

@end


@implementation CCScheduler {
	CFBinaryHeapRef _heap;
	CFMutableDictionaryRef _scheduledTargets;
	
	NSMutableArray *_updates;
	NSMutableArray *_fixedUpdates;
	
	CCTimer *_fixedUpdateTimer;
}

static CFComparisonResult
ComparePriorities(const void *a, const void *b)
{
	NSInteger priority_a = [(__bridge CCTimer *)a scheduledTarget].target.priority;
	NSInteger priority_b = [(__bridge CCTimer *)b scheduledTarget].target.priority;
	
	if(priority_a < priority_b){
		return kCFCompareLessThan;
	} else if(priority_b < priority_a){
		return kCFCompareGreaterThan;
	} else {
		return kCFCompareEqualTo;
	}
}

static CFComparisonResult
CompareTimers(const void *a, const void *b, void *context)
{
	CCTime time_a = [(__bridge CCTimer *)a invokeTimeInternal];
	CCTime time_b = [(__bridge CCTimer *)b invokeTimeInternal];
	
	if(time_a < time_b){
		return kCFCompareLessThan;
	} else if(time_b < time_a){
		return kCFCompareGreaterThan;
	} else {
		return ComparePriorities(a, b);
	}
}

-(id)init
{
	if((self = [super init])){
		_timeScale = 1.0;
		_maxTimeStep = 1.0/10.0;
		
		CFBinaryHeapCallBacks callbacks = {
			.version = 0,
			.retain = NULL,
			.release = NULL,
			.copyDescription = NULL,
			.compare = CompareTimers,
		};
		
		_heap = CFBinaryHeapCreate(NULL, 0, &callbacks, NULL);
		
		_scheduledTargets = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		
		// All targets except nil should be implicitly paused initially.
		CCScheduledTarget *nilTarget = [self scheduledTargetForTarget:[NSNull null] insert:YES];
		nilTarget.paused = NO;
		
		_updates = [NSMutableArray array];
		_fixedUpdates = [NSMutableArray array];
		
		// Annoyance to avoid a retain cycle.
		__block __weak __typeof(self) _self = self;
		
		// Schedule a timer to run the fixedUpdate: methods.
		_fixedUpdateTimer = [self scheduleBlock:^(CCTimer *timer){
			if(timer.invokeTime > 0.0){
				CCScheduler *sceduler = _self;
				InvokeMethods(sceduler->_fixedUpdates, @selector(fixedUpdate:), timer.repeatInterval);
				sceduler->_lastFixedUpdateTime = timer.invokeTime;
			}
		} forTarget:self withDelay:0];

		_fixedUpdateTimer.repeatCount = CCTimerRepeatForever;
		_fixedUpdateTimer.repeatInterval = 1.0/60.0;
	}
	
	return self;
}

-(void)dealloc
{
	CFRelease(_heap);
	CFRelease(_scheduledTargets);
}

-(NSInteger)priority
{
	return NSIntegerMax;
}

-(CCTime)fixedUpdateInterval {return _fixedUpdateTimer.repeatInterval;}
-(void)setFixedUpdateInterval:(CCTime)fixedTimeStep {_fixedUpdateTimer.repeatInterval = fixedTimeStep;}

-(CCScheduledTarget *)scheduledTargetForTarget:(NSObject<CCSchedulerTarget> *)target insert:(BOOL)insert
{
	// Need to transform nil -> NSNulls.
	target = (target == nil ? [NSNull null] : target);
	
	CCScheduledTarget *scheduledTarget = CFDictionaryGetValue(_scheduledTargets, (__bridge CFTypeRef)target);
	if(scheduledTarget == nil && insert){
		scheduledTarget = [[CCScheduledTarget alloc] initWithTarget:target];
		CFDictionarySetValue(_scheduledTargets, (__bridge CFTypeRef)target, (__bridge CFTypeRef)scheduledTarget);
		
		// New targets are implicitly paused.
		scheduledTarget.paused = YES;
	}
	
	return scheduledTarget;
}

-(CCTimer *)scheduleBlock:(CCTimerBlock)block forTarget:(NSObject<CCSchedulerTarget> *)target withDelay:(CCTime)delay
{
	CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:YES];
	
	CCTimer *timer = [[CCTimer alloc] initWithDelay:delay scheduler:self scheduledTarget:scheduledTarget block:block];
	CFBinaryHeapAddValue(_heap, CFRetain((__bridge CFTypeRef)timer));
	
	timer.next = scheduledTarget.timers;
	scheduledTarget.timers = timer;
	
	return timer;
}

-(void)updateTo:(CCTime)targetTime
{
	NSAssert(targetTime >= _currentTime, @"Cannot step to a time in the past.");
	
	while(CFBinaryHeapGetCount(_heap) > 0){
		CCTimer *timer = CFBinaryHeapGetMinimum(_heap);
		CCTime invokeTime = timer.invokeTimeInternal;
		
		if(invokeTime > targetTime){
			break;
		} else {
			CFBinaryHeapRemoveMinimumValue(_heap);
		}
		
		_currentTime = invokeTime;
		
		CCTime pauseDelay = timer.pauseDelay;
		if(pauseDelay > 0.0){
			// Rschedule the timer with the minimum remaining delay due to the timer being paused.
			timer.invokeTimeInternal += pauseDelay;
			CFBinaryHeapAddValue(_heap, (__bridge CFTypeRef)timer);
		} else {
			timer.block(timer);
			
			if(timer.repeatCount > 0){
				if(timer.repeatCount < CCTimerRepeatForever) timer.repeatCount--;
				
				CCTime delay = timer.deltaTime = timer.repeatInterval;
				timer.invokeTimeInternal += delay;
				
				CFBinaryHeapAddValue(_heap, (__bridge CFTypeRef)timer);
			} else {
				CCScheduledTarget *scheduledTarget = timer.scheduledTarget;
				[scheduledTarget removeTimer:timer];
				if(scheduledTarget.empty){
					CFDictionaryRemoveValue(_scheduledTargets, (__bridge CFTypeRef)scheduledTarget.target);
				}
				
				[timer invalidate];
				
				// Timer was removed from the heap permanently.
				CFRelease((__bridge CFTypeRef)timer);
			}
		}
	}
	
	_currentTime = targetTime;
}

static NSUInteger
PrioritySearch(NSArray *array, NSInteger priority)
{
	for(NSUInteger i=0, count=array.count; i<count; i++){
		CCScheduledTarget *scheduledTarget = array[i];
		if(scheduledTarget.target.priority > priority) return i;
	}
	
	return array.count;
}

-(void)scheduleTarget:(NSObject<CCSchedulerTarget> *)target
{
	BOOL update = [target respondsToSelector:@selector(update:)];
	BOOL fixedUpdate = [target respondsToSelector:@selector(fixedUpdate:)];
	
	// Don't bother scheduling anything if it doesn't implement any methods.
	if(update || fixedUpdate){
		CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:YES];
		
		// Don't schedule something more than once.
		if(!scheduledTarget.enableUpdates){
			scheduledTarget.enableUpdates = YES;
			NSInteger priority = target.priority;
			
			if(update) [_updates insertObject:scheduledTarget atIndex:PrioritySearch(_updates, priority)];
			if(fixedUpdate) [_fixedUpdates insertObject:scheduledTarget atIndex:PrioritySearch(_fixedUpdates, priority)];
		}
	}
}

-(void)unscheduleTarget:(NSObject<CCSchedulerTarget> *)target
{
	CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:NO];
	
	if(scheduledTarget){
		// Remove the update methods if they are scheduled
		if(scheduledTarget.enableUpdates){
			if([scheduledTarget.target respondsToSelector:@selector(update:)]){
				[_updates removeObject:scheduledTarget];
			}
			
			if([scheduledTarget.target respondsToSelector:@selector(fixedUpdate:)]){
				[_fixedUpdates removeObject:scheduledTarget];
			}
		}
		
		[scheduledTarget invalidateTimers];
		
		CFDictionaryRemoveValue(_scheduledTargets, (__bridge CFTypeRef)target);
	}
}

-(BOOL)isTargetScheduled:(NSObject<CCSchedulerTarget> *)target
{
	return ([self scheduledTargetForTarget:target insert:NO] != nil);
}

-(void)setPaused:(BOOL)paused target:(NSObject<CCSchedulerTarget> *)target
{
	CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:NO];
	scheduledTarget.paused = paused;
}

-(BOOL)isTargetPaused:(NSObject<CCSchedulerTarget> *)target
{
	CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:NO];
	return scheduledTarget.paused;
}

-(NSArray *)timersForTarget:(NSObject<CCSchedulerTarget> *)target
{
	CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:NO];
	
	NSMutableArray *arr = [NSMutableArray array];
	for(CCTimer *timer = scheduledTarget.timers; timer; timer = timer.next){
		[arr addObject:timer];
	}
	
	return arr;
}

-(void)update:(CCTime)dt
{
	CCTime clampedDelta = MIN(dt*_timeScale, _maxTimeStep);
	[self updateTo:_currentTime + clampedDelta];
	
	InvokeMethods(_updates, @selector(update:), clampedDelta);
	_lastUpdateTime = _currentTime;
}

@end
