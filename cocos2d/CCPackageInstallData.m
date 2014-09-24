#import "CCPackageInstallData.h"
#import "CCPackage.h"


static NSString *const PACKAGE_SERIALIZATION_KEY_LOCAL_DOWNLOAD_URL = @"localDownloadURL";
static NSString *const PACKAGE_SERIALIZATION_KEY_LOCAL_UNZIP_URL = @"localUnzipURL";
static NSString *const PACKAGE_SERIALIZATION_KEY_FOLDER_NAME = @"folderName";
static NSString *const PACKAGE_SERIALIZATION_KEY_ENABLE_ON_DOWNLOAD = @"enableOnDownload";

@implementation CCPackageInstallData

- (instancetype)initWithPackage:(CCPackage *)package
{
    NSAssert(package != nil, @"package must not be nil.");

    self = [super init];
    if (self)
    {
        self.package = package;
    }

    return self;
}

- (void)populateInstallDataWithDictionary:(NSDictionary *)dictionary
{
    if (dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_DOWNLOAD_URL])
    {
        self.localDownloadURL = [NSURL URLWithString:dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_DOWNLOAD_URL]];
    }

    if (dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_UNZIP_URL])
    {
        self.unzipURL = [NSURL URLWithString:dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_UNZIP_URL]];
    }

    if (dictionary[PACKAGE_SERIALIZATION_KEY_FOLDER_NAME])
    {
        self.folderName = dictionary[PACKAGE_SERIALIZATION_KEY_FOLDER_NAME];
    }

    if (dictionary[PACKAGE_SERIALIZATION_KEY_FOLDER_NAME])
    {
        self.enableOnDownload = [dictionary[PACKAGE_SERIALIZATION_KEY_ENABLE_ON_DOWNLOAD] boolValue];
    }
}

- (void)writeInstallDataToDictionary:(NSMutableDictionary *)dictionary
{
    if (_localDownloadURL)
    {
        dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_DOWNLOAD_URL] = [_localDownloadURL absoluteString];
    }

    if (_unzipURL)
    {
        dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_UNZIP_URL] = [_unzipURL absoluteString];
    }

    if (_folderName)
    {
        dictionary[PACKAGE_SERIALIZATION_KEY_FOLDER_NAME] = _folderName;
    }

    dictionary[PACKAGE_SERIALIZATION_KEY_ENABLE_ON_DOWNLOAD] = @(_enableOnDownload);
}


@end
