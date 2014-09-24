//
//  CCPackageTests.m
//  cocos2d-tests-ios
//
//  Created by Nicky Weber on 23.09.14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCPackage.h"
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
        @"installURL" : @"/Library/Caches/Packages",
        @"status" : @(CCPackageStatusInstalledDisabled),
    };

    CCPackage *package = [[CCPackage alloc] initWithDictionary:dictionary];

    CCAssertEqualStrings(package.name, @"DLC");
    CCAssertEqualStrings(package.resolution, @"tablethd");
    CCAssertEqualStrings(package.os, @"iOS");
    XCTAssertEqualObjects(package.remoteURL, [NSURL URLWithString:@"http://foo.fake"]);
    XCTAssertEqualObjects(package.installURL, [NSURL fileURLWithPath:@"/Library/Caches/Packages"]);
    XCTAssertEqual(package.status, CCPackageStatusInstalledDisabled);
}

- (void)testToDictionary
{
    CCPackage *package = [[CCPackage alloc] initWithName:@"DLC"
                                              resolution:@"tablethd"
                                                      os:@"iOS"
                                               remoteURL:[NSURL URLWithString:@"http://foo.fake"]];

    [package setValue:@(CCPackageStatusInstalledDisabled) forKey:@"status"];
    [package setValue:[NSURL fileURLWithPath:@"/Library/Caches/Packages"] forKey:@"installURL"];

    NSDictionary *dictionary = [package toDictionary];

    CCAssertEqualStrings(dictionary[@"name"], @"DLC");
    CCAssertEqualStrings(dictionary[@"resolution"], @"tablethd");
    CCAssertEqualStrings(dictionary[@"os"], @"iOS");
    CCAssertEqualStrings(dictionary[@"remoteURL"], @"http://foo.fake");
    CCAssertEqualStrings(dictionary[@"installURL"], @"/Library/Caches/Packages");
    XCTAssertEqual([dictionary[@"status"] integerValue], CCPackageStatusInstalledDisabled);
}

@end
