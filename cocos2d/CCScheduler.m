/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009,2010 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

// cocos2d imports
#import "CCScheduler.h"
#import "ccMacros.h"
#import "Support/uthash.h"

//
// CCTimer
//
#pragma mark -
#pragma mark - CCTimer

@implementation CCTimer

@synthesize interval;

-(id) init
{
	NSException* myException = [NSException
								exceptionWithName:@"TimerInvalid"
								reason:@"Invalid init for Timer. Use initWithTarget:sel:"
								userInfo:nil];
	@throw myException;
}

+(id) timerWithTarget:(id) t selector:(SEL)s
{
	return [[[self alloc] initWithTarget:t selector:s] autorelease];
}

+(id) timerWithTarget:(id) t selector:(SEL)s interval:(ccTime) i
{
	return [[[self alloc] initWithTarget:t selector:s interval:i] autorelease];
}

-(id) initWithTarget:(id) t selector:(SEL)s
{
	return [self initWithTarget:t selector:s interval:0];
}

-(id) initWithTarget:(id) t selector:(SEL)s interval:(ccTime) seconds
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

-(void) fire: (ccTime) dt
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
-(void) deleteHashElement:(tCCSchedHashElement)element;
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
}

- (id) init
{
	if( (self=[super init]) ) {		
		timeScale_ = 1.0f;

		fireSelector = @selector(fire:);
		impMethod = (TICK_IMP) [CCTimer instanceMethodForSelector:fireSelector];

		currentTarget = nil;
		currentTargetSalvaged = NO;
		targets = nil;
	}

	return self;
}

- (void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);

	[self unscheduleAllSelectors];
	uthash_free( targets );

	sharedScheduler = nil;

	[super dealloc];
}

#pragma mark CCScheduler - Private

-(void) removeHashElement:(tCCSchedHashElement*)element
{
	ccArrayFree(element->timers);
	[element->target release];
	HASH_DEL(targets, element);
	free(element);
}


#pragma mark CCScheduler - scheduling / unscheduling

-(void) scheduleTimer: (CCTimer*) t
{
	NSAssert(NO, @"Not implemented. Use scheduleSelector:forTarget:");
}

-(void) unscheduleTimer: (CCTimer*) t
{
	NSAssert(NO, @"Not implemented. Use unscheduleSelector:forTarget:");
}

-(void) unscheduleAllTimers
{
	NSAssert(NO, @"Not implemented. Use unscheduleAllSelectors");
}

-(void) unscheduleAllSelectors
{
	for(tCCSchedHashElement *element=targets; element != NULL; element=element->hh.next) {	
		id target = element->target;
		[self unscheduleAllSelectorsForTarget:target];
	}
}

-(void) scheduleSelector:(SEL)selector forTarget:(id)target interval:(float)interval paused:(BOOL)paused
{
	NSAssert( selector != nil, @"Argument selector must be non-nil");
	NSAssert( target != nil, @"Argument target must be non-nil");	
	
	tCCSchedHashElement *element = nil;
	HASH_FIND_INT(targets, &target, element);
	
	if( ! element ) {
		element = calloc( sizeof( *element ), 1 );
		element->target = [target retain];
		HASH_ADD_INT( targets, target, element );
	
		// Is this the 1st element ? Then set the pause level to all the selectors of this target
		element->paused = paused;
	
	} else {
		NSAssert( element->paused == paused, @"CCScheduler. Trying to schedule a selector with a pause value different than the target");
	}
	
	if( element->timers == nil )
		element->timers = ccArrayNew(10);
	else if( element->timers->num == element->timers->max )
		ccArrayDoubleCapacity(element->timers);
	
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
	
	tCCSchedHashElement *element = nil;
	HASH_FIND_INT(targets, &target, element);
	
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
					if( currentTarget == element ) {
						currentTargetSalvaged = YES;						
					}
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

-(void) unscheduleAllSelectorsForTarget:(id)target
{
	// explicit nil handling
	if( target == nil )
		return;
	
	tCCSchedHashElement *element = nil;
	HASH_FIND_INT(targets, &target, element);

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
	} else {
//		NSLog(@"CCSCheduler#unscheduleAllSelectorsForTarget Target not found: %@", target);
	}

}

-(void) resumeAllSelectorsForTarget:(id)target
{
	NSAssert( target != nil, @"target must be non nil" );

	tCCSchedHashElement *element = nil;
	HASH_FIND_INT(targets, &target, element);
	
	if( element )
		element->paused = NO;
}

-(void) pauseAllSelectorsForTarget:(id)target
{
	NSAssert( target != nil, @"target must be non nil" );
			 
	tCCSchedHashElement *element = nil;
	HASH_FIND_INT(targets, &target, element);
	
	if( element )
		element->paused = YES;
}

#pragma mark CCScheduler - Main Loop

-(void) tick: (ccTime) dt
{
	if( timeScale_ != 1.0f )
		dt *= timeScale_;
	
	// Iterate all over the Updates
	
	// Iterate all over the Timers
	for(tCCSchedHashElement *element=targets; element != NULL; element=element->hh.next) {	
		
		currentTarget = element;
		currentTargetSalvaged = NO;

		if( ! element->paused ) {

			// The 'timers' ccArray may change while inside this loop.
			for( element->timerIndex = 0; element->timerIndex < element->timers->num; element->timerIndex++) {
				element->currentTimer = element->timers->arr[element->timerIndex];
				element->currentTimerSalvaged = NO;

				impMethod( element->currentTimer, fireSelector, dt);
				
				if( element->currentTimerSalvaged ) {
					// The currentTimer told the remove itself. To prevent the timer from
					// accidentally deallocating itself before finishing its step, we retained
					// it. Now that step is done, it's safe to release it.
					[element->currentTimer release];
				}
			}
			
			// only delete currentTarget if no actions were scheduled during the cycle (issue #481)
			if( currentTargetSalvaged && currentTarget->timers->num == 0 )
				[self removeHashElement:currentTarget];
		}
		
		element->currentTimer = nil;
	}
	
	currentTarget = nil;
}

@end

