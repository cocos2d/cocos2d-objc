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


@interface CCPackageInstallerTests : XCTestCase

@property (nonatomic, strong) CCPackage *package;
@property (nonatomic, copy) NSString *installPath;
@property (nonatomic, strong) CCPackageInstaller *installer;

@end


@implementation CCPackageInstallerTests

- (void)setUp
{
    [super setUp];

    self.package = [[CCPackage alloc] initWithName:@"Test"
                                        resolution:@"phonehd"
                                                os:@"iOS"
                                         remoteURL:[NSURL URLWithString:@"http://test.foo"]];

    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    self.installPath = [cachesPath stringByAppendingPathComponent:@"tests.Packages"];

    self.installer = [[CCPackageInstaller alloc] initWithPackage:_package installPath:_installPath];
    
    
    [self deleteInstallData];

    [self createPackageInstallFolder];
}

- (void)createPackageInstallFolder
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager createDirectoryAtURL:[NSURL fileURLWithPath:_installPath]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error])
    {
        NSLog(@"%@", error);
    }
}

- (void)tearDown
{
    [self deleteInstallData];

    [super tearDown];
}

- (void)deleteInstallData
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    if (![fileManager removeItemAtPath:_installPath error:&error])
    {
        // NSLog(@"%@", error);
    }
}


#pragma mark - Tests

- (void)testInstallWithoutEnablingPackage
{
    [self setupInstallablePackage];

    NSError *error;
    BOOL success = [_installer installWithError:&error];
    XCTAssertTrue(success, @"Installation was unsuccessful: %@", error);
    XCTAssertEqual(_package.status, CCPackageStatusInstalledDisabled);
}

- (void)testInstallFailingUnzippedPackageDoesNotExist
{
    NSString *pathToPackage = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources-shared/Packages/DOES_NOT_EXIST"];
    _package.unzipURL = [NSURL fileURLWithPath:pathToPackage];

    NSError *error;
    BOOL success = [_installer installWithError:&error];
    XCTAssertFalse(success, @"Installation was successful: %@", error);
    XCTAssertEqual(_package.status, CCPackageStatusInstallationFailed);
    XCTAssertEqual(error.code, PACKAGE_ERROR_INSTALL_UNZIPPED_PACKAGE_NOT_FOUND);
}

- (void)testInstallFailingPackageAlreadyExists
{
    [self setupInstallablePackage];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:[_installPath stringByAppendingPathComponent:@"testpackage-iOS-phonehd"]
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];

    NSError *error;
    BOOL success = [_installer installWithError:&error];
    XCTAssertFalse(success, @"Installation was successful: %@", error);
    XCTAssertEqual(_package.status, CCPackageStatusInstallationFailed);
    XCTAssertEqual(error.code, PACKAGE_ERROR_INSTALL_COULD_NOT_MOVE_PACKAGE_TO_INSTALL_FOLDER);
}


#pragma mark - Helper

- (void)setupInstallablePackage
{
    NSString *pathToPackage = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources-shared/Packages/testpackage-iOS-phonehd_unzipped"];

    _package.unzipURL = [NSURL fileURLWithPath:pathToPackage];
    _package.folderName = @"testpackage-iOS-phonehd";
    _package.enableOnDownload = NO;
}

@end
