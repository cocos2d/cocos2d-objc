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
@synthesize paused;
@synthesize timeScale;

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
		timeScale = 1.0f;
	}
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | target:%@ selector:(%@) paused:%d>", [self class], self, [target class], NSStringFromSelector(selector),paused];
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
		elapsed += (dt * timeScale);
	if( elapsed >= interval ) {
		impMethod(target, selector, elapsed);
		elapsed = 0;
		
		if(ticksUntilAutoExpire > 0)
			--ticksUntilAutoExpire;
		
	}
}
@end


#pragma mark -
#pragma mark CCScheduler

// Uncomment to add debug logging for the scheduler
// #define DEBUG_SCHEDULER	


@interface CCScheduler (Private)
-(void) trackerTimerByTarget:(CCTimer*) t;
-(void) untrackTimer:(CCTimer*) t;
@end

//
// Scheduler
//
@implementation CCScheduler

static CCScheduler *sharedScheduler;

@synthesize timeScale;

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
		scheduledMethods = [[NSMutableSet setWithCapacity:50] retain];
		methodsToRemove = [[NSMutableSet setWithCapacity:20] retain];
		methodsToAdd = [[NSMutableSet setWithCapacity:20] retain];
		
		
		targets = [[NSMutableDictionary dictionaryWithCapacity:128] retain];
		
		timeScale = 1.0f;
	}

	return self;
}

- (void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);
	[scheduledMethods release];
	[methodsToRemove release];
	[methodsToAdd release];
	[targets release];
 	
	sharedScheduler = nil;
	
	[super dealloc];
}

-(void) addTimer: (CCTimer*)t paused:(BOOL) paused;
{
	t.paused = paused;
	
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

-(void) removeTimer:(CCTimer*)t;
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
	
#ifdef DEBUG_SCHEDULER	
	NSLog(@"%s: remembering to remove timer: %@",__PRETTY_FUNCTION__,t);	
#endif	
	[methodsToRemove addObject:t];
}

-(void) unscheduleAllTimers
{
	[methodsToAdd removeAllObjects];
	[methodsToRemove removeAllObjects];
	[scheduledMethods removeAllObjects];
	[targets removeAllObjects];
}

-(void) tick: (ccTime) dt
{
	if( timeScale != 1.0f )
		dt *= timeScale;

	for( id k in methodsToRemove ) {
		[scheduledMethods removeObject:k];
		[self untrackTimer:k];
	}
	[methodsToRemove removeAllObjects];

	for( id k in methodsToAdd ) {
		[scheduledMethods addObject:k];
		[self trackerTimerByTarget:k];
	}
	[methodsToAdd removeAllObjects];
	
	for( CCTimer *t in scheduledMethods ) {
		[t fire: dt];
		if (t->ticksUntilAutoExpire == 0) {
			[self removeTimer:t];
		}
	}
}



-(void) removeAllTimersFromTarget:(id)target {
	
#ifdef DEBUG_SCHEDULER	
	NSLog(@"%s: [%@|%@]",__PRETTY_FUNCTION__,target,[target class]);
#endif	
	
	NSArray* timers = [targets objectForKey:[NSNumber numberWithInteger:(NSInteger)target]];
	for(CCTimer* t in timers) {
		[self removeTimer:t];
	}
	// Check any we were going to add
	for(CCTimer* t in methodsToAdd) {
		if(t.target == target) {
			[methodsToAdd removeObject:t];
			break;
		}
	}
}




-(void) setTarget:(id) target paused:(BOOL) paused {
	NSArray* timers = [targets objectForKey:[NSNumber numberWithInteger:(NSInteger)target]];
	for(CCTimer* t in timers) {
		t.paused = paused;
	}
	// Check any we were going to add
	for(CCTimer* t in methodsToAdd) {
		if(t.target == target ) {
			t.paused = paused;
			break;
		}
	}	
}

-(void) pauseAllTimersForTarget:(id)target {
	[self setTarget:target paused:YES];
}

-(void) resumeAllTimersForTarget:(id)target {
	[self setTarget:target paused:NO];
}


-(void) unscheduleAllTimersOfSelector:(SEL)selector Target:(id)target {
	
#ifdef DEBUG_SCHEDULER	
	NSLog(@"%s: [%@|%@] sel:%@",__PRETTY_FUNCTION__,target,[target class],NSStringFromSelector(selector));
#endif	
	
	
	NSArray* timers = [targets objectForKey:[NSNumber numberWithInteger:(NSInteger)target]];
	for(CCTimer* t in timers) {
		if (t.selector == selector) {
			[self removeTimer:t];
		}
	}
	// Check any we were going to add
	for(CCTimer* t in methodsToAdd) {
		if(t.target == target && t.selector == selector) {
			[methodsToAdd removeObject:t];
			break;
		}
	}
	
}




-(void) scaleAllTimersForTarget:(id)target ScaleFactor:(float)scaleFactor {
#ifdef DEBUG_SCHEDULER		
	NSLog(@"%s targets: %@",__PRETTY_FUNCTION__,targets);
#endif		
	NSArray* timers = [targets objectForKey:[NSNumber numberWithInteger:(NSInteger)target]];
	for(CCTimer* t in timers) {
		t.timeScale = scaleFactor;
	}
	// Check any we were going to add
	for(CCTimer* t in methodsToAdd) {
		if(t.target == target ) {
			t.timeScale = scaleFactor;
			break;
		}
	}	
}



-(void) trackerTimerByTarget:(CCTimer*) t
{
	
#ifdef DEBUG_SCHEDULER	
	NSLog(@"%s: %@",__PRETTY_FUNCTION__,t);
#endif	

	NSNumber* key = [NSNumber numberWithInteger:(NSInteger)t.target];
	NSMutableArray* timers = [targets objectForKey:key];
	if (timers == nil) {
		timers = [NSMutableArray arrayWithCapacity:1]; // Usually only 1 timer per target
		[targets setObject:timers forKey:key];
	}
	[timers addObject:t];
#ifdef DEBUG_SCHEDULER		
	NSLog(@"%s targets: %@",__PRETTY_FUNCTION__,targets);
#endif	
}

-(NSArray*) getTimersForTarget:(id) target {
	return [targets objectForKey:[NSNumber numberWithInteger:(NSInteger)target]];
}

-(void) untrackTimer:(CCTimer*) t {

#ifdef DEBUG_SCHEDULER	
	NSLog(@"%s: %@",__PRETTY_FUNCTION__,t);
	NSLog(@"%s targets: %@",__PRETTY_FUNCTION__,targets);
#endif
	
	NSNumber* key = [NSNumber numberWithInteger:(NSInteger)t.target];

	NSMutableArray* timers = [targets objectForKey:key];
	NSAssert2(timers != nil,@"%s: did not have any timers tracked for target:%@",__PRETTY_FUNCTION__,[t.target class]);
	[timers removeObject:t];
	if([timers count] == 0)
		[targets removeObjectForKey:key];
}


@end
