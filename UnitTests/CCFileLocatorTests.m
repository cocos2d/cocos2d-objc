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

- (void)testFileNamedSearchOrderPrecedenceDefaultContentScale
{
    [self createEmptyFiles:@[
        @"Resources/Hero-4x.png",
        @"Resources/Hero-2x.png",
        @"Resources/Hero-1x.png",
        @"Resources/Hero.png"
    ]];

    _fileLocator.deviceContentScale = 3;
    _fileLocator.defaultContentScale = 4;

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero.png" contentScale:4.0 error:error];
}

- (void)assertSuccessForFile:(CCFile *)file filePath:(NSString *)filePath contentScale:(CGFloat)contentScale error:(NSError *)error
{
    XCTAssertNil(error);
    XCTAssertNotNil(file);
    XCTAssertEqualObjects(file.absoluteFilePath, [self fullPathForFile:filePath]);
    XCTAssertEqual(file.contentScale, contentScale );
}

- (void)testFileNamedRecursiveSimpleWithDefaultContentScale
{
    [self createEmptyFiles:@[@"Resources/images/vehicles/spaceship.png"]];

    _fileLocator.defaultContentScale = 4;

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"spaceship.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/images/vehicles/spaceship.png" contentScale:4.0 error:error];
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

- (void)testShouldNotReturnDirectoryURLWithAssetFilename
{
    [self createFolders:@[@"Resources/image.png"]];

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"image.png" options:nil error:&error];

    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, ERROR_FILELOCATOR_NO_FILE_FOUND);
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
