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
	* Binary search in insertTarget: withPriority. ( would need a lot of actions per object)
*/


// cocos2d imports
#import "CCScheduler_Private.h"
#import <objc/message.h>
#import "CCAction_Private.h"

#define FOREACH_TIMER(__scheduledTarget__, __timerVar__) for(CCTimer *__timerVar__ = __scheduledTarget__->_timers; __timerVar__; __timerVar__ = __timerVar__.next)


#pragma mark Private Interfaces

@interface CCScheduledTarget : NSObject {
    @public
    BOOL _paused;
}


@property(nonatomic, readonly, unsafe_unretained) NSObject<CCSchedulableTarget> *target;

@property(nonatomic, strong) CCTimer *timers;
@property(nonatomic, strong) NSMutableArray *actions;
@property(nonatomic, readonly) BOOL empty;
@property(nonatomic, assign) BOOL paused;
@property(nonatomic, assign) BOOL enableUpdates;

@end


@interface CCTimer()

@property(nonatomic, readwrite) CCTime deltaTime;
@property(nonatomic, readonly) CCTimerBlock block;
@property(nonatomic, readonly) CCScheduledTarget *scheduledTarget;

// May differ from invoke time due to pausing.
@property(nonatomic, assign) CCTime invokeTimeInternal;
// Timers form a linked list per target.
@property(nonatomic, strong) CCTimer *next;
// Invocation requires an extra delay due to being paused.
@property(nonatomic, readonly) BOOL requiresDelay;
// If the timer is currently added to the heap or not.
@property(nonatomic, assign) BOOL scheduled;

@end


@interface CCScheduler() <CCSchedulableTarget>

@property(nonatomic, strong) CCTimer *timers;

-(void)scheduleTimer:(CCTimer *)timer retain:(BOOL)retain;

@end


#pragma mark Copy on Write Arrays

// This is an NSMutableArray-like class that implements copy-on-write to allow modifying an array while iterating it.
// This is for performance reasons so that we don't need to copy large arrays every frame to iterate them safely.
// Instead, the copy is only performed when the array is actually changed.

@interface CopyOnWriteArray : NSObject<NSFastEnumeration> @end
@implementation CopyOnWriteArray {
    NSMutableArray * _array;
    NSMutableArray * _copyArray;
    BOOL _locked;
    Class backingClass;
}

// Provide NSMutableArray or NSMutableSet
-(instancetype)initWithBackingClass:(Class) c
{
    if((self = [super init])){
        backingClass = c;
    }
    return self;
}

-(id) writeArray
{
    // Lazily init the array.
    if(_array == nil){
        _array = [[backingClass alloc] init];
    }
    
    if(_locked){
        // When the array is locked, we have to mutate a copy.
        // The modified array is commited in the unlock method.
        if(_copyArray == nil){
            _copyArray = [_array mutableCopy];
        }
        
        return _copyArray;
    }else{
        return _array;
    }
}

-(void)dealloc
{
    [_array release]; _array = nil;
    [_copyArray release]; _copyArray = nil;
    
    [super dealloc];
}

// Intended to be called only on arrays of scheduled targets!
- (void)insertTarget:(CCScheduledTarget*)object withPriority:(NSUInteger)priority;
{
    NSMutableArray *array = self.writeArray;
    for(NSUInteger i=0, count=array.count; i<count; i++){
        CCScheduledTarget *scheduledTarget = array[i];
        if(scheduledTarget.target.priority > priority) {
            [array insertObject:object atIndex:i];
            return;
        };
    }
    
    // All targets are lower priority, add to the end.
    [self addObject:object];
}

-(void)addObject:(id) obj
{
    [self.writeArray addObject:obj];
}

-(void)removeObject:(id) obj
{
    [self.writeArray removeObject:obj];
}

-(void)removeAllObjects
{
    [self.writeArray removeAllObjects];
}

-(void)lock
{
    NSAssert(!_locked, @"Enumerator started when already locked");
    _locked = YES;
}

-(void)unlock
{
    NSAssert(_locked, @"Already unlocked!");
    _locked = NO;
    
    // If the array was mutated, _copyArray will be non-nil and contain the changes.
    if(_copyArray){
        [_array release];
        
        _array = _copyArray;
        _copyArray = nil;
    }
}

// If the enumerator will modify the array, it must be locked before iteration and unlocked aferwards to commit the changes.
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;
{
    return [_array countByEnumeratingWithState:state objects:buffer count:len];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ locked:%d", [self.writeArray description], _locked];
}

@end


#pragma mark Scheduled Targets

@implementation CCScheduledTarget

static void
InvokeMethods(CopyOnWriteArray *methods, SEL selector, CCTime dt)
{
	[methods lock];
    for(CCScheduledTarget *scheduledTarget in methods){
		typedef void (*Func)(id, SEL, CCTime);
		if(!scheduledTarget->_paused) ((Func)objc_msgSend)(scheduledTarget->_target, selector, dt);
	}
    [methods unlock];
}

-(id)initWithTarget:(NSObject<CCSchedulableTarget> *)target
{
    if((self = [super init])){
        _target = target;
    }
    
    return self;
}

-(void)dealloc
{
    self.timers = nil;
    self.actions = nil;
    
    [super dealloc];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"<CCScheduledTarget: %@, %@, %@>", _target.description, _timers.description, _actions.description];
}

-(NSMutableArray *)actions
{
    if(_actions == nil){
        _actions = [[NSMutableArray alloc] init];
    }
    
    return _actions;
}

-(BOOL)hasActions
{
    return !(_actions == nil || [_actions count] == 0);
}

-(void)addAction:(CCAction *)action
{
    [self.actions addObject:action];
}

-(void)removeAction:(CCAction *) action
{
    [_actions removeObject:action];
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
    self.timers = RemoveRecursive(_timers, timer);
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


@interface NSNull(CCSchedulableTarget)<CCSchedulableTarget>
@end


@implementation NSNull(CCSchedulableTarget)
-(NSInteger)priority {return NSIntegerMax;}
@end


#pragma mark CCTimer

@implementation CCTimer {
	CCTimerBlock _block;

	CCTime _invokeTimeInternal;
	CCTime _pauseDelay;
	BOOL _scheduled;
	
	__weak CCScheduler *_scheduler;
	__weak CCScheduledTarget *_scheduledTarget;
}

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

-(void)dealloc
{
    [_block release]; _block = nil;
    self.next = nil;
    self.userData = nil;
    
    [super dealloc];
}

-(CCTime)invokeTime
{
	return (_paused || self.invalid ? INFINITY : _invokeTimeInternal + _pauseDelay);
}

-(void)applyPauseDelay:(CCTime)currentTime
{
	_invokeTimeInternal = MAX(_invokeTimeInternal, currentTime) + _pauseDelay;
	_pauseDelay = 0.0;
}

-(void)setPaused:(BOOL)paused
{
	if(paused != _paused){
		CCTime currentTime = _scheduler.currentTime;
		
		// This should ensure _pauseDelay is always positive since currentTime can never decrease.
		_pauseDelay += MAX(_invokeTimeInternal - currentTime, 0.0)*(paused ? 1.0 : -1.0);
		
		if(!paused && !_scheduled){
			[self applyPauseDelay:currentTime];
			[_scheduler scheduleTimer:self retain:YES];
		}
		
		_paused = paused;
	}
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
    [_block release];
	_block = [INVALIDATED_BLOCK copy];
	_scheduledTarget = nil;
	_repeatCount = 0;
}

-(BOOL)invalid {return (_block == INVALIDATED_BLOCK);}

-(BOOL)requiresDelay {return (_pauseDelay > 0.0);}

-(BOOL)scheduled {return _scheduled;}
-(void)setScheduled:(BOOL)scheduled {_scheduled = scheduled;}

-(CCTime)invokeTimeInternal {return _invokeTimeInternal;}
-(void)setInvokeTimeInternal:(CCTime)invokeTimeInternal {_invokeTimeInternal = invokeTimeInternal;}

-(CCTimerBlock)block {return _block;}
-(CCScheduledTarget *)scheduledTarget {return _scheduledTarget;}

-(void)setDeltaTime:(CCTime)deltaTime {_deltaTime = deltaTime;}

@end


#pragma mark CCScheduler

@implementation CCScheduler {
	CFBinaryHeapRef _heap;
	CFMutableDictionaryRef _scheduledTargets;
	
	CopyOnWriteArray *_updates;
    CopyOnWriteArray *_fixedUpdates;
    CopyOnWriteArray *_scheduledTargetsWithActions;
	
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
        
        _updates = [[CopyOnWriteArray alloc ] initWithBackingClass:[NSMutableArray class]];
        _fixedUpdates = [[CopyOnWriteArray alloc ] initWithBackingClass:[NSMutableArray class]];
        _scheduledTargetsWithActions = [[CopyOnWriteArray alloc ] initWithBackingClass:[NSMutableSet class]];
        
        // Annoyance to avoid a retain cycle.
        __block __typeof(self) _self = self;
        
        // Schedule a timer to run the fixedUpdate: methods.
        _fixedUpdateTimer = [[self scheduleBlock:^(CCTimer *timer){
            if(timer.invokeTime > 0.0){
                CCScheduler *scheduler = _self;
                InvokeMethods(scheduler->_fixedUpdates, @selector(fixedUpdate:), timer.repeatInterval);
                if(_self.actionsRunInFixedMode){
                    [_self updateActions:timer.repeatInterval];
                }
                scheduler->_lastFixedUpdateTime = timer.invokeTime;
            }
            
        } forTarget:self withDelay:0] retain];
        
        _fixedUpdateTimer.repeatCount = CCTimerRepeatForever;
        _fixedUpdateTimer.repeatInterval = 1.0/60.0;
    }
    
    return self;
}

-(void)dealloc
{
    CFRelease(_heap); _heap = nil;
    CFRelease(_scheduledTargets); _scheduledTargets = nil;
    
    [_updates release]; _updates = nil;
    [_fixedUpdates release]; _fixedUpdates = nil;
    [_scheduledTargetsWithActions release]; _scheduledTargetsWithActions = nil;
  
    [_fixedUpdateTimer release]; _fixedUpdateTimer = nil;
    
    [super dealloc];
}

-(NSInteger)priority
{
	return NSIntegerMax;
}

-(CCTime)fixedUpdateInterval {return _fixedUpdateTimer.repeatInterval;}
-(void)setFixedUpdateInterval:(CCTime)fixedTimeStep {_fixedUpdateTimer.repeatInterval = fixedTimeStep;}

-(CCScheduledTarget *)scheduledTargetForTarget:(NSObject<CCSchedulableTarget> *)target insert:(BOOL)insert
{
	// Need to transform nil -> NSNulls.
	target = (target == nil ? [NSNull null] : target);
	
	CCScheduledTarget *scheduledTarget = CFDictionaryGetValue(_scheduledTargets, target);
	if(scheduledTarget == nil && insert){
		scheduledTarget = [[CCScheduledTarget alloc] initWithTarget:target];
		CFDictionarySetValue(_scheduledTargets, target, scheduledTarget);
        [scheduledTarget release];
        
		// New targets are implicitly paused.
		scheduledTarget.paused = YES;
	}
	
	return scheduledTarget;
}

-(void)scheduleTimer:(CCTimer *)timer retain:(BOOL)retain
{
	if(retain) [timer retain];
	
	CFBinaryHeapAddValue(_heap, timer);
	timer.scheduled = YES;
}

-(CCTimer *)scheduleBlock:(CCTimerBlock)block forTarget:(NSObject<CCSchedulableTarget> *)target withDelay:(CCTime)delay
{
	CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:YES];
	
	CCTimer *timer = [[CCTimer alloc] initWithDelay:delay scheduler:self scheduledTarget:scheduledTarget block:block];
	[self scheduleTimer:timer retain:YES];
    [timer release];
	
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
			timer.scheduled = NO;
		}
		
		_currentTime = invokeTime;
		
		if(timer.paused){
			// Release the timer now in case it never becomes rescheduled.
            [timer release];
		} else if(timer.requiresDelay){
			[timer applyPauseDelay:_currentTime];
			[self scheduleTimer:timer retain:NO];
		} else {
			timer.block(timer);
			
			if(timer.repeatCount > 0){
				if(timer.repeatCount < CCTimerRepeatForever) timer.repeatCount--;
				
				CCTime delay = timer.deltaTime = timer.repeatInterval;
				timer.invokeTimeInternal += delay;
				
				NSAssert(delay > 0.0, @"Rescheduling a timer with a repeat interval of 0 will cause an infinite loop.");
				[self scheduleTimer:timer retain:NO];
			} else {
				CCScheduledTarget *scheduledTarget = timer.scheduledTarget;
				[scheduledTarget removeTimer:timer];
				if(scheduledTarget.empty){
					CFDictionaryRemoveValue(_scheduledTargets, scheduledTarget.target);
				}
				
				// We are done with the timer.
				[timer invalidate];
                [timer release];
			}
		}
	}
	
	_currentTime = targetTime;
}


-(void)scheduleTarget:(NSObject<CCSchedulableTarget> *)target
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
			
			if(update) [_updates insertTarget:scheduledTarget withPriority:priority];
			if(fixedUpdate) [_fixedUpdates insertTarget:scheduledTarget withPriority:priority];
		}
        
    }
}

-(void)unscheduleTarget:(NSObject<CCSchedulableTarget> *)target
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
        
        if([scheduledTarget hasActions]){
            [_scheduledTargetsWithActions removeObject:scheduledTarget];
        }
        
		[scheduledTarget invalidateTimers];
		
		CFDictionaryRemoveValue(_scheduledTargets, target);
	}
}

-(BOOL)isTargetScheduled:(NSObject<CCSchedulableTarget> *)target
{
	return ([self scheduledTargetForTarget:target insert:NO] != nil);
}

-(void)setPaused:(BOOL)paused target:(NSObject<CCSchedulableTarget> *)target
{
	CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:NO];
	scheduledTarget.paused = paused;
}

-(BOOL)isTargetPaused:(NSObject<CCSchedulableTarget> *)target
{
	CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:NO];
	return scheduledTarget.paused;
}

-(NSArray *)timersForTarget:(NSObject<CCSchedulableTarget> *)target
{
	CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:NO];
	
	NSMutableArray *arr = [NSMutableArray array];
	for(CCTimer *timer = scheduledTarget.timers; timer; timer = timer.next){
		if(!timer.invalid) [arr addObject:timer];
	}
	
	return arr;
}

-(void)update:(CCTime)dt
{
    CCTime clampedDelta = MIN(dt*_timeScale, _maxTimeStep);
    [self updateTo:_currentTime + clampedDelta];
    
    InvokeMethods(_updates, @selector(update:), clampedDelta);
    if(!self.actionsRunInFixedMode) {
        [self updateActions:dt];
    }
    
    _lastUpdateTime = _currentTime;
}

#pragma mark Scheduling CCActions

-(void)addAction:(CCAction*)action target:(NSObject<CCSchedulableTarget> *)target paused:(BOOL)paused
{
    NSAssert(action, @"Argument action must be non-nil");
    NSAssert(target, @"Argument target must be non-nil");
    
    CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:YES];
    scheduledTarget.paused = paused;
    
    if(scheduledTarget.hasActions){
        NSAssert(![scheduledTarget.actions containsObject:action], @"Action already running on this target.");
    } else {
        // This is the first action that has been scheduled for this target.
        // It needs to be added to the list of targets with actions.
        [_scheduledTargetsWithActions addObject:scheduledTarget];
    }
    
    [scheduledTarget addAction:action];
    
    [action startWithTarget:target];
}

-(void)removeAction:(CCAction*) action fromTarget:(NSObject<CCSchedulableTarget> *)target;
{
    CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:YES];
    [scheduledTarget.actions removeObject:action];
}

-(void)removeAllActionsFromTarget:(NSObject<CCSchedulableTarget> *)target
{
    CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:YES];
    
    for(CCAction *action in [scheduledTarget.actions copy]){
        [scheduledTarget removeAction:action];
    }
    
    [_scheduledTargetsWithActions removeObject:scheduledTarget];
}

-(void)removeActionByName:(NSString *)name target:(NSObject<CCSchedulableTarget> *)target
{
    CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:YES];
    
    for (CCAction *action in [scheduledTarget.actions copy]) {
        if ([action.name isEqualToString:name]){
            [scheduledTarget removeAction:action];
        }
    }
    
    if(!scheduledTarget.hasActions){
        [_scheduledTargetsWithActions removeObject:scheduledTarget];
    }
}

-(CCAction*)getActionByName:(NSString *)name target:(NSObject<CCSchedulableTarget> *)target
{
    CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:YES];
    for (CCAction *action in scheduledTarget.actions) {
        if ([action.name isEqualToString:name]) return action;
    }
    return nil;
}

-(NSArray *) actionsForTarget:(NSObject<CCSchedulableTarget> *)target
{
    CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:YES];
    return scheduledTarget.actions;
}

-(void) updateActions: (CCTime)dt
{
    NSMutableArray *completedActions = [[NSMutableArray alloc] init];
    
    [_scheduledTargetsWithActions lock];
    for (CCScheduledTarget *st in _scheduledTargetsWithActions) {
        if(st->_paused) continue;
        
        for (CCAction *action in st.actions) {
            [action step: dt];
            if([action isDone]){
                [action stop];
                [completedActions addObject:action];
            }
        }
        
        if(completedActions.count > 0){
            for (CCAction *action in completedActions) {
                [st removeAction: action];
            }
            
            if(![st hasActions]){
                [_scheduledTargetsWithActions removeObject: st];
            }
            
            [completedActions removeAllObjects];
        }
    }
    [_scheduledTargetsWithActions unlock];
    
    [completedActions release];
}

@end
