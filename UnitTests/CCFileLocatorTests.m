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


#pragma mark - Tests for search order

- (void)testFileNamedSearchOrderPrecedenceDefaultContentScale
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"4", @"2", @"1", @"default"]];

    _fileLocator.deviceContentScale = 4;
    _fileLocator.defaultContentScale = 4;

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero.png" contentScale:4.0 error:error];
}

- (void)testFileNamedSearchOrder3XDeviceScaleNoDefaultImage
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"4", @"2", @"1"]];

    _fileLocator.deviceContentScale = 3;

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero-4x.png" contentScale:4.0 error:error];
}

- (void)testFileNamedSearchOrder2XDeviceScaleNoDefaultImage
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"4", @"2", @"1"]];

    _fileLocator.deviceContentScale = 2;

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero-2x.png" contentScale:2.0 error:error];
}

- (void)testFileNamedSearchOrder2XDeviceScaleNoDefaultAndPixelPerfectImage
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"4", @"1"]];

    _fileLocator.deviceContentScale = 2;

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero-4x.png" contentScale:4.0 error:error];
}

- (void)testFileNamedSearchOrder4XDeviceScaleOnlyLowResFallback
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"1"]];

    _fileLocator.deviceContentScale = 4;

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero-1x.png" contentScale:1.0 error:error];
}

- (void)testFileNamedSearchOrder4XDeviceScaleDefaultAndLowResImageAvailable
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"2", @"default"]];

    _fileLocator.deviceContentScale = 4;
    _fileLocator.defaultContentScale = 4;

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero.png" contentScale:4.0 error:error];
}


#pragma mark - Tests for search paths

- (void)testSearchPathsOrderImageAvailableInBothPaths
{
    [self createPNGsInDir:@"Packages/baa" name:@"Hero" scales:@[@"4", @"2", @"1"]];
    [self createPNGsInDir:@"Packages/foo" name:@"Hero" scales:@[@"4", @"2", @"1"]];

    _fileLocator.searchPaths = @[[self fullPathForFile:@"Packages/foo"], [self fullPathForFile:@"Packages/baa"]];
    _fileLocator.deviceContentScale = 2;

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Packages/foo/Hero-2x.png" contentScale:2.0 error:error];
}

- (void)testSearchPathsOrderImageAvailableOnlyInLastPath
{
    [self createPNGsInDir:@"Packages/baa" name:@"Hero" scales:@[@"4", @"2", @"1"]];
    [self createPNGsInDir:@"Packages/foo" name:@"Spaceship" scales:@[@"4", @"2", @"1"]];

    _fileLocator.searchPaths = @[[self fullPathForFile:@"Packages/foo"], [self fullPathForFile:@"Packages/baa"]];
    _fileLocator.deviceContentScale = 2;

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Packages/baa/Hero-2x.png" contentScale:2.0 error:error];
}


#pragma mark - Tests with errors

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


#pragma mark - helper

- (void)createPNGsInDir:(NSString *)dir name:(NSString *)name scales:(NSArray *)scales
{
    for (NSString *scale in scales)
    {
        NSString *imageName = [scale isEqualToString:@"default"]
            ? [NSString stringWithFormat:@"%@.png", name]
            : [NSString stringWithFormat:@"%@-%@x.png", name, scale];

        [self createEmptyFilesRelativeToDirectory:dir files:@[imageName]];
    }
}

- (void)assertSuccessForFile:(CCFile *)file filePath:(NSString *)filePath contentScale:(CGFloat)contentScale error:(NSError *)error
{
    XCTAssertNil(error);
    XCTAssertNotNil(file);
    XCTAssertEqualObjects(file.absoluteFilePath, [self fullPathForFile:filePath]);
    XCTAssertEqual(file.contentScale, contentScale );
}

@end
