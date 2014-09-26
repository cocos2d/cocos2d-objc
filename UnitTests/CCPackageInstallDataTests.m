//
//  CCPackageInstallDataTests.m
//  cocos2d-tests-ios
//
//  Created by Nicky Weber on 24.09.14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "CCPackageInstallData.h"
#import "CCPackage.h"
#import "CCUnitTestAssertions.h"

@interface CCPackageInstallDataTests : XCTestCase

@property (nonatomic, strong) CCPackageInstallData *installData;

@end


@implementation CCPackageInstallDataTests

- (void)setUp
{
    [super setUp];

    CCPackage *package = [[CCPackage alloc] initWithName:@"Foo"
                                              resolution:@"phonehd"
                                                      os:@"iOS"
                                               remoteURL:[NSURL URLWithString:@"http://foo.fake/Foo-iOS-phonehd.zip"]];

    self.installData = [[CCPackageInstallData alloc] initWithPackage:package];
    _installData.unzipURL = [NSURL fileURLWithPath:@"/unzupfolder/foo"];
    _installData.folderName = @"somename";
    _installData.localDownloadURL = [NSURL fileURLWithPath:@"/downloadfolder/baa.zip"];
    _installData.enableOnDownload = NO;

}


#pragma mark - Tests

- (void)testPopulateInstallDataWithDictionary
{
    // Constants for dict keys are only used internally, not making them public
    NSDictionary *installDataDict = @{
        @"localDownloadURL" : @"file:///downloadfolder/baa.zip",
        @"localUnzipURL" : @"file:///unzupfolder/foo",
        @"folderName" : @"somename",
        @"enableOnDownload" : @(YES)
    };

    [_installData populateInstallDataWithDictionary:installDataDict];

    XCTAssertEqualObjects(_installData.localDownloadURL, [NSURL fileURLWithPath:@"/downloadfolder/baa.zip"]);
    XCTAssertEqualObjects(_installData.unzipURL, [NSURL fileURLWithPath:@"/unzupfolder/foo"]);
    CCAssertEqualStrings(_installData.folderName, @"somename");
    XCTAssertTrue(_installData.enableOnDownload);
}

- (void)testWriteInstallDataToDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    [_installData writeInstallDataToDictionary:dictionary];

    NSURL *dictDownloadURL = [NSURL URLWithString:dictionary[@"localDownloadURL"]];
    XCTAssertEqualObjects(dictDownloadURL, [NSURL fileURLWithPath:@"/downloadfolder/baa.zip"]);

    NSURL *dictUnzipURL = [NSURL URLWithString:dictionary[@"localUnzipURL"]];
    XCTAssertEqualObjects(dictUnzipURL, [NSURL fileURLWithPath:@"/unzupfolder/foo"]);

    NSString *dictFolderName = dictionary[@"folderName"];
    CCAssertEqualStrings(dictFolderName, @"somename");

    XCTAssertFalse([dictionary[@"enableOnDownload"] boolValue]);
}

@end
