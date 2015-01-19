//
//  CCFileUtilsDatabaseTests.m
//  cocos2d-tests
//
//  Created by Nicky Weber on 13.01.15.
//  Copyright (c) 2015 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCFileUtilsDatabase.h"
#import "FileSystemTestCase.h"
#import "CCUnitTestHelperMacros.h"

@interface CCFileUtilsDatabaseTests : FileSystemTestCase

@property (nonatomic, strong) CCFileUtilsDatabase *fileUtilsDB;
@property (nonatomic, copy) NSString *searchPath;
@property (nonatomic, copy) NSString *dbPath;

@end

@implementation CCFileUtilsDatabaseTests

- (void)setUp
{
    [super setUp];

    NSString *json = MULTILINESTRING(
        {
            "images/foo.png" : {}
        }
    );

    self.searchPath = [self fullPathForFile:@"Resources"];
    self.dbPath = @"config/filedb.json";

    [self createFilesWithContents:@{@"Resources/config/filedb.json" : [json dataUsingEncoding:NSUTF8StringEncoding]}];

    self.fileUtilsDB = [[CCFileUtilsDatabase alloc] init];
}

- (void)testAddDatabaseWithFilePathInSearchPath
{
    XCTAssertTrue([_fileUtilsDB addJSONWithFilePath:_dbPath forSearchPath:_searchPath error:NULL]);

    NSDictionary *metaData = [_fileUtilsDB metaDataForFileNamed:@"images/foo.png" inSearchPath:_searchPath];

    XCTAssertNotNil(metaData);
};

- (void)testRemoveDatabaseWithFilePathInSearchPath
{
    XCTAssertTrue([_fileUtilsDB addJSONWithFilePath:_dbPath forSearchPath:_searchPath error:NULL]);

    [_fileUtilsDB removeEntriesForSearchPath:[self fullPathForFile:@"Resources"]];

    NSDictionary *metaData = [_fileUtilsDB metaDataForFileNamed:@"images/foo.png" inSearchPath:[self fullPathForFile:@"Resources"]];

    XCTAssertNil(metaData);
}

- (void)testAddDataBaseWithCorruptJSON
{
    NSString *json = MULTILINESTRING(
        {
            []  asdasdasd {}
        };
    );

    [self createFilesWithContents:@{@"Resources/config/filedb.json" : [json dataUsingEncoding:NSUTF8StringEncoding]}];

    NSError *error;
    XCTAssertFalse([_fileUtilsDB addJSONWithFilePath:_dbPath forSearchPath:_searchPath error:&error]);
    XCTAssertNotNil(error);
}

- (void)testAddDataBaseWithNonExistingDatabaseFile
{
    NSError *error;
    XCTAssertFalse([_fileUtilsDB addJSONWithFilePath:@"/adasdasd/ddddd.json" forSearchPath:_searchPath error:&error]);
    XCTAssertNotNil(error);
}

@end
