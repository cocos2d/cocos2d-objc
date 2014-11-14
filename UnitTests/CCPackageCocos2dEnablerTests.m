//
//  CCPackageCocos2dEnablerTests.m
//  cocos2d-tests-ios
//
//  Created by Nicky Weber on 23.09.14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCPackageCocos2dEnabler.h"
#import "CCPackage.h"
#import "CCFileUtils.h"
#import "CCSprite.h"
#import "CCBReader.h"
#import "AppDelegate.h"
#import "CCPackage_private.h"
#import "CCPackageHelper.h"
#import "CCPackagesTestFixturesAndHelpers.h"

@interface CCPackageCocos2dEnablerTests : XCTestCase

@end


@implementation CCPackageCocos2dEnablerTests

- (void)setUp
{
    [super setUp];
    [(AppController *)[UIApplication sharedApplication].delegate configureCocos2d];
}


#pragma mark - Tests

- (void)testEnablePackage
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageWithStatus:CCPackageStatusInstalledDisabled installRelPath:@"Packages"];

    CCPackageCocos2dEnabler *packageEnabler = [[CCPackageCocos2dEnabler alloc] init];
    [packageEnabler enablePackages:@[package]];

    XCTAssertTrue([CCPackagesTestFixturesAndHelpers isPackageInSearchPath:package]);
    XCTAssertEqual(package.status, CCPackageStatusInstalledEnabled);

    CCSprite *sprite = [CCSprite spriteWithImageNamed:@"boredSmiley.png"];
    XCTAssertNotNil(sprite);
}

- (void)testDisablePackage
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageWithStatus:CCPackageStatusInstalledDisabled installRelPath:@"Packages"];

    [self testEnablePackage];

    CCPackageCocos2dEnabler *packageEnabler = [[CCPackageCocos2dEnabler alloc] init];
    [packageEnabler disablePackages:@[package]];

    XCTAssertEqual(package.status, CCPackageStatusInstalledDisabled);

    XCTAssertFalse([CCPackagesTestFixturesAndHelpers isPackageInSearchPath:package]);

    // Can't use [CCSprite spriteWithImageNamed:@"boredSmiley.png"], assertion exception is screwing up test result
    NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:@"boredSmiley.png" contentScale:NULL];
    XCTAssertNil(path);
}

@end
