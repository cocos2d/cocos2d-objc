//
//  CCPackageTests.m
//  cocos2d-tests-ios
//
//  Created by Nicky Weber on 23.09.14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCPackage.h"
#import "CCPackage_private.h"
#import "CCUnitTestHelperMacros.h"

@interface CCPackageTests : XCTestCase

@end


@implementation CCPackageTests

- (void)testInitializer
{
    CCPackage *package = [[CCPackage alloc] initWithName:@"DLC"
                                              resolution:@"tablethd"
                                                      os:@"iOS"
                                               remoteURL:[NSURL URLWithString:@"http://foo.fake"]];

    XCTAssertEqualObjects(package.name, @"DLC");
    XCTAssertEqualObjects(package.resolution, @"tablethd");
    XCTAssertEqualObjects(package.os, @"iOS");
    XCTAssertEqualObjects(package.remoteURL, [NSURL URLWithString:@"http://foo.fake"]);
    XCTAssertEqual(package.status, CCPackageStatusInitial);
}


#pragma mark - Tests

- (void)testStandardIdentifier
{
    CCPackage *package = [[CCPackage alloc] initWithName:@"DLC"
                                              resolution:@"tablethd"
                                                      os:@"iOS"
                                               remoteURL:[NSURL URLWithString:@"http://foo.fake"]];

    XCTAssertEqualObjects([package standardIdentifier], @"DLC-iOS-tablethd");
}

- (void)testInitWithDictionary
{
    NSDictionary *dictionary = @{
        @"name" : @"DLC",
        @"resolution" : @"tablethd",
        @"os" : @"iOS",
        @"remoteURL" : @"http://foo.fake",
        @"installURL" : @"Packages",
        @"status" : @(CCPackageStatusInstalledDisabled),
        @"localDownloadURL" : @"/downloadfolder/baa.zip",
        @"localUnzipURL" : @"/unzupfolder/foo",
        @"folderName" : @"somename",
        @"enableOnDownload" : @(YES)
    };

    CCPackage *package = [[CCPackage alloc] initWithDictionary:dictionary];

    XCTAssertEqualObjects(package.name, @"DLC");
    XCTAssertEqualObjects(package.resolution, @"tablethd");
    XCTAssertEqualObjects(package.os, @"iOS");
    XCTAssertEqualObjects(package.remoteURL, [NSURL URLWithString:@"http://foo.fake"]);
    XCTAssertEqualObjects(package.installRelURL, [NSURL fileURLWithPath:@"Packages"]);
    XCTAssertEqual(package.status, CCPackageStatusInstalledDisabled);
    XCTAssertEqualObjects(package.localDownloadURL, [NSURL fileURLWithPath:@"/downloadfolder/baa.zip"]);
    XCTAssertEqualObjects(package.unzipURL, [NSURL fileURLWithPath:@"/unzupfolder/foo"]);
    XCTAssertEqualObjects(package.folderName, @"somename");
    XCTAssertTrue(package.enableOnDownload);
}

- (void)testInitWithDictionaryMinimumValuesSet
{
    NSDictionary *dictionary = @{
        @"name" : @"DLC",
        @"resolution" : @"tablethd",
        @"os" : @"iOS",
        @"remoteURL" : @"http://foo.fake",
        @"status" : @(CCPackageStatusInitial),
        @"enableOnDownload" : @(NO)
    };

    CCPackage *package = [[CCPackage alloc] initWithDictionary:dictionary];

    XCTAssertEqualObjects(package.name, @"DLC");
    XCTAssertEqualObjects(package.resolution, @"tablethd");
    XCTAssertEqualObjects(package.os, @"iOS");
    XCTAssertEqualObjects(package.remoteURL, [NSURL URLWithString:@"http://foo.fake"]);
    XCTAssertNil(package.installRelURL);
    XCTAssertEqual(package.status, CCPackageStatusInitial);
    XCTAssertNil(package.localDownloadURL);
    XCTAssertNil(package.unzipURL);
    XCTAssertNil(package.folderName);
    XCTAssertFalse(package.enableOnDownload);
}

- (void)testToDictionary
{
    CCPackage *package = [[CCPackage alloc] initWithName:@"DLC"
                                              resolution:@"tablethd"
                                                      os:@"iOS"
                                               remoteURL:[NSURL URLWithString:@"http://foo.fake"]];

    package.status = CCPackageStatusInstalledDisabled;
    package.installRelURL = [NSURL URLWithString:@"Packages"];
    package.unzipURL = [NSURL fileURLWithPath:@"/unzupfolder/foo"];
    package.folderName = @"somename";
    package.localDownloadURL = [NSURL fileURLWithPath:@"/downloadfolder/baa.zip"];
    package.enableOnDownload = NO;

    NSDictionary *dictionary = [package toDictionary];

    XCTAssertEqualObjects(dictionary[@"name"], @"DLC");
    XCTAssertEqualObjects(dictionary[@"resolution"], @"tablethd");
    XCTAssertEqualObjects(dictionary[@"os"], @"iOS");
    XCTAssertEqualObjects(dictionary[@"remoteURL"], @"http://foo.fake");
    XCTAssertEqualObjects(dictionary[@"installURL"], @"Packages");
    XCTAssertEqual([dictionary[@"status"] integerValue], CCPackageStatusInstalledDisabled);
    XCTAssertEqualObjects(dictionary[@"localDownloadURL"], @"/downloadfolder/baa.zip");
    XCTAssertEqualObjects(dictionary[@"localUnzipURL"], @"/unzupfolder/foo");
    XCTAssertEqualObjects(dictionary[@"folderName"], @"somename");
    XCTAssertFalse([dictionary[@"enableOnDownload"] boolValue]);
}

@end
