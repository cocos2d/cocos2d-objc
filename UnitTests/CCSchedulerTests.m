//
//  CCSchedulerTests.m
//  cocos2d-ios
//
//  Created by Scott Lembcke on 10/21/13.
//
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"


// XCTAssertEqual() doesn't like comparing to the preprocessor token for some reason.
static CCTime inf = INFINITY;


@interface SequenceTester : NSObject<CCSchedulerTarget>
@property(nonatomic, strong) NSMutableArray *sequence;
@property(nonatomic, assign) NSInteger priority;
@property(nonatomic, copy) NSString *name;
@end


@implementation SequenceTester

-(void)update:(CCTime)delta
{
	if(_sequence) [_sequence addObject:[NSString stringWithFormat:@"update(%@):%.1f", self.name, delta]];
}

-(void)fixedUpdate:(CCTime)delta
{
	if(_sequence) [_sequence addObject:[NSString stringWithFormat:@"fixedUpdate(%@):%.1f", self.name, delta]];
}

@end


@interface ScheduledRemoveTester : NSObject<CCSchedulerTarget>
-(id)initWithScheduler:(CCScheduler *)scheduler removalTime:(int)removalTime;
@end


@implementation ScheduledRemoveTester {
	CCScheduler *_scheduler;
	// int since it's also used as a priority.
	int _removalTime;
}

-(NSInteger)priority
{
	// Force it to sort by removal time to ensure objects are removed in worst case order.
	return _removalTime;
}

-(id)initWithScheduler:(CCScheduler *)scheduler removalTime:(int)removalTime
{
	if((self = [super init])){
		_scheduler = scheduler;
		_removalTime = removalTime;
	}
	
	return self;
}

-(void)update:(CCTime)delta
{
	if(_scheduler.currentTime > _removalTime){
		[_scheduler unscheduleTarget:self];
	}
}

@end


@interface NSNumber(CCSchedulerTarget)<CCSchedulerTarget>
@end


@implementation NSNumber(CCSchedulerTarget)

-(NSInteger)priority {return self.integerValue;}

@end


@interface CCSchedulerTests : XCTestCase
@end

@implementation CCSchedulerTests {
}

- (void)testInvoke0
{
	NSMutableArray *seq = [NSMutableArray array];
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	[scheduler scheduleBlock:^(CCTimer *timer){
		XCTAssertEqual(timer.deltaTime, 0.0, @"");
		XCTAssertEqual(timer.invokeTime, 0.0, @"");
		[seq addObject:@(timer.invokeTime)];
	} forTarget:nil withDelay:0.0];
	
	[scheduler update:0.0];
	
	XCTAssertEqualObjects(seq, (@[@0.0]), @"");
}

- (void)testInvokeDelay
{
	NSMutableArray *seq = [NSMutableArray array];
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	[scheduler scheduleBlock:^(CCTimer *timer){
		XCTAssertEqual(timer.deltaTime, 1.0, @"");
		XCTAssertEqual(timer.invokeTime, 1.0, @"");
		[seq addObject:@(timer.invokeTime)];
	} forTarget:nil withDelay:1.0];
	
	[scheduler update:1.0];
	
	XCTAssertEqualObjects(seq, (@[@1.0]), @"");
}

- (void)testInvokeDelay2
{
	NSMutableArray *seq = [NSMutableArray array];
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	[scheduler scheduleBlock:^(CCTimer *timer){
		XCTAssertEqual(timer.deltaTime, 1.0, @"");
		XCTAssertEqual(timer.invokeTime, 1.0, @"");
		[seq addObject:@(timer.invokeTime)];
	} forTarget:nil withDelay:1.0];
	
	// Updating beyond the timestep should still work.
	[scheduler update:10.0];
	
	XCTAssertEqualObjects(seq, (@[@1.0]), @"");
}

- (void)testInvokeReschedule
{
	NSMutableArray *seq = [NSMutableArray array];
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	__block CCTime expectedInvokeTime = 1.0;
	__block CCTime expectedDeltaTime = 1.0;
	
	[scheduler scheduleBlock:^(CCTimer *timer){
		XCTAssertEqual(timer.deltaTime, expectedDeltaTime, @"");
		XCTAssertEqual(timer.invokeTime, expectedInvokeTime, @"");
		
		expectedDeltaTime = 0.5;
		expectedInvokeTime += expectedDeltaTime;
		
		[seq addObject:@(timer.invokeTime)];
		[timer repeatOnceWithInterval:0.5];
	} forTarget:nil withDelay:1.0];
	
	// Updating beyond the timestep should still work.
	[scheduler update:2.0];
	
	XCTAssertEqualObjects(seq, (@[@1.0, @1.5, @2.0]), @"");
}

- (void)testInvokeRepeat
{
	NSMutableArray *seq = [NSMutableArray array];
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	CCTimer *timer = [scheduler scheduleBlock:^(CCTimer *timer){
			[seq addObject:@(timer.invokeTime)];
	} forTarget:nil withDelay:1.0];
	
	timer.repeatCount = 3;
	timer.repeatInterval = 0.5;
	
	// Updating beyond the timestep should still work because the timer should get unscheduled.
	[scheduler update:10.0];
	
	XCTAssertEqualObjects(seq, (@[@1.0, @1.5, @2.0, @2.5]), @"");
}

- (void)testInvalidate
{
	__block int counter = 0;
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	CCTimer *timer = [scheduler scheduleBlock:^(CCTimer *timer){
			counter++;
	} forTarget:nil withDelay:0];
	XCTAssertFalse(timer.invalid, @"");
	
	timer.repeatCount = CCTimerRepeatForever;
	timer.repeatInterval = 1.0;
	
	[scheduler update:10.0];
	XCTAssertEqual(counter, 11, @"");
	XCTAssertFalse(timer.invalid, @"");
	
	[timer invalidate];
	XCTAssertTrue(timer.invalid, @"");
	
	[scheduler update:10.0];
	XCTAssertEqual(counter, 11, @"");
	XCTAssertTrue(timer.invalid, @"");
}

- (void)testUpdate
{
	NSMutableArray *seq = [NSMutableArray array];
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = 1.0;
	
	SequenceTester *target = [[SequenceTester alloc] init];
	target.sequence = seq;
	target.name = @"foo";
	
	XCTAssertFalse([scheduler isTargetScheduled:target], @"");
	
	[scheduler scheduleTarget:target];
	XCTAssertTrue([scheduler isTargetScheduled:target], @"");
	
	// Targets are initially paused.
	XCTAssertTrue([scheduler isTargetPaused:target], @"");
	
	[seq removeAllObjects];
	[scheduler update:2.0];
	XCTAssertEqualObjects(seq, (@[
	]), @"");
	
	// Unpause and try a few steps.
	[scheduler setPaused:NO target:target];
	XCTAssertFalse([scheduler isTargetPaused:target], @"");
	
	[seq removeAllObjects];
	[scheduler update:3.0];
	XCTAssertEqualObjects(seq, (@[
		@"fixedUpdate(foo):1.0",
		@"fixedUpdate(foo):1.0",
		@"fixedUpdate(foo):1.0",
		@"update(foo):3.0",
	]), @"");
	
	[seq removeAllObjects];
	[scheduler update:2.0];
	XCTAssertEqualObjects(seq, (@[
		@"fixedUpdate(foo):1.0",
		@"fixedUpdate(foo):1.0",
		@"update(foo):2.0",
	]), @"");
	
	// Enable pause again.
	[scheduler setPaused:YES target:target];
	XCTAssertTrue([scheduler isTargetPaused:target], @"");
	
	[seq removeAllObjects];
	[scheduler update:2.0];
	XCTAssertEqualObjects(seq, (@[
	]), @"");
	
	// Unpause the second time.
	[scheduler setPaused:NO target:target];
	XCTAssertFalse([scheduler isTargetPaused:target], @"");
	
	[seq removeAllObjects];
	[scheduler update:2.0];
	XCTAssertEqualObjects(seq, (@[
		@"fixedUpdate(foo):1.0",
		@"fixedUpdate(foo):1.0",
		@"update(foo):2.0",
	]), @"");
	
	// Remove the target.
	[scheduler unscheduleTarget:target];
	XCTAssertFalse([scheduler isTargetScheduled:target], @"");
	
	[seq removeAllObjects];
	[scheduler update:2.0];
	XCTAssertEqualObjects(seq, (@[
	]), @"");
}

- (void)testLotsOfTimers
{
	NSMutableSet *invocations = [NSMutableSet set];
	NSMutableSet *expectedInvocations = [NSMutableSet set];
	
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	// Stuff 100k timers into the scheduler.
	for(int i=0; i<100000; i++){
		NSNumber *n = @(i);
		
		CCTimer *timer = [scheduler scheduleBlock:^(CCTimer *timer){
			[invocations addObject:n];
		} forTarget:n withDelay:CCRANDOM_0_1()*200.0];
		
		// Invalidate some of the timers.
		if(CCRANDOM_0_1() > 0.5){
			[timer invalidate];
		} else {
			// Only stepping to t=100, timers are scheduled to t=200
			if(timer.invokeTime <= 100.0){
				[expectedInvocations addObject:n];
			}
		}
	}
	
	// 1/(power of two) just to avoid floating point issues
	CCTime dt = 1.0/64.0;
	for(CCTime t=0.0; t<100.0; t += dt){
		[scheduler update:dt];
	}
	
	XCTAssertEqualObjects(invocations, expectedInvocations, @"");
}

- (void)testLotsOfRepeatingTimers
{
	NSMutableDictionary *invocations = [NSMutableDictionary dictionary];
	NSMutableDictionary *expectedInvocations = [NSMutableDictionary dictionary];
	
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	int repeatCount = 1000;
	NSNumber *expectedInvocationCount = @(repeatCount + 1);
	
	// Stuff 1k timers into the scheduler.
	for(int i=0; i<1000; i++){
		NSNumber *n = @(i);
		
		CCTimer *timer = [scheduler scheduleBlock:^(CCTimer *timer){
			NSNumber *count = [invocations objectForKey:n];
			[invocations setObject:@(count.intValue + 1) forKey:n];
		} forTarget:n withDelay:CCRANDOM_0_1()];
		
		timer.repeatCount = repeatCount;
		timer.repeatInterval = CCRANDOM_0_1();
		
		[expectedInvocations setObject:expectedInvocationCount forKey:n];
	}
	
	CCTime dt = 1.0/60.0;
	for(CCTime t=0.0; t<(repeatCount + 1); t += dt){
		[scheduler update:dt];
	}
	
	XCTAssertEqualObjects(invocations, expectedInvocations, @"");
}

- (void)testPauseTimer
{
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	[scheduler update:2.0];
	XCTAssertEqual(scheduler.currentTime, 2.0, @"");
	
	__block CCTime invokedTime = -1.0;
	CCTimer *timer = [scheduler scheduleBlock:^(CCTimer *timer){
		invokedTime = timer.invokeTime;
		
		// deltaTime should not include paused time.
		XCTAssertEqual(timer.invokeTime, timer.scheduler.currentTime, @"");
		XCTAssertEqual(timer.deltaTime, 5.0, @"");
	} forTarget:nil withDelay:5.0];
	XCTAssertEqual(timer.invokeTime, 7.0, @"");
	
	[scheduler update:2.0];
	XCTAssertEqual(timer.invokeTime, 7.0, @"");
	
	timer.paused = YES;
	timer.paused = YES;
	XCTAssertEqual(timer.invokeTime, inf, @"");
	// After resuming the timer should have 3 seconds remaining.
	
	[scheduler update:10.0];
	XCTAssertEqual(invokedTime, -1.0, @"");
	XCTAssertEqual(scheduler.currentTime, 14.0, @"");
	
	timer.paused = NO;
	XCTAssertEqual(timer.invokeTime, 17.0, @"");
	
	timer.paused = YES;
	XCTAssertEqual(timer.invokeTime, inf, @"");
	
	timer.paused = NO;
	timer.paused = NO;
	XCTAssertEqual(timer.invokeTime, 17.0, @"");
	
	[scheduler update:10.0];
	XCTAssertEqual(invokedTime, 17.0, @"");
	
	// The timer should have an infinite invoke time after it has expired.
	XCTAssertEqual(timer.invokeTime, inf, @"");
}

- (void)testPauseTimerTarget
{
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	[scheduler update:2.0];
	XCTAssertEqual(scheduler.currentTime, 2.0, @"");
	
	__block CCTime invokedTime = -1.0;
	CCTimer *timer = [scheduler scheduleBlock:^(CCTimer *timer){
		invokedTime = timer.invokeTime;
		
		// deltaTime should not include paused time.
		XCTAssertEqual(timer.deltaTime, 5.0, @"");
	} forTarget:nil withDelay:5.0];
	XCTAssertEqual(timer.invokeTime, 7.0, @"");
	
	[scheduler update:2.0];
	XCTAssertEqual(timer.invokeTime, 7.0, @"");
	
	[scheduler setPaused:YES target:nil];
	XCTAssertEqual(timer.invokeTime, inf, @"");
	// After resuming the timer should have 3 seconds remaining.
	
	[scheduler update:10.0];
	XCTAssertEqual(invokedTime, -1.0, @"");
	XCTAssertEqual(scheduler.currentTime, 14.0, @"");
	
	[scheduler setPaused:NO target:nil];
	XCTAssertEqual(timer.invokeTime, 17.0, @"");
	
	[scheduler setPaused:YES target:nil];
	XCTAssertEqual(timer.invokeTime, inf, @"");
	
	[scheduler setPaused:NO target:nil];
	XCTAssertEqual(timer.invokeTime, 17.0, @"");
	
	[scheduler update:10.0];
	XCTAssertEqual(invokedTime, 17.0, @"");
	
	// The timer should have an infinite invoke time after it has expired.
	XCTAssertEqual(timer.invokeTime, inf, @"");
}

-(void)testTimerIncrement
{
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	__block int invocations = 0;
	__block CCTime delay = 1.0;
	__block CCTime expectedInvokeTime = delay;
	
	CCTimer *timer = [scheduler scheduleBlock:^(CCTimer *timer){
		XCTAssertEqual(timer.invokeTime, expectedInvokeTime, @"");
		
		invocations++;
		if(invocations == 3){
			invocations = 0;
			delay += 1.0;
		}
		
		if(delay < 10){
			expectedInvokeTime += delay;
			[timer repeatOnceWithInterval:delay];
		}
	} forTarget:nil withDelay:delay];
	
	[scheduler update:1000.0];
	XCTAssertTrue(timer.invalid, @"");
}

-(void)testTimerPriorities
{
	NSMutableArray *seq = [NSMutableArray array];
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	NSArray *priorities = @[@4, @5, @8, @0, @7, @2, @3, @9, @6, @1];
	
	for(NSNumber *priority in priorities){
		SequenceTester *target = [[SequenceTester alloc] init];
		target.priority = priority.integerValue;
		
		[scheduler scheduleBlock:^(CCTimer *timer){[seq addObject:priority];} forTarget:target withDelay:1.0];
		[scheduler setPaused:NO target:target];
	}
	
	XCTAssertEqualObjects(seq, [seq sortedArrayUsingSelector:@selector(compare:)], @"");
}

// Pausing a timer at exactly it's invokation time should still invoke the timer.
-(void)testTimerPauseAtInvoke
{
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	__block int timer1CallCount = 0;
	__block int timer2CallCount = 0;
	
	// This target will be paused at exactly it's invocation time.
	CCTimer *timer1 = [scheduler scheduleBlock:^(CCTimer *timer){
		timer1CallCount++;
	} forTarget:nil withDelay:1.0];
	
	timer1.repeatCount = CCTimerRepeatForever;
	
	// This is a high priority target and will be called first to pause the first timer.
	SequenceTester *target = [[SequenceTester alloc] init];
	target.priority = -1;
	
	[scheduler setPaused:NO target:target];
	
	[scheduler scheduleBlock:^(CCTimer *unused){
		timer1.paused = true;
		timer2CallCount++;
	} forTarget:target withDelay:1.0];
	
	[scheduler update:10.0];
	XCTAssertEqual(timer1CallCount, 0, @"");
	XCTAssertEqual(timer2CallCount, 1, @"");
}

-(void)testTimerPause1
{
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	CCTimer *timer = [scheduler scheduleBlock:^(CCTimer *t){
		XCTAssertEqual(t.deltaTime, 3.0, @"");
		XCTAssertEqual(t.invokeTime, 6.0, @"");
		XCTAssertEqual(t.scheduler.currentTime, 6.0, @"");
	} forTarget:nil withDelay:3.0];
	XCTAssertEqual(timer.invokeTime, 3.0, @"");
	
	// Pause at 1.0
	[scheduler scheduleBlock:^(CCTimer *t){
		timer.paused = YES;
		XCTAssertEqual(timer.invokeTime, inf, @"");
	} forTarget:nil withDelay:1.0];
	
	// Unpause at 4.0
	[scheduler scheduleBlock:^(CCTimer *t){
		timer.paused = NO;
		XCTAssertEqual(timer.invokeTime, 6.0, @"");
	} forTarget:nil withDelay:4.0];
	
	[scheduler update:20.0];
}

-(void)testTimerPause2
{
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	CCTimer *timer = [scheduler scheduleBlock:^(CCTimer *t){
		XCTAssertEqual(t.deltaTime, 3.0, @"");
		XCTAssertEqual(t.invokeTime, 4.0, @"");
		XCTAssertEqual(t.scheduler.currentTime, 4.0, @"");
	} forTarget:nil withDelay:3.0];
	XCTAssertEqual(timer.invokeTime, 3.0, @"");
	
	// Pause at 1.0
	[scheduler scheduleBlock:^(CCTimer *t){
		timer.paused = YES;
		XCTAssertEqual(timer.invokeTime, inf, @"");
	} forTarget:nil withDelay:1.0];
	
	// Unpause at 2.0
	[scheduler scheduleBlock:^(CCTimer *t){
		timer.paused = NO;
		XCTAssertEqual(timer.invokeTime, 4.0, @"");
	} forTarget:nil withDelay:2.0];
	
	[scheduler update:20.0];
}

-(void)testTimerPause3
{
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	CCTimer *timer = [scheduler scheduleBlock:^(CCTimer *t){
		XCTAssertEqual(t.deltaTime, 2.0, @"");
		XCTAssertEqual(t.invokeTime, 4.0, @"");
		XCTAssertEqual(t.scheduler.currentTime, 4.0, @"");
	} forTarget:nil withDelay:2.0];
	XCTAssertEqual(timer.invokeTime, 2.0, @"");
	
	// Pause at 1.0
	[scheduler scheduleBlock:^(CCTimer *t){
		timer.paused = YES;
		XCTAssertEqual(timer.invokeTime, inf, @"");
	} forTarget:nil withDelay:1.0];
	
	// Unpause at 3.0
	[scheduler scheduleBlock:^(CCTimer *t){
		timer.paused = NO;
		XCTAssertEqual(timer.invokeTime, 4.0, @"");
	} forTarget:nil withDelay:3.0];
	
	[scheduler update:20.0];
}

-(void)testTimerPause4
{
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	__block int invokeCount = 0;
	
	CCTimer *timer = [scheduler scheduleBlock:^(CCTimer *t){
		XCTAssertEqual(t.deltaTime, 2.0, @"");
		XCTAssertEqual(fmod(t.invokeTime, 4.0), 0.0, @"");
		XCTAssertEqual(t.invokeTime, t.scheduler.currentTime, @"");
		
		invokeCount++;
	} forTarget:nil withDelay:2.0];
	
	timer.repeatCount = 2;
	
	// Pause at 0.5 + 2i
	[scheduler scheduleBlock:^(CCTimer *pausingTimer){
		timer.paused = YES;
		XCTAssertEqual(timer.invokeTime, inf, @"");
		
		[pausingTimer repeatOnceWithInterval:2.0];
	} forTarget:nil withDelay:0.5];
	
	// Unpause at 1.5 + 2i
	[scheduler scheduleBlock:^(CCTimer *unpausingTimer){
		timer.paused = NO;
		
		if(timer.invokeTime > 12.0){
			// After 12.0, the timer will stop repeating and become invalid.
			XCTAssertEqual(timer.invokeTime, inf, @"");
		} else if(fmod(unpausingTimer.invokeTime, 4.0) == 1.5){
			XCTAssertEqual(fmod(timer.invokeTime, 4.0), 3.0, @"");
		} else {
			XCTAssertEqual(fmod(timer.invokeTime, 4.0), 0.0, @"");
		}
		
		[unpausingTimer repeatOnceWithInterval:2.0];
	} forTarget:nil withDelay:1.5];
	
	[scheduler update:20.0];
	XCTAssertEqual(invokeCount, 3, @"");
}

-(void)testRemoveScheduledUpdate
{
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	const int count = 10;
	NSMutableArray *targets = [NSMutableArray array];
	
	for(int i=0; i<count; i++){
		ScheduledRemoveTester *target = [[ScheduledRemoveTester alloc] initWithScheduler:scheduler removalTime:i];
		[scheduler scheduleTarget:target];
		[scheduler setPaused:FALSE target:target];
		[targets addObject:target];
	}
	
	for(id target in targets){
		XCTAssertTrue([scheduler isTargetScheduled:target], @"");
	}
	
	CCTime dt = 1.0/60.0;
	for(CCTime t=0.0; t<count; t += dt){
		// Update methods will remove the targets one by one.
		[scheduler update:dt];
	}
	
	for(id target in targets){
		XCTAssertFalse([scheduler isTargetScheduled:target], @"");
	}
}

-(void)testLotsOfTargetRemovals
{
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedUpdateInterval = INFINITY;
	
	const int count = 500;
	NSMutableArray *targets = [NSMutableArray array];
	
	for(int i=0; i<count; i++){
		SequenceTester *target = [[SequenceTester alloc] init];
		[scheduler scheduleTarget:target];
		[scheduler setPaused:FALSE target:target];
		[targets addObject:target];
	}
	
	for(id target in targets){
		XCTAssertTrue([scheduler isTargetScheduled:target], @"");
	}
	
	CCTime dt = 1.0/60.0;
	for(CCTime t=0.0; t<count; t += dt){
		CCTime t = scheduler.currentTime;
		// Remove the scheduler targets outside of the update loop in this test.
		if(floor(t) < floor(t + dt)){
			[scheduler unscheduleTarget:targets[(int)t]];
		}
		
		[scheduler update:dt];
	}
	
	for(id target in targets){
		XCTAssertFalse([scheduler isTargetScheduled:target], @"");
	}
}

@end
