#import "CCPackagesTestFixturesAndHelpers.h"
#import "CCPackageTypes.h"
#import "CCPackage.h"
#import "CCPackageCocos2dEnabler.h"
#import "CCPackage_private.h"
#import "CCFileUtils.h"
#import "CCPackageHelper.h"


@implementation CCPackagesTestFixturesAndHelpers

+ (void)cleanCachesFolder
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *array = [fileManager contentsOfDirectoryAtPath:[CCPackageHelper cachesFolder] error:nil];
    for (NSString *filename in array)
    {
        NSString *filePath = [[CCPackageHelper cachesFolder] stringByAppendingPathComponent:filename];
        if (![fileManager removeItemAtPath:filePath error:&error] && error.code != 4)
        {
            NSLog(@"ERROR: tearDown remove packages install folder %@", error);
        }
    }
}

+ (void)cleanTempFolder
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *array = [fileManager contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];
    for (NSString *filename in array)
    {
        NSString *filePath = [[CCPackageHelper cachesFolder] stringByAppendingPathComponent:filename];
        if (![fileManager removeItemAtPath:filePath error:&error] && error.code != 4)
        {
            NSLog(@"ERROR: tearDown remove packages install folder %@", error);
        }
    }
}

+ (CCPackage *)testPackageInitial
{
    return [self testPackageWithStatus:CCPackageStatusInitial installRelPath:nil];
}

+ (CCPackage *)testPackageWithStatus:(CCPackageStatus)status installRelPath:(NSString *)installFolderPath
{
    NSString *pathToUnzippedPackage = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources-shared/Packages/testpackage-iOS-phonehd_unzipped/testpackage-iOS-phonehd"];
    NSString *pathToZippedPackage = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources-shared/Packages/testpackage-iOS-phonehd.zip"];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    [fileManager createDirectoryAtPath:[[CCPackageHelper cachesFolder] stringByAppendingPathComponent:installFolderPath]
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];

    CCPackage *package = [[CCPackage alloc] initWithName:@"testpackage"
                                              resolution:@"phonehd"
                                                      os:@"iOS"
                                               remoteURL:[[NSURL URLWithString:@"http://manager.test"]
                                                                 URLByAppendingPathComponent:@"testpackage-iOS-phonehd.zip"]];
    package.status = status;

    if (status == CCPackageStatusInstalledDisabled
        || status == CCPackageStatusInstalledEnabled)
    {
        package.installRelURL = [NSURL URLWithString:[installFolderPath stringByAppendingPathComponent:@"testpackage-iOS-phonehd"]];

        [fileManager createDirectoryAtPath:package.installRelURL.path withIntermediateDirectories:YES attributes:nil error:nil];

        [fileManager copyItemAtPath:pathToUnzippedPackage toPath:package.installFullURL.path error:nil];
    }

    if (status == CCPackageStatusInstalledEnabled)
    {
        CCPackageCocos2dEnabler *packageEnabler = [[CCPackageCocos2dEnabler alloc] init];
        [packageEnabler enablePackages:@[package]];
    }

    if (status == CCPackageStatusDownloaded)
    {
        NSString *pathDownloadFolder = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Downloads"];
        [fileManager createDirectoryAtPath:pathDownloadFolder withIntermediateDirectories:YES attributes:nil error:nil];

        package.localDownloadURL = [NSURL fileURLWithPath:[pathDownloadFolder stringByAppendingPathComponent:@"testpackage-iOS-phonehd.zip"]];

        [fileManager copyItemAtPath:pathToZippedPackage toPath:package.localDownloadURL.path error:nil];
    }

    if (status == CCPackageStatusUnzipped)
    {
        package.folderName = @"testpackage-iOS-phonehd";

        NSString *pathToUnzippedPackageContents = [pathToUnzippedPackage stringByDeletingLastPathComponent];
        NSString *unzipPath = [NSTemporaryDirectory() stringByAppendingPathComponent:package.folderName];

        NSError *error;
        [fileManager removeItemAtPath:unzipPath error:nil];
        if (![fileManager copyItemAtPath:pathToUnzippedPackageContents toPath:unzipPath error:&error])
        {
            NSLog(@"%@", error);
        }

        package.unzipURL = [NSURL fileURLWithPath:unzipPath];

        package.enableOnDownload = NO;
    }

    return package;
}

+ (void)waitForCondition:(WaitConditionBlock)waitConditionBlock
{
    while (waitConditionBlock())
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

+ (BOOL)isURLInCocos2dSearchPath:(NSURL *)URL
{
    for (NSString *aSearchPath in [CCFileUtils sharedFileUtils].searchPath)
    {
        NSString *fullPath = [[CCPackageHelper cachesFolder] stringByAppendingPathComponent:URL.path];
        if ([aSearchPath isEqualToString:fullPath])
        {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isPackageInSearchPath:(CCPackage *)package
{
    for (NSString *aSearchPath in [CCFileUtils sharedFileUtils].searchPath)
    {
        if ([aSearchPath isEqualToString:package.installFullURL.path])
        {
            return YES;
        }
    }
    return NO;
}

@end
