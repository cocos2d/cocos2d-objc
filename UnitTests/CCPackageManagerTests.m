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
#import "CCUnitTestAssertions.h"
#import "CCDirector.h"
#import "AppDelegate.h"
#import "CCPackageCocos2dEnabler.h"
#import "CCPackageManager_private.h"
#import "CCPackagesTestFixturesAndHelpers.h"
#import "CCPackageDownloadManager.h"
#import "CCPackageHelper.h"


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


@interface CCPackageManagerTests : IGNORE_TEST_CASE <CCPackageManagerDelegate>

@property (nonatomic, strong) CCPackageManager *packageManager;
@property (nonatomic) BOOL managerReturnedSuccessfully;
@property (nonatomic) BOOL managerReturnedFailed;
@property (nonatomic, copy) NSString *customFolderName;
@property (nonatomic, strong) NSError *managerReturnedWithError;
@property (nonatomic, strong) NSMutableSet *cleanPathsArrayOnTearDown;

@end


@implementation CCPackageManagerTests

- (void)setUp
{
    [super setUp];

    [(AppController *)[UIApplication sharedApplication].delegate configureCocos2d];
    [[CCDirector sharedDirector] stopAnimation];

    self.packageManager = [[CCPackageManager alloc] init];
    _packageManager.delegate = self;

    self.managerReturnedSuccessfully = NO;
    self.managerReturnedFailed = NO;
    self.managerReturnedWithError = nil;
    self.customFolderName = nil;

    // A set of paths to be removed on tear down
    self.cleanPathsArrayOnTearDown = [NSMutableSet set];
    [_cleanPathsArrayOnTearDown addObject:[NSTemporaryDirectory() stringByAppendingPathComponent:PACKAGE_REL_UNZIP_FOLDER]];
    [_cleanPathsArrayOnTearDown addObject:[NSTemporaryDirectory() stringByAppendingPathComponent:PACKAGE_REL_DOWNLOAD_FOLDER]];
    [_cleanPathsArrayOnTearDown addObject:_packageManager.installRelPath];

    // Important for the standard identifier of packages which most often determined internally instead
    // of provided by the user. In this case resolution will default to phonehd.
    [CCFileUtils sharedFileUtils].searchResolutionsOrder = [@[CCFileUtilsSuffixiPhoneHD] mutableCopy];

    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:PACKAGE_STORAGE_USERDEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [NSURLProtocol registerClass:[CCPackageManagerTestURLProtocol class]];
}

- (void)tearDown
{
    [NSURLProtocol unregisterClass:[CCPackageManagerTestURLProtocol class]];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    for (NSString *path in _cleanPathsArrayOnTearDown)
    {
        if (![fileManager removeItemAtPath:path error:&error] && error.code != 4)
        {
            NSLog(@"ERROR: tearDown remove item %@ - %@", path, error);
        }
    }

    [CCPackagesTestFixturesAndHelpers cleanCachesFolder];

/*
    NSArray *array = [fileManager contentsOfDirectoryAtPath:[CCPackageHelper cachesFolder] error:nil];
    for (NSString *filename in array)
    {
        NSString *filePath = [[CCPackageHelper cachesFolder] stringByAppendingPathComponent:filename];
        if (![fileManager removeItemAtPath:filePath error:&error] && error.code != 4)
        {
            NSLog(@"ERROR: tearDown remove packages install folder %@", error);
        }
    }
*/

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

- (void)testPackageWithNameResolution
{
    [CCFileUtils sharedFileUtils].searchResolutionsOrder = [@[CCFileUtilsSuffixiPadHD] mutableCopy];

    CCPackage *aPackage = [[CCPackage alloc] initWithName:@"foo3"
                                               resolution:@"foobarresolution" // See note above
                                                       os:@"iOS"
                                                remoteURL:[NSURL URLWithString:@"http://foo.fake"]];

    [_packageManager addPackage:aPackage];

    CCPackage *result = [_packageManager packageWithName:@"foo3" resolution:@"foobarresolution"];

    XCTAssertEqual(aPackage, result);
}

- (void)testPackageWithNameResolutionOS
{
    [CCFileUtils sharedFileUtils].searchResolutionsOrder = [@[CCFileUtilsSuffixiPadHD] mutableCopy];

    CCPackage *aPackage = [[CCPackage alloc] initWithName:@"foo2"
                                               resolution:@"phonehd" // See note above
                                                       os:@"Mac"
                                                remoteURL:[NSURL URLWithString:@"http://foo.fake"]];

    [_packageManager addPackage:aPackage];

    CCPackage *result = [_packageManager packageWithName:@"foo2" resolution:@"phonehd" os:@"Mac"];

    XCTAssertEqual(aPackage, result);
}

- (void)testSavePackages
{
    CCPackage *package1 = [[CCPackage alloc] initWithName:@"DLC1"
                                               resolution:@"phonehd"
                                                       os:@"iOS"
                                                remoteURL:[NSURL URLWithString:@"http://foo.fake"]];
    package1.installRelURL = [NSURL fileURLWithPath:@"/packages/DLC1-iOS-phonehd"];
    package1.status = CCPackageStatusInitial;


    CCPackage *package2 = [[CCPackage alloc] initWithName:@"DLC2"
                                               resolution:@"tablethd"
                                                       os:@"iOS"
                                                remoteURL:[NSURL URLWithString:@"http://baa.fake"]];
    package2.installRelURL = [NSURL fileURLWithPath:@"/packages/DLC2-iOS-tablethd"];
    package2.status = CCPackageStatusInitial;

    [_packageManager addPackage:package1];
    [_packageManager addPackage:package2];

    [_packageManager savePackages];

    NSArray *packages = [[NSUserDefaults standardUserDefaults] objectForKey:PACKAGE_STORAGE_USERDEFAULTS_KEY];

    XCTAssertEqual(packages.count, 2);
    // Note: Persistency of CCPackage is tested in CCPackageTests
}

- (void)testDownloadWithNameAndBaseURLAndUnzipOnCustomQueue
{
    _packageManager.baseURL = [NSURL URLWithString:PACKAGE_BASE_URL];

    CCPackage *package = [_packageManager downloadPackageWithName:@"testpackage" enableAfterDownload:YES];

    dispatch_queue_t queue = dispatch_queue_create("testqueue", DISPATCH_QUEUE_CONCURRENT);
    _packageManager.unzippingQueue = queue;

    [self waitForDelegateToReturn];

    XCTAssertNotNil(package);
    XCTAssertTrue(_managerReturnedSuccessfully);
    XCTAssertEqual(package.status, CCPackageStatusInstalledEnabled);
}

- (void)testDownloadWithCustomFolderNameInPackage
{
    // The installer used by the package manager will look into the unzipped contents and expect a folder
    // named after the standard identifier: Foo-iOS-phonehd.
    // Since the testpackage-iOS-phonehd is downloaded the delegate is used to correct this.

    [CCFileUtils sharedFileUtils].searchResolutionsOrder = [@[CCFileUtilsSuffixiPhoneHD] mutableCopy];

    _packageManager.baseURL = [NSURL URLWithString:PACKAGE_BASE_URL];

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

    CCPackage *package = [_packageManager downloadPackageWithName:@"Foo" enableAfterDownload:YES];

    [self waitForDelegateToReturn];

    XCTAssertNotNil(package);
    XCTAssertTrue(_managerReturnedFailed);
    XCTAssertEqual(_managerReturnedWithError.code, PACKAGE_ERROR_INSTALL_PACKAGE_FOLDER_NAME_NOT_FOUND);
}

- (void)testDownloadWithoutBaseURLShouldFail
{
    CCPackage *package = [_packageManager downloadPackageWithName:@"testpackage" enableAfterDownload:YES];

    [self waitForDelegateToReturn];

    XCTAssertNil(package);
    XCTAssertTrue(_managerReturnedFailed);
    XCTAssertEqual(_managerReturnedWithError.code, PACKAGE_ERROR_MANAGER_NO_BASE_URL_SET);
}

- (void)testSetInstallPath
{
    // Test: set to empty string and nil should not change path
    NSString *installedRelPathCopy = [_packageManager.installRelPath copy];
    _packageManager.installRelPath = @" \t \n  ";
    CCAssertEqualStrings(installedRelPathCopy, _packageManager.installRelPath);

    _packageManager.installRelPath = nil;
    CCAssertEqualStrings(installedRelPathCopy, _packageManager.installRelPath);

    _packageManager.installRelPath = @"";
    CCAssertEqualStrings(installedRelPathCopy, _packageManager.installRelPath);


    // Test: set a non existing folder
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *relPath = @"Foo/Bar";
    NSString *fullPath = [[CCPackageHelper cachesFolder] stringByAppendingPathComponent:relPath];

    [_cleanPathsArrayOnTearDown addObject:fullPath];

    _packageManager.installRelPath = relPath;

    XCTAssertTrue([fileManager fileExistsAtPath:fullPath]);
    CCAssertEqualStrings(relPath, _packageManager.installRelPath);

    // Test2: set an existing path
    NSString *relPath2 = @"Foo2";
    NSString *fullPath2 = [[CCPackageHelper cachesFolder] stringByAppendingPathComponent:relPath];
    [_cleanPathsArrayOnTearDown addObject:fullPath2];

    [fileManager createDirectoryAtPath:fullPath2 withIntermediateDirectories:YES attributes:nil error:nil];

    _packageManager.installRelPath = relPath2;
    XCTAssertTrue([fileManager fileExistsAtPath:fullPath2]);
    CCAssertEqualStrings(relPath2, _packageManager.installRelPath);
}

- (void)testDownloadOfPackageWithDifferentInstallPath
{
    _packageManager.installRelPath = @"PackagesInstall";

    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageInitial];

    [_packageManager downloadPackage:package enableAfterDownload:NO];

    [self waitForDelegateToReturn];

    XCTAssertNotNil(package);
    XCTAssertTrue(_managerReturnedSuccessfully);
    XCTAssertEqual(package.status, CCPackageStatusInstalledDisabled);
}

- (void)testEnablePackage
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageInitial];

    NSString *pathToPackage = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources-shared/Packages/testpackage-iOS-phonehd_unzipped"];
    package.installRelURL = [[NSURL fileURLWithPath:pathToPackage] URLByAppendingPathComponent:@"testpackage-iOS-phonehd"];
    package.status = CCPackageStatusInstalledDisabled;

    NSError *error;
    BOOL success = [_packageManager enablePackage:package error:&error];

    XCTAssertTrue(success);
    XCTAssertNil(error);
    XCTAssertNotNil([_packageManager packageWithName:@"testpackage"]);
    XCTAssertEqual(package.status, CCPackageStatusInstalledEnabled);
}

- (void)testEnableNonDisabledPackage
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageWithStatus:CCPackageStatusInitial
                                                                  installRelPath:_packageManager.installRelPath];

    NSError *error;
    BOOL success = [_packageManager enablePackage:package error:&error];

    XCTAssertFalse(success);
    XCTAssertEqual(error.code, PACKAGE_ERROR_MANAGER_CANNOT_ENABLE_NON_DISABLED_PACKAGE);
    XCTAssertNotNil([_packageManager packageWithName:@"testpackage"]);
    XCTAssertEqual(package.status, CCPackageStatusInitial);
}

- (void)testDisablePackage
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageWithStatus:CCPackageStatusInstalledEnabled
                                                                  installRelPath:_packageManager.installRelPath];

    NSError *error;
    BOOL success = [_packageManager disablePackage:package error:&error];

    XCTAssertTrue(success);
    XCTAssertNil(error);
    XCTAssertNotNil([_packageManager packageWithName:@"testpackage"]);
    XCTAssertEqual(package.status, CCPackageStatusInstalledDisabled);
}

- (void)testDisableNonEnabledPackage
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageWithStatus:CCPackageStatusInitial
                                                                  installRelPath:_packageManager.installRelPath];

    NSError *error;
    BOOL success = [_packageManager disablePackage:package error:&error];

    XCTAssertFalse(success);
    XCTAssertEqual(error.code, PACKAGE_ERROR_MANAGER_CANNOT_DISABLE_NON_ENABLED_PACKAGE);
    XCTAssertNotNil([_packageManager packageWithName:@"testpackage"]);
    XCTAssertEqual(package.status, CCPackageStatusInitial);
}

- (void)testDeleteInstalledPackage
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageWithStatus:CCPackageStatusInstalledEnabled
                                                                  installRelPath:_packageManager.installRelPath];
    [_packageManager.packages addObject:package];

    NSArray *urls = [self copyOfURLsOfPackage:package];

    NSError *error;
    BOOL success = [_packageManager deletePackage:package error:&error];

    XCTAssertTrue(success);

    XCTAssertFalse([CCPackagesTestFixturesAndHelpers isURLInCocos2dSearchPath:package.installRelURL]);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    XCTAssertFalse([fileManager fileExistsAtPath:package.installRelURL.path]);
    XCTAssertNil([_packageManager packageWithName:@"testpackage"]);
    XCTAssertTrue([self allURLsInArrayDontExistOnDisk:urls]);

    [self assertURLsAreNilledStatusIsDeleted:package];
}

- (void)testDeleteUnzippedPackage
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageWithStatus:CCPackageStatusUnzipped
                                                                  installRelPath:_packageManager.installRelPath];
    [_packageManager.packages addObject:package];

    NSArray *urls = [self copyOfURLsOfPackage:package];

    NSError *error;
    BOOL success = [_packageManager deletePackage:package error:&error];

    XCTAssertTrue(success);
    XCTAssertNil([_packageManager packageWithName:@"testpackage"]);
    XCTAssertTrue([self allURLsInArrayDontExistOnDisk:urls]);

    [self assertURLsAreNilledStatusIsDeleted:package];
}

- (void)testDeleteDownloadedPackage
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageWithStatus:CCPackageStatusDownloaded
                                                                  installRelPath:_packageManager.installRelPath];
    [_packageManager.packages addObject:package];

    NSArray *urls = [self copyOfURLsOfPackage:package];

    NSError *error;
    BOOL success = [_packageManager deletePackage:package error:&error];

    XCTAssertTrue(success);
    XCTAssertNil([_packageManager packageWithName:@"testpackage"]);
    XCTAssertTrue([self allURLsInArrayDontExistOnDisk:urls]);

    [self assertURLsAreNilledStatusIsDeleted:package];
}

- (void)assertURLsAreNilledStatusIsDeleted:(CCPackage *)package
{
    XCTAssertNil(package.localDownloadURL);
    XCTAssertNil(package.unzipURL);
    XCTAssertNil(package.installRelURL);
    XCTAssertEqual(package.status, CCPackageStatusDeleted);
}

- (void)testDeleteUnzippingPackage
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageInitial];
    package.status = CCPackageStatusUnzipping;
    package.localDownloadURL = [NSURL fileURLWithPath:@"/Foo"];
    package.unzipURL = [NSURL fileURLWithPath:@"/Baa"];
    package.installRelURL = [NSURL fileURLWithPath:@"/Fubar"];

    [_packageManager.packages addObject:package];

    NSError *error;
    BOOL success = [_packageManager deletePackage:package error:&error];

    XCTAssertFalse(success);
    XCTAssertEqual(error.code, PACKAGE_ERROR_MANAGER_CANNOT_DELETE_UNZIPPING_PACKAGE);
    XCTAssertNotNil([_packageManager packageWithName:@"testpackage"]);
    XCTAssertNotNil(package.localDownloadURL);
    XCTAssertNotNil(package.unzipURL);
    XCTAssertNotNil(package.installRelURL);
    XCTAssertEqual(package.status, CCPackageStatusUnzipping);
}

- (void)testCancelDownload
{
    _packageManager.baseURL = [NSURL URLWithString:PACKAGE_BASE_URL];
    CCPackage *package = [_packageManager downloadPackageWithName:@"testpackage" enableAfterDownload:YES];

    [_packageManager cancelDownloadOfPackage:package];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *filesInDownloadFolder = [fileManager contentsOfDirectoryAtPath:_packageManager.downloadManager.downloadPath error:nil];

    XCTAssertEqual(filesInDownloadFolder.count, 0);
    XCTAssertEqual(_packageManager.downloadManager.allDownloads.count, 0);
    XCTAssertEqual(package.status, CCPackageStatusInitial);
    XCTAssertEqual(_packageManager.allPackages.count, 1);
}

- (void)testCancelDownloadOfPackageThatIsInstalled
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageWithStatus:CCPackageStatusInstalledDisabled
                                                                  installRelPath:_packageManager.installRelPath];

    [_packageManager cancelDownloadOfPackage:package];

    XCTAssertEqual(package.status, CCPackageStatusInstalledDisabled);
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

- (void)testLoadPackagesReEnable
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageWithStatus:CCPackageStatusInstalledDisabled
                                                                  installRelPath:_packageManager.installRelPath];
    // To simulate the loadPackages we need an installed but not actually enabled package just the status has to state it is enabled.
    package.status = CCPackageStatusInstalledEnabled;

    CCPackage *package2 = [CCPackagesTestFixturesAndHelpers testPackageInitial];

    NSArray *packages = @[[package toDictionary], [package2 toDictionary]];

    [[NSUserDefaults standardUserDefaults] setValue:packages forKey:PACKAGE_STORAGE_USERDEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [_packageManager loadPackages];

    XCTAssertEqual(_packageManager.allPackages.count, 2);
    XCTAssertTrue([CCPackagesTestFixturesAndHelpers isURLInCocos2dSearchPath:package.installRelURL]);
}

- (void)testLoadPackagesResumeDownloads
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageInitial];
    package.status = CCPackageStatusDownloadPaused;
    package.enableOnDownload = NO;

    NSString *fileName = [NSString stringWithFormat:@"%@.zip", [package standardIdentifier]];
    package.localDownloadURL = [NSURL fileURLWithPath:[_packageManager.downloadManager.downloadPath stringByAppendingPathComponent:fileName]];

    NSArray *packages = @[[package toDictionary]];

    [[NSUserDefaults standardUserDefaults] setValue:packages forKey:PACKAGE_STORAGE_USERDEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [_packageManager loadPackages];

    [self waitForDelegateToReturn];

    XCTAssertTrue(_managerReturnedSuccessfully);
    CCPackage *loadedPackage = _packageManager.allPackages[0];
    XCTAssertEqual(loadedPackage.status, CCPackageStatusInstalledDisabled);
}

- (void)testLoadPackagesRestartUnzipping
{
    CCPackage *package = [CCPackagesTestFixturesAndHelpers testPackageWithStatus:CCPackageStatusDownloaded
                                                                  installRelPath:_packageManager.installRelPath];
    package.enableOnDownload = NO;

    NSArray *packages = @[[package toDictionary]];

    [[NSUserDefaults standardUserDefaults] setValue:packages forKey:PACKAGE_STORAGE_USERDEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [_packageManager loadPackages];

    [self waitForDelegateToReturn];

    XCTAssertTrue(_managerReturnedSuccessfully);
    CCPackage *loadedPackage = _packageManager.allPackages[0];
    XCTAssertEqual(loadedPackage.status, CCPackageStatusInstalledDisabled);
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


#pragma mark - Helper

- (void)waitForDelegateToReturn
{
    [CCPackagesTestFixturesAndHelpers waitForCondition:^bool {
        return !_managerReturnedFailed && !_managerReturnedSuccessfully;
    }];
}

- (NSArray *)copyOfURLsOfPackage:(CCPackage *)package
{
    NSMutableArray *result = [NSMutableArray array];

    if (package.installRelURL)
    {
        [result addObject:[package.installRelURL copy]];
    }

    if (package.localDownloadURL)
    {
        [result addObject:[package.localDownloadURL copy]];
    }

    if (package.unzipURL)
    {
        [result addObject:[package.unzipURL copy]];
    }

    return result;
}

- (BOOL)allURLsInArrayDontExistOnDisk:(NSArray *)urls
{
    for (NSURL *url in urls)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:url.path])
        {
            return NO;
        }
    }
    return YES;
}

@end
