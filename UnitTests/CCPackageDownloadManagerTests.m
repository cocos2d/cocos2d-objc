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
#import "CCUnitTestAssertions.h"
#import "CCPackageInstallData.h"
#import "CCPackage+InstallData.h"

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

@interface CCPackageDownloadManagerTests : XCTestCase <CCPackageDownloadManagerDelegate>

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
    CCPackage *package1 = [[CCPackage alloc] initWithName:@"package1" resolution:@"phonehd" os:@"iOS" remoteURL:[NSURL URLWithString:@"http://package.fake/package1"]];
    CCPackageInstallData  *installData1 = [[CCPackageInstallData  alloc] init];
    [package1 setInstallData:installData1];

    CCPackage *package2 = [[CCPackage alloc] initWithName:@"package2" resolution:@"phonehd" os:@"iOS" remoteURL:[NSURL URLWithString:@"http://package.fake/package2"]];
    CCPackageInstallData  *installData2 = [[CCPackageInstallData  alloc] init];
    [package2 setInstallData:installData2];

    [_downloadManager enqueuePackageForDownload:package1];
    [_downloadManager enqueuePackageForDownload:package2];

    while (!_allDownloadsReturned)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    XCTAssertTrue([fileManager fileExistsAtPath:[package1 installData].localDownloadURL.path]);
    XCTAssertTrue([fileManager fileExistsAtPath:[package2 installData].localDownloadURL.path]);

    CCAssertEqualStrings(@"package1", [NSString stringWithContentsOfFile:[package1 installData].localDownloadURL.path encoding:NSUTF8StringEncoding error:nil]);
    CCAssertEqualStrings(@"package2", [NSString stringWithContentsOfFile:[package2 installData].localDownloadURL.path encoding:NSUTF8StringEncoding error:nil]);
}

- (void)testCancelDownload
{
    CCPackage *package1 = [[CCPackage alloc] initWithName:@"package1" resolution:@"phonehd" os:@"iOS" remoteURL:[NSURL URLWithString:@"http://package.fake/package1"]];
    CCPackageInstallData  *installData1 = [[CCPackageInstallData  alloc] init];
    [package1 setInstallData:installData1];

    [_downloadManager enqueuePackageForDownload:package1];
    [_downloadManager cancelDownloadOfPackage:package1];

    // Can't wait for delegate since cancelling won't trigger them
    // Just wait a short amount of time and see if nothing has been written to disk
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]]];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    XCTAssertFalse([fileManager fileExistsAtPath:[package1 installData].localDownloadURL.path]);
}


#pragma mark -

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
