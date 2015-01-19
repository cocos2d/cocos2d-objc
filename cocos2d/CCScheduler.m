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
#import "CCScheduler.h"
#import <objc/message.h>
#import "CCAction.h"

#define FOREACH_TIMER(__scheduledTarget__, __timerVar__) for(CCTimer *__timerVar__ = __scheduledTarget__->_timers; __timerVar__; __timerVar__ = __timerVar__.next)

@interface CCScheduledTarget : NSObject
{
    @public
    BOOL _paused;
}


@property(nonatomic, readonly) NSObject<CCSchedulableTarget> *target;

@property(nonatomic, strong) CCTimer *timers;
@property(nonatomic, readonly) BOOL empty;
@property(nonatomic, assign) BOOL paused;
@property(nonatomic, assign) BOOL enableUpdates;

@end

@interface CopyOnWriteArray : NSObject<NSFastEnumeration>

@end

@implementation CopyOnWriteArray
{
    NSMutableArray * _array;
    NSMutableArray * _copyArray;
    BOOL _locked;
}

-(NSMutableArray *) writeArray
{
    if(_array == nil){
        _array = [[NSMutableArray alloc] init];
    }
    if(_locked){
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
    [self removeAllObjects];
    [super dealloc];
}

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
    [_array release]; _array = nil;
    [_copyArray release]; _copyArray = nil;
}

-(void)lock
{
    if(_array == nil){
        _array = [[NSMutableArray alloc] init];
    }

    NSAssert(!_locked, @"Enumerator started when already locked");
    _locked = YES;
    [_array retain];
}

-(void)unlock
{
    [_array release];
    NSAssert(_locked, @"Already unlocked!");
    if(_copyArray){
        _array = _copyArray;
        _copyArray = nil;
    }
    _locked = NO;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;
{
    return [_array countByEnumeratingWithState:state objects:buffer count:len];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ locked:%d", self.writeArray.description, _locked];
}

@end


@interface CCTimer ()

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


@interface CCScheduler (Private) <CCSchedulableTarget>

@property(nonatomic, strong) CCTimer *timers;

-(void)scheduleTimer:(CCTimer *)timer retain:(BOOL)retain;

@end


@implementation CCScheduledTarget {
	__unsafe_unretained NSObject<CCSchedulableTarget> *_target;
    NSMutableArray *_actions;
}

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
    [_actions release];
    _actions = nil;
    [super dealloc];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"<CCScheduledTarget: %@, %@, %@>", _target.description, _timers.description, _actions.description];
}

/**
 Get or create a list of CCActions for this scheduled target.
 */
-(NSMutableArray *) getActions
{
    if(_actions == nil){
        _actions = [[NSMutableArray alloc] init];
    }
    return _actions;
}

/**
 Set the array of CCActions.
 */
-(void) setActions:(NSMutableArray *)arr;
{
    NSMutableArray * a =[arr retain];
    [_actions release];
    _actions = a;
}

-(BOOL) hasActions
{
    return (_actions == nil || [_actions count] == 0);
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
		
		_updates = [[CopyOnWriteArray alloc ] init];
		_fixedUpdates = [[CopyOnWriteArray alloc ] init];
        _scheduledTargetsWithActions = [[CopyOnWriteArray alloc ] init];
		
		// Annoyance to avoid a retain cycle.
        __block __typeof(self) _self = self;
		
		// Schedule a timer to run the fixedUpdate: methods.
		_fixedUpdateTimer = [[self scheduleBlock:^(CCTimer *timer){
			if(timer.invokeTime > 0.0){
				CCScheduler *scheduler = _self;
				InvokeMethods(scheduler->_fixedUpdates, @selector(fixedUpdate:), timer.repeatInterval);
				scheduler->_lastFixedUpdateTime = timer.invokeTime;
			}
        #warning TODO: also invoke fixed update actions:
            
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
	
	CCScheduledTarget *scheduledTarget = CFDictionaryGetValue(_scheduledTargets, (__bridge CFTypeRef)target);
	if(scheduledTarget == nil && insert){
		scheduledTarget = [[CCScheduledTarget alloc] initWithTarget:target];
		CFDictionarySetValue(_scheduledTargets, (__bridge CFTypeRef)target, (__bridge CFTypeRef)scheduledTarget);
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
    
    #warning TODO: also invoke update actions:
    [self updateActions:dt];
    
	_lastUpdateTime = _currentTime;
}

//MARK: Scheduling CCActions

-(void)addAction:(CCAction*)action target:(NSObject<CCSchedulableTarget> *)target paused:(BOOL)paused
{
    [action startWithTarget:target];
    
    // retrieve or create scheduled target:
    CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:YES];
    [[scheduledTarget getActions] addObject:action];
    [_scheduledTargetsWithActions addObject:scheduledTarget];
}

-(void)removeAllActions
{
    for (CCScheduledTarget *st in _scheduledTargetsWithActions) {
        st.actions = nil;
    }

    [_scheduledTargetsWithActions removeAllObjects];
}

-(void)removeAllActionsFromTarget:(NSObject<CCSchedulableTarget> *)target
{
    CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:YES];
    scheduledTarget.actions = nil;
}

-(void)removeAction:(CCAction*) action
{
    [_scheduledTargetsWithActions lock];
    for (CCScheduledTarget *st in _scheduledTargetsWithActions ) {
        [st removeAction:action];
        if(![st hasActions]){
            [_scheduledTargetsWithActions removeObject: st];
        }
    }
    [_scheduledTargetsWithActions unlock];

}

-(void)removeActionByTag:(NSInteger)tag target:(NSObject<CCSchedulableTarget> *)target
{
    CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:YES];
    NSMutableArray *keep = [NSMutableArray array];
    for (CCAction *action in [scheduledTarget getActions]) {
        if (action.tag != tag){
            [keep addObject:action];
        }
    }
    scheduledTarget.actions = keep;
}

-(CCAction*)getActionByTag:(NSInteger) tag target:(NSObject<CCSchedulableTarget> *)target
{
    CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:YES];
    for (CCAction *action in [scheduledTarget getActions]) {
        if (action.tag == tag) return action;
    }
    return nil;
}

-(NSArray *) actionsForTarget:(NSObject<CCSchedulableTarget> *)target
{
    CCScheduledTarget *scheduledTarget = [self scheduledTargetForTarget:target insert:YES];
    return [scheduledTarget getActions];
}

-(NSSet *)pauseAllRunningActions
{
    NSMutableSet *set = [NSMutableSet set];
    for (CCScheduledTarget *st in _scheduledTargetsWithActions) {
        if(!st.paused){
            st.paused = true;
            [set addObject:st];
        }
    }
    return set;
}

-(void)resumeTargets:(NSSet *)targetsToResume
{
    for (CCScheduledTarget *st in _scheduledTargetsWithActions) {
        st.paused = false;
    }
}

-(void) updateActions: (CCTime)dt
{
    NSMutableArray *removals = [NSMutableArray array];
    
    [_scheduledTargetsWithActions lock];
    for (CCScheduledTarget *st in _scheduledTargetsWithActions) {
        if(st->_paused) continue;
       
        [removals removeAllObjects];
        
        for (CCAction *action in [st getActions]) {
            [action step: dt];
            if([action isDone]){
                [action stop];
                [removals addObject:action];
            }
        }
        
        if(removals.count > 0){
            for (CCAction *action in removals) {
                [st removeAction: action];
            }
            if(![st hasActions]){
                [_scheduledTargetsWithActions removeObject: st];
            }
        }
    }
    [_scheduledTargetsWithActions unlock];
}


@end
