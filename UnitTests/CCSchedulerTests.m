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
@end


@implementation SchedulerTarget

-(void)update:(ccTime)delta
{
	[_sequence addObject:[NSString stringWithFormat:@"update:%f", delta]];
}

-(void)fixedUpdate:(ccTime)delta
{
	[_sequence addObject:[NSString stringWithFormat:@"fixedUpdate:%f", delta]];
}

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
	// Easier to debug if it doesn't call fixed updates.
	scheduler.fixedTimeStep = INFINITY;
	
	[scheduler scheduleBlock:^(CCTimer *timer){
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
	// Easier to debug if it doesn't call fixed updates.
	scheduler.fixedTimeStep = INFINITY;
	
	[scheduler scheduleBlock:^(CCTimer *timer){
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
	// Easier to debug if it doesn't call fixed updates.
	scheduler.fixedTimeStep = INFINITY;
	
	[scheduler scheduleBlock:^(CCTimer *timer){
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
	// Easier to debug if it doesn't call fixed updates.
	scheduler.fixedTimeStep = INFINITY;
	
	[scheduler scheduleBlock:^(CCTimer *timer){
			[seq addObject:@(timer.invokeTime)];
			[timer repeatOnceWithInterval:0.5];
	} forTarget:nil withDelay:1.0];
	
	// Updating beyond the timestep should still work.
	[scheduler update:2.0];
	
	XCTAssertEqualObjects(seq, (@[@1.0, @1.5, @2.0]), @"");
}

@end
