//
//  CCFileUtilsV2Tests.m
//  cocos2d-tests
//
//  Created by Nicky Weber on 08.01.15.
//  Copyright (c) 2015 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCFile.h"
#import "CCFileUtilsV2.h"
#import "CCPackageConstants.h"
#import "FileSystemTestCase.h"
#import "CCUnitTestHelperMacros.h"
#import "CCFileUtilsDatabase.h"

@interface CCFileUtilsV2Tests : FileSystemTestCase

@property (nonatomic, strong) CCFileUtilsV2 *fileUtils;

@end


@implementation CCFileUtilsV2Tests

- (void)setUp
{
    [super setUp];

    self.fileUtils = [[CCFileUtilsV2 alloc] init];
    _fileUtils.searchPaths = @[[self fullPathForFile:@"Resources"]];
}


#pragma mark - Tests for search order with database

- (void)testFileNamedMultipleDatabasesAndSearchPaths
{
    NSString *jsonA = MULTILINESTRING(
        {
            "images/horse.png" : {
                "filename" : "images/mule.png"
            }
        }
    );

    NSString *jsonB = MULTILINESTRING(
        {
            "images/bicycle.png" : {
                "filename" : "images/unicycle.png"
            }
        }
    );

    _fileUtils.searchPaths = @[[self fullPathForFile:@"Resources"], [self fullPathForFile:@"Packages/Superpackage.sbpack"]];

    [self addDatabaseWithJSON:jsonA forSearchPath:[self fullPathForFile:@"Resources"]];
    [self addDatabaseWithJSON:jsonB forSearchPath:[self fullPathForFile:@"Packages/Superpackage.sbpack"]];

    _fileUtils.deviceContentScale = 4;
    _fileUtils.untaggedContentScale = 4;

    NSError *error1;
    CCFile *file1 = [_fileUtils fileNamed:@"images/horse.png" options:nil error:&error1];

    NSError *error2;
    CCFile *file2 = [_fileUtils fileNamed:@"images/bicycle.png" options:nil error:&error2];

    [self assertSuccessForFile:file1 filePath:@"Resources/mule.png" contentScale:4.0 error:error1];
    [self assertSuccessForFile:file2 filePath:@"Resources/unicycle.png" contentScale:4.0 error:error2];
}

- (void)testFileNamedNonExistingFileWithDatabase
{
    NSString *jsonA = MULTILINESTRING(
        {
            "images/foo.png" : {
                "filename" : "images/foo.png"
            }
        }
    );

    [self addDatabaseWithJSON:jsonA forSearchPath:[self fullPathForFile:@"Resources"]];

    NSError *error;
    CCFile *file = [_fileUtils fileNamed:@"images/foo.png" options:nil error:&error];

    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, ERROR_FILELOCATOR_FILE_IN_DATABASE_NOT_IN_FILESYSTEM);
    XCTAssertNil(file);
}

- (void)testFileNamedMetaDataWithDatabase
{
    NSString *json = MULTILINESTRING(
        {
            "images/foo.png" : {
                "filename" : "images/foo.png",
                "special" : "abc"
            }
        }
    );
    [self addDatabaseWithJSON:json forSearchPath:[self fullPathForFile:@"Resources"]];

    [self createPNGsInDir:@"Resources/images" name:@"foo" scales:@[@"default"]];

    _fileUtils.deviceContentScale = 4;


    CCFile *file = [_fileUtils fileNamed:@"images/foo.png" options:nil error:nil];

    XCTAssertEqualObjects(file.metaData[@"special"], @"abc");
}

- (void)testFileNamedLocalizationSearchOrderWithDatabase
{
    NSString *json = MULTILINESTRING(
        {
            "images/foo.png" : {
                "localizations" : {
                     "ja" : "images/should_be_returned.png"
                },
                "filename" : "images/fallback_should_not_be_used.png"
            }
        }
    );
    [self addDatabaseWithJSON:json forSearchPath:[self fullPathForFile:@"Resources"]];
    [self createEmptyFilesRelativeToDirectory:@"Resources/images" files:@[
        @"should_be_returned.png",
        @"images/fallback_should_not_be_used.png",
    ]];

    _fileUtils.preferredLanguages = @[@"en", @"es", @"ja"];

    NSLog(@"%@", [NSLocale preferredLanguages]);

    NSError *error;
    CCFile *file = [_fileUtils fileNamed:@"images/foo.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/images/should_be_returned.png" contentScale:4.0 error:error];
}


- (void)testFileNamedNoLocalizedImageAvailableWithDatabase
{
    NSString *json = MULTILINESTRING(
        {
            "images/foo.png" : {
                "localizations" : {
                    "en" : "images/shouldnotbereturned.png"
                },
                "filename" : "images/fallback.png"
            }
        }
    );
    [self addDatabaseWithJSON:json forSearchPath:[self fullPathForFile:@"Resources"]];
    [self createEmptyFilesRelativeToDirectory:@"Resources/images" files:@[
        @"shouldnotbereturned.png",
        @"fallback.png",
    ]];

    _fileUtils.preferredLanguages = @[@"de"];

    NSLog(@"%@", [NSLocale preferredLanguages]);

    NSError *error;
    CCFile *file = [_fileUtils fileNamed:@"images/foo.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/images/fallback.png" contentScale:4.0 error:error];
}

- (void)testFileNamedLocalizationWithDatabase
{
    NSString *json = MULTILINESTRING(
        {
            "images/foo.png" : {
                "localizations" : {
                    "en" : "images/foo-en.png"
                    "de" : "images/foo-de.png"
                },
                "filename" : "images/foo-en.png"
            }
        }
    );
    [self addDatabaseWithJSON:json forSearchPath:[self fullPathForFile:@"Resources"]];
    [self createEmptyFilesRelativeToDirectory:@"Resources/images" files:@[
        @"foo-en.png",
        @"foo-de.png"
    ]];

    _fileUtils.preferredLanguages = @[@"de", @"en"];

    NSError *error;
    CCFile *file = [_fileUtils fileNamed:@"images/foo.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/images/foo-de.png" contentScale:4.0 error:error];
}

- (void)testFileNamedAliasingWithDatabase
{
    NSString *json = MULTILINESTRING(
        {
            "images/foo.png" : {
                "filename" : "images/baa.png"
            }
        }
    );
    [self addDatabaseWithJSON:json forSearchPath:[self fullPathForFile:@"Resources"]];

    [self createPNGsInDir:@"Resources/images" name:@"baa" scales:@[@"default"]];

    _fileUtils.deviceContentScale = 4;
    _fileUtils.untaggedContentScale = 4;

    NSError *error;
    CCFile *file = [_fileUtils fileNamed:@"images/foo.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/images/baa.png" contentScale:4.0 error:error];
}


#pragma mark - Tests for search order no database

- (void)testFileNamedSearchOrderPrecedenceDefaultContentScale
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"4", @"2", @"1", @"default"]];

    _fileUtils.deviceContentScale = 4;
    _fileUtils.untaggedContentScale = 4;

    NSError *error;
    CCFile *file = [_fileUtils fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero.png" contentScale:4.0 error:error];
}

- (void)testFileNamedSearchOrder3XDeviceScaleNoDefaultImage
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"4", @"2", @"1"]];

    _fileUtils.deviceContentScale = 3;

    NSError *error;
    CCFile *file = [_fileUtils fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero-4x.png" contentScale:4.0 error:error];
}

- (void)testFileNamedSearchOrder2XDeviceScaleNoDefaultImage
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"4", @"2", @"1"]];

    _fileUtils.deviceContentScale = 2;

    NSError *error;
    CCFile *file = [_fileUtils fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero-2x.png" contentScale:2.0 error:error];
}

- (void)testFileNamedSearchOrder2XDeviceScaleNoDefaultAndPixelPerfectImage
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"4", @"1"]];

    _fileUtils.deviceContentScale = 2;

    NSError *error;
    CCFile *file = [_fileUtils fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero-4x.png" contentScale:4.0 error:error];
}

- (void)testFileNamedSearchOrder4XDeviceScaleOnlyLowResFallback
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"1"]];

    _fileUtils.deviceContentScale = 4;

    NSError *error;
    CCFile *file = [_fileUtils fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero-1x.png" contentScale:1.0 error:error];
}

- (void)testFileNamedSearchOrder4XDeviceScaleDefaultAndLowResImageAvailable
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"2", @"default"]];

    _fileUtils.deviceContentScale = 4;
    _fileUtils.untaggedContentScale = 4;

    NSError *error;
    CCFile *file = [_fileUtils fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero.png" contentScale:4.0 error:error];
}


#pragma mark - Tests for search paths

- (void)testSearchPathsOrderImageAvailableInBothPaths
{
    [self createPNGsInDir:@"Packages/baa" name:@"Hero" scales:@[@"4", @"2", @"1"]];
    [self createPNGsInDir:@"Packages/foo" name:@"Hero" scales:@[@"4", @"2", @"1"]];

    _fileUtils.searchPaths = @[[self fullPathForFile:@"Packages/foo"], [self fullPathForFile:@"Packages/baa"]];
    _fileUtils.deviceContentScale = 2;

    NSError *error;
    CCFile *file = [_fileUtils fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Packages/foo/Hero-2x.png" contentScale:2.0 error:error];
}

- (void)testSearchPathsOrderImageAvailableOnlyInLastPath
{
    [self createPNGsInDir:@"Packages/baa" name:@"Hero" scales:@[@"4", @"2", @"1"]];
    [self createPNGsInDir:@"Packages/foo" name:@"Spaceship" scales:@[@"4", @"2", @"1"]];

    _fileUtils.searchPaths = @[[self fullPathForFile:@"Packages/foo"], [self fullPathForFile:@"Packages/baa"]];
    _fileUtils.deviceContentScale = 2;

    NSError *error;
    CCFile *file = [_fileUtils fileNamed:@"Hero.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Packages/baa/Hero-2x.png" contentScale:2.0 error:error];
}


#pragma mark - Tests with errors

- (void)testFileNamedRecursiveSimpleWithDefaultContentScale
{
    [self createEmptyFiles:@[@"Resources/images/vehicles/spaceship.png"]];

    _fileUtils.untaggedContentScale = 4;

    NSError *error;
    CCFile *file = [_fileUtils fileNamed:@"images/vehicles/spaceship.png" options:nil error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/images/vehicles/spaceship.png" contentScale:4.0 error:error];
}

- (void)testEmptySearchPaths
{
    _fileUtils.searchPaths = @[];

    NSError *error;
    CCFile *file = [_fileUtils fileNamed:@"someasset.png" options:nil error:&error];

    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, ERROR_FILELOCATOR_NO_SEARCH_PATHS);
    XCTAssertNil(file);
}

- (void)testShouldNotReturnDirectoryURLWithAssetFilename
{
    [self createFolders:@[@"Resources/image.png"]];

    NSError *error;
    CCFile *file = [_fileUtils fileNamed:@"image.png" options:nil error:&error];

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

- (void)addDatabaseWithJSON:(NSString *)json forSearchPath:(NSString *)searchPath
{
    [self createFilesWithContents:@{[searchPath stringByAppendingPathComponent:@"filedb.json"] : [json dataUsingEncoding:NSUTF8StringEncoding]}];

    if (!_fileUtils.database)
    {
        _fileUtils.database = [[CCFileUtilsDatabase alloc] init];
    }

    [(CCFileUtilsDatabase *) _fileUtils.database addDatabaseWithFilePath:@"filedb.json" inSearchPath:searchPath];
}

@end
