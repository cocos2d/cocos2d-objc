/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

// cocos2d imports
#import "Scheduler.h"
#import "ccMacros.h"

//
// Timer
//
@implementation Timer

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
#ifdef DEBUG
		NSMethodSignature *sig = [t methodSignatureForSelector:s];
		NSAssert(sig !=0 , @"Signature not found for selector - does it have the following form? -(void) name: (ccTime) dt");
#endif
		
		target = [t retain];
		selector = s;
		impMethod = (TICK_IMP) [t methodForSelector:s];
		
		interval = seconds;
	}
	return self;
}

-(void) dealloc
{
	CCLOG( @"deallocing %@", self);
	
	[target release];
	[super dealloc];
}

-(void) fire: (ccTime) dt
{
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
@implementation Scheduler

static Scheduler *sharedScheduler;

+ (Scheduler *)sharedScheduler
{
	@synchronized([Scheduler class])
	{
		if (!sharedScheduler)
			[[Scheduler alloc] init];
		
		return sharedScheduler;
	}
	// to avoid compiler warning
	return nil;
}

+(id)alloc
{
	@synchronized([Scheduler class])
	{
		NSAssert(sharedScheduler == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedScheduler = [super alloc];
		return sharedScheduler;
	}
	// to avoid compiler warning
	return nil;
}

- (id) init
{
	if( ! (self=[super init]) )
		return nil;
	
	scheduledMethods = [[NSMutableArray arrayWithCapacity:50] retain];
	methodsToRemove = [[NSMutableArray arrayWithCapacity:20] retain];
	methodsToAdd = [[NSMutableArray arrayWithCapacity:20] retain];

	return self;
}

- (void) dealloc
{
	CCLOG( @"deallocing %@", self);
	[scheduledMethods release];
	[methodsToRemove release];
	[methodsToAdd release];
	
	[super dealloc];
}

-(Timer*) scheduleTarget: (id) target selector:(SEL)sel
{
	Timer *t = [Timer timerWithTarget:target selector:sel];
	
	[methodsToAdd addObject: t];
	
	return t;
}

-(Timer*) scheduleTarget: (id) target selector:(SEL)sel interval:(ccTime) i
{
	Timer *t = [Timer timerWithTarget:target selector:sel];
	
	[t setInterval:i];
	
	[methodsToAdd addObject: t];
	
	return t;
}

-(void) scheduleTimer: (Timer*) t
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

-(void) unscheduleTimer: (Timer*) t;
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

-(void) tick: (ccTime) dt
{
	for( id k in methodsToRemove )
		[scheduledMethods removeObject:k];

	[methodsToRemove removeAllObjects];

	for( id k in methodsToAdd )
		[scheduledMethods addObject:k];
	[methodsToAdd removeAllObjects];
	
	for( Timer *t in scheduledMethods )
		[t fire: dt];
}
@end
