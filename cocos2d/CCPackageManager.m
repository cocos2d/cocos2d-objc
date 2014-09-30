#import "CCPackageManager.h"
#import "CCPackage.h"
#import "CCPackageDownloadManager.h"
#import "CCPackageUnzipper.h"
#import "CCPackageInstaller.h"
#import "CCPackageManagerDelegate.h"
#import "CCPackageConstants.h"
#import "CCPackageCocos2dEnabler.h"
#import "ccMacros.h"
#import "CCPackageHelper.h"
#import "CCPackage_private.h"


@interface CCPackageManager()

@property (nonatomic, strong) NSMutableArray *packages;
@property (nonatomic, strong) NSMutableArray *unzipTasks;
@property (nonatomic, strong) CCPackageDownloadManager *downloadManager;
@property (nonatomic) BOOL initialized;

@end


@implementation CCPackageManager

+ (CCPackageManager *)sharedManager
{
    static CCPackageManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[CCPackageManager alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.initialized = NO;

        self.packages = [NSMutableArray array];
        self.unzipTasks = [NSMutableArray array];

        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        self.installedPackagesPath = [cachesPath stringByAppendingPathComponent:@"Packages"];

        self.downloadManager = [[CCPackageDownloadManager alloc] init];
        _downloadManager.delegate = self;
        _downloadManager.resumeDownloads = YES;

        self.unzippingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    }

    return self;
}

- (NSArray *)allPackages
{
    return _packages;
}

- (void)loadPackages
{
    if (_initialized)
    {
        return;
    }

    [self loadPackagesFromUserDefaults];

    [self enablePackages];

    [self resumePausedDownloads];

    [self restartUnzippingTasks];

    CCLOGINFO(@"[PACKAGES] Packages loaded (%u): %@", _packages.count, _packages);

    self.initialized = YES;
}

- (void)restartUnzippingTasks
{
    for (CCPackage *aPackage in _packages)
    {
        CCPackageUnzipper *unzipper = [self unzipperForPackage:aPackage];
        if (unzipper)
        {
            continue;
        }

        if (aPackage.status == CCPackageStatusUnzipped
            || aPackage.status == CCPackageStatusUnzipping)
        {
            [self unzipPackage:aPackage];
        }
    }
}

- (CCPackageUnzipper *)unzipperForPackage:(CCPackage *)aPackage
{
    for (CCPackageUnzipper *packageUnzipper in _unzipTasks)
    {
        if (packageUnzipper.package == aPackage)
        {
            return packageUnzipper;
        }
    }

    return nil;
}

- (void)resumePausedDownloads
{
    for (CCPackage *aPackage in _packages)
    {
        if (aPackage.status == CCPackageStatusDownloadPaused)
        {
            [_downloadManager enqueuePackageForDownload:aPackage];
        }
    }
}

- (void)loadPackagesFromUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *packages = [userDefaults objectForKey:PACKAGE_STORAGE_USERDEFAULTS_KEY];

    CCLOGINFO(@"[PACKAGE][INFO] Packages info loading from userdefaults...");
    for (NSDictionary *aPackageDict in packages)
    {
        CCPackage *aPackage = [[CCPackage alloc] initWithDictionary:aPackageDict];

/*      TODO
        CCPackageInstallData *installData = [[CCPackageInstallData alloc] initWithPackage:aPackage];
        [aPackage setInstallData:installData];
        [installData populateInstallDataWithDictionary:aPackageDict];
*/

        [_packages addObject:aPackage];
        CCLOGINFO(@"[PACKAGE][INFO] Package info added: %@: %@", [aPackage standardIdentifier], [aPackage statusToString]);
    }
}

- (void)enablePackages
{
    NSMutableArray *packagesToEnable = [NSMutableArray array];
    for (CCPackage *aPackage in _packages)
    {
        if (aPackage.status == CCPackageStatusInstalledEnabled)
        {
            [packagesToEnable addObject:aPackage];
        }
    }

    CCPackageCocos2dEnabler *packageCocos2dEnabler = [[CCPackageCocos2dEnabler alloc] init];
    [packageCocos2dEnabler enablePackages:packagesToEnable];
}

- (void)savePackages
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *packagesToSave = [NSMutableArray arrayWithCapacity:_packages.count];

    for (CCPackage *aPackage in _packages)
    {
        [packagesToSave addObject:[aPackage toDictionary]];
    }

    [userDefaults setObject:packagesToSave forKey:PACKAGE_STORAGE_USERDEFAULTS_KEY];
    [userDefaults synchronize];
}

- (void)setInstalledPackagesPath:(NSString *)installedPackagesPath
{
    if ([_installedPackagesPath isEqualToString:installedPackagesPath])
    {
        return;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_installedPackagesPath])
    {
        NSError *error;
        if (![fileManager createDirectoryAtPath:installedPackagesPath
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:&error])
        {
            CCLOGINFO(@"[PACKAGE][Error] Setting installation path to %@ - %@", installedPackagesPath, error);
            return;
        }
    }

    [self willChangeValueForKey:@"installedPackagesPath"];
    _installedPackagesPath = installedPackagesPath;
    [self didChangeValueForKey:@"installedPackagesPath"];
}

- (void)setUnzippingQueue:(dispatch_queue_t)unzippingQueue
{
    if (!unzippingQueue)
    {
        _unzippingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        return;
    }

    _unzippingQueue = unzippingQueue;
}

- (void)setResumeDownloads:(BOOL)resumeDownloads
{
    _downloadManager.resumeDownloads = resumeDownloads;
}

- (BOOL)resumeDownloads
{
    return _downloadManager.resumeDownloads;
}


#pragma mark - download

- (CCPackage *)downloadPackageWithName:(NSString *)name enableAfterDownload:(BOOL)enableAfterDownload
{
    return [self downloadPackageWithName:name
                              resolution:[CCPackageHelper defaultResolution]
                     enableAfterDownload:enableAfterDownload];
}

- (CCPackage *)downloadPackageWithName:(NSString *)name resolution:(NSString *)resolution enableAfterDownload:(BOOL)enableAfterDownload
{
    NSAssert(_baseURL != nil, @"baseURL must not be nil");

    NSString *packageName = [NSString stringWithFormat:@"%@-%@-%@.zip", name, [CCPackageHelper currentOS], resolution];
    NSURL *remoteURL = [_baseURL URLByAppendingPathComponent:packageName];

    return [self downloadPackageWithName:name resolution:resolution remoteURL:remoteURL enableAfterDownload:enableAfterDownload];
}

- (BOOL)downloadPackage:(CCPackage *)package enableAfterDownload:(BOOL)enableAfterDownload
{
    if (![_packages containsObject:package])
    {
        return NO;
    }

    NSAssert(package, @"package must not be nil");
    NSAssert(package.name, @"package.name must not be nil");
    NSAssert(package.resolution, @"package.resolution must not be nil");

    if (!package.remoteURL && !_baseURL)
    {
        return NO;
    }
    else if (!package.remoteURL)
    {
        NSString *packageName = [NSString stringWithFormat:@"%@-%@-%@.zip", package.name, package.os, package.resolution];
        NSURL *remoteURL = [_baseURL URLByAppendingPathComponent:packageName];
        [package setValue:remoteURL forKey:@"remoteURL"];
    }

    package.enableOnDownload = enableAfterDownload;

    CCLOGINFO(@"[PACKAGE][INFO]: adding package to download queue: %@", package);

    [_downloadManager enqueuePackageForDownload:package];

    return YES;
}

- (CCPackage *)downloadPackageWithName:(NSString *)name remoteURL:(NSURL *)remoteURL enableAfterDownload:(BOOL)enableAfterDownload
{
    return [self downloadPackageWithName:name
                              resolution:[CCPackageHelper defaultResolution]
                               remoteURL:remoteURL
                     enableAfterDownload:enableAfterDownload];
}

- (CCPackage *)downloadPackageWithName:(NSString *)name resolution:(NSString *)resolution remoteURL:(NSURL *)remoteURL enableAfterDownload:(BOOL)enableAfterDownload
{
    CCPackage *aPackage = [self packageWithName:name resolution:resolution];
    if (aPackage)
    {
        return aPackage;
    }

    CCPackage *package = [[CCPackage alloc] initWithName:name resolution:resolution remoteURL:remoteURL];
    package.enableOnDownload = enableAfterDownload;

    [_packages addObject:package];

    CCLOGINFO(@"[PACKAGE][INFO]: adding package to download queue: %@", package);

    [_downloadManager enqueuePackageForDownload:package];

    return package;
}

- (CCPackage *)packageWithName:(NSString *)name
{
    NSString *resolution = [CCPackageHelper defaultResolution];

    return [self packageWithName:name resolution:resolution];
}

- (CCPackage *)packageWithName:(NSString *)name resolution:(NSString *)resolution
{
    for (CCPackage *aPackage in _packages)
    {
        if ([aPackage.name isEqualToString:name]
            && [aPackage.resolution isEqualToString:resolution])
        {
            return aPackage;
        }
    }

    return nil;
}


#pragma mark - CCPackageDownloadManagerDelegate

- (void)downloadFinishedOfPackage:(CCPackage *)package
{
    [_delegate packageDownloadFinished:package];

    [self unzipPackage:package];
}

- (void)downloadFailedOfPackage:(CCPackage *)package error:(NSError *)error
{
    [_delegate packageDownloadFailed:package error:error];
}

- (void)downloadProgressOfPackage:(CCPackage *)package downloadedBytes:(NSUInteger)downloadedBytes totalBytes:(NSUInteger)totalBytes
{
    if ([_delegate respondsToSelector:@selector(packageDownloadProgress:downloadedBytes:totalBytes:)])
    {
        [_delegate packageDownloadProgress:package downloadedBytes:downloadedBytes totalBytes:totalBytes];
    }
}


#pragma mark - CCPackageUnzipperDelegate

- (void)unzipFinished:(CCPackageUnzipper *)packageUnzipper
{
    [self runOnMainQueue:^
    {
        [self removeDownloadFile:packageUnzipper.package];

        [_unzipTasks removeObject:packageUnzipper];

        [packageUnzipper.package setValue:@(CCPackageStatusUnzipped) forKey:@"status"];

        if ([_delegate respondsToSelector:@selector(packageUnzippingFinished:)])
        {
            [_delegate packageUnzippingFinished:packageUnzipper.package];
        }

        if (![self installPackage:packageUnzipper.package])
        {
            return;
        }

        [self tidyUpAfterInstallation:packageUnzipper.package];
    }];
}

- (void)unzipFailed:(CCPackageUnzipper *)packageUnzipper error:(NSError *)error
{
    [self runOnMainQueue:^
    {
        [_unzipTasks removeObject:packageUnzipper];

        [_delegate packageUnzippingFailed:packageUnzipper.package error:error];
    }];
}

- (void)unzipProgress:(CCPackageUnzipper *)packageUnzipper unzippedBytes:(NSUInteger)unzippedBytes totalBytes:(NSUInteger)totalBytes
{
    [self runOnMainQueue:^
    {
        if ([_delegate respondsToSelector:@selector(packageUnzippingProgress:unzippedBytes:totalBytes:)])
        {
            [_delegate packageUnzippingProgress:packageUnzipper.package unzippedBytes:unzippedBytes totalBytes:totalBytes];
        }
    }];
}


#pragma mark - Flow

- (void)tidyUpAfterInstallation:(CCPackage *)package
{
    [self removeUnzippedPackage:package];
}

- (void)unzipPackage:(CCPackage *)package
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:package.unzipURL.path])
    {
        NSError *error;
        CCLOGINFO(@"[PACKAGE/UNZIP][INFO] Removing incomplete unzipped archive: %@", installData.unzipURL.path);
        if ([fileManager removeItemAtURL:package.unzipURL error:&error])
        {
            CCLOG(@"[PACKAGE/UNZIP][ERROR] Removing incomplete unzipped archive: %@", error);
        }
    }

    // Note: This is done on purpose in case a zip contains more than the expected root package folder or something completely different which can lead to a mess
    // The content is checked later on after unzipping finishes
    package.unzipURL = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:PACKAGE_REL_UNZIP_FOLDER] stringByAppendingPathComponent:[package standardIdentifier]]];
    CCPackageUnzipper *packageUnzipper = [[CCPackageUnzipper alloc] initWithPackage:package];

    [_unzipTasks addObject:packageUnzipper];

    if ([_delegate respondsToSelector:@selector(passwordForPackageZipFile:)])
    {
        packageUnzipper.password = [_delegate passwordForPackageZipFile:package];
    }

    packageUnzipper.delegate = self;
    [packageUnzipper unpackPackageOnQueue:_unzippingQueue];
}

- (void)removeDownloadFile:(CCPackage *)package
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    if (![fileManager removeItemAtPath:package.localDownloadURL.path error:&error])
    {
        CCLOG(@"[PACKAGE][ERROR] Removing download file: %@", error);
    }
}

- (void)removeUnzippedPackage:(CCPackage *)package
{
    NSAssert(package.unzipURL, @"installData.unzipURL must not be nil");

    NSError *error;
    if (![[NSFileManager defaultManager] removeItemAtURL:package.unzipURL error:&error])
    {
        CCLOG(@"[PACKAGE][ERROR] removing unzipped package after successful installation: %@", error);
    }
}

- (BOOL)installPackage:(CCPackage *)package
{
    NSError *error;
    if (![self determinePackageFolderNameInUnzippedFile:package error:&error])
    {
        CCLOG(@"[PACKAGE][ERROR] Could not determine package folder name: %@", error);

        [_delegate packageInstallationFailed:package error:error];
        return NO;
    }

    CCPackageInstaller *packageInstaller = [[CCPackageInstaller alloc] initWithPackage:package installPath:_installedPackagesPath];

    if (![packageInstaller installWithError:&error])
    {
        CCLOG(@"[PACKAGE][ERROR] Installation failed: %@", error);

        [package setValue:@(CCPackageStatusInstallationFailed) forKey:NSStringFromSelector(@selector(status))];
        [_delegate packageInstallationFailed:package error:error];
        return NO;
    }

    if (package.enableOnDownload)
    {
        CCPackageCocos2dEnabler *packageCocos2dEnabler = [[CCPackageCocos2dEnabler alloc] init];
        [packageCocos2dEnabler enablePackages:@[package]];
    }

    CCLOGINFO(@"[PACKAGE/INSTALL][INFO] Installation of package successful! Package enabled: %d", [package installData].enableOnDownload);

    [_delegate packageInstallationFinished:package];
    return YES;
}

- (BOOL)determinePackageFolderNameInUnzippedFile:(CCPackage *)package error:(NSError **)error
{
    NSAssert(package.unzipURL, @"installData.unzipURL must not be nil");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtURL:package.unzipURL
                                includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLNameKey]
                                                   options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                     error:nil];

    if ([files count] == 0)
    {
        [self setPackageEmptyError:error package:package];
        return NO;
    }

    if ([self searchForStandardFolderNameFiles:files package:package])
    {
        return YES;
    }

    if ([self askDelegateForCustomFolderName:package files:files])
    {
        return YES;
    }

    [self setPackageFolderNameUndefinedError:error package:package];

    return NO;
}

- (void)setPackageFolderNameUndefinedError:(NSError **)error package:(CCPackage *)package
{
    if (error)
    {
        *error = [NSError errorWithDomain:@"cocos2d"
                                     code:PACKAGE_ERROR_INSTALL_PACKAGE_FOLDER_NAME_NOT_FOUND
                                 userInfo:
                                         @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The package folder name could not be determined. "
                                                                                                  "Check delegate method customFolderName:packageContents:."],
                                         @"package" : package}];
    }
}

- (void)setPackageEmptyError:(NSError **)error package:(CCPackage *)package
{
    NSAssert(package.unzipURL, @"installData.unzipURL must not be nil");

    if (error)
    {
        *error = [NSError errorWithDomain:@"cocos2d"
                                     code:PACKAGE_ERROR_INSTALL_PACKAGE_EMPTY
                                 userInfo:
                                         @{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"The zip file is empty: \"%@\"", package.unzipURL],
                                         @"package" : package}];
    }
}

- (BOOL)askDelegateForCustomFolderName:(CCPackage *)package files:(NSArray *)files
{
    NSAssert(package.unzipURL, @"installData.unzipURL must not be nil");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([_delegate respondsToSelector:@selector(customFolderName:packageContents:)])
    {
        NSString *customFolderNameToUse = [_delegate customFolderName:package packageContents:files];
        if ([fileManager fileExistsAtPath:[package.unzipURL.path stringByAppendingPathComponent:customFolderNameToUse]])
        {
            package.folderName = customFolderNameToUse;
            return YES;
        }
    }
    return NO;
}

- (BOOL)searchForStandardFolderNameFiles:(NSArray *)files package:(CCPackage *)package
{
    for (NSURL *fileURL in files)
    {
        NSDictionary *resourceValues = [fileURL resourceValuesForKeys:@[NSURLIsDirectoryKey, NSURLNameKey] error:nil];
        NSString *name = resourceValues[NSURLNameKey];
        BOOL isDir = [resourceValues[NSURLIsDirectoryKey] boolValue];

        if (isDir && [name isEqualToString:[package standardIdentifier]])
        {
            package.folderName = [package standardIdentifier];
            return YES;
        }
    }
    return NO;
}

- (BOOL)disablePackage:(CCPackage *)package error:(NSError **)error
{
    if (package.status == CCPackageStatusInstalledDisabled)
    {
        return YES;
    }

    if (package.status != CCPackageStatusInstalledEnabled)
    {
        if (error)
        {
            *error = [NSError errorWithDomain:@"com.cocos2d"
                                         code:PACKAGE_ERROR_MANAGER_CANNOT_DISABLE_NON_ENABLED_PACKAGE
                                     userInfo:@{NSLocalizedDescriptionKey: @"Error disabling package. Only packages with status CCPackageStatusInstalledEnabled can be disabled."}];
        }
        return NO;
    }

    CCPackageCocos2dEnabler *packageCocos2dEnabler = [[CCPackageCocos2dEnabler alloc] init];
    [packageCocos2dEnabler disablePackages:@[package]];

    if (![_packages containsObject:package])
    {
        [_packages addObject:package];
    }
    return YES;
}

- (BOOL)enablePackage:(CCPackage *)package error:(NSError **)error
{
    if (package.status == CCPackageStatusInstalledEnabled)
    {
        return YES;
    }

    if (package.status != CCPackageStatusInstalledDisabled)
    {
        if (error)
        {
            *error = [NSError errorWithDomain:@"com.cocos2d"
                                         code:PACKAGE_ERROR_MANAGER_CANNOT_ENABLE_NON_DISABLED_PACKAGE
                                     userInfo:@{NSLocalizedDescriptionKey: @"Error enabling package. Only packages with status CCPackageStatusInstalledDisabled can be enabled."}];
        }
        return NO;
    }

    CCPackageCocos2dEnabler *packageCocos2dEnabler = [[CCPackageCocos2dEnabler alloc] init];
    [packageCocos2dEnabler enablePackages:@[package]];

    if (![_packages containsObject:package])
    {
        [_packages addObject:package];
    }
    return YES;
}

- (void)addPackage:(CCPackage *)package;
{
    NSAssert(package, @"package must not be nil");
    NSAssert(package.status == CCPackageStatusInitial, @"package status must be CCPackageStatusInitial");

    if ([_packages containsObject:package]
        || [self packageWithName:package.name resolution:package.resolution])
    {
        return;
    }

    [_packages addObject:package];
}

- (BOOL)deletePackage:(CCPackage *)package error:(NSError **)error
{
    CCPackageCocos2dEnabler *packageCocos2dEnabler = [[CCPackageCocos2dEnabler alloc] init];
    [packageCocos2dEnabler disablePackages:@[package]];

    [_packages removeObject:package];
    [self savePackages];

    [_downloadManager cancelDownloadOfPackage:package];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (package.unzipURL
        && [fileManager fileExistsAtPath:package.unzipURL.path]
        && (![fileManager removeItemAtURL:package.unzipURL error:error]))
    {
        return NO;
    }

    BOOL result = ([fileManager fileExistsAtPath:package.installURL.path]
                   && [fileManager removeItemAtURL:package.installURL error:error]);

    if (result)
    {
        CCLOGINFO(@"[PACKAGE/INSTALL][INFO] Package deletion successful!");
    }
    else
    {
        CCLOG(@"[PACKAGE/INSTALL][ERROR] Package deletion failed: %@", *error);
    }

    return result;
}

- (void)cancelDownloadOfPackage:(CCPackage *)package
{
    if (!(package.status == CCPackageStatusDownloadPaused
          || package.status == CCPackageStatusDownloading
          || package.status == CCPackageStatusDownloaded
          || package.status == CCPackageStatusDownloadFailed))
    {
        return;
    }

    [_packages removeObject:package];

    [_downloadManager cancelDownloadOfPackage:package];

    [self savePackages];
}

- (void)pauseDownloadOfPackage:(CCPackage *)package
{
    [_downloadManager pauseDownloadOfPackage:package];
}

- (void)resumeDownloadOfPackage:(CCPackage *)package
{
    [_downloadManager resumeDownloadOfPackage:package];
}

- (void)pauseAllDownloads
{
    [_downloadManager pauseAllDownloads];
}

- (void)resumeAllDownloads
{
    [_downloadManager resumeAllDownloads];
}

- (void)request:(NSMutableURLRequest *)request ofPackage:(CCPackage *)package
{
    if ([_delegate respondsToSelector:@selector(request:ofPackage:)])
    {
        [_delegate request:request ofPackage:package];
    }
}

- (void)runOnMainQueue:(dispatch_block_t)block
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
