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


// cocos2d imports
#import "CCScheduler.h"
#import "ccMacros.h"
#import "CCDirector.h"
#import "Support/uthash.h"
#import "Support/utlist.h"
#import "Support/ccCArray.h"

//
// Data structures
//
#pragma mark -
#pragma mark Data Structures

// A list double-linked list used for "updates with priority"
typedef struct _listEntry
{
	struct	_listEntry *prev, *next;
	TICK_IMP	impMethod;
	id			target;				// not retained (retained by hashUpdateEntry)
	NSInteger	priority;
	BOOL		paused;
    BOOL		markedForDeletion;	// selector will no longer be called and entry will be removed at end of the next tick
} tListEntry;

typedef struct _hashUpdateEntry
{
	tListEntry		**list;		// Which list does it belong to ?
	tListEntry		*entry;		// entry in the list
	id				target;		// hash key (retained)
	UT_hash_handle  hh;
} tHashUpdateEntry;

// Hash Element used for "selectors with interval"
typedef struct _hashSelectorEntry
{
	struct ccArray	*timers;
	id				target;		// hash key (retained)
	unsigned int	timerIndex;
	CCTimer			*currentTimer;
	BOOL			currentTimerSalvaged;
	BOOL			paused;
	UT_hash_handle  hh;
} tHashTimerEntry;



//
// CCTimer
//
#pragma mark - CCTimer

@interface CCTimer ()
-(void) setupTimerWithInterval:(ccTime)seconds repeat:(uint)r delay:(ccTime)d;
-(void) trigger;
-(void) cancel;
@end

@implementation CCTimer

@synthesize interval=_interval;

-(void) setupTimerWithInterval:(ccTime)seconds repeat:(uint)r delay:(ccTime)d
{
	_elapsed = -1;
	_interval = seconds;
	_delay = d;
	_useDelay = (_delay > 0) ? YES : NO;
	_repeat = r;
	_runForever = (_repeat == kCCRepeatForever) ? YES : NO;
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);

	[super dealloc];
}

-(void) trigger
{
	// override me
}

-(void) cancel
{
	// override me
}

-(void) update: (ccTime) dt
{
	if( _elapsed == - 1)
	{
		_elapsed = 0;
		_nTimesExecuted = 0;
	}
	else
	{
		if (_runForever && !_useDelay)
		{//standard timer usage
			_elapsed += dt;
			if( _elapsed >= _interval ) {
				[self trigger];
				_elapsed = 0;

			}
		}
		else
		{//advanced usage
			_elapsed += dt;
			if (_useDelay)
			{
				if( _elapsed >= _delay )
				{
					[self trigger];
					_elapsed = _elapsed - _delay;
					_nTimesExecuted+=1;
					_useDelay = NO;
				}
			}
			else
			{
				if (_elapsed >= _interval)
				{
					[self trigger];
					_elapsed = 0;
					_nTimesExecuted += 1;

				}
			}

			if (!_runForever && _nTimesExecuted > _repeat)
			{	//unschedule timer
				[self cancel];
			}
		}
	}
}
@end

#pragma mark CCTimerTargetSelector

@implementation CCTimerTargetSelector

@synthesize selector=_selector;

+(id) timerWithTarget:(id)t selector:(SEL)s
{
	return [[[self alloc] initWithTarget:t selector:s interval:0 repeat:kCCRepeatForever delay:0] autorelease];
}

+(id) timerWithTarget:(id)t selector:(SEL)s interval:(ccTime) i
{
	return [[[self alloc] initWithTarget:t selector:s interval:i repeat:kCCRepeatForever delay:0] autorelease];
}

-(id) initWithTarget:(id)t selector:(SEL)s
{
	return [self initWithTarget:t selector:s interval:0 repeat:kCCRepeatForever delay: 0];
}

-(id) initWithTarget:(id)t selector:(SEL)s interval:(ccTime) seconds repeat:(uint) r delay:(ccTime) d
{
	if( (self=[super init]) ) {
#if COCOS2D_DEBUG
		NSMethodSignature *sig = [t methodSignatureForSelector:s];
		NSAssert(sig !=0 , @"Signature not found for selector - does it have the following form? -(void) name: (ccTime) dt");
#endif

		// target is not retained. It is retained in the hash structure
		_target = t;
		_selector = s;
		_impMethod = (TICK_IMP) [t methodForSelector:s];
		
		[self setupTimerWithInterval:seconds repeat:r delay:d];
	}
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | target:%@ selector:(%@)>", [self class], self, [_target class], NSStringFromSelector(_selector)];
}

-(void) trigger
{
	_impMethod(_target, _selector, _elapsed);
}

-(void) cancel
{
	[[[CCDirector sharedDirector] scheduler] unscheduleSelector:_selector forTarget:_target];
}

@end

#pragma mark CCTimerBlock

@implementation CCTimerBlock

@synthesize key=_key;
@synthesize target=_target;

+(id) timerWithTarget:(id)owner interval:(ccTime)seconds key:(NSString*)key block:(void(^)(ccTime delta)) block
{
	return [[[self alloc] initWithTarget:(id)owner interval:seconds repeat:kCCRepeatForever delay:0 key:key block:block] autorelease];
}

-(id) initWithTarget:(id)owner interval:(ccTime) seconds repeat:(uint) r delay:(ccTime)d key:(NSString*)key block:(void(^)(ccTime delta))block
{
	if( (self=[super init]) ) {
		_block = [block copy];
		_key = [key copy];
		_target = owner;
		
		[self setupTimerWithInterval:seconds repeat:r delay:d];
	}
	
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | block>", [self class], self];
}

- (void)dealloc
{
	[_key release];
    [_block release];

    [super dealloc];
}

-(void) trigger
{
	_block( _elapsed);
}

-(void) cancel
{
	[[[CCDirector sharedDirector] scheduler] unscheduleBlockForKey:_key target:_target];
}

@end



//
// CCScheduler
//
#pragma mark - CCScheduler

@interface CCScheduler (Private)
-(void) removeHashElement:(tHashTimerEntry*)element;
@end

@implementation CCScheduler

@synthesize timeScale = timeScale_;

- (id) init
{
	if( (self=[super init]) ) {
		timeScale_ = 1.0f;

		// used to trigger CCTimer#update
		updateSelector = @selector(update:);
		impMethod = (TICK_IMP) [CCTimerTargetSelector instanceMethodForSelector:updateSelector];

		// updates with priority
		updates0 = NULL;
		updatesNeg = NULL;
		updatesPos = NULL;
		hashForUpdates = NULL;

		// selectors with interval
		currentTarget = nil;
		currentTargetSalvaged = NO;
		hashForTimers = nil;
        updateHashLocked = NO;
	}

	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | timeScale = %0.2f >", [self class], self, timeScale_];
}

- (void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);

	[self unscheduleAll];

	[super dealloc];
}


#pragma mark CCScheduler - Timers

-(void) removeHashElement:(tHashTimerEntry*)element
{
	ccArrayFree(element->timers);
	[element->target release];
	HASH_DEL(hashForTimers, element);
	free(element);
}

-(void) scheduleSelector:(SEL)selector forTarget:(id)target interval:(ccTime)interval paused:(BOOL)paused
{
	[self scheduleSelector:selector forTarget:target interval:interval repeat:kCCRepeatForever delay:0.0f paused:paused];
}

-(void) scheduleSelector:(SEL)selector forTarget:(id)target interval:(ccTime)interval repeat:(uint)repeat delay:(ccTime)delay paused:(BOOL)paused 
{
	NSAssert( selector != nil, @"Argument selector must be non-nil");
	NSAssert( target != nil, @"Argument target must be non-nil");

	tHashTimerEntry *element = NULL;
	HASH_FIND_INT(hashForTimers, &target, element);

	if( ! element ) {
		element = calloc( sizeof( *element ), 1 );
		element->target = [target retain];
		HASH_ADD_INT( hashForTimers, target, element );

		// Is this the 1st element ? Then set the pause level to all the selectors of this target
		element->paused = paused;

	} else
		NSAssert( element->paused == paused, @"CCScheduler. Trying to schedule a selector with a pause value different than the target");


	if( element->timers == nil )
		element->timers = ccArrayNew(10);
	else
	{
		for( unsigned int i=0; i< element->timers->num; i++ ) {
			CCTimer *timer = element->timers->arr[i];
			if( [timer isKindOfClass:[CCTimerTargetSelector class]] && selector == [(CCTimerTargetSelector*)timer selector] ) {
				CCLOG(@"CCScheduler#scheduleSelector. Selector already scheduled. Updating interval from: %.4f to %.4f", [timer interval], interval);
				[timer setInterval: interval];
				return;
			}
		}
		ccArrayEnsureExtraCapacity(element->timers, 1);
	}

	CCTimerTargetSelector *timer = [[CCTimerTargetSelector alloc] initWithTarget:target selector:selector interval:interval repeat:repeat delay:delay];
	ccArrayAppendObject(element->timers, timer);
	[timer release];
}

-(void) scheduleBlockForKey:(NSString*)key target:(id)owner interval:(ccTime)interval repeat:(uint)repeat delay:(ccTime)delay paused:(BOOL)paused block:(void(^)(ccTime dt))block
{
	NSAssert( block != nil, @"Argument block must be non-nil");
	NSAssert( owner != nil, @"Argument owner must be non-nil");
	
	tHashTimerEntry *element = NULL;
	HASH_FIND_INT(hashForTimers, &owner, element);
	
	if( ! element ) {
		element = calloc( sizeof( *element ), 1 );
		element->target = [owner retain];
		HASH_ADD_INT( hashForTimers, target, element );
		
		// Is this the 1st element ? Then set the pause level to all the selectors of this target
		element->paused = paused;
		
	} else
		NSAssert( element->paused == paused, @"CCScheduler. Trying to schedule a block with a pause value different than the target");
	
	
	if( element->timers == nil )
		element->timers = ccArrayNew(10);
	else
	{
		for( unsigned int i=0; i< element->timers->num; i++ ) {
			CCTimer *timer = element->timers->arr[i];
			if( [timer isKindOfClass:[CCTimerBlock class]] && [key isEqualToString:[(CCTimerBlock*)timer key] ] ) {
				CCLOG(@"CCScheduler#scheduleBlock. Block already scheduled. Updating interval from: %.4f to %.4f", [timer interval], interval);
				[timer setInterval: interval];
				return;
			}
		}
		ccArrayEnsureExtraCapacity(element->timers, 1);
	}
	
	CCTimerBlock *timer = [[CCTimerBlock alloc] initWithTarget:owner interval:interval repeat:repeat delay:delay key:key block:block];
	ccArrayAppendObject(element->timers, timer);
	[timer release];
}

-(void) unscheduleSelector:(SEL)selector forTarget:(id)target
{
	// explicity handle nil arguments when removing an object
	if( target==nil && selector==NULL)
		return;
	
	NSAssert( target != nil, @"Target MUST not be nil");
	NSAssert( selector != NULL, @"Selector MUST not be NULL");
	
	tHashTimerEntry *element = NULL;
	HASH_FIND_INT(hashForTimers, &target, element);
	
	if( element ) {
		
		for( unsigned int i=0; i< element->timers->num; i++ ) {
			CCTimer *timer = element->timers->arr[i];
			
			
			if( [timer isKindOfClass:[CCTimerTargetSelector class]] && selector == [(CCTimerTargetSelector*)timer selector] ) {
				
				if( timer == element->currentTimer && !element->currentTimerSalvaged ) {
					[element->currentTimer retain];
					element->currentTimerSalvaged = YES;
				}
				
				ccArrayRemoveObjectAtIndex(element->timers, i );
				
				// update timerIndex in case we are in tick:, looping over the actions
				if( element->timerIndex >= i )
					element->timerIndex--;
				
				if( element->timers->num == 0 ) {
					if( currentTarget == element )
						currentTargetSalvaged = YES;
					else
						[self removeHashElement: element];
				}
				return;
			}
		}
	}
	
	// Not Found
	//	NSLog(@"CCScheduler#unscheduleSelector:forTarget: selector not found: %@", selString);
	
}

-(void) unscheduleBlockForKey:(NSString*)key target:(id)target
{
	// explicity handle nil arguments when removing an object
	if( target==nil && key==NULL)
		return;

	NSAssert( target != nil, @"Target MUST not be nil");
	NSAssert( key != NULL, @"key MUST not be NULL");

	tHashTimerEntry *element = NULL;
	HASH_FIND_INT(hashForTimers, &target, element);

	if( element ) {

		for( unsigned int i=0; i< element->timers->num; i++ ) {
			CCTimer *timer = element->timers->arr[i];


			if( [timer isKindOfClass:[CCTimerBlock class]] &&  [key isEqualToString: [(CCTimerBlock*)timer key]] ) {

				if( timer == element->currentTimer && !element->currentTimerSalvaged ) {
					[element->currentTimer retain];
					element->currentTimerSalvaged = YES;
				}

				ccArrayRemoveObjectAtIndex(element->timers, i );

				// update timerIndex in case we are in tick:, looping over the actions
				if( element->timerIndex >= i )
					element->timerIndex--;

				if( element->timers->num == 0 ) {
					if( currentTarget == element )
						currentTargetSalvaged = YES;
					else
						[self removeHashElement: element];
				}
				return;
			}
		}
	}

	// Not Found
//	NSLog(@"CCScheduler#unscheduleSelector:forTarget: selector not found: %@", selString);
}

#pragma mark CCScheduler - Update Specific

-(void) priorityIn:(tListEntry**)list target:(id)target priority:(NSInteger)priority paused:(BOOL)paused
{
	tListEntry *listElement = malloc( sizeof(*listElement) );

	listElement->target = target;
	listElement->priority = priority;
	listElement->paused = paused;
	listElement->impMethod = (TICK_IMP) [target methodForSelector:updateSelector];
	listElement->next = listElement->prev = NULL;
    listElement->markedForDeletion = NO;

	// empty list ?
	if( ! *list ) {
		DL_APPEND( *list, listElement );

	} else {
		BOOL added = NO;

		for( tListEntry *elem = *list; elem ; elem = elem->next ) {
			if( priority < elem->priority ) {

				if( elem == *list )
					DL_PREPEND(*list, listElement);
				else {
					listElement->next = elem;
					listElement->prev = elem->prev;

					elem->prev->next = listElement;
					elem->prev = listElement;
				}

				added = YES;
				break;
			}
		}

		// Not added? priority has the higher value. Append it.
		if( !added )
			DL_APPEND(*list, listElement);
	}

	// update hash entry for quicker access
	tHashUpdateEntry *hashElement = calloc( sizeof(*hashElement), 1 );
	hashElement->target = [target retain];
	hashElement->list = list;
	hashElement->entry = listElement;
	HASH_ADD_INT(hashForUpdates, target, hashElement );
}

-(void) appendIn:(tListEntry**)list target:(id)target paused:(BOOL)paused
{
	tListEntry *listElement = malloc( sizeof( * listElement ) );

	listElement->target = target;
	listElement->paused = paused;
    listElement->markedForDeletion = NO;
	listElement->impMethod = (TICK_IMP) [target methodForSelector:updateSelector];

	DL_APPEND(*list, listElement);


	// update hash entry for quicker access
	tHashUpdateEntry *hashElement = calloc( sizeof(*hashElement), 1 );
	hashElement->target = [target retain];
	hashElement->list = list;
	hashElement->entry = listElement;
	HASH_ADD_INT(hashForUpdates, target, hashElement );
}

-(void) scheduleUpdateForTarget:(id)target priority:(NSInteger)priority paused:(BOOL)paused
{
	tHashUpdateEntry * hashElement = NULL;
	HASH_FIND_INT(hashForUpdates, &target, hashElement);
    if(hashElement)
    {
#if COCOS2D_DEBUG >= 1
        NSAssert( hashElement->entry->markedForDeletion, @"CCScheduler: You can't re-schedule an 'update' selector'. Unschedule it first");
#endif
        // TODO : check if priority has changed!

        hashElement->entry->markedForDeletion = NO;
        return;
    }

	// most of the updates are going to be 0, that's way there
	// is an special list for updates with priority 0
	if( priority == 0 )
		[self appendIn:&updates0 target:target paused:paused];

	else if( priority < 0 )
		[self priorityIn:&updatesNeg target:target priority:priority paused:paused];

	else // priority > 0
		[self priorityIn:&updatesPos target:target priority:priority paused:paused];
}

- (void) removeUpdateFromHash:(tListEntry*)entry
{
	tHashUpdateEntry * element = NULL;
	
	HASH_FIND_INT(hashForUpdates, &entry->target, element);
	if( element ) {
		// list entry
		DL_DELETE( *element->list, element->entry );
		free( element->entry );
		
		// hash entry
		id target = element->target;
		HASH_DEL( hashForUpdates, element);
		free(element);
		
		// target#release should be the last one to prevent
		// a possible double-free. eg: If the [target dealloc] might want to remove it itself from there
		[target release];
	}
}

-(void) unscheduleUpdateForTarget:(id)target
{
	if( target == nil )
		return;

	tHashUpdateEntry * element = NULL;
	HASH_FIND_INT(hashForUpdates, &target, element);
	if( element ) {
        if(updateHashLocked)
            element->entry->markedForDeletion = YES;
        else
            [self removeUpdateFromHash:element->entry];

//		// list entry
//		DL_DELETE( *element->list, element->entry );
//		free( element->entry );
//
//		// hash entry
//		[element->target release];
//		HASH_DEL( hashForUpdates, element);
//		free(element);
	}
}

#pragma mark CCScheduler - Common for Update selector & Custom Selectors

-(void) unscheduleAll
{
    [self unscheduleAllWithMinPriority:kCCPrioritySystem];
}

-(void) unscheduleAllWithMinPriority:(NSInteger)minPriority
{
	// Custom Selectors
	for(tHashTimerEntry *element=hashForTimers; element != NULL; ) {
		id target = element->target;
		element=element->hh.next;
		[self unscheduleAllForTarget:target];
	}

	// Updates selectors
	tListEntry *entry, *tmp;
    if(minPriority < 0) {
        DL_FOREACH_SAFE( updatesNeg, entry, tmp ) {
            if(entry->priority >= minPriority) {
                [self unscheduleUpdateForTarget:entry->target];
            }
        }
    }
    if(minPriority <= 0) {
        DL_FOREACH_SAFE( updates0, entry, tmp ) {
            [self unscheduleUpdateForTarget:entry->target];
        }
    }
	DL_FOREACH_SAFE( updatesPos, entry, tmp ) {
        if(entry->priority >= minPriority) {
            [self unscheduleUpdateForTarget:entry->target];
        }
	}

}

-(void) unscheduleAllForTarget:(id)target
{
	// explicit nil handling
	if( target == nil )
		return;

	// Custom Selectors
	tHashTimerEntry *element = NULL;
	HASH_FIND_INT(hashForTimers, &target, element);

	if( element ) {
		if( ccArrayContainsObject(element->timers, element->currentTimer) && !element->currentTimerSalvaged ) {
			[element->currentTimer retain];
			element->currentTimerSalvaged = YES;
		}
		ccArrayRemoveAllObjects(element->timers);
		if( currentTarget == element )
			currentTargetSalvaged = YES;
		else
			[self removeHashElement:element];
	}

	// Update Selector
	[self unscheduleUpdateForTarget:target];
}

-(void) resumeTarget:(id)target
{
	NSAssert( target != nil, @"target must be non nil" );

	// Custom Selectors
	tHashTimerEntry *element = NULL;
	HASH_FIND_INT(hashForTimers, &target, element);
	if( element )
		element->paused = NO;

	// Update selector
	tHashUpdateEntry * elementUpdate = NULL;
	HASH_FIND_INT(hashForUpdates, &target, elementUpdate);
	if( elementUpdate ) {
		NSAssert( elementUpdate->entry != NULL, @"resumeTarget: unknown error");
		elementUpdate->entry->paused = NO;
	}
}

-(void) pauseTarget:(id)target
{
	NSAssert( target != nil, @"target must be non nil" );

	// Custom selectors
	tHashTimerEntry *element = NULL;
	HASH_FIND_INT(hashForTimers, &target, element);
	if( element )
		element->paused = YES;

	// Update selector
	tHashUpdateEntry * elementUpdate = NULL;
	HASH_FIND_INT(hashForUpdates, &target, elementUpdate);
	if( elementUpdate ) {
		NSAssert( elementUpdate->entry != NULL, @"pauseTarget: unknown error");
		elementUpdate->entry->paused = YES;
	}

}

-(BOOL) isTargetPaused:(id)target
{
	NSAssert( target != nil, @"target must be non nil" );

	// Custom selectors
	tHashTimerEntry *element = NULL;
	HASH_FIND_INT(hashForTimers, &target, element);
	if( element )
		return element->paused;
	
	// We should check update selectors if target does not have custom selectors
	tHashUpdateEntry * elementUpdate = NULL;
	HASH_FIND_INT(hashForUpdates, &target, elementUpdate);
	if ( elementUpdate )
		return elementUpdate->entry->paused;
	
	return NO;  // should never get here
}

-(NSSet*) pauseAllTargets
{
	return [self pauseAllTargetsWithMinPriority:kCCPrioritySystem];
}

-(NSSet*) pauseAllTargetsWithMinPriority:(NSInteger)minPriority
{
	NSMutableSet* idsWithSelectors = [NSMutableSet setWithCapacity:50];

	// Custom Selectors
	for(tHashTimerEntry *element=hashForTimers; element != NULL; element=element->hh.next) {
		element->paused = YES;
		[idsWithSelectors addObject:element->target];
	}

	// Updates selectors
	tListEntry *entry, *tmp;
	if(minPriority < 0) {
		DL_FOREACH_SAFE( updatesNeg, entry, tmp ) {
			if(entry->priority >= minPriority) {
				entry->paused = YES;
				[idsWithSelectors addObject:entry->target];
			}
		}
	}
	if(minPriority <= 0) {
		DL_FOREACH_SAFE( updates0, entry, tmp ) {
			entry->paused = YES;
			[idsWithSelectors addObject:entry->target];
		}
	}
	DL_FOREACH_SAFE( updatesPos, entry, tmp ) {
		if(entry->priority >= minPriority) {
			entry->paused = YES;
			[idsWithSelectors addObject:entry->target];
		}
	}

	return idsWithSelectors;
}

-(void) resumeTargets:(NSSet *)targetsToResume
{
    for(id target in targetsToResume) {
        [self resumeTarget:target];
    }
}

#pragma mark CCScheduler - Main Loop

-(void) update: (ccTime) dt
{
    updateHashLocked = YES;

	if( timeScale_ != 1.0f )
		dt *= timeScale_;

	// Iterate all over the Updates selectors
	tListEntry *entry, *tmp;

	// updates with priority < 0
	DL_FOREACH_SAFE( updatesNeg, entry, tmp ) {
		if( ! entry->paused && !entry->markedForDeletion )
			entry->impMethod( entry->target, updateSelector, dt );
	}

	// updates with priority == 0
	DL_FOREACH_SAFE( updates0, entry, tmp ) {
		if( ! entry->paused && !entry->markedForDeletion )
        {
			entry->impMethod( entry->target, updateSelector, dt );
        }
	}

	// updates with priority > 0
	DL_FOREACH_SAFE( updatesPos, entry, tmp ) {
		if( ! entry->paused  && !entry->markedForDeletion )
			entry->impMethod( entry->target, updateSelector, dt );
	}

	// Iterate all over the custom selectors (CCTimers)
	for(tHashTimerEntry *elt=hashForTimers; elt != NULL; ) {

		currentTarget = elt;
		currentTargetSalvaged = NO;

		if( ! currentTarget->paused ) {

			// The 'timers' ccArray may change while inside this loop.
			for( elt->timerIndex = 0; elt->timerIndex < elt->timers->num; elt->timerIndex++) {
				elt->currentTimer = elt->timers->arr[elt->timerIndex];
				elt->currentTimerSalvaged = NO;

				impMethod( elt->currentTimer, updateSelector, dt);

				if( elt->currentTimerSalvaged ) {
					// The currentTimer told the remove itself. To prevent the timer from
					// accidentally deallocating itself before finishing its step, we retained
					// it. Now that step is done, it is safe to release it.
					[elt->currentTimer release];
				}

				elt->currentTimer = nil;
			}
		}

		// elt, at this moment, is still valid
		// so it is safe to ask this here (issue #490)
		elt = elt->hh.next;

		// only delete currentTarget if no actions were scheduled during the cycle (issue #481)
		if( currentTargetSalvaged && currentTarget->timers->num == 0 )
			[self removeHashElement:currentTarget];
	}

    // delete all updates that are morked for deletion
    // updates with priority < 0
	DL_FOREACH_SAFE( updatesNeg, entry, tmp ) {
		if(entry->markedForDeletion )
        {
            [self removeUpdateFromHash:entry];
        }
	}

	// updates with priority == 0
	DL_FOREACH_SAFE( updates0, entry, tmp ) {
		if(entry->markedForDeletion )
        {
            [self removeUpdateFromHash:entry];
        }
	}

	// updates with priority > 0
	DL_FOREACH_SAFE( updatesPos, entry, tmp ) {
		if(entry->markedForDeletion )
        {
            [self removeUpdateFromHash:entry];
        }
	}

    updateHashLocked = NO;
	currentTarget = nil;
}
@end

