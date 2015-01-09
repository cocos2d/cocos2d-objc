//
//  CCPackageDownloadTests.m
//  cocos2d-tests-ios
//
//  Created by Nicky Weber on 23.09.14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "CCPackageDownload.h"
#import "CCPackage.h"
#import "CCPackageDownloadDelegate.h"
#import "CCDirector.h"
#import "AppDelegate.h"
#import "CCPackagesTestFixturesAndHelpers.h"


@interface CCPackageDownload()
- (NSString *)createTempName;
@end

static NSUInteger __fileDownloadSize = 0;
static BOOL __support_range_request = YES;

@interface CCPackageDownloadTestURLProtocol : NSURLProtocol @end

@implementation CCPackageDownloadTestURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest*)theRequest
{
    return [theRequest.URL.scheme caseInsensitiveCompare:@"http"] == NSOrderedSame;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)theRequest
{
    return theRequest;
}

- (NSUInteger)parseRangeHeaderValue:(NSString *)string
{
    if (!string)
    {
        return 0;
    }

    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"bytes=(\\d+)-"
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:&error];

    NSTextCheckingResult *match = [regex firstMatchInString:string
                                                    options:NSMatchingAnchored
                                                      range:NSMakeRange(0, string.length)];

    if (match.numberOfRanges == 2)
    {
        NSString *byteStr = [string substringWithRange:[match rangeAtIndex:1]];
        return (NSUInteger) [byteStr integerValue];
    }

    return 0;
}

- (void)startLoading
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileName = [self.request.URL lastPathComponent];
    NSString *pathToPackage = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Resources-shared/Packages/%@", fileName] ofType:nil];
    NSDictionary *attribs = [fileManager attributesOfItemAtPath:pathToPackage error:nil];
    NSUInteger fileSize = [attribs[NSFileSize] unsignedIntegerValue];

    NSUInteger byteRangeStart = 0;
    if (__support_range_request)
    {
        byteRangeStart = [self parseRangeHeaderValue:self.request.allHTTPHeaderFields[@"Range"]];
        headers[@"Accept-Ranges"] = @"bytes";
        headers[@"Content-Range"] = [NSString stringWithFormat:@"bytes %u-%u/%u", (unsigned int)byteRangeStart, (unsigned int)fileSize - 1, (unsigned int)fileSize];
    }

    NSData *data = [[NSData dataWithContentsOfFile:pathToPackage] subdataWithRange:NSMakeRange(byteRangeStart, fileSize - byteRangeStart)];

    __fileDownloadSize = fileSize;

    NSHTTPURLResponse *response;
    if (pathToPackage)
    {
        headers[@"Content-Length"] = [NSString stringWithFormat:@"%u", (unsigned int)[data length]];
        response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                              statusCode:200
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:headers];
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


@interface CCPackageDownloadTests : IGNORE_TEST_CASE <CCPackageDownloadDelegate>

@property (nonatomic, strong) CCPackageDownload *download;
@property (nonatomic, strong) CCPackage *package;
@property (nonatomic, copy) NSString *downloadPath;
@property (nonatomic) BOOL downloadReturned;
@property (nonatomic) BOOL downloadSuccessful;
@property (nonatomic, strong) NSError *downloadError;
@property (nonatomic, copy) NSURL *localURL;
@property (nonatomic) BOOL shouldOverwriteDownloadedFile;

@end

@implementation CCPackageDownloadTests

- (void)setUp
{
    [super setUp];

    [(AppController *)[UIApplication sharedApplication].delegate configureCocos2d];
    [[CCDirector sharedDirector] stopAnimation];
    // Spin the runloop a bit otherwise nondeterministic exceptions are thrown in the CCScheduler.
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeInterval:0.2 sinceDate:[NSDate date]]];

    [NSURLProtocol registerClass:[CCPackageDownloadTestURLProtocol class]];

    self.downloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Downloads"];

    [self deleteDownloadFolder];
    [self createDownloadFolder];

    self.downloadReturned = NO;
    self.downloadError = nil;
    self.downloadSuccessful = NO;
    [self shouldOverwriteDownloadedFile];

    self.package = [[CCPackage alloc] initWithName:@"testpackage"
                                        resolution:@"phonehd"
                                                os:@"iOS"
                                         remoteURL:[NSURL URLWithString:@"http://package.request.fake/testpackage-iOS-phonehd.zip"]];

    self.localURL = [[NSURL fileURLWithPath:_downloadPath] URLByAppendingPathComponent:@"testdownload.zip"];
    self.download = [[CCPackageDownload alloc] initWithPackage:_package localURL:_localURL];
    _download.delegate = self;
}

- (void)tearDown
{
    [NSURLProtocol unregisterClass:[CCPackageDownloadTestURLProtocol class]];

    [[CCDirector sharedDirector] startAnimation];

    [super tearDown];
}

- (void)deleteDownloadFolder
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if (![fileManager removeItemAtPath:_downloadPath error:&error])
    {
        NSLog(@"%@",error);
    }
}

- (void)createDownloadFolder
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager createDirectoryAtURL:[NSURL fileURLWithPath:_downloadPath]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error])
    {
        NSLog(@"%@", error);
    }
}


#pragma mark - Tests

- (void)testDownloadPackage
{
    [_download start];
    XCTAssertEqual(_package.status, CCPackageStatusDownloading);

    [self waitForDelegateToReturn];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attribs = [fileManager attributesOfItemAtPath:_localURL.path error:nil];
    XCTAssertTrue(_downloadSuccessful);
    XCTAssertTrue([fileManager fileExistsAtPath:_localURL.path]);
    XCTAssertEqual([attribs[NSFileSize] unsignedIntegerValue], __fileDownloadSize);
}

- (void)testResumeDownloadAKARangeRequest
{
    [self setupPartialDownloadOnDisk];

    [_download start];
    XCTAssertEqual(_package.status, CCPackageStatusDownloading);

    [self waitForDelegateToReturn];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attribs = [fileManager attributesOfItemAtPath:_localURL.path error:nil];
    XCTAssertTrue(_downloadSuccessful);
    XCTAssertTrue([fileManager fileExistsAtPath:_localURL.path]);
    XCTAssertEqual([attribs[NSFileSize] unsignedIntegerValue], __fileDownloadSize);
}

- (void)testDownloadOfExistingFile
{
    self.shouldOverwriteDownloadedFile = NO;

    NSUInteger filesize = [self createDownloadFile];

    [_download start];
    XCTAssertEqual(_package.status, CCPackageStatusDownloaded);

    [self waitForDelegateToReturn];

    NSFileManager *fileManager = [NSFileManager defaultManager];;
    NSDictionary *attribs = [fileManager attributesOfItemAtPath:_localURL.path error:nil];
    XCTAssertTrue(_downloadSuccessful);
    XCTAssertTrue([fileManager fileExistsAtPath:_localURL.path]);
    XCTAssertEqual([attribs[NSFileSize] unsignedIntegerValue], filesize);
}

- (void)testOverwriteExistingDownload
{
    self.shouldOverwriteDownloadedFile = YES;

    [self createDownloadFile];

    [_download start];
    XCTAssertEqual(_package.status, CCPackageStatusDownloading);

    [self waitForDelegateToReturn];

    NSFileManager *fileManager = [NSFileManager defaultManager];;
    NSDictionary *attribs = [fileManager attributesOfItemAtPath:_localURL.path error:nil];
    XCTAssertTrue(_downloadSuccessful);
    XCTAssertTrue([fileManager fileExistsAtPath:_localURL.path]);
    XCTAssertEqual([attribs[NSFileSize] unsignedIntegerValue], __fileDownloadSize);
}

- (void)testDownloadWith404Response
{
    [_package setValue:[NSURL URLWithString:@"http://package.request.fake/DOES_NOT_EXIST.zip"] forKey:NSStringFromSelector(@selector(remoteURL))];

    [_download start];
    XCTAssertEqual(_package.status, CCPackageStatusDownloading);

    [self waitForDelegateToReturn];

    XCTAssertFalse(_downloadSuccessful);
    XCTAssertNotNil(_downloadError);
    XCTAssertEqual(_package.status, CCPackageStatusDownloadFailed);
}

- (void)testDownloadFolderNotAccessible
{
    // Writing to root level is supposed to fail
    [_download setValue:[NSURL fileURLWithPath:@"/test.zip"] forKey:NSStringFromSelector(@selector(localURL))];

    [_download start];

    [self waitForDelegateToReturn];

    XCTAssertFalse(_downloadSuccessful);
    XCTAssertNotNil(_downloadError);
    XCTAssertEqual(_package.status, CCPackageStatusDownloadFailed);
}

- (void)testCancelDownload
{
    [_download start];
    [_download cancel];

    // Can't wait for delegate since cancelling won't trigger them
    // Just wait a short amount of time and see if nothing has been written to disk
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]]];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    XCTAssertFalse([fileManager fileExistsAtPath:_download.localURL.path]);
    XCTAssertEqual(_package.status, CCPackageStatusInitial);
}

- (void)testPauseDownload
{
    [_download start];
    [_download pause];

    // Can't wait for delegate since cancelling won't trigger them
    // Just wait a short amount of time and see if nothing has been written to disk
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeInterval:0.5 sinceDate:[NSDate date]]];

    XCTAssertEqual(_package.status, CCPackageStatusDownloadPaused);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempName = [_download createTempName];

    BOOL success = [fileManager fileExistsAtPath:[[_localURL.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:tempName]]
                   || [fileManager fileExistsAtPath:_download.localURL.path];

    XCTAssertTrue(success, @"Temp file nor downloaded file exists.");
}

- (void)testResumeDownload
{
    [_download start];
    [_download pause];
    [_download resume];

    while (!_downloadReturned)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attribs = [fileManager attributesOfItemAtPath:_localURL.path error:nil];
    XCTAssertTrue(_downloadSuccessful);
    XCTAssertTrue([fileManager fileExistsAtPath:_localURL.path]);
    XCTAssertEqual([attribs[NSFileSize] unsignedIntegerValue], __fileDownloadSize);
}


#pragma mark - Helper

- (void)setupPartialDownloadOnDisk
{
    NSString *fileName = [_package.remoteURL lastPathComponent];
    NSString *pathToPackage = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Resources-shared/Packages/%@", fileName] ofType:nil];
    NSData *data = [[NSData dataWithContentsOfFile:pathToPackage] subdataWithRange:NSMakeRange(0, 5000)];
    NSString *tempName = [_download createTempName];
    [data writeToFile:[[_localURL.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:tempName] atomically:YES];
}

- (void)waitForDelegateToReturn
{
    while (!_downloadReturned)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

- (NSUInteger)createDownloadFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:_localURL.path
                         contents:[@"nothing in here, really" dataUsingEncoding:NSUTF8StringEncoding]
                       attributes:nil];

    NSDictionary *attribs = [fileManager attributesOfItemAtPath:_localURL.path error:nil];
    return [attribs[NSFileSize] unsignedIntegerValue];
}


#pragma mark - CCPackageDownloadDelegate

- (void)downloadFinished:(CCPackageDownload *)download
{
    self.downloadReturned = YES;
    self.downloadSuccessful = YES;
}

- (void)downloadFailed:(CCPackageDownload *)download error:(NSError *)error
{
    self.downloadReturned = YES;
    self.downloadError = error;
    self.downloadSuccessful = NO;
}

- (BOOL)shouldResumeDownload:(CCPackageDownload *)download
{
    return YES;
}

- (BOOL)shouldOverwriteDownloadedFile:(CCPackageDownload *)download
{
    return _shouldOverwriteDownloadedFile;
}

@end
