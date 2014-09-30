//
//  CCPackageManagerTests.m
//  cocos2d-tests-ios
//
//  Created by Nicky Weber on 23.09.14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCPackageManager.h"
#import "CCPackage.h"
#import "CCFileUtils.h"
#import "CCPackage_private.h"
#import "CCPackageConstants.h"
#import "CCPackageManagerDelegate.h"

static NSString *const PACKAGE_BASE_URL = @"http://manager.test";

@interface CCPackageManagerTestURLProtocol : NSURLProtocol @end

@implementation CCPackageManagerTestURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest*)theRequest
{
    return [theRequest.URL.scheme caseInsensitiveCompare:@"http"] == NSOrderedSame;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)theRequest
{
    return theRequest;
}

- (void)startLoading
{
    NSData *data;
    NSHTTPURLResponse *response;
    if ([self.request.URL.absoluteString rangeOfString:PACKAGE_BASE_URL].location != NSNotFound)
    {
        NSString *pathToPackage = [[NSBundle mainBundle] pathForResource:@"Resources-shared/Packages/testpackage-iOS-phonehd.zip" ofType:nil];
        data = [NSData dataWithContentsOfFile:pathToPackage];

        response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                              statusCode:200
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:nil];
    }
    else
    {
        response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                              statusCode:404
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:nil];
    }

    id<NSURLProtocolClient> client = [self client];
    [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [client URLProtocol:self didLoadData:data];
    [client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
    // Nothing to do
}

@end


@interface CCPackageManagerTests : XCTestCase <CCPackageManagerDelegate>

@property (nonatomic, strong) CCPackageManager *packageManager;
@property (nonatomic) BOOL managerReturnedSuccessfully;
@property (nonatomic) BOOL managerReturnedFailed;
@property (nonatomic, copy) NSString *customFolderName;
@property (nonatomic, strong) NSError *managerReturnedWithError;

@end


@implementation CCPackageManagerTests

- (void)setUp
{
    [super setUp];
    self.packageManager = [[CCPackageManager alloc] init];
    self.managerReturnedSuccessfully = NO;
    self.managerReturnedFailed = NO;

    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:PACKAGE_STORAGE_USERDEFAULTS_KEY];

    [NSURLProtocol registerClass:[CCPackageManagerTestURLProtocol class]];
}

- (void)tearDown
{
    [NSURLProtocol unregisterClass:[CCPackageManagerTestURLProtocol class]];

    // Delete all relevant folders: Download, unzip, install
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:PACKAGE_REL_UNZIP_FOLDER] error:nil];
    [fileManager removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:PACKAGE_REL_DOWNLOAD_FOLDER] error:nil];
    [fileManager removeItemAtPath:_packageManager.installedPackagesPath error:nil];

    [super tearDown];
}


#pragma mark - Tests

- (void)testPackageWithName
{
    [CCFileUtils sharedFileUtils].searchResolutionsOrder = [@[CCFileUtilsSuffixiPadHD] mutableCopy];

    CCPackage *aPackage = [[CCPackage alloc] initWithName:@"foo"
                                               resolution:@"tablethd" // See note above
                                                       os:@"iOS"
                                                remoteURL:[NSURL URLWithString:@"http://foo.fake"]];

    [_packageManager addPackage:aPackage];

    CCPackage *result = [_packageManager packageWithName:@"foo"];

    XCTAssertEqual(aPackage, result);
}

- (void)testSavePackages
{
    CCPackage *package1 = [[CCPackage alloc] initWithName:@"DLC1"
                                               resolution:@"phonehd"
                                                       os:@"iOS"
                                                remoteURL:[NSURL URLWithString:@"http://foo.fake"]];
    package1.installURL = [NSURL fileURLWithPath:@"/packages/DLC1-iOS-phonehd"];
    package1.status = CCPackageStatusInitial;


    CCPackage *package2 = [[CCPackage alloc] initWithName:@"DLC2"
                                               resolution:@"tablethd"
                                                       os:@"iOS"
                                                remoteURL:[NSURL URLWithString:@"http://baa.fake"]];
    package2.installURL = [NSURL fileURLWithPath:@"/packages/DLC2-iOS-tablethd"];
    package2.status = CCPackageStatusInitial;

    [_packageManager addPackage:package1];
    [_packageManager addPackage:package2];

    [_packageManager savePackages];

    NSArray *packages = [[NSUserDefaults standardUserDefaults] objectForKey:PACKAGE_STORAGE_USERDEFAULTS_KEY];

    XCTAssertEqual(packages.count, 2);
    // Note: Persistency of CCPackage is tested in CCPackageTests
}

- (void)testLoadPackages
{
    XCTFail(@"Not implemented yet.");
}

- (void)testDownloadWithNameAndBaseURL
{
    [CCFileUtils sharedFileUtils].searchResolutionsOrder = [@[CCFileUtilsSuffixiPhoneHD] mutableCopy];

    _packageManager.baseURL = [NSURL URLWithString:PACKAGE_BASE_URL];
    _packageManager.delegate = self;
    CCPackage *package = [_packageManager downloadPackageWithName:@"testpackage" enableAfterDownload:YES];

    [self waitForDelegateToReturn];

    XCTAssertNotNil(package);
    XCTAssertTrue(_managerReturnedSuccessfully);
}

- (void)testDownloadWithCustomFolderNameInPackage
{
    // The installer used by the package manager will look into the unzipped contents and expect a folder
    // named after the standard identifier: Foo-iOS-phonehd.
    // Since the testpackage-iOS-phonehd is downloaded the delegate is used to correct this.

    [CCFileUtils sharedFileUtils].searchResolutionsOrder = [@[CCFileUtilsSuffixiPhoneHD] mutableCopy];

    _packageManager.baseURL = [NSURL URLWithString:PACKAGE_BASE_URL];
    _packageManager.delegate = self;

    self.customFolderName = @"testpackage-iOS-phonehd";

    CCPackage *package = [_packageManager downloadPackageWithName:@"Foo" enableAfterDownload:YES];

    [self waitForDelegateToReturn];

    XCTAssertNotNil(package);
    XCTAssertTrue(_managerReturnedSuccessfully);
}

- (void)testCannotDetermineFolderNameWhenUnzipping
{
    // Like in testDownloadWithCustomFolderNameInPackage but this time we expect an error and a failing delegate method

    _packageManager.baseURL = [NSURL URLWithString:PACKAGE_BASE_URL];
    _packageManager.delegate = self;

    CCPackage *package = [_packageManager downloadPackageWithName:@"Foo" enableAfterDownload:YES];

    [self waitForDelegateToReturn];

    XCTAssertNotNil(package);
    XCTAssertTrue(_managerReturnedFailed);
    XCTAssertEqual(_managerReturnedWithError.code, PACKAGE_ERROR_INSTALL_PACKAGE_FOLDER_NAME_NOT_FOUND);
}

- (void)testDownloadWithoutBaseURLShouldFail
{
    _packageManager.delegate = self;
    CCPackage *package = [_packageManager downloadPackageWithName:@"testpackage" enableAfterDownload:YES];

    [self waitForDelegateToReturn];

    XCTAssertNil(package);
    XCTAssertTrue(_managerReturnedFailed);
    XCTAssertEqual(_managerReturnedWithError.code, PACKAGE_ERROR_MANAGER_NO_BASE_URL_SET);
}

- (void)testDownloadWithNameAndWithoutBaseURLUnzipOnACustomQueue
{
    // Use a custom queue for unzipping
    XCTFail(@"Not implemented yet.");
}

- (void)testDownloadOfPackageWithDifferentInstallPath
{
    // add CCPackage and download:package
    // use different installPath

    XCTFail(@"Not implemented yet.");
}

- (void)testDisablePackage
{
    XCTFail(@"Not implemented yet.");
}

- (void)testEnablePackage
{
    XCTFail(@"Not implemented yet.");
}

- (void)testDeletePackage
{
    XCTFail(@"Not implemented yet.");
}

- (void)testCancelDownload
{
    XCTFail(@"Not implemented yet.");
}

- (void)testAllOtherDownloadRelatedMethods
{
/* - (void)resumeAllDownloads;
 * - (void)pauseAllDownloads;
 * - (void)pauseDownloadOfPackage:(CCPackage *)package;
 * - (void)resumeDownloadOfPackage:(CCPackage *)package;
 *
 * These should be already tests in the CCPackageDownloadManagerTests class as CCPackageManager is just delegating the class to that class.
 */
}


#pragma mark - CCPackageManagerDelegate

- (void)packageInstallationFinished:(CCPackage *)package
{
    self.managerReturnedSuccessfully = YES;
}

- (void)packageInstallationFailed:(CCPackage *)package error:(NSError *)error
{
    self.managerReturnedFailed = YES;
    self.managerReturnedWithError = error;
}

- (void)packageDownloadFinished:(CCPackage *)package
{
    // Nothing to do at the moment
}

- (void)packageDownloadFailed:(CCPackage *)package error:(NSError *)error
{
    self.managerReturnedFailed = YES;
    self.managerReturnedWithError = error;
}

- (void)packageUnzippingFinished:(CCPackage *)package
{
    // Nothing to do at the moment
}

- (void)packageUnzippingFailed:(CCPackage *)package error:(NSError *)error
{
    self.managerReturnedFailed = YES;
    self.managerReturnedWithError = error;
}

- (NSString *)customFolderName:(CCPackage *)package packageContents:(NSArray *)packageContents
{
    return _customFolderName;
}



#pragma mark - helper

- (void)waitForDelegateToReturn
{
    while (!_managerReturnedFailed
           && !_managerReturnedSuccessfully)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

@end
