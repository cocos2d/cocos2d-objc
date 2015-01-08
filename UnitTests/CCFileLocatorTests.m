//
//  CCFileLocatorTests.m
//  cocos2d-tests
//
//  Created by Nicky Weber on 08.01.15.
//  Copyright (c) 2015 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCFile.h"
#import "CCFileLocator.h"
#import "CCPackageConstants.h"

@interface CCFileLocatorTests : XCTestCase

@property (nonatomic, strong) CCFileLocator *fileLocator;

@end


@implementation CCFileLocatorTests

- (void)setUp
{
    [super setUp];

    self.fileLocator = [[CCFileLocator alloc] init];
}

- (void)testEmptySearchPaths
{
    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"someasset.png" options:nil error:&error];

    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, ERROR_FILELOCATOR_NO_SEARCH_PATHS, @"Error code returned does not match expectation");
    XCTAssertNil(file, @"file should be nil");
}

- (void)testPerformanceExample
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
