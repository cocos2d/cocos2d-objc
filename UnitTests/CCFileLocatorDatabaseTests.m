//
//  CCFileLocatorDatabaseTests.m
//  cocos2d-tests
//
//  Created by Nicky Weber on 13.01.15.
//  Copyright (c) 2015 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FileSystemTestCase.h"
#import "CCUnitTestHelperMacros.h"
#import "CCFileLocator.h"

@interface CCFileLocatorDatabaseTests : FileSystemTestCase

@property (nonatomic, copy) NSString *searchPath;
@property (nonatomic, copy) NSString *dbPath;

@end

@implementation CCFileLocatorDatabaseTests

- (void)setUp
{
    [super setUp];

    id metadata = @{
        @"version": @(1),
        @"data": @{
            @"images/foo.png": @{
                @"UIScale": @(YES),
                @"filename": @"images/foo.jpg",
                @"localizations": @{
                    @"en": @"images/foo-en.jpg"
                }
            }
        }
    };

    self.searchPath = [self fullPathForFile:@"Resources"];
    self.dbPath = @"metadata.plist";

    [self createFilesWithContents:@{@"Resources/metadata.plist": [NSPropertyListSerialization dataFromPropertyList:metadata format:NSPropertyListXMLFormat_v1_0 errorDescription:nil]}];
}

- (void)testAddDatabaseWithFilePathInSearchPath
{
    CCFileLocator *locator = [[CCFileLocator alloc] init];
    locator.searchPaths = @[_searchPath];
    
    CCFileMetaData *metaData = [locator metaDataForFileNamed:@"images/foo.png" inSearchPath:_searchPath];

    XCTAssertNotNil(metaData);
    XCTAssertEqualObjects(metaData.filename, @"images/foo.jpg");
    XCTAssertEqualObjects(metaData.localizations, @{@"en" : @"images/foo-en.jpg"});
};

- (void)testRemoveDatabaseWithFilePathInSearchPath
{
    CCFileLocator *locator = [[CCFileLocator alloc] init];
    locator.searchPaths = @[[self fullPathForFile:@"Resources"]];
    locator.searchPaths = @[];
    
    CCFileMetaData *metaData = [locator metaDataForFileNamed:@"images/foo.png" inSearchPath:[self fullPathForFile:@"Resources"]];

    XCTAssertNil(metaData);
}

@end
