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

-(id) initWithTarget:(id) t selector:(SEL)s
{
	if(! [super init] )
		return nil;
	
	NSMethodSignature * sig = [[t class] instanceMethodSignatureForSelector:s];
	invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:t];
	[invocation setSelector:s];
	
	[invocation retain];
	return self;
}

-(void) dealloc
{
	[invocation release];
	[super dealloc];
}

-(void) fire: (double) dt
{
//	[target performSelector:sel];

	[invocation setArgument:&dt atIndex:2];
	[invocation invoke];
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
	if( ! [super init] )
		return nil;
	
	scheduledMethods = [[NSMutableArray arrayWithCapacity:50] retain];
	methodsToRemove = [[NSMutableArray arrayWithCapacity:20] retain];
	methodsToAdd = [[NSMutableArray arrayWithCapacity:20] retain];

	return self;
}

- (void) dealloc
{
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
	// some wants to remove it before it was added
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

-(void) tick: (double) dt
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