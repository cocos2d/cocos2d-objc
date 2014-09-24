#import <objc/runtime.h>
#import "CCPackage+InstallData.h"
#import "CCPackageInstallData.h"

static NSString *const PACKAGE_SERIALIZATION_KEY_LOCAL_DOWNLOAD_URL = @"localDownloadURL";
static NSString *const PACKAGE_SERIALIZATION_KEY_LOCAL_UNZIP_URL = @"localUnzipURL";
static NSString *const PACKAGE_SERIALIZATION_KEY_FOLDER_NAME = @"folderName";
static NSString *const PACKAGE_SERIALIZATION_KEY_ENABLE_ON_DOWNLOAD = @"enableOnDownload";

char *const KEY_INSTALL_DATA = "installData";


@implementation CCPackage (InstallData)

- (CCPackageInstallData *)installData
{
    CCPackageInstallData *result = objc_getAssociatedObject(self, KEY_INSTALL_DATA);

    return result;
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

- (NSString *)description
{
    CCPackageInstallData *installData = [self installData];

    return [NSString stringWithFormat:@"Name: %@, resolution: %@, os: %@, status: %d, folder name: %@\nremoteURL: %@\ninstallURL: %@\nunzipURL: %@\ndownloadURL: %@\n",
                                      self.name, self.resolution, self.os, self.status, installData.folderName, self.remoteURL, self.installURL, installData.unzipURL, installData.localDownloadURL];
}

@end
