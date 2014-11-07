#include <CommonCrypto/CommonDigest.h>

#import "CCPackageDownload.h"
#import "CCPackageDownloadDelegate.h"
#import "CCPackage.h"
#import "CCPackageConstants.h"
#import "ccMacros.h"
#import "CCPackage_private.h"
#import "CCFileUtils.h"

@interface CCPackageDownload()

@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong, readwrite) CCPackage *package;
@property (nonatomic, copy) NSString *tempPath;
@property (nonatomic, copy, readwrite) NSURL *localURL;

@property (nonatomic, readwrite) NSUInteger totalBytes;
@property (nonatomic, readwrite) NSUInteger downloadedBytes;

@property (nonatomic) NSUInteger fileSize;
@end


@implementation CCPackageDownload

- (instancetype)initWithPackage:(CCPackage *)package localURL:(NSURL *)localURL
{
    NSAssert(package != nil, @"package must not be nil");
    NSAssert(localURL != nil, @"localURL must not be nil");

    self = [super init];
    if (self)
    {
        self.package = package;
        self.localURL = localURL;
        self.fileSize = [self fileSizeOfDownload];
        self.tempPath = [[_localURL.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:[self createTempName]];

        CCLOGINFO(@"[PACKAGE/DOWNLOAD][INFO] Package Download created: \n%@\n%@", _package, _localURL);
    }

    return self;
}

- (void)dealloc
{
    [_fileHandle closeFile];
}


#pragma mark - actions

- (void)start
{
    [self startDownloadAskingDelegateIfToResume:YES];
}

- (void)cancel
{
    CCLOGINFO(@"[PACKAGE/DOWNLOAD][INFO] Cancelling");

    [self closeConnectionAndFileHandle];

    [self removeTempAndDownloadFile];

    _package.status = CCPackageStatusInitial;
}

- (void)pause
{
    CCLOGINFO(@"[PACKAGE/DOWNLOAD][INFO] Pause");

    _package.status = CCPackageStatusDownloadPaused;

    [self closeConnectionAndFileHandle];
}

- (void)resume
{
    [self startDownloadAskingDelegateIfToResume:NO];
}


#pragma mark - actions

- (NSString *)createTempName
{
    return [NSString stringWithFormat:@"%@_%@", [self sha1:[_package.remoteURL absoluteString]], [_package standardIdentifier]];
}

- (NSString *)sha1:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, (CC_LONG)strlen(cStr), result);
    NSString *hash = [NSString stringWithFormat:
                                    @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                    result[0], result[1], result[2], result[3], result[4],
                                    result[5], result[6], result[7],result[8], result[9],
                                    result[10], result[11], result[12], result[13], result[14],
                                    result[15], result[16], result[17], result[18], result[19]
    ];

    return hash;
}

- (void)createConnectionAndStartDownload
{
    NSURLRequest *request = [self createRequest];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    CCLOGINFO(@"[PACKAGE/DOWNLOAD][INFO] starting download of %@", _package);

    _package.status = CCPackageStatusDownloading;

    [_connection start];
}

- (void)determineIfDownloadShouldBeResumedAndShouldAskDelegate:(BOOL)askDelegate
{
    BOOL shouldResume = _fileSize > 0;
    BOOL delegateDecision = askDelegate
        && [_delegate respondsToSelector:@selector(shouldResumeDownload:)]
        && [_delegate shouldResumeDownload:self];

    if (shouldResume
        && (!askDelegate || delegateDecision))
    {
        [_fileHandle seekToEndOfFile];
    }
    else
    {
        [_fileHandle seekToFileOffset:0];
        self.fileSize = 0;
    }
}

- (NSUInteger)fileSizeOfDownload
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath:_tempPath])
    {
        return 0;
    }

    NSError *error;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:_tempPath error:&error];

    if (error)
    {
        return 0;
    }

    return [attributes[NSFileSize] unsignedIntegerValue];
}

- (void)startDownloadAskingDelegateIfToResume:(BOOL)askDelegate
{
    if ([self fileAlreadyDownloaded]
        && [self keepDownload])
    {
        [self finishDownload];
        return;
    }

    if (_connection)
    {
        CCLOGINFO(@"[PACKAGE/DOWNLOAD][INFO] Already downloading");
        return;
    }

    NSError *error;
    if (![self createFileHandle:&error])
    {
        [self connection:_connection didFailWithError:error];
        return;
    }

    self.fileSize = [self fileSizeOfDownload];

    [self determineIfDownloadShouldBeResumedAndShouldAskDelegate:askDelegate];

    self.downloadedBytes = _fileSize;

    [self createConnectionAndStartDownload];
}

- (BOOL)keepDownload
{
    if ([self shouldOverwriteAlreadyDownloadedFile])
    {
        CCLOGINFO(@"[PACKAGE/DOWNLOAD][INFO] Overwriting download file %@", _localURL);
        [self removeDownloadFile];
    }
    else
    {
        CCLOGINFO(@"[PACKAGE/DOWNLOAD][INFO] Download file exists %@", _localURL);
        [self closeConnectionAndFileHandle];

        _package.status = CCPackageStatusDownloaded;

        if ([_delegate respondsToSelector:@selector(downloadFinished:)])
        {
            [_delegate downloadFinished:self];
        }
        return YES;
    }
    return NO;
}

- (BOOL)fileAlreadyDownloaded
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:_localURL.path];
}

- (BOOL)shouldOverwriteAlreadyDownloadedFile
{
    return [_delegate respondsToSelector:@selector(shouldOverwriteDownloadedFile:)]
            && [_delegate shouldOverwriteDownloadedFile:self];
}

- (void)removeTempAndDownloadFile
{
    CCLOGINFO(@"[PACKAGE/DOWNLOAD][INFO] Removing download file: %@", _localURL);

    [_fileHandle closeFile];
    self.fileHandle = nil;

    [self removeDownloadFile];
    [self removeTempFile];
}

- (void)removeDownloadFile
{
    NSError *error;
    if (![[NSFileManager defaultManager] removeItemAtURL:_localURL error:&error])
    {
        CCLOG(@"[PACKAGE/DOWNLOAD][ERROR] Removing download file \"%@\" with error %@", _localURL, error);
    }
}

- (void)removeTempFile
{
    NSError *error;
    if (![[NSFileManager defaultManager] removeItemAtPath:_tempPath error:&error])
    {
        CCLOG(@"[PACKAGE/DOWNLOAD][ERROR] Removing temp file \"%@\" with error %@", _tempPath, error);
    }
}

- (NSURLRequest *)createRequest
{
    NSMutableURLRequest *result = [NSMutableURLRequest requestWithURL:_package.remoteURL];

    if ([_delegate respondsToSelector:@selector(request:ofDownload:)])
    {
        [_delegate request:result ofDownload:self];
    }

    if (_fileSize > 0)
    {
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%d-", (unsigned int)_fileSize];
        [result setValue:requestRange forHTTPHeaderField:@"Range"];
    }

    return result;
}

- (BOOL)createFileHandle:(NSError **)error
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:_tempPath] error:error];
    CCLOGINFO(@"[PACKAGE/DOWNLOAD][INFO] Opening/Creating file for download: %@", _tempPath);

    if (!fileHandle)
    {
        [[NSFileManager defaultManager] createFileAtPath:_tempPath contents:nil attributes:nil];
        fileHandle = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:_tempPath] error:error];
    }

    if (!fileHandle)
    {
        CCLOG(@"[PACKAGE/DOWNLOAD][ERROR] %@, cannot open file for writing download %@", *error, _tempPath);
        return NO;
    }

    self.fileHandle = fileHandle;

    return YES;
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    CCLOGINFO(@"[PACKAGE/DOWNLOAD][DEBUG]RESPONSE HEADERS: %@", [httpResponse allHeaderFields]);

    if ([httpResponse statusCode] >= 400)
    {
        [self cancel];
        [self forwardResponseErrorToDelegate:httpResponse];
        return;
    }

    if ([self didServerRejectRangeRequest:httpResponse])
    {
        [self restartDownload];
        return;
    }

    CCLOGINFO(@"[PACKAGE/DOWNLOAD][INFO] response received - %d %@", [httpResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]);

    if ([httpResponse expectedContentLength] != NSURLResponseUnknownLength)
    {
        self.totalBytes = [self extractTotalBytesFromResponse:httpResponse];
        CCLOGINFO(@"[PACKAGE/DOWNLOAD][INFO] Download Content-Length: %u", _totalBytes);

        if (_fileSize == _totalBytes)
        {
            CCLOGINFO(@"[PACKAGE/DOWNLOAD][INFO] Download already finished. Stopping download request.");
        }
        else if (_fileSize > _totalBytes)
        {
            CCLOG(@"[PACKAGE/DOWNLOAD][ERROR] Restarting download: Size mismatch: File is larger(%lu) than expected download size(%lu)", (unsigned long)_fileSize, (unsigned long)_totalBytes);
            [self restartDownload];
        }
    }
    else
    {
        CCLOGINFO(@"[PACKAGE/DOWNLOAD][INFO] No Content-Length header set. totalBytes is 0.");
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self closeConnectionAndFileHandle];
    NSError *error;
    if (![[[CCFileUtils sharedFileUtils] fileManager] moveItemAtURL:[NSURL fileURLWithPath:_tempPath] toURL:_localURL error:&error])
    {
        [self connection:connection didFailWithError:error];
        return;
    }

    [self finishDownload];
}

- (void)finishDownload
{
    CCLOGINFO(@"[PACKAGE/DOWNLOAD][INFO] Download finished");
    CCLOGINFO(@"[PACKAGE/DOWNLOAD][INFO] local file: %@", _localURL.path);

    [self closeConnectionAndFileHandle];

    _package.status = CCPackageStatusDownloaded;

    [_delegate downloadFinished:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!_fileHandle)
    {
        return;
    }

    self.downloadedBytes += [data length];

    // CCLOGINFO(@"[PACKAGE DOWNLOAD] [INFO] Download progress: %u / %u", _downloadedBytes, _totalBytes);

    @try
    {
        [_fileHandle writeData:data];

        if ([_delegate respondsToSelector:@selector(downlowdProgress:downloadedBytes:totalBytes:)])
        {
            [_delegate downlowdProgress:self downloadedBytes:_downloadedBytes totalBytes:_totalBytes];
        }
    }
    @catch (NSException *e)
    {
        CCLOG(@"[PACKAGE/DOWNLOAD][ERROR] writing to file %@", _tempPath);

        [self cancel];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    CCLOG(@"[PACKAGE/DOWNLOAD][ERROR] Download failed %@", error);

    [self cancel];

    _package.status = CCPackageStatusDownloadFailed;

    [_delegate downloadFailed:self error:error];
}


#pragma mark - Misc

- (void)forwardResponseErrorToDelegate:(NSHTTPURLResponse *)httpResponse
{
    NSError *error = [NSError errorWithDomain:@"Cocos2d"
                                         code:PACKAGE_ERROR_DOWNLOAD_SERVER_RESPONSE_NOT_OK
                                     userInfo:@{
                                             NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Error: The host respondeded with status code %d.", (unsigned int)[httpResponse statusCode]],
                                             @"HTTPResponse" : httpResponse
                                     }];

    _package.status = CCPackageStatusDownloadFailed;

    [_delegate downloadFailed:self error:error];
}

- (NSUInteger)extractTotalBytesFromResponse:(NSHTTPURLResponse *)response
{
    NSDictionary *headers = [response allHeaderFields];
    if (headers[@"Content-Range"])
    {
        NSString *rangeValue = headers[@"Content-Range"];

        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"bytes \\d+-\\d+/(\\d+)"
                                                              options:NSRegularExpressionCaseInsensitive
                                                                error:&error];

        NSTextCheckingResult *match = [regex firstMatchInString:rangeValue
                                                        options:NSMatchingAnchored
                                                          range:NSMakeRange(0, rangeValue.length)];

        if (match.numberOfRanges == 2)
        {
            NSString *byteStr = [rangeValue substringWithRange:[match rangeAtIndex:1]];
            return (NSUInteger) [byteStr integerValue];
        }
    }

    return (NSUInteger) [response expectedContentLength];
}

- (BOOL)didServerRejectRangeRequest:(NSHTTPURLResponse *)httpResponse
{
    return _fileSize > 0
        && (_fileSize != [httpResponse expectedContentLength])
        && ([httpResponse.allHeaderFields[@"Accept-Ranges"] isEqualToString:@"none"]
            || !httpResponse.allHeaderFields[@"Accept-Ranges"]);
}

- (void)restartDownload
{
    [_fileHandle truncateFileAtOffset:0];
    [_fileHandle seekToFileOffset:0];

    self.downloadedBytes = 0;

    [self closeConnectionAndFileHandle];

    [self startDownloadAskingDelegateIfToResume:NO];
}

- (void)closeConnectionAndFileHandle
{
    [_fileHandle closeFile];
    self.fileHandle = nil;

    [_connection cancel];
    self.connection = nil;

    self.fileSize = 0;
}


#pragma mark - debug

- (NSString *)description
{
    return [NSString stringWithFormat:@"PACKAGE URL: %@, LOCAL URL: %@", _package.remoteURL, _localURL];
}

@end
