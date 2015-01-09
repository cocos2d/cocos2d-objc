//
//  CCPackageDownloadManagerTests.m
//  cocos2d-tests-ios
//
//  Created by Nicky Weber on 23.09.14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCPackageDownloadManager.h"
#import "CCPackageDownloadManagerDelegate.h"
#import "CCPackage.h"
#import "CCDirector.h"
#import "AppDelegate.h"
#import "CCPackagesTestFixturesAndHelpers.h"
#import "CCUnitTestAssertions.h"
#import "CCPackage_private.h"

@interface CCPackageDownloadManagerTestURLProtocol : NSURLProtocol @end

@implementation CCPackageDownloadManagerTestURLProtocol

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
    // just send back what was received in URL as last path component
    NSString *payload = [self.request.URL lastPathComponent];
    NSData *data = [payload dataUsingEncoding:NSUTF8StringEncoding];

    NSHTTPURLResponse *response;
        response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                              statusCode:200
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:nil];

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


@interface CCPackageDownloadManagerTests : IGNORE_TEST_CASE <CCPackageDownloadManagerDelegate>

@property (nonatomic, strong) CCPackageDownloadManager *downloadManager;
@property (nonatomic) BOOL allDownloadsReturned;
@property (nonatomic, copy) NSString *downloadPath;

@end

@implementation CCPackageDownloadManagerTests

- (void)setUp
{
    [super setUp];

    [(AppController *)[UIApplication sharedApplication].delegate configureCocos2d];
    [[CCDirector sharedDirector] stopAnimation];
    // Spin the runloop a bit otherwise nondeterministic exceptions are thrown in the CCScheduler.
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeInterval:0.2 sinceDate:[NSDate date]]];

    [NSURLProtocol registerClass:[CCPackageDownloadManagerTestURLProtocol class]];

    self.downloadManager = [[CCPackageDownloadManager alloc] init];
    self.allDownloadsReturned = NO;

    self.downloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Downloads"];

    [self deleteOldDownloads];

    _downloadManager.downloadPath = _downloadPath;
    _downloadManager.delegate = self;
}

- (void)tearDown
{
    [NSURLProtocol unregisterClass:[CCPackageDownloadManagerTestURLProtocol class]];
    [super tearDown];
}

- (void)deleteOldDownloads
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:_downloadPath error:nil];
}


#pragma mark - Tests

- (void)testSetDownloadPath
{
    NSString *newPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"NewDownloads"];
    _downloadManager.downloadPath = newPath;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;

    XCTAssert([fileManager fileExistsAtPath:newPath isDirectory:&isDir]);
    XCTAssertTrue(isDir);
    CCAssertEqualStrings(newPath, _downloadManager.downloadPath);
}

- (void)testTwoDownloads
{
    NSArray *packages = @[[self completePackageWithName:@"package1"], [self completePackageWithName:@"package2"]];

    for (CCPackage *aPackage in packages)
    {
        [_downloadManager enqueuePackageForDownload:aPackage];
    }

    [self waitUntilDelegateReturns];

    [self assertPackagesDownloadedAndContentsAreAsExpected:packages];
}

- (void)testCancelDownload
{
    CCPackage *package1 = [self completePackageWithName:@"package1"];

    [_downloadManager enqueuePackageForDownload:package1];
    [_downloadManager cancelDownloadOfPackage:package1];

    // Can't wait for delegate since cancelling won't trigger them
    // Just wait a short amount of time and see if nothing has been written to disk
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]]];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    XCTAssertFalse([fileManager fileExistsAtPath:package1.localDownloadURL.path]);
}

- (void)testPauseAndResumeAllDownloads
{
    NSArray *packages = @[[self completePackageWithName:@"package1"],
                          [self completePackageWithName:@"package2"],
                          [self completePackageWithName:@"package3"]];

    for (CCPackage *aPackage in packages)
    {
        [_downloadManager enqueuePackageForDownload:aPackage];
    }

    [_downloadManager pauseAllDownloads];
    [_downloadManager resumeAllDownloads];

    [self waitUntilDelegateReturns];

    [self assertPackagesDownloadedAndContentsAreAsExpected:packages];
}

- (void)testEnqueuePausedPackage
{
    CCPackage *package1 = [self completePackageWithName:@"package1"];

    [_downloadManager enqueuePackageForDownload:package1];
    [_downloadManager pauseDownloadOfPackage:package1];
    [_downloadManager enqueuePackageForDownload:package1];

    [self waitUntilDelegateReturns];

    [self assertPackagesDownloadedAndContentsAreAsExpected:@[package1]];
}

- (void)testResumeDownloadAfterLoadingPackages
{
    // This test aims at the situation when coming back from persistency and
    // the package manager resume downloads.

    CCPackage *package = [self completePackageWithName:@"package"];
    package.status = CCPackageStatusDownloadPaused;
    package.localDownloadURL = [NSURL fileURLWithPath:[_downloadManager.downloadPath stringByAppendingPathComponent:@"foo.zip"]];

    [_downloadManager enqueuePackageForDownload:package];

    [self waitUntilDelegateReturns];

    [self assertPackagesDownloadedAndContentsAreAsExpected:@[package]];
}

- (void)waitUntilDelegateReturns
{
    while (!_allDownloadsReturned)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}


#pragma mark - Helpers

- (void)assertPackagesDownloadedAndContentsAreAsExpected:(NSArray *)packages
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (CCPackage *aPackage in packages)
    {
        XCTAssertTrue([fileManager fileExistsAtPath:aPackage.localDownloadURL.path]);
        CCAssertEqualStrings(aPackage.name, [NSString stringWithContentsOfFile:aPackage.localDownloadURL.path encoding:NSUTF8StringEncoding error:nil]);
    }
}


#pragma mark - Fixtures

- (CCPackage *)completePackageWithName:(NSString *)name
{
    CCPackage *package = [[CCPackage alloc] initWithName:name resolution:@"phonehd" os:@"iOS" remoteURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://package.fake/%@", name]]];
    return package;
}


#pragma mark - CCPackageDownloadManagerDelegate

- (void)downloadFinishedOfPackage:(CCPackage *)package
{
    NSLog(@"%@ finished", package);
    self.allDownloadsReturned =  _downloadManager.allDownloads.count == 0;
}

- (void)downloadFailedOfPackage:(CCPackage *)package error:(NSError *)error
{
    NSLog(@"%@ failed", package);
    self.allDownloadsReturned =  _downloadManager.allDownloads.count == 0;
}

@end
