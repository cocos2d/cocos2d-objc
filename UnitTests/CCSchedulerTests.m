//
//  CCSchedulerTests.m
//  cocos2d-ios
//
//  Created by Scott Lembcke on 10/21/13.
//
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"


@interface SchedulerTarget : NSObject<CCSchedulerTarget>
@property(nonatomic, strong) NSMutableArray *sequence;
@property(nonatomic, assign) NSInteger priority;
@property(nonatomic, copy) NSString *name;
@end


@implementation SchedulerTarget

-(void)update:(ccTime)delta
{
	[_sequence addObject:[NSString stringWithFormat:@"update(%@):%.1f", self.name, delta]];
}

-(void)fixedUpdate:(ccTime)delta
{
	[_sequence addObject:[NSString stringWithFormat:@"fixedUpdate(%@):%.1f", self.name, delta]];
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
	scheduler.fixedTimeStep = INFINITY;
	
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
	scheduler.fixedTimeStep = INFINITY;
	
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
	scheduler.fixedTimeStep = INFINITY;
	
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
	scheduler.fixedTimeStep = INFINITY;
	
	__block ccTime expectedInvokeTime = 1.0;
	__block ccTime expectedDeltaTime = 1.0;
	
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
	scheduler.fixedTimeStep = INFINITY;
	
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
	scheduler.fixedTimeStep = INFINITY;
	
	CCTimer *timer = [scheduler scheduleBlock:^(CCTimer *timer){
			counter++;
	} forTarget:nil withDelay:0];
	
	timer.repeatCount = CCTimerRepeatForever;
	timer.repeatInterval = 1.0;
	
	[scheduler update:10.0];
	XCTAssertEqual(counter, 11, @"");
	
	[timer invalidate];
	[scheduler update:10.0];
	XCTAssertEqual(counter, 11, @"");
}

- (void)testUpdate
{
	NSMutableArray *seq = [NSMutableArray array];
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedTimeStep = 1.0;
	
	SchedulerTarget *target = [[SchedulerTarget alloc] init];
	target.sequence = seq;
	target.name = @"foo";
	
	[scheduler scheduleTarget:target];
	
	[scheduler update:3.0];
	XCTAssertEqualObjects(seq, (@[
		@"fixedUpdate(foo):1.0", // First fixedUpdate: is called at t=0
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
}

- (void)testLotsOfTimers
{
	NSMutableSet *invocations = [NSMutableSet set];
	NSMutableSet *expectedInvocations = [NSMutableSet set];
	
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	scheduler.maxTimeStep = INFINITY;
	scheduler.fixedTimeStep = INFINITY;
	
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
	ccTime dt = 1.0/64.0;
	for(ccTime t=0.0; t<100.0; t += dt){
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
	scheduler.fixedTimeStep = INFINITY;
	
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
	
	ccTime dt = 1.0/60.0;
	for(ccTime t=0.0; t<(repeatCount + 1); t += dt){
		[scheduler update:dt];
	}
	
	XCTAssertEqualObjects(invocations, expectedInvocations, @"");
}

@end
