#import "CCPackage.h"
#import "CCPackageInstallData.h"
#import "CCPackage+InstallData.h"
#import "CCPackageHelper.h"


NSUInteger PACKAGE_SERIALIZATION_VERSION = 1;
NSString *const PACKAGE_SERIALIZATION_KEY_NAME = @"name";
NSString *const PACKAGE_SERIALIZATION_KEY_RESOLUTION = @"resolution";
NSString *const PACKAGE_SERIALIZATION_KEY_OS = @"os";
NSString *const PACKAGE_SERIALIZATION_KEY_REMOTE_URL = @"remoteURL";
NSString *const PACKAGE_SERIALIZATION_KEY_INSTALL_URL = @"installURL";
NSString *const PACKAGE_SERIALIZATION_KEY_VERSION = @"version";
NSString *const PACKAGE_SERIALIZATION_KEY_STATUS = @"status";


@interface CCPackage()

@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSString *resolution;
@property (nonatomic, copy, readwrite) NSString *os;
@property (nonatomic, copy, readwrite) NSURL *remoteURL;
@property (nonatomic, copy, readwrite) NSString *folderName;
@property (nonatomic, copy, readwrite) NSURL *installURL;
@property (nonatomic, readwrite) CCPackageStatus status;

@end


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
    }

    return self;
}

- (instancetype)initWithName:(NSString *)name resolution:(NSString *)resolution remoteURL:(NSURL *)remoteURL
{
    return [[CCPackage alloc] initWithName:name
                                resolution:resolution
                                        os:[CCPackageHelper currentOS]
                                 remoteURL:remoteURL];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    CCPackage *package = [[CCPackage alloc] initWithName:dictionary[PACKAGE_SERIALIZATION_KEY_NAME]
                                              resolution:dictionary[PACKAGE_SERIALIZATION_KEY_RESOLUTION]
                                                      os:dictionary[PACKAGE_SERIALIZATION_KEY_OS]
                                               remoteURL:[NSURL URLWithString:dictionary[PACKAGE_SERIALIZATION_KEY_REMOTE_URL]]];

    package.installURL = [NSURL URLWithString:dictionary[PACKAGE_SERIALIZATION_KEY_INSTALL_URL]];
    package.status = (CCPackageStatus) [dictionary[PACKAGE_SERIALIZATION_KEY_STATUS] unsignedIntegerValue];

    CCPackageInstallData *installData = [[CCPackageInstallData alloc] initWithPackage:package];
    [package setInstallData:installData];
    [package populateInstallDataWithDictionary:dictionary];

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
    if (_installURL)
    {
        dictionary[PACKAGE_SERIALIZATION_KEY_INSTALL_URL] = [_installURL absoluteString];
    }

    [self writeInstallDataToDictionary:dictionary];

    return dictionary;
}

- (NSString *)description
{
    CCPackageInstallData *installData = [self installData];

    return [NSString stringWithFormat:@"Name: %@, resolution: %@, os: %@, status: %d, folder name: %@\nremoteURL: %@\ninstallURL: %@\nunzipURL: %@\ndownloadURL: %@\n",
                                      _name, _resolution, _os, _status, installData.folderName, _remoteURL, _installURL, installData.unzipURL, installData.localDownloadURL];
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

@end
