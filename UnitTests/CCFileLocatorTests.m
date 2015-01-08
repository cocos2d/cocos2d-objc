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
#import "FileSystemTestCase.h"

@interface CCFileLocatorTests : FileSystemTestCase

@property (nonatomic, strong) CCFileLocator *fileLocator;

@end


@implementation CCFileLocatorTests

- (void)setUp
{
    [super setUp];

    self.fileLocator = [[CCFileLocator alloc] init];
    _fileLocator.searchPaths = @[[self fullPathForFile:@"Resources"]];
}

- (void)testFileNamedFileDoesNotExist
{
    [self createEmptyFiles:@[
            @"Resources/images/vehicles/spaceship.png",
            @"Resources/images/vehicles/car.png",
            @"Resources/images/vehicles/bike.png",
            @"Resources/images/vehicles/airplane.png",
    ]];

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"train.png" options:nil error:&error];

    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, ERROR_FILELOCATOR_NO_FILE_FOUND);
    XCTAssertNil(file);
}

- (void)testFileNamedRecursiveSimple
{
    NSString *fileRelPath = @"Resources/images/vehicles/spaceship.png";

    [self createEmptyFiles:@[
            fileRelPath
    ]];

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"spaceship.png" options:nil error:&error];

    XCTAssertNotNil(file);
    XCTAssertNil(error);
    XCTAssertEqualObjects(file.absoluteFilePath, [self fullPathForFile:fileRelPath]);
}

- (void)testEmptySearchPaths
{
    _fileLocator.searchPaths = @[];

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"someasset.png" options:nil error:&error];

    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, ERROR_FILELOCATOR_NO_SEARCH_PATHS);
    XCTAssertNil(file);
}

/*
- (void)testPerformanceExample
{
    [self createEmptyFiles:@[
            @"Resources/images/vehicles/spaceship.png",
            @"Resources/images/vehicles/car.png",
            @"Resources/images/vehicles/bike.png",
            @"Resources/images/vehicles/airplane.png",
            @"Resources/images/housing/castle.png",
            @"Resources/images/housing/skyscraper.png",
            @"Resources/images/housing/cottage.png",
            @"Resources/images/housing/tent.png",
            @"Resources/sounds/animals/cat.png",
            @"Resources/sounds/animals/dog.png",
            @"Resources/sounds/animals/snake.png",
            @"Resources/sounds/animals/elephant.png",
    ]];

    [self measureBlock:^
    {
        CCFile *file = [_fileLocator fileNamed:@"elephant.png" options:nil error:nil];
    }];
}
*/

@end
