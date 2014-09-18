#import "CCPackageDownloadManager.h"
#import "CCPackage.h"
#import "CCPackageDownload.h"
#import "CCPackageDownloadManagerDelegate.h"
#import "CCPackageInstallData.h"
#import "CCPackage+InstallData.h"
#import "CCPackageConstants.h"
#import "ccMacros.h"


@interface CCPackageDownloadManager()

@property (nonatomic, strong) NSMutableArray *downloads;

@end


@implementation CCPackageDownloadManager

- (id)init
{
    self = [super init];

    if (self)
    {
        self.downloads = [NSMutableArray array];
        self.downloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:PACKAGE_REL_DOWNLOAD_FOLDER];
        self.resumeDownloads = NO;
        self.overwriteFinishedDownloads = NO;
    }

    return self;
}

- (void)setDownloadPath:(NSString *)downloadPath
{
    if ([_downloadPath isEqualToString:downloadPath])
    {
        return;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_downloadPath])
    {
        NSError *error;
        if (![fileManager createDirectoryAtPath:downloadPath
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:&error])
        {
            CCLOG(@"[PACKAGE/DOWNLOAD][ERROR] Setting installation path to %@ - %@", downloadPath, error);
            return;
        }
    }

    [self willChangeValueForKey:@"downloadPath"];
    _downloadPath = downloadPath;
    [self didChangeValueForKey:@"downloadPath"];
}

- (void)enqueuePackageForDownload:(CCPackage *)package
{
    if (package.status == CCPackageStatusDownloadPaused)
    {
        [self resumeDownloadOfPackage:package];
        return;
    }

    if ([self packageDownloadForPackage:package])
    {
        return;
    }

    if (!(package.status == CCPackageStatusDownloadFailed
          || package.status == CCPackageStatusInitial))
    {
        return;
    }

    NSString *fileName = [[package standardIdentifier] stringByAppendingPathExtension:@"zip"];

    CCPackageDownload *packageDownload = [[CCPackageDownload alloc] initWithPackage:package
                                                                           localURL:[NSURL fileURLWithPath:[_downloadPath stringByAppendingPathComponent:fileName]]];

    CCPackageInstallData *installData = [package installData];
    installData.localDownloadURL = [NSURL fileURLWithPath:[_downloadPath stringByAppendingPathComponent:fileName]];

    packageDownload.delegate = self;

    [_downloads addObject:packageDownload];

    CCLOGINFO(@"[PACKAGE/DOWNLOADS][INFO] Download enqueued of package %@.", package);

    [packageDownload start];
}

- (void)cancelDownloadOfPackage:(CCPackage *)package
{
    CCPackageDownload *packageDownload = [self packageDownloadForPackage:package];
    [_downloads removeObject:packageDownload];

    [packageDownload cancel];
}

- (CCPackageDownload *)packageDownloadForPackage:(CCPackage *)aPackage
{
    for (CCPackageDownload *download in _downloads)
    {
        if (download.package == aPackage)
        {
            return download;
        }
    }

    return nil;
}

- (void)pauseDownloadOfPackage:(CCPackage *)package
{
    CCLOGINFO(@"[PACKAGE/DOWNLOADS][INFO] Pausing download of package %@.", package);
    CCPackageDownload *packageDownload = [self packageDownloadForPackage:package];
    [packageDownload pause];
}

- (void)resumeDownloadOfPackage:(CCPackage *)package
{
    CCLOGINFO(@"[PACKAGE/DOWNLOADS][INFO] Resuming download of package %@.", package);
    CCPackageDownload *packageDownload = [self packageDownloadForPackage:package];
    [packageDownload resume];
}

- (void)pauseAllDownloads
{
    CCLOGINFO(@"[PACKAGE/DOWNLOADS][INFO] Pausing all downloads.");
    for (CCPackageDownload *download in _downloads)
    {
        [download pause];
    }
}

- (void)resumeAllDownloads
{
    CCLOGINFO(@"[PACKAGE/DOWNLOADS][INFO] Resuming all downloads.");
    for (CCPackageDownload *download in _downloads)
    {
        [download resume];
    }
}


#pragma mark - CCPackageDownloadDelegate

- (void)downloadFinished:(CCPackageDownload *)download
{
    [_downloads removeObject:download];

    [_delegate downloadFinishedOfPackage:download.package];
}

- (void)downloadFailed:(CCPackageDownload *)download error:(NSError *)error
{
    [_downloads removeObject:download];

    [download.package setValue:@(CCPackageStatusDownloadFailed) forKey:@"status"];

    [_delegate downloadFailedOfPackage:download.package error:error];
}

- (void)downlowdProgress:(CCPackageDownload *)download downloadedBytes:(NSUInteger)downloadedBytes totalBytes:(NSUInteger)totalBytes
{
    if ([_delegate respondsToSelector:@selector(downloadProgressOfPackage:downloadedBytes:totalBytes:)])
    {
        [_delegate downloadProgressOfPackage:download.package downloadedBytes:downloadedBytes totalBytes:totalBytes];
    }
}

- (BOOL)shouldResumeDownload:(CCPackageDownload *)download
{
    return _resumeDownloads;
}

- (BOOL)shouldOverwriteDownloadedFile:(CCPackageDownload *)download
{
    return _overwriteFinishedDownloads;
}

- (void)request:(NSMutableURLRequest *)request ofDownload:(CCPackageDownload *)download
{
    if ([_delegate respondsToSelector:@selector(request:ofPackage:)])
    {
        [_delegate request:request ofPackage:download.package];
    }
}

@end
