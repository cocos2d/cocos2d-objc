//
//  CCSchedulerTests.m
//  cocos2d-ios
//
//  Created by Scott Lembcke on 10/21/13.
//
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"

@interface CCSchedulerTests : XCTestCase

@end

@implementation CCSchedulerTests {
	NSArray *_sequence;
}

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

-(void)tick:(ccTime)dt
{
	_sequence = [_sequence arrayByAddingObject:[NSString stringWithFormat:@"%.1f", dt]];
}

- (void)testSchedule
{
	CCScheduler *scheduler = [[CCScheduler alloc] init];
	
	_sequence = @[];
	[scheduler scheduleSelector:@selector(tick:) forTarget:self interval:1.0 paused:NO];
	
	[scheduler update:0.0];
	[scheduler update:3.0];
	XCTAssertEqualObjects(_sequence,  (@[@"1.0", @"1.0", @"1.0"]), @"");
}

@end
