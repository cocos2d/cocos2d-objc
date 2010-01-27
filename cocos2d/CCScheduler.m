/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009,2010 Ricardo Quesada
 * Copyright (C) 2010 David Whatley
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
#import "CCProtocols.h"

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


+(id) timerWithTarget:(id) t selector:(SEL)s interval:(ccTime) i repeat:(int)times paused:(BOOL)paused
{
	return [[[self alloc] initWithTarget:t selector:s interval:i repeat:times paused:paused] autorelease];
}

-(id) initWithTarget:(id) t selector:(SEL)s interval:(ccTime) seconds repeat:(int)times paused:(BOOL)isPaused
{
	if( (self=[super init]) ) {
#if	COCOS2D_DEBUG
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
		paused = isPaused;
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
#pragma mark CCUpdateBucket

@implementation CCUpdateBucket
@synthesize priority;


-(id) initWithPriority:(NSInteger) aPriority
{	
	if( (self = [super init])) {
	
		priority = aPriority;
		updateRequests = [[NSMutableArray arrayWithCapacity:64] retain];
	}
	
	return self;	
}

- (void) dealloc {
	[updateRequests release];
	[super dealloc];
}

-(void) requestUpdatesFor:(id <CCPerFrameUpdateProtocol>) aNode {
	[updateRequests addObject:aNode];
}

-(BOOL) cancelUpdatesFor:(id <CCPerFrameUpdateProtocol>) aNode {
	NSUInteger index = [updateRequests indexOfObject:aNode];
	if(index == NSNotFound)
		return NO;
	[updateRequests removeObjectAtIndex:index];
	return YES;
}

-(void) update:(ccTime) dt {
	
	[updateRequests makeObjectsPerformSelector:@selector(perFrameUpdate:)];
	
	for(id <CCPerFrameUpdateProtocol> n in updateRequests)
			[n perFrameUpdate:dt];	
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
@synthesize perFrameCount;

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
		
		buckets = [[NSMutableArray arrayWithCapacity:128] retain];
		perFrameCount = 0;
		
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
	[buckets release];
	[targets release];
 	
	sharedScheduler = nil;
	
	[super dealloc];
}

-(void) addTimer: (CCTimer*)t
{
	// it is possible that sometimes (in transitions in particular) an scene unschedule a timer
	// and before the timer is deleted, it is re-scheduled
	if( [methodsToRemove containsObject:t] )
	{
		[methodsToRemove removeObject:t];
		return;
	}
	
	NSAssert( ! ([scheduledMethods containsObject:t] || [methodsToAdd containsObject:t]), @"Scheduler.addTimer: timer already scheduled");

	[methodsToAdd addObject: t];
}

-(void) removeTimer:(CCTimer*)t;
{
	// someone wants to remove it before it was added
	if( [methodsToAdd containsObject:t] ) {
		[methodsToAdd removeObject:t];
		return;
	}
	
	NSAssert( [scheduledMethods containsObject:t], @"Scheduler.removeTimer: timer not scheduled");
	
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
	//
	// New dt
	//
	if( timeScale != 1.0f )
		dt *= timeScale;

	//
	// Timers
	//
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
		if( ! t->paused ) {
			[t fire: dt];
			if (t->ticksUntilAutoExpire == 0) {
				[self removeTimer:t];
			}
		}
	}
	
	//
	// PerFrameUpdates
	//
	for(CCUpdateBucket* b in buckets) {
		[b update:dt];
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
	// Remove any timers we were scheduled to add (using set logic since we're iterating the set)
	NSMutableSet* toRemove = nil;
	for(CCTimer* t in methodsToAdd) {
		if(t.target == target) {
			if(toRemove == nil)
				toRemove = [NSMutableSet setWithCapacity:10];
			[toRemove addObject:t];
		}
	}
	if(toRemove)
		[methodsToAdd minusSet:toRemove];
	
}

-(void) setTarget:(id) target paused:(BOOL) paused {
	NSArray* timers = [targets objectForKey:[NSNumber numberWithInteger:(NSInteger)target]];
	for(CCTimer* t in timers) {
		t.paused = paused;
	}
	// pause/resume possible timers in methodsToAdd
	for(CCTimer* t in methodsToAdd) {
		if(t.target == target )
			t.paused = paused;
	}	
}

-(void) pauseAllTimersForTarget:(id)target {
	[self setTarget:target paused:YES];
}

-(void) resumeAllTimersForTarget:(id)target {
	[self setTarget:target paused:NO];
}


-(void) unscheduleSelector:(SEL)selector target:(id)target {
	
#ifdef DEBUG_SCHEDULER	
	NSLog(@"%s: [%@|%@] sel:%@",__PRETTY_FUNCTION__,target,[target class],NSStringFromSelector(selector));
#endif	
	
	
	NSArray* timers = [targets objectForKey:[NSNumber numberWithInteger:(NSInteger)target]];
	for(CCTimer* t in timers) {
		if (t.selector == selector) {
			[self removeTimer:t];
			break; // break, since it is impossible that to have duplicate selectors in 1 target
		}
	}
	// Check any we were going to add
	for(CCTimer* t in methodsToAdd) {
		// We can remove an object from an array we are iterating in this case because we break immediately after
		if(t.target == target && t.selector == selector) {
			[methodsToAdd removeObject:t];
			break; // break, since it is impossible that to have duplicate selectors in 1 target
		}
	}	
}




-(void) scaleAllTimersForTarget:(id)target scaleFactor:(float)scaleFactor {
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



-(void) requestPerFrameUpdatesForTarget:(id <CCPerFrameUpdateProtocol>) aNode priority:(NSInteger) aPriority {
	
	// The number of buckets will likely be small, so a linear scan is fine
	
	CCUpdateBucket* updateBucket = nil;
	for(CCUpdateBucket* b in buckets) {
		if(b.priority == aPriority) {
			updateBucket = b;
			break;
		}
	}
	
	if(updateBucket == nil) {
		updateBucket = [[[CCUpdateBucket alloc] initWithPriority:aPriority] autorelease];
		
		// Insertion sort
		NSUInteger insertAt = 0;
		for(CCUpdateBucket* b in buckets) {
			if(b.priority < aPriority)  // Higher priority buckets happen first
				break;
			++insertAt;
		}
		if(insertAt >= [buckets count]) {
			[buckets addObject:updateBucket];
		}
		else {
			[buckets insertObject:updateBucket atIndex:insertAt];
		}
	}
	
	[updateBucket requestUpdatesFor:aNode];
	++perFrameCount;
	
	
}


-(void) cancelPerFrameUpdatesForTarget:(id <CCPerFrameUpdateProtocol>) aNode {
	for(CCUpdateBucket* b in buckets) {
		if([b cancelUpdatesFor:aNode]) {
			--perFrameCount;
			break;
		}
	}
}



@end
