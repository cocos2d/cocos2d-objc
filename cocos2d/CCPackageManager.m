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
#import "CCDirector.h"


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

        self.installRelPath = @"Packages";

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

    CCLOGINFO(@"[PACKAGES] Packages loaded (%lu): %@", _packages.count, _packages);

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

        if (aPackage.status == CCPackageStatusDownloaded
            || aPackage.status == CCPackageStatusUnzipped
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

- (void)savePackagesForceWriteToDefaults:(BOOL)forceWrite
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *packagesToSave = [NSMutableArray arrayWithCapacity:_packages.count];

    for (CCPackage *aPackage in _packages)
    {
        [packagesToSave addObject:[aPackage toDictionary]];
    }

    [userDefaults setObject:packagesToSave forKey:PACKAGE_STORAGE_USERDEFAULTS_KEY];

    if (forceWrite)
    {
        [userDefaults synchronize];
    }
}

- (void)savePackages
{
    [self savePackagesForceWriteToDefaults:YES];
}

- (void)setInstallRelPath:(NSString *)newInstallRelPath
{
    if ([_installRelPath isEqualToString:newInstallRelPath]
        || !newInstallRelPath
        || [newInstallRelPath length] == 0
        || ![[newInstallRelPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length])
    {
        return;
    }

    NSString *fullPath = [[CCPackageHelper cachesFolder] stringByAppendingPathComponent:newInstallRelPath];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fullPath])
    {
        NSError *error;
        if (![fileManager createDirectoryAtPath:fullPath
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:&error])
        {
            CCLOGINFO(@"[PACKAGE][Error] Setting installation path to %@ - %@", fullPath, error);
            return;
        }
    }

    [self willChangeValueForKey:@"installRelPath"];
    _installRelPath = [newInstallRelPath copy];
    [self didChangeValueForKey:@"installRelPath"];
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
    NSString *packageName = [NSString stringWithFormat:@"%@-%@-%@.zip", name, [CCPackageHelper currentOS], resolution];
    NSURL *remoteURL = [_baseURL URLByAppendingPathComponent:packageName];

    if (!_baseURL)
    {
        [_delegate packageDownloadFailed:nil error:[NSError errorWithDomain:@"cocos2d"
                                                                       code:PACKAGE_ERROR_MANAGER_NO_BASE_URL_SET
                                                                   userInfo:@{NSLocalizedDescriptionKey: @"No baseURL set for package manager."}]];
        return nil;
    }

    return [self downloadPackageWithName:name resolution:resolution os:[CCPackageHelper currentOS] remoteURL:remoteURL enableAfterDownload:enableAfterDownload];
}

- (void)downloadPackage:(CCPackage *)package enableAfterDownload:(BOOL)enableAfterDownload
{
    NSAssert(package, @"package must not be nil");
    NSAssert(package.name, @"package.name must not be nil");
    NSAssert(package.resolution, @"package.resolution must not be nil");
    NSAssert(package.os, @"package.os must not be nil");
    NSAssert(package.remoteURL, @"package.remoteURL must not be nil");

    if (![_packages containsObject:package])
    {
        [self addPackage:package];
    }

    package.enableOnDownload = enableAfterDownload;

    CCLOGINFO(@"[PACKAGE][INFO]: adding package to download queue: %@", package);

    [_downloadManager enqueuePackageForDownload:package];
}

- (CCPackage *)downloadPackageWithName:(NSString *)name resolution:(NSString *)resolution os:(NSString *)os remoteURL:(NSURL *)remoteURL enableAfterDownload:(BOOL)enableAfterDownload
{
    CCPackage *aPackage = [self packageWithName:name resolution:resolution];
    if (aPackage)
    {
        return aPackage;
    }

    CCPackage *package = [[CCPackage alloc] initWithName:name
                                              resolution:resolution
                                                      os:os
                                               remoteURL:remoteURL];

    package.enableOnDownload = enableAfterDownload;

    [_packages addObject:package];

    CCLOGINFO(@"[PACKAGE][INFO]: adding package to download queue: %@", package);

    [_downloadManager enqueuePackageForDownload:package];

    [self savePackagesForceWriteToDefaults:NO];

    return package;
}

- (CCPackage *)packageWithName:(NSString *)name
{
    NSString *resolution = [CCPackageHelper defaultResolution];
    NSString *os = [CCPackageHelper currentOS];

    return [self packageWithName:name resolution:resolution os:os];
}

- (CCPackage *)packageWithName:(NSString *)name resolution:(NSString *)resolution
{
    NSString *os = [CCPackageHelper currentOS];
    return [self packageWithName:name resolution:resolution os:os];
}

- (CCPackage *)packageWithName:(NSString *)name resolution:(NSString *)resolution os:(NSString *)os
{
    for (CCPackage *aPackage in _packages)
    {
        if ([aPackage.name isEqualToString:name]
            && [aPackage.resolution isEqualToString:resolution]
            && [aPackage.os isEqualToString:os])
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

    [self savePackagesForceWriteToDefaults:NO];

    [self unzipPackage:package];
}

- (void)downloadFailedOfPackage:(CCPackage *)package error:(NSError *)error
{
    [_delegate packageDownloadFailed:package error:error];

    [self savePackagesForceWriteToDefaults:NO];
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
    [self runOnCocosThread:^
    {
        [self removeDownloadFile:packageUnzipper.package];

        [_unzipTasks removeObject:packageUnzipper];

        [packageUnzipper.package setValue:@(CCPackageStatusUnzipped) forKey:@"status"];

        if ([_delegate respondsToSelector:@selector(packageUnzippingFinished:)])
        {
            [_delegate packageUnzippingFinished:packageUnzipper.package];
        }

        [self savePackagesForceWriteToDefaults:NO];

        if (![self installPackage:packageUnzipper.package])
        {
            return;
        }

        [self tidyUpAfterInstallation:packageUnzipper.package];
    }];
}

- (void)unzipFailed:(CCPackageUnzipper *)packageUnzipper error:(NSError *)error
{
    [self runOnCocosThread:^
    {
        [_unzipTasks removeObject:packageUnzipper];

        [_delegate packageUnzippingFailed:packageUnzipper.package error:error];

        [self savePackagesForceWriteToDefaults:NO];
    }];
}

- (void)unzipProgress:(CCPackageUnzipper *)packageUnzipper unzippedBytes:(NSUInteger)unzippedBytes totalBytes:(NSUInteger)totalBytes
{
    [self runOnCocosThread:^
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
        CCLOGINFO(@"[PACKAGE/UNZIP][INFO] Removing incomplete unzipped archive: %@", package.unzipURL.path);
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
    NSAssert(package.unzipURL, @"package.unzipURL must not be nil");

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

    CCPackageInstaller *packageInstaller = [[CCPackageInstaller alloc] initWithPackage:package installRelPath:_installRelPath];

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

    CCLOGINFO(@"[PACKAGE/INSTALL][INFO] Installation of package successful! Package enabled: %d", package.enableOnDownload);

    [_delegate packageInstallationFinished:package];

    [self savePackagesForceWriteToDefaults:YES];

    return YES;
}

- (BOOL)determinePackageFolderNameInUnzippedFile:(CCPackage *)package error:(NSError **)error
{
    NSAssert(package.unzipURL, @"package.unzipURL must not be nil");

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

- (BOOL)setPackageFolderNameUndefinedError:(NSError **)error package:(CCPackage *)package
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
    return (error == nil);
}

- (BOOL)setPackageEmptyError:(NSError **)error package:(CCPackage *)package
{
    NSAssert(package.unzipURL, @"package.unzipURL must not be nil");

    if (error)
    {
        *error = [NSError errorWithDomain:@"cocos2d"
                                     code:PACKAGE_ERROR_INSTALL_PACKAGE_EMPTY
                                 userInfo:
                                         @{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"The zip file is empty: \"%@\"", package.unzipURL],
                                         @"package" : package}];
    }
    return (error == nil);
}

- (BOOL)askDelegateForCustomFolderName:(CCPackage *)package files:(NSArray *)files
{
    NSAssert(package.unzipURL, @"package.unzipURL must not be nil");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([_delegate respondsToSelector:@selector(customFolderName:packageContents:)])
    {
        NSString *customFolderNameToUse = [_delegate customFolderName:package packageContents:files];
        if (!customFolderNameToUse)
        {
            return NO;
        }

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
    if (![_packages containsObject:package])
    {
        [_packages addObject:package];
    }

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

    [self savePackagesForceWriteToDefaults:YES];

    return YES;
}

- (BOOL)enablePackage:(CCPackage *)package error:(NSError **)error
{
    if (![_packages containsObject:package])
    {
        [_packages addObject:package];
    }

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

    [self savePackagesForceWriteToDefaults:YES];

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

    [self savePackagesForceWriteToDefaults:NO];
}

- (BOOL)deletePackage:(CCPackage *)package error:(NSError **)error
{
    BOOL result = YES;
    if (package.status == CCPackageStatusUnzipping)
    {
        if (error)
        {
            *error = [NSError errorWithDomain:@"cocos2d"
                                         code:PACKAGE_ERROR_MANAGER_CANNOT_DELETE_UNZIPPING_PACKAGE
                                     userInfo:@{NSLocalizedDescriptionKey:@"Cannot delete a package being unzipped. Please try after unzipping finished"}];
        }
        return NO;
    }

    CCPackageCocos2dEnabler *packageCocos2dEnabler = [[CCPackageCocos2dEnabler alloc] init];
    [packageCocos2dEnabler disablePackages:@[package]];

    [_packages removeObject:package];

    [_downloadManager cancelDownloadOfPackage:package];

    if (![self deleteURLSelector:@selector(localDownloadURL) ofPackage:package error:error])
    {
        result = NO;
    }

    if (![self deleteURLSelector:@selector(unzipURL) ofPackage:package error:error])
    {
        result = NO;
    }

    if (![self deleteURLSelector:@selector(installRelURL) ofPackage:package error:error])
    {
        result = NO;
    }

    if (result)
    {
        package.localDownloadURL = nil;
        package.unzipURL = nil;
        package.installRelURL = nil;
        package.status = CCPackageStatusDeleted;

        CCLOGINFO(@"[PACKAGE/INSTALL][INFO] Package deletion successful!");

        [self savePackagesForceWriteToDefaults:YES];
    }
    else
    {
        CCLOG(@"[PACKAGE/INSTALL][ERROR] Package deletion failed: %@", *error);
    }

    return result;
}

- (BOOL)deleteURLSelector:(SEL)urlSelector ofPackage:(CCPackage *)aPackage error:(NSError **)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSURL *url = [aPackage valueForKey:NSStringFromSelector(urlSelector)];

    BOOL result = YES;
    if (url && [fileManager fileExistsAtPath:url.path])
    {
        result = [fileManager removeItemAtURL:url error:error];
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

    [_downloadManager cancelDownloadOfPackage:package];
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

- (void)runOnCocosThread:(dispatch_block_t)block
{
    if ([[NSThread currentThread] isEqual:[[CCDirector sharedDirector] runningThread]])
    {
        block();
    }
    else
    {
        [self performSelector:_cmd onThread:[[CCDirector sharedDirector] runningThread] withObject:block waitUntilDone:YES];
    }
}

@end
