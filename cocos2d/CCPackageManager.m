#import "CCPackageManager.h"
#import "CCPackage.h"
#import "CCPackageDownloadManager.h"
#import "CCPackageUnzipper.h"
#import "CCPackageInstaller.h"
#import "CCPackageManagerDelegate.h"
#import "CCPackageConstants.h"
#import "CCPackageInstallData.h"
#import "CCPackage+InstallData.h"
#import "CCPackageCocos2dEnabler.h"
#import "ccMacros.h"
#import "CCPackageHelper.h"


@interface CCPackageManager()

@property (nonatomic, strong) NSMutableArray *packages;
@property (nonatomic, strong) NSMutableArray *unzipTasks;
@property (nonatomic, strong) CCPackageDownloadManager *downloadManager;

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
        self.packages = [NSMutableArray array];
        self.unzipTasks = [NSMutableArray array];

        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        self.installedPackagesPath = [cachesPath stringByAppendingPathComponent:@"Packages"];

        self.downloadManager = [[CCPackageDownloadManager alloc] init];
        _downloadManager.delegate = self;

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
    [self loadPackagesFromUserDefaults];

    [self enablePackages];

    [self enqueuePausedDownloads];

    [self restartUnzippingTasks];
}

- (void)restartUnzippingTasks
{
    for (CCPackage *aPackage in _packages)
    {
        if (aPackage.status == CCPackageStatusUnzipped
            || aPackage.status == CCPackageStatusUnzipping)
        {
            [self unzipPackage:aPackage];
        }
    }
}

- (void)enqueuePausedDownloads
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

- (void)storePackagesAndPauseDownloads
{
    CCLOGINFO(@"[PACKAGE][INFO] Packages info saved to userdefaults.");

    [_downloadManager pauseAllDownloads];

    [self savePackages];
}

- (void)savePackages
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *packagesToSave = [NSMutableArray arrayWithCapacity:_packages.count];

    for (CCPackage *aPackage in _packages)
    {
        NSDictionary *packageDict = [aPackage toDictionary];
        if (packageDict)
        {
            [packagesToSave addObject:packageDict];
        }
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


#pragma mark - download

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

    [self attachNewInstallDataToPackage:package enableAfterDownload:enableAfterDownload];

    CCLOGINFO(@"[PACKAGE][INFO]: adding package to download queue: %@", package);

    [_downloadManager enqueuePackageForDownload:package];

    return YES;
}

- (CCPackage *)downloadPackageWithName:(NSString *)name resolution:(NSString *)resolution remoteURL:(NSURL *)remoteURL enableAfterDownload:(BOOL)enableAfterDownload
{
    CCPackage *aPackage = [self packageWithName:name resolution:resolution];
    if (aPackage)
    {
        return aPackage;
    }

    CCPackage *package = [[CCPackage alloc] initWithName:name resolution:resolution remoteURL:remoteURL];
    [self attachNewInstallDataToPackage:package enableAfterDownload:enableAfterDownload];

    [_packages addObject:package];

    CCLOGINFO(@"[PACKAGE][INFO]: adding package to download queue: %@", package);

    [_downloadManager enqueuePackageForDownload:package];

    return package;
}

- (void)attachNewInstallDataToPackage:(CCPackage *)package enableAfterDownload:(BOOL)enableAfterDownload
{
    CCPackageInstallData *installData = [[CCPackageInstallData alloc] initWithPackage:package];
    installData.enableOnDownload = enableAfterDownload;
    [package setInstallData:installData];
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

    [package removeInstallData];
}

- (void)unzipPackage:(CCPackage *)package
{
    CCPackageInstallData *installData = [package installData];
    NSAssert(installData, @"installData must not be nil");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:installData.unzipURL.path])
    {
        NSError *error;
        CCLOGINFO(@"[PACKAGE/UNZIP][INFO] Removing incomplete unzipped archive: %@", installData.unzipURL.path);
        if ([fileManager removeItemAtURL:installData.unzipURL error:&error])
        {
            CCLOG(@"[PACKAGE/UNZIP][ERROR] Removing incomplete unzipped archive: %@", error);
        }
    }

    // Note: This is done on purpose in case a zip contains more than the expected root package folder or something completely different which can lead to a mess
    // The content is checked later on after unzipping finishes
    installData.unzipURL = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:PACKAGE_REL_UNZIP_FOLDER] stringByAppendingPathComponent:[package standardIdentifier]]];
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
    CCPackageInstallData *installData = [package installData];
    if (![fileManager removeItemAtPath:[installData localDownloadURL].path error:&error])
    {
        CCLOG(@"[PACKAGE][ERROR] Removing download file: %@", error);
    }
}

- (void)removeUnzippedPackage:(CCPackage *)package
{
    CCPackageInstallData *installData = [package installData];
    NSAssert(installData.unzipURL, @"installData.unzipURL must not be nil");

    NSError *error;
    if (![[NSFileManager defaultManager] removeItemAtURL:installData.unzipURL error:&error])
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

    CCLOGINFO(@"[PACKAGE/INSTALL][INFO] Installation of package successful! Package enabled: %d", [package installData].enableOnDownload);

    [_delegate packageInstallationFinished:package];
    return YES;
}

- (BOOL)determinePackageFolderNameInUnzippedFile:(CCPackage *)package error:(NSError **)error
{
    CCPackageInstallData *installData = [package installData];
    NSAssert(installData.unzipURL, @"installData.unzipURL must not be nil");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtURL:installData.unzipURL
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
    CCPackageInstallData *installData = [package installData];
    NSAssert(installData.unzipURL, @"installData.unzipURL must not be nil");

    if (error)
    {
        *error = [NSError errorWithDomain:@"cocos2d"
                                     code:PACKAGE_ERROR_INSTALL_PACKAGE_EMPTY
                                 userInfo:
                                         @{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"The zip file is empty: \"%@\"", installData.unzipURL],
                                         @"package" : package}];
    }
}

- (BOOL)askDelegateForCustomFolderName:(CCPackage *)package files:(NSArray *)files
{
    CCPackageInstallData *installData = [package installData];
    NSAssert(installData.unzipURL, @"installData.unzipURL must not be nil");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([_delegate respondsToSelector:@selector(customFolderName:packageContents:)])
    {
        NSString *customFolderNameToUse = [_delegate customFolderName:package packageContents:files];
        if ([fileManager fileExistsAtPath:[installData.unzipURL.path stringByAppendingPathComponent:customFolderNameToUse]])
        {
            installData.folderName = customFolderNameToUse;
            return YES;
        }
    }
    return NO;
}

- (BOOL)searchForStandardFolderNameFiles:(NSArray *)files package:(CCPackage *)package
{
    CCPackageInstallData *installData = [package installData];
    NSAssert(installData != nil, @"installData must not be nil");

    for (NSURL *fileURL in files)
    {
        NSDictionary *resourceValues = [fileURL resourceValuesForKeys:@[NSURLIsDirectoryKey, NSURLNameKey] error:nil];
        NSString *name = resourceValues[NSURLNameKey];
        BOOL isDir = [resourceValues[NSURLIsDirectoryKey] boolValue];

        if (isDir && [name isEqualToString:[package standardIdentifier]])
        {
            installData.folderName = [package standardIdentifier];
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

    [package setValue:@(CCPackageStatusInstalledDisabled) forKey:@"status"];

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

    [package setValue:@(CCPackageStatusInstalledEnabled) forKey:@"status"];

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
    CCPackageInstallData *installData = [package installData];
    if (installData.unzipURL
        && [fileManager fileExistsAtPath:installData.unzipURL.path]
        && (![fileManager removeItemAtURL:installData.unzipURL error:error]))
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
