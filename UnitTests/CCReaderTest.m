//
//  CCReaderTest.m
//  cocos2d-tests-ios
//
//  Created by John Twigg on 4/1/14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"
#import "CCBReader.h"
#include <mach/mach.h>
#include <mach/mach_time.h>

@interface CCReaderTest : XCTestCase

@end

@implementation CCReaderTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

double machGetClockS()
{
    static bool init = 0 ;
    static mach_timebase_info_data_t tbInfo ;
    static double conversionFactor ;
    if(!init)
    {
        init = 1 ;
        // get the time base
        mach_timebase_info( &tbInfo ) ;
        conversionFactor = tbInfo.numer / (1e9*tbInfo.denom) ; // ns->s
    }
    
    return mach_absolute_time() * conversionFactor ; // seconds
}

double machGetClockDiffS()
{
    static double lastTime = 0;
    
    double currentTime = machGetClockS() ;
    
    double diff = currentTime - lastTime ;
    
    lastTime = currentTime ; // update for next call
    
    return diff ; // that's your answer
}

-(void)testReaderPerformance
{
    NSString *filePath =[[NSBundle mainBundle] pathsForResourcesOfType:@"ccbi" inDirectory:@"Resources-shared/Tests"][0];
    XCTAssertNotNil(filePath);
    
    NSData * fileData = [[NSData alloc] initWithContentsOfFile:filePath];
    
    CCBReader  * ccbReader = [[CCBReader alloc] init];
    
    machGetClockDiffS();
    for (int i = 0; i < 100; i++)
    {
            [ccbReader loadWithData:fileData owner:self];
    }

    NSLog(@"TimeToRun: %0.8f", machGetClockDiffS());
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

@end
