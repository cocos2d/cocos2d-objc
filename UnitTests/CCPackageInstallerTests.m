//
//  CCPackageInstallerTests.m
//  cocos2d-tests-ios
//
//  Created by Nicky Weber on 23.09.14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCPackage.h"
#import "CCPackageInstaller.h"
#import "CCPackageConstants.h"
#import "CCPackage_private.h"
#import "CCPackagesTestFixturesAndHelpers.h"
#import "CCPackageHelper.h"


@interface CCPackageInstallerTests : XCTestCase

@property (nonatomic, strong) CCPackage *package;
@property (nonatomic, copy) NSString *installRelPath;
@property (nonatomic, strong) CCPackageInstaller *installer;

@end


@implementation CCPackageInstallerTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [CCPackagesTestFixturesAndHelpers cleanCachesFolder];

    [CCPackagesTestFixturesAndHelpers cleanTempFolder];

    [super tearDown];
}


#pragma mark - Tests

- (void)testInstallWithoutEnablingPackage
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageWithStatus:CCPackageStatusUnzipped installRelPath:@"tests.Packages"];

    NSError *error;
    CCPackageInstaller *installer = [[CCPackageInstaller alloc] initWithPackage:package installRelPath:@"tests.Packages"];
    BOOL success = [installer installWithError:&error];

    XCTAssertTrue(success, @"Installation failed: %@", error);
    XCTAssertEqual(package.status, CCPackageStatusInstalledDisabled);
}

- (void)testInstallFailingUnzippedPackageDoesNotExist
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageWithStatus:CCPackageStatusUnzipped installRelPath:@"tests.Packages"];

    NSString *pathToPackage = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources-shared/Packages/DOES_NOT_EXIST"];
    package.unzipURL = [NSURL fileURLWithPath:pathToPackage];

    NSError *error;
    CCPackageInstaller *installer = [[CCPackageInstaller alloc] initWithPackage:package installRelPath:@"tests.Packages"];
    BOOL success = [installer installWithError:&error];
    XCTAssertFalse(success, @"Installation was successful: %@", error);
    XCTAssertEqual(package.status, CCPackageStatusInstallationFailed);
    XCTAssertEqual(error.code, PACKAGE_ERROR_INSTALL_UNZIPPED_PACKAGE_NOT_FOUND);
}

- (void)testInstallSuccessfulPackageAlreadyExists
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageWithStatus:CCPackageStatusUnzipped installRelPath:@"tests.Packages"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:[[CCPackageHelper cachesFolder] stringByAppendingPathComponent:@"tests.Packages/testpackage-iOS-phonehd"]
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];

    NSError *error;
    CCPackageInstaller *installer = [[CCPackageInstaller alloc] initWithPackage:package installRelPath:@"tests.Packages"];
    BOOL success = [installer installWithError:&error];

    XCTAssertTrue(success, @"Installation was failed: %@", error);
    XCTAssertEqual(package.status, CCPackageStatusInstalledDisabled);
}

@end
