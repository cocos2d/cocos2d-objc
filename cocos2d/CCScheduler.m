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
#import "CCScheduler.h"
#import "ccMacros.h"
#import "CCNode.h"
//
// Timer
//
@implementation CCTimer

@synthesize interval;
@synthesize ticksUntilAutoExpire;
@synthesize target;
@synthesize selector;

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


+(id) timerWithTarget:(id) t selector:(SEL)s repeat:(int)times
{
	return [[[self alloc] initWithTarget:t selector:s repeat:times] autorelease];
}

+(id) timerWithTarget:(id) t selector:(SEL)s interval:(ccTime) i repeat:(int)times
{
	return [[[self alloc] initWithTarget:t selector:s interval:i repeat:times] autorelease];
}



-(id) initWithTarget:(id) t selector:(SEL)s
{
	return [self initWithTarget:t selector:s interval:0];
}

-(id) initWithTarget:(id) t selector:(SEL)s repeat:(int)times
{
	return [self initWithTarget:t selector:s interval:0 repeat:times];
}

-(id) initWithTarget:(id) t selector:(SEL)s interval:(ccTime) seconds {
	return [self initWithTarget:t selector:s interval:seconds repeat:CCTIMER_REPEAT_FOREVER];
}

-(id) initWithTarget:(id) t selector:(SEL)s interval:(ccTime) seconds repeat:(int)times
{
	if( (self=[super init]) ) {
#ifdef DEBUG
		NSMethodSignature *sig = [t methodSignatureForSelector:s];
		NSAssert(sig !=0 , @"Signature not found for selector - does it have the following form? -(void) name: (ccTime) dt");
		NSAssert( times >= CCTIMER_REPEAT_FOREVER, @"Repeat argument invalid");
#endif
		
		// target is being retained. Be careful with ciruclar references
		target = [t retain];
		selector = s;
		impMethod = (TICK_IMP) [t methodForSelector:s];
		elapsed = -1;
		interval = seconds;
		ticksUntilAutoExpire = times;
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
		
		if(ticksUntilAutoExpire > 0)
			--ticksUntilAutoExpire;
		
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
	@synchronized([CCScheduler class])
	{
		if (!sharedScheduler)
			sharedScheduler = [[CCScheduler alloc] init];
		
	}
	// to avoid compiler warning
	return sharedScheduler;
}

+(id)alloc
{
	@synchronized([CCScheduler class])
	{
		NSAssert(sharedScheduler == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	// to avoid compiler warning
	return nil;
}

+(void)purgeSharedScheduler
{
	@synchronized( self ) {
		[sharedScheduler release];
	}
}

- (id) init
{
	if( (self=[super init]) ) {
		scheduledMethods = [[NSMutableArray arrayWithCapacity:50] retain];
		methodsToRemove = [[NSMutableArray arrayWithCapacity:20] retain];
		methodsToAdd = [[NSMutableArray arrayWithCapacity:20] retain];
		
		timeScale_ = 1.0f;
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
	
	for( CCTimer *t in scheduledMethods ) {
		[t fire: dt];
		if (t->ticksUntilAutoExpire == 0) {
			// Time to automatically remove this timer
			if([t.target isKindOfClass:[CCNode class]] == YES) {
				// A CCNode has it's own housekeeping to cleanup and
				// will then, ultimately, unschedule us.
				[(CCNode*)t.target unschedule:t.selector];
			}
			else {
				[self unscheduleTimer:t];
			}
		}
	}
}

@end
