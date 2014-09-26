//
//  CCPackageUnzipperTests.m
//  cocos2d-tests-ios
//
//  Created by Nicky Weber on 23.09.14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCPackageUnzipper.h"
#import "CCPackage.h"
#import "CCPackageInstallData.h"
#import "CCPackage+InstallData.h"
#import "CCPackageConstants.h"
#import "CCPackageUnzipperDelegate.h"
#import "CCUnitTestAssertions.h"

@interface CCPackageUnzipperTests : XCTestCase <CCPackageUnzipperDelegate>

@property (nonatomic, strong) CCPackage *package;
@property (nonatomic, strong) CCPackageInstallData *installData;
@property (nonatomic, copy) NSString *unzipFolderPath;
@property (nonatomic, strong) NSCondition *condition;
@property (nonatomic) BOOL unzipperReturned;
@property (nonatomic) BOOL unzippingSuccessful;
@property (nonatomic, strong) NSError *unzippingError;

@end


@implementation CCPackageUnzipperTests

- (void)setUp
{
    [super setUp];

    [self deleteGeneratedFiles];
    self.unzipperReturned = NO;
    self.unzippingError = nil;
    self.unzippingSuccessful = NO;

    self.unzipFolderPath = [NSTemporaryDirectory() stringByAppendingPathComponent:PACKAGE_REL_UNZIP_FOLDER];

    [self createUnzipFolder];

    self.package = [[CCPackage alloc] initWithName:@"Foo"
                                        resolution:@"phonehd"
                                                os:@"iOS"
                                         remoteURL:[NSURL URLWithString:@"http://foo.fake/Foo-iOS-phonehd.zip"]];

    self.installData = [[CCPackageInstallData alloc] initWithPackage:_package];
    [_package setInstallData:_installData];

    NSString *pathToZip = [[NSBundle mainBundle] pathForResource:@"Resources-shared/Packages/testpackage-iOS-phonehd" ofType:@"zip"];
    _installData.localDownloadURL = [NSURL fileURLWithPath:pathToZip];
    _installData.unzipURL = [NSURL fileURLWithPath:[_unzipFolderPath stringByAppendingPathComponent:[_package standardIdentifier]]];

    NSLog(@"%@", _installData.unzipURL.path);
}

- (void)createUnzipFolder
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager createDirectoryAtURL:[NSURL fileURLWithPath:_unzipFolderPath]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error])
    {
        NSLog(@"%@", error);
    }
}

- (void)tearDown
{
    [self deleteGeneratedFiles];

    [super tearDown];
}

- (void)deleteGeneratedFiles
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:_unzipFolderPath error:nil];
}

- (void)testUnzipping
{
    [self unzipUntilDelegateMethodsReturn:nil];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:[_installData.unzipURL URLByAppendingPathComponent:@"testpackage-iOS-phonehd"]
                                   includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                      options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                        error:nil];

    XCTAssertEqual(contents.count, 4);
    XCTAssertTrue(_unzippingSuccessful);
}

- (void)testUnzippingOfNonExistingArchive
{
    _installData.localDownloadURL = [NSURL fileURLWithPath:@"/foo.zip"];

    [self unzipUntilDelegateMethodsReturn:nil];

    XCTAssertFalse(_unzippingSuccessful);
}

// This test is not working as SSZipArchive will return succes although file operations fail
// This requires some modifications of SSZipArchive
- (void)testUnzippingOfInaccessibleUnzipFolder
{
    _installData.unzipURL = [NSURL fileURLWithPath:@"/temp/surelynotexistingfolder"];

    // [self unzipUntilDelegateMethodsReturn:];

    // XCTAssertFalse(_unzippingSuccessful);
}

- (void)testUnzipOfPasswordProtectedPackage
{
    NSString *pathToZip = [[NSBundle mainBundle] pathForResource:@"Resources-shared/Packages/password-iOS-phone" ofType:@"zip"];
    _installData.localDownloadURL = [NSURL fileURLWithPath:pathToZip];

    [self unzipUntilDelegateMethodsReturn:@"foobar"];

    NSString *secretFilePath = [_installData.unzipURL.path stringByAppendingPathComponent:@"password-iOS-phone/secret.txt"];
    NSError *error;
    NSString *contentsOfSecretFile = [NSString stringWithContentsOfFile:secretFilePath encoding:NSUTF8StringEncoding error:&error];
    XCTAssertNil(error);
    CCAssertEqualStrings(contentsOfSecretFile, @"unzipping successful");
}

- (void)unzipUntilDelegateMethodsReturn:(NSString *)password
{
    self.condition = [[NSCondition alloc] init];
    [_condition lock];

    CCPackageUnzipper *unzipper = [[CCPackageUnzipper alloc] initWithPackage:_package];
    unzipper.password = password;
    unzipper.delegate = self;
    [unzipper unpackPackage];

    while(!_unzipperReturned)
    {
        [_condition wait];
    }
    [_condition unlock];
}

- (void)unzipFinished:(CCPackageUnzipper *)packageUnzipper
{
    self.unzippingSuccessful = YES;
    self.unzipperReturned = YES;
    [_condition signal];
}

- (void)unzipFailed:(CCPackageUnzipper *)packageUnzipper error:(NSError *)error
{
    self.unzippingSuccessful = NO;
    self.unzippingError = error;

    self.unzipperReturned = YES;
    [_condition signal];
}

@end
