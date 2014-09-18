#import <objc/runtime.h>
#import "CCPackage+InstallData.h"
#import "CCPackageInstallData.h"

NSString *const PACKAGE_SERIALIZATION_KEY_LOCAL_DOWNLOAD_URL = @"localDownloadURL";
NSString *const PACKAGE_SERIALIZATION_KEY_LOCAL_UNZIP_URL = @"localUnzipURL";
NSString *const PACKAGE_SERIALIZATION_KEY_FOLDER_NAME = @"folderName";
NSString *const PACKAGE_SERIALIZATION_KEY_ENABLE_ON_DOWNLOAD = @"enableOnDownload";

char *const KEY_INSTALL_DATA = "installData";


@implementation CCPackage (InstallData)

- (CCPackageInstallData *)installData
{
    CCPackageInstallData *result = objc_getAssociatedObject(self, KEY_INSTALL_DATA);

    return result;
}

- (void)populateInstallDataWithDictionary:(NSDictionary *)dictionary
{
    CCPackageInstallData *installData = [self installData];
    NSAssert(installData != nil, @"Install data must not be nil");

    if (dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_DOWNLOAD_URL])
    {
        installData.localDownloadURL = [NSURL URLWithString:dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_DOWNLOAD_URL]];
    }

    if (dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_UNZIP_URL])
    {
        installData.unzipURL = [NSURL URLWithString:dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_UNZIP_URL]];
    }

    if (dictionary[PACKAGE_SERIALIZATION_KEY_FOLDER_NAME])
    {
        installData.folderName = dictionary[PACKAGE_SERIALIZATION_KEY_FOLDER_NAME];
    }

    if (dictionary[PACKAGE_SERIALIZATION_KEY_FOLDER_NAME])
    {
        installData.enableOnDownload = [dictionary[PACKAGE_SERIALIZATION_KEY_ENABLE_ON_DOWNLOAD] boolValue];
    }
}

- (void)setInstallData:(CCPackageInstallData *)installData
{
    if (!installData)
    {
        return;
    }

    objc_setAssociatedObject(self, KEY_INSTALL_DATA, installData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)removeInstallData
{
    objc_setAssociatedObject(self, KEY_INSTALL_DATA, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)writeInstallDataToDictionary:(NSMutableDictionary *)dictionary
{
    CCPackageInstallData *installData = [self installData];

    if (installData.localDownloadURL)
    {
        dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_DOWNLOAD_URL] = [installData.localDownloadURL absoluteString];
    }

    if (installData.unzipURL)
    {
        dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_UNZIP_URL] = [installData.unzipURL absoluteString];
    }

    if (installData.folderName)
    {
        dictionary[PACKAGE_SERIALIZATION_KEY_FOLDER_NAME] = installData.folderName;
    }

    dictionary[PACKAGE_SERIALIZATION_KEY_ENABLE_ON_DOWNLOAD] = @(installData.enableOnDownload);
}

@end
