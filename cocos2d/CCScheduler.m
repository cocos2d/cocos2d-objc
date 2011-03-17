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


// cocos2d imports
#import "CCScheduler.h"
#import "ccMacros.h"
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
	TICK_IMP impMethod;
	id		target;				// not retained (retained by hashUpdateEntry)
	int		priority;
	BOOL	paused;
	
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
} tHashSelectorEntry;



//
// CCTimer
//
#pragma mark -
#pragma mark - CCTimer

@implementation CCTimer

@synthesize interval;

-(id) init
{
	NSAssert(NO, @"CCTimer: Init not supported.");
	[self release];
	return nil;
}

+(id) timerWithTarget:(id)t selector:(SEL)s
{
	return [[[self alloc] initWithTarget:t selector:s] autorelease];
}

+(id) timerWithTarget:(id)t selector:(SEL)s interval:(ccTime) i
{
	return [[[self alloc] initWithTarget:t selector:s interval:i] autorelease];
}

-(id) initWithTarget:(id)t selector:(SEL)s
{
	return [self initWithTarget:t selector:s interval:0];
}

-(id) initWithTarget:(id)t selector:(SEL)s interval:(ccTime) seconds
{
	if( (self=[super init]) ) {
#if COCOS2D_DEBUG
		NSMethodSignature *sig = [t methodSignatureForSelector:s];
		NSAssert(sig !=0 , @"Signature not found for selector - does it have the following form? -(void) name: (ccTime) dt");
#endif
		
		// target is not retained. It is retained in the hash structure
		target = t;
		selector = s;
		impMethod = (TICK_IMP) [t methodForSelector:s];
		elapsed = -1;
		interval = seconds;
	}
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | target:%@ selector:(%@)>", [self class], self, [target class], NSStringFromSelector(selector)];
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	[super dealloc];
}

-(void) update: (ccTime) dt
{
	if( elapsed == - 1)
		elapsed = 0;
	else
		elapsed += dt;
	if( elapsed >= interval ) {
		impMethod(target, selector, elapsed);
		elapsed = 0;
	}
}
@end

//
// CCScheduler
//
#pragma mark -
#pragma mark - CCScheduler

@interface CCScheduler (Private)
-(void) removeHashElement:(tHashSelectorEntry*)element;
@end

@implementation CCScheduler

static CCScheduler *sharedScheduler;

@synthesize timeScale = timeScale_;

+ (CCScheduler *)sharedScheduler
{
	if (!sharedScheduler)
		sharedScheduler = [[CCScheduler alloc] init];

	return sharedScheduler;
}

+(id)alloc
{
	NSAssert(sharedScheduler == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

+(void)purgeSharedScheduler
{
	[sharedScheduler release];
	sharedScheduler = nil;
}

- (id) init
{
	if( (self=[super init]) ) {		
		timeScale_ = 1.0f;

		// used to trigger CCTimer#update
		updateSelector = @selector(update:);
		impMethod = (TICK_IMP) [CCTimer instanceMethodForSelector:updateSelector];

		// updates with priority
		updates0 = NULL;
		updatesNeg = NULL;
		updatesPos = NULL;
		hashForUpdates = NULL;
		
		// selectors with interval
		currentTarget = nil;
		currentTargetSalvaged = NO;
		hashForSelectors = nil;
	}

	return self;
}

- (void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);

	[self unscheduleAllSelectors];

	sharedScheduler = nil;

	[super dealloc];
}


#pragma mark CCScheduler - Custom Selectors

-(void) removeHashElement:(tHashSelectorEntry*)element
{
	ccArrayFree(element->timers);
	[element->target release];
	HASH_DEL(hashForSelectors, element);
	free(element);
}

-(void) scheduleSelector:(SEL)selector forTarget:(id)target interval:(ccTime)interval paused:(BOOL)paused
{
	NSAssert( selector != nil, @"Argument selector must be non-nil");
	NSAssert( target != nil, @"Argument target must be non-nil");	
	
	tHashSelectorEntry *element = NULL;
	HASH_FIND_INT(hashForSelectors, &target, element);
	
	if( ! element ) {
		element = calloc( sizeof( *element ), 1 );
		element->target = [target retain];
		HASH_ADD_INT( hashForSelectors, target, element );
	
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
			if( selector == timer->selector ) {
				CCLOG(@"CCScheduler#scheduleSelector. Selector already scheduled. Updating interval from: %.2f to %.2f", timer->interval, interval);
				timer->interval = interval;
				return;
			}
		}
		ccArrayEnsureExtraCapacity(element->timers, 1);
	}
	
	CCTimer *timer = [[CCTimer alloc] initWithTarget:target selector:selector interval:interval];
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
	
	tHashSelectorEntry *element = NULL;
	HASH_FIND_INT(hashForSelectors, &target, element);
	
	if( element ) {
		
		for( unsigned int i=0; i< element->timers->num; i++ ) {
			CCTimer *timer = element->timers->arr[i];
			
			
			if( selector == timer->selector ) {
				
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

-(void) priorityIn:(tListEntry**)list target:(id)target priority:(int)priority paused:(BOOL)paused
{
	tListEntry *listElement = malloc( sizeof(*listElement) );

	listElement->target = target;
	listElement->priority = priority;
	listElement->paused = paused;
	listElement->impMethod = (TICK_IMP) [target methodForSelector:updateSelector];
	listElement->next = listElement->prev = NULL;
	
	
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
	listElement->impMethod = (TICK_IMP) [target methodForSelector:updateSelector];
	
	DL_APPEND(*list, listElement);

	
	// update hash entry for quicker access
	tHashUpdateEntry *hashElement = calloc( sizeof(*hashElement), 1 );
	hashElement->target = [target retain];
	hashElement->list = list;
	hashElement->entry = listElement;
	HASH_ADD_INT(hashForUpdates, target, hashElement );	
}

-(void) scheduleUpdateForTarget:(id)target priority:(int)priority paused:(BOOL)paused
{
#if COCOS2D_DEBUG >= 1
	tHashUpdateEntry * hashElement = NULL;
	HASH_FIND_INT(hashForUpdates, &target, hashElement);
	NSAssert( hashElement == NULL, @"CCScheduler: You can't re-schedule an 'update' selector'. Unschedule it first");
#endif	
		
	// most of the updates are going to be 0, that's way there
	// is an special list for updates with priority 0
	if( priority == 0 )
		[self appendIn:&updates0 target:target paused:paused];

	else if( priority < 0 )
		[self priorityIn:&updatesNeg target:target priority:priority paused:paused];

	else // priority > 0
		[self priorityIn:&updatesPos target:target priority:priority paused:paused];
}

-(void) unscheduleUpdateForTarget:(id)target
{
	if( target == nil )
		return;
	
	tHashUpdateEntry * element = NULL;
	HASH_FIND_INT(hashForUpdates, &target, element);
	if( element ) {
	
		// list entry
		DL_DELETE( *element->list, element->entry );
		free( element->entry );
	
		// hash entry
		[element->target release];
		HASH_DEL( hashForUpdates, element);
		free(element);
	}
}

#pragma mark CCScheduler - Common for Update selector & Custom Selectors

-(void) unscheduleAllSelectors
{
	// Custom Selectors
	for(tHashSelectorEntry *element=hashForSelectors; element != NULL; ) {	
		id target = element->target;
		element=element->hh.next;
		[self unscheduleAllSelectorsForTarget:target];
	}

	// Updates selectors
	tListEntry *entry, *tmp;
	DL_FOREACH_SAFE( updates0, entry, tmp ) {
		[self unscheduleUpdateForTarget:entry->target];
	}
	DL_FOREACH_SAFE( updatesNeg, entry, tmp ) {
		[self unscheduleUpdateForTarget:entry->target];
	}
	DL_FOREACH_SAFE( updatesPos, entry, tmp ) {
		[self unscheduleUpdateForTarget:entry->target];
	}
	
}

-(void) unscheduleAllSelectorsForTarget:(id)target
{
	// explicit nil handling
	if( target == nil )
		return;
	
	// Custom Selectors
	tHashSelectorEntry *element = NULL;
	HASH_FIND_INT(hashForSelectors, &target, element);
	
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
	tHashSelectorEntry *element = NULL;
	HASH_FIND_INT(hashForSelectors, &target, element);
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
	tHashSelectorEntry *element = NULL;
	HASH_FIND_INT(hashForSelectors, &target, element);
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

#pragma mark CCScheduler - Main Loop

-(void) tick: (ccTime) dt
{
	if( timeScale_ != 1.0f )
		dt *= timeScale_;
	
	// Iterate all over the Updates selectors
	tListEntry *entry, *tmp;

	// updates with priority < 0
	DL_FOREACH_SAFE( updatesNeg, entry, tmp ) {
		if( ! entry->paused )
			entry->impMethod( entry->target, updateSelector, dt );
	}

	// updates with priority == 0
	DL_FOREACH_SAFE( updates0, entry, tmp ) {
		if( ! entry->paused )
			entry->impMethod( entry->target, updateSelector, dt );
	}
	
	// updates with priority > 0
	DL_FOREACH_SAFE( updatesPos, entry, tmp ) {
		if( ! entry->paused )
			entry->impMethod( entry->target, updateSelector, dt );
	}
	
	// Iterate all over the  custome selectors
	for(tHashSelectorEntry *elt=hashForSelectors; elt != NULL; ) {	
		
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
					// it. Now that step is done, it's safe to release it.
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
	
	currentTarget = nil;
}

@end

