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
#import "CCUnitTestAssertions.h"

@interface CCPackageTests : XCTestCase

@end


@implementation CCPackageTests

- (void)testInitializer
{
    CCPackage *package = [[CCPackage alloc] initWithName:@"DLC"
                                              resolution:@"tablethd"
                                                      os:@"iOS"
                                               remoteURL:[NSURL URLWithString:@"http://foo.fake"]];

    CCAssertEqualStrings(package.name, @"DLC");
    CCAssertEqualStrings(package.resolution, @"tablethd");
    CCAssertEqualStrings(package.os, @"iOS");
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

    CCAssertEqualStrings([package standardIdentifier], @"DLC-iOS-tablethd");
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

    CCAssertEqualStrings(package.name, @"DLC");
    CCAssertEqualStrings(package.resolution, @"tablethd");
    CCAssertEqualStrings(package.os, @"iOS");
    XCTAssertEqualObjects(package.remoteURL, [NSURL URLWithString:@"http://foo.fake"]);
    XCTAssertEqualObjects(package.installRelURL, [NSURL fileURLWithPath:@"Packages"]);
    XCTAssertEqual(package.status, CCPackageStatusInstalledDisabled);
    XCTAssertEqualObjects(package.localDownloadURL, [NSURL fileURLWithPath:@"/downloadfolder/baa.zip"]);
    XCTAssertEqualObjects(package.unzipURL, [NSURL fileURLWithPath:@"/unzupfolder/foo"]);
    CCAssertEqualStrings(package.folderName, @"somename");
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

    CCAssertEqualStrings(package.name, @"DLC");
    CCAssertEqualStrings(package.resolution, @"tablethd");
    CCAssertEqualStrings(package.os, @"iOS");
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

    CCAssertEqualStrings(dictionary[@"name"], @"DLC");
    CCAssertEqualStrings(dictionary[@"resolution"], @"tablethd");
    CCAssertEqualStrings(dictionary[@"os"], @"iOS");
    CCAssertEqualStrings(dictionary[@"remoteURL"], @"http://foo.fake");
    CCAssertEqualStrings(dictionary[@"installURL"], @"Packages");
    XCTAssertEqual([dictionary[@"status"] integerValue], CCPackageStatusInstalledDisabled);
    CCAssertEqualStrings(dictionary[@"localDownloadURL"], @"/downloadfolder/baa.zip");
    CCAssertEqualStrings(dictionary[@"localUnzipURL"], @"/unzupfolder/foo");
    CCAssertEqualStrings(dictionary[@"folderName"], @"somename");
    XCTAssertFalse([dictionary[@"enableOnDownload"] boolValue]);
}

@end
