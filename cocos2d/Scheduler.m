/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */


#import "Scheduler.h"


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

-(id) initWithTarget:(id) t selector:(SEL)s interval:(ccTime) i
{
	if( ! (self=[super init]) )
		return nil;
	
	interval = i;
	elapsed = 0;
	
	NSMethodSignature * sig = [[t class] instanceMethodSignatureForSelector:s];
	invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:t];
	[invocation setSelector:s];
	[invocation retainArguments];
	
	[invocation retain];
	return self;
}

-(void) dealloc
{
#if DEBUG
	NSLog( @"deallocing %@", self);
#endif
	[invocation release];
	[super dealloc];
}

-(void) fire: (ccTime) dt
{
	elapsed += dt;
	if( elapsed >= interval ) {
		[invocation setArgument:&elapsed atIndex:2];
		[invocation invoke];
		
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
	@synchronized(self)
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
	@synchronized(self)
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
#if DEBUG
	NSLog( @"deallocing %@", self);
#endif	
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
		NSLog(@"Scheduler.schedulerTimer: timer already scheduled");
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
