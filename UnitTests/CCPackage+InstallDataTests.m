//
//  CCPackage+InstallDataTests.m
//  cocos2d-tests-ios
//
//  Created by Nicky Weber on 23.09.14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCPackage.h"
#import "CCPackageInstallData.h"
#import "CCPackage+InstallData.h"

@interface CCPackage_InstallDataTests : XCTestCase

@property (nonatomic, strong) CCPackage *package;
@property (nonatomic, strong) CCPackageInstallData *installData;

@end


@implementation CCPackage_InstallDataTests

- (void)setUp
{
    [super setUp];

    self.package = [[CCPackage alloc] initWithName:@"Foo"
                                        resolution:@"phonehd"
                                                os:@"iOS"
                                         remoteURL:[NSURL URLWithString:@"http://foo.fake/Foo-iOS-phonehd.zip"]];

    self.installData = [[CCPackageInstallData alloc] initWithPackage:_package];
}

- (void)testSetAndGetInstallData
{
    [_package setInstallData:_installData];
    CCPackageInstallData *installDataGet = [_package installData];
    XCTAssertTrue(_installData == installDataGet, @"InstallData set is not the same as the retrieved one.");
}

- (void)testRemoveInstallData
{
    [_package setInstallData:_installData];
    [_package removeInstallData];
    CCPackageInstallData *installDataGet = [_package installData];
    XCTAssertNil(installDataGet, @"Retrieved installData should be nil.");
}

@end
