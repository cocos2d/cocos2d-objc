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

//
// Timer
//
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
		
		// target is being retained. Be careful with ciruclar references
		target = [t retain];
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
	CCLOG(@"cocos2d: deallocing %@", self);
	[target release];
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
// Scheduler
//
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
		scheduledMethods = [[NSMutableArray arrayWithCapacity:50] retain];
		methodsToRemove = [[NSMutableArray arrayWithCapacity:20] retain];
		methodsToAdd = [[NSMutableArray arrayWithCapacity:20] retain];
		
		timeScale_ = 1.0f;

		fireSelector = @selector(fire:);
		impMethod = (TICK_IMP) [CCTimer instanceMethodForSelector:fireSelector];
	}

	return self;
}

- (void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);
	[scheduledMethods release];
	[methodsToRemove release];
	[methodsToAdd release];
	sharedScheduler = nil;
	
	[super dealloc];
}

-(void) scheduleTimer: (CCTimer*) t
{
	// it is possible that sometimes (in transitions in particular) an scene unschedule a timer
	// and before the timer is deleted, it is re-scheduled
	if( [methodsToRemove containsObject:t] )
	{
		[methodsToRemove removeObject:t];
		return;
	}
	
	if( [scheduledMethods containsObject:t] || [methodsToAdd containsObject:t]) {
		NSLog(@"Scheduler.schedulerTimer: timer %@ already scheduled", t);
		NSException* myException = [NSException
									exceptionWithName:@"SchedulerTimerAlreadyScheduled"
									reason:@"Scheduler.scheduleTimer already scheduled"
									userInfo:nil];
		@throw myException;		
	}

	[methodsToAdd addObject: t];
}

-(void) unscheduleTimer: (CCTimer*) t
{
	// someone wants to remove it before it was added
	if( [methodsToAdd containsObject:t] ) {
		[methodsToAdd removeObject:t];
		return;
	}
	
	if( ![scheduledMethods containsObject:t] ) {
		NSLog(@"Scheduler.unscheduleTimer: timer not scheduled");
		NSException* myException = [NSException
									exceptionWithName:@"SchedulerTimerNotFound"
									reason:@"Scheduler.unscheduleTimer not found"
									userInfo:nil];
		@throw myException;		
	}
	
	[methodsToRemove addObject:t];
}

-(void) unscheduleAllTimers
{
	[methodsToAdd removeAllObjects];
	[methodsToRemove removeAllObjects];
	[scheduledMethods removeAllObjects];
}

-(void) tick: (ccTime) dt
{
	if( timeScale_ != 1.0f )
		dt *= timeScale_;

	for( id k in methodsToRemove )
		[scheduledMethods removeObject:k];

	[methodsToRemove removeAllObjects];

	for( id k in methodsToAdd )
		[scheduledMethods addObject:k];
	[methodsToAdd removeAllObjects];
	
	for( CCTimer *t in scheduledMethods )
		impMethod(t, fireSelector, dt);
}
@end
