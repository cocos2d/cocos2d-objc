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
@property (nonatomic, copy) NSString *installRelPath;
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

    self.installRelPath = @"tests.Packages";

    self.installer = [[CCPackageInstaller alloc] initWithPackage:_package installRelPath:_installRelPath];
    
    
    [self deleteInstallData];

    [self createPackageInstallFolder];
}

- (void)createPackageInstallFolder
{
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *installPath = [cachesPath stringByAppendingPathComponent:_installRelPath];

    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager createDirectoryAtURL:[NSURL fileURLWithPath:installPath]
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
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *installPath = [cachesPath stringByAppendingPathComponent:_installRelPath];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    if (![fileManager removeItemAtPath:installPath error:&error])
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
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *installPath = [cachesPath stringByAppendingPathComponent:_installRelPath];

    [self setupInstallablePackage];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:[installPath stringByAppendingPathComponent:@"testpackage-iOS-phonehd"]
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
    _package.folderName = @"testpackage-iOS-phonehd";

    NSString *pathToPackage = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources-shared/Packages/testpackage-iOS-phonehd_unzipped"];
    NSString *unzipPath = [NSTemporaryDirectory() stringByAppendingPathComponent:_package.folderName];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:unzipPath error:nil];
    if (![fileManager copyItemAtPath:pathToPackage toPath:unzipPath error:&error])
    {
        NSLog(@"%@", error);
    }

    _package.unzipURL = [NSURL fileURLWithPath:unzipPath];

    _package.enableOnDownload = NO;
}

@end
