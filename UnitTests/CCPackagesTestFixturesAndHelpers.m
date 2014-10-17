#import "CCPackagesTestFixturesAndHelpers.h"
#import "CCPackageTypes.h"
#import "CCPackage.h"
#import "CCPackageCocos2dEnabler.h"
#import "CCPackage_private.h"
#import "CCFileUtils.h"


@implementation CCPackagesTestFixturesAndHelpers

+ (CCPackage *)testPackageInitial
{
    return [self testPackageWithStatus:CCPackageStatusInitial installFolderPath:nil];
}

+ (CCPackage *)testPackageWithStatus:(CCPackageStatus)status installFolderPath:(NSString *)installFolderPath
{
    NSString *pathToUnzippedPackage = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources-shared/Packages/testpackage-iOS-phonehd_unzipped/testpackage-iOS-phonehd"];
    NSString *pathToZippedPackage = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources-shared/Packages/testpackage-iOS-phonehd.zip"];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    CCPackage *package = [[CCPackage alloc] initWithName:@"testpackage"
                                              resolution:@"phonehd"
                                                      os:@"iOS"
                                               remoteURL:[[NSURL URLWithString:@"http://manager.test"]
                                                                 URLByAppendingPathComponent:@"testpackage-iOS-phonehd.zip"]];
    package.status = status;

    if (status == CCPackageStatusInstalledDisabled
        || status == CCPackageStatusInstalledEnabled)
    {
        package.installURL = [NSURL fileURLWithPath:[installFolderPath stringByAppendingPathComponent:@"testpackage-iOS-phonehd"]];

        [fileManager copyItemAtPath:pathToUnzippedPackage toPath:package.installURL.path error:nil];
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
        NSString *pathUnzipFolder = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Unzipped"];
        [fileManager createDirectoryAtPath:pathUnzipFolder withIntermediateDirectories:YES attributes:nil error:nil];

        package.unzipURL = [NSURL fileURLWithPath:[pathUnzipFolder stringByAppendingPathComponent:@"testpackage-iOS-phonehd"]];

        [fileManager copyItemAtPath:pathToUnzippedPackage toPath:package.unzipURL.path error:nil];
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
        if ([aSearchPath isEqualToString:URL.path])
        {
            return YES;
        }
    }
    return NO;
}

@end