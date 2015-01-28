//
//  CCFileLocatorDatabaseTests.m
//  cocos2d-tests
//
//  Created by Nicky Weber on 13.01.15.
//  Copyright (c) 2015 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCFileLocatorDatabase.h"
#import "FileSystemTestCase.h"
#import "CCUnitTestHelperMacros.h"
#import "CCFileMetaData.h"

@interface CCFileLocatorDatabaseTests : FileSystemTestCase

@property (nonatomic, strong) CCFileLocatorDatabase *fileLocatorDB;
@property (nonatomic, copy) NSString *searchPath;
@property (nonatomic, copy) NSString *dbPath;

@end

@implementation CCFileLocatorDatabaseTests

- (void)setUp
{
    [super setUp];

    NSString *json = MULTILINESTRING(
        {
            "version" : 1,
            "data" : {
                "images/foo.png" : {
                    "UIScale" : true,
                    "filename" : "images/foo.jpg",
                    "localizations" : {
                        "en" : "images/foo-en.jpg"
                    }
                }
            }
        }
    );

    self.searchPath = [self fullPathForFile:@"Resources"];
    self.dbPath = @"config/filedb.json";

    [self createFilesWithContents:@{@"Resources/config/filedb.json" : [json dataUsingEncoding:NSUTF8StringEncoding]}];

    self.fileLocatorDB = [[CCFileLocatorDatabase alloc] init];
}

- (void)testAddDatabaseWithFilePathInSearchPath
{
    NSError *error;
    XCTAssertTrue([_fileLocatorDB addJSONWithFilePath:_dbPath forSearchPath:_searchPath error:&error]);

    CCFileMetaData *metaData = [_fileLocatorDB metaDataForFileNamed:@"images/foo.png" inSearchPath:_searchPath];

    XCTAssertNotNil(metaData);
    XCTAssertNil(error);
    XCTAssertEqualObjects(metaData.filename, @"images/foo.jpg");
    XCTAssertEqualObjects(metaData.localizations, @{@"en" : @"images/foo-en.jpg"});
};

- (void)testRemoveDatabaseWithFilePathInSearchPath
{
    XCTAssertTrue([_fileLocatorDB addJSONWithFilePath:_dbPath forSearchPath:_searchPath error:NULL]);

    [_fileLocatorDB removeEntriesForSearchPath:[self fullPathForFile:@"Resources"]];

    CCFileMetaData *metaData = [_fileLocatorDB metaDataForFileNamed:@"images/foo.png" inSearchPath:[self fullPathForFile:@"Resources"]];

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
    XCTAssertFalse([_fileLocatorDB addJSONWithFilePath:_dbPath forSearchPath:_searchPath error:&error]);
    XCTAssertNotNil(error);
}

- (void)testAddDataBaseWithNonExistingDatabaseFile
{
    NSError *error;
    XCTAssertFalse([_fileLocatorDB addJSONWithFilePath:@"/adasdasd/ddddd.json" forSearchPath:_searchPath error:&error]);
    XCTAssertNotNil(error);
}

@end
