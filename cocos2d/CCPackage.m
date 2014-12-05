#import <Foundation/Foundation.h>
#import "CCPackage.h"
#import "CCPackageHelper.h"
#import "CCPackage_private.h"

static NSUInteger PACKAGE_SERIALIZATION_VERSION = 1;
static NSString *const PACKAGE_SERIALIZATION_KEY_NAME = @"name";
static NSString *const PACKAGE_SERIALIZATION_KEY_RESOLUTION = @"resolution";
static NSString *const PACKAGE_SERIALIZATION_KEY_OS = @"os";
static NSString *const PACKAGE_SERIALIZATION_KEY_REMOTE_URL = @"remoteURL";
static NSString *const PACKAGE_SERIALIZATION_KEY_INSTALL_URL = @"installURL";
static NSString *const PACKAGE_SERIALIZATION_KEY_VERSION = @"version";
static NSString *const PACKAGE_SERIALIZATION_KEY_STATUS = @"status";
static NSString *const PACKAGE_SERIALIZATION_KEY_LOCAL_DOWNLOAD_URL = @"localDownloadURL";
static NSString *const PACKAGE_SERIALIZATION_KEY_LOCAL_UNZIP_URL = @"localUnzipURL";
static NSString *const PACKAGE_SERIALIZATION_KEY_FOLDER_NAME = @"folderName";
static NSString *const PACKAGE_SERIALIZATION_KEY_ENABLE_ON_DOWNLOAD = @"enableOnDownload";


@implementation CCPackage

- (instancetype)initWithName:(NSString *)name resolution:(NSString *)resolution os:(NSString *)os remoteURL:(NSURL *)remoteURL
{
    NSAssert(name != nil, @"name must not be nil");
    NSAssert(resolution != nil, @"resolution must not be nil");
    NSAssert(os != nil, @"os must not be nil");
    NSAssert(remoteURL != nil, @"remoteURL must not be nil");

    self = [super init];
    if (self)
    {
        self.name = name;
        self.resolution = resolution;
        self.os = os;
        self.remoteURL = remoteURL;
        self.status = CCPackageStatusInitial;
        self.enableOnDownload = NO;
    }

    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    CCPackage *package = [[CCPackage alloc] initWithName:dictionary[PACKAGE_SERIALIZATION_KEY_NAME]
                                              resolution:dictionary[PACKAGE_SERIALIZATION_KEY_RESOLUTION]
                                                      os:dictionary[PACKAGE_SERIALIZATION_KEY_OS]
                                               remoteURL:[NSURL URLWithString:dictionary[PACKAGE_SERIALIZATION_KEY_REMOTE_URL]]];

    package.status = (CCPackageStatus) [dictionary[PACKAGE_SERIALIZATION_KEY_STATUS] unsignedIntegerValue];
    package.enableOnDownload = [dictionary[PACKAGE_SERIALIZATION_KEY_ENABLE_ON_DOWNLOAD] boolValue];

    if (dictionary[PACKAGE_SERIALIZATION_KEY_INSTALL_URL])
    {
        package.installRelURL = [NSURL fileURLWithPath:dictionary[PACKAGE_SERIALIZATION_KEY_INSTALL_URL]];
    }

    if (dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_DOWNLOAD_URL])
    {
        package.localDownloadURL = [NSURL fileURLWithPath:dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_DOWNLOAD_URL]];
    }

    if (dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_UNZIP_URL])
    {
        package.unzipURL = [NSURL fileURLWithPath:dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_UNZIP_URL]];
    }

    if (dictionary[PACKAGE_SERIALIZATION_KEY_FOLDER_NAME])
    {
        package.folderName = dictionary[PACKAGE_SERIALIZATION_KEY_FOLDER_NAME];
    }

    return package;
}

- (NSString *)standardIdentifier
{
    return [NSString stringWithFormat:@"%@-%@-%@", _name, _os, _resolution];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    dictionary[PACKAGE_SERIALIZATION_KEY_STATUS] = @(_status);
    dictionary[PACKAGE_SERIALIZATION_KEY_NAME] = _name;
    dictionary[PACKAGE_SERIALIZATION_KEY_RESOLUTION] = _resolution;
    dictionary[PACKAGE_SERIALIZATION_KEY_OS] = _os;
    dictionary[PACKAGE_SERIALIZATION_KEY_REMOTE_URL] = [_remoteURL absoluteString];
    dictionary[PACKAGE_SERIALIZATION_KEY_VERSION] = @(PACKAGE_SERIALIZATION_VERSION);
    dictionary[PACKAGE_SERIALIZATION_KEY_ENABLE_ON_DOWNLOAD] = @(_enableOnDownload);

    if (_installRelURL)
    {
        dictionary[PACKAGE_SERIALIZATION_KEY_INSTALL_URL] = [_installRelURL path];
    }

    if (_localDownloadURL)
    {
        dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_DOWNLOAD_URL] = [_localDownloadURL path];
    }

    if (_unzipURL)
    {
        dictionary[PACKAGE_SERIALIZATION_KEY_LOCAL_UNZIP_URL] = [_unzipURL path];
    }

    if (_folderName)
    {
        dictionary[PACKAGE_SERIALIZATION_KEY_FOLDER_NAME] = _folderName;
    }

    return dictionary;
}

- (NSString *)statusToString
{
    switch (_status)
    {
        case CCPackageStatusInitial  :
            return @"Initial";
        case CCPackageStatusDownloading  :
            return @"Downloading";
        case CCPackageStatusDownloadPaused :
            return @"Download Paused";
        case CCPackageStatusDownloaded :
            return @"Downloaded";
        case CCPackageStatusUnzipping :
            return @"Unzipping";
        case CCPackageStatusUnzipped :
            return @"Unzipped";
        case CCPackageStatusInstalledEnabled :
            return @"Installed/Enabled";
        case CCPackageStatusInstalledDisabled :
            return @"Installed/Disabled";

        default : return @"Unknown";
    }
}

- (NSURL *)installFullURL
{
    return [NSURL fileURLWithPath:[[CCPackageHelper cachesFolder] stringByAppendingPathComponent:_installRelURL.path]];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name: %@, res: %@, os: %@, status: %@, remote url: %@, unzip url: %@, install url: %@",_name, _resolution, _os, [self statusToString], _remoteURL, _unzipURL, [self installFullURL]];
}

@end
