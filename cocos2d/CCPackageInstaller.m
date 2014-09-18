#import "CCPackageInstaller.h"
#import "CCPackageConstants.h"
#import "CCPackage.h"
#import "CCPackageInstallData.h"
#import "CCPackage+InstallData.h"
#import "CCPackageCocos2dEnabler.h"
#import "ccMacros.h"


@interface CCPackageInstaller ()

@property (nonatomic, strong, readwrite) CCPackage *package;
@property (nonatomic, copy, readwrite) NSString *installPath;

@end


@implementation CCPackageInstaller

- (instancetype)initWithPackage:(CCPackage *)package installPath:(NSString *)installPath
{
    NSAssert(package != nil, @"package must not be nil");
    NSAssert(installPath != nil, @"installPath must not be nil");

    self = [super init];
    if (self)
    {
        self.package = package;
        self.installPath = installPath;
    }

    return self;
}

- (BOOL)installWithError:(NSError **)error
{
    CCPackageInstallData *installData = [_package installData];

    NSAssert(installData != nil, @"installData must not be nil");
    NSAssert(installData.unzipURL != nil, @"installData.unzipURL must not be nil");

    if (![self packageExists:error])
    {
        [_package setValue:@(CCPackageStatusInstallationFailed) forKey:@"status"];
        return NO;
    }

    if (![self movePackageToInstallPathWithError:error])
    {
        [_package setValue:@(CCPackageStatusInstallationFailed) forKey:@"status"];
        return NO;
    }

    if (installData.enableOnDownload)
    {
        [self enablePackageInCocos2d];
        [_package setValue:@(CCPackageStatusInstalledEnabled) forKey:@"status"];
    }
    else
    {
        [_package setValue:@(CCPackageStatusInstalledDisabled) forKey:@"status"];
    }

    return YES;
}

- (void)enablePackageInCocos2d
{
    CCPackageCocos2dEnabler *packageCocos2dEnabler = [[CCPackageCocos2dEnabler alloc] init];
    [packageCocos2dEnabler enablePackages:@[_package]];
}

- (BOOL)movePackageToInstallPathWithError:(NSError **)error
{
    CCPackageInstallData *installData = [_package installData];

    NSAssert(installData.unzipURL != nil, @"installData.unzipURL must not be nil.");
    NSAssert(installData.folderName != nil, @"installData.folderName must not be nil.");

    [_package setValue:[NSURL fileURLWithPath:[_installPath stringByAppendingPathComponent:installData.folderName]] forKey:@"installURL"];

    NSError *errorMove;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager moveItemAtPath:[installData.unzipURL.path stringByAppendingPathComponent:installData.folderName]
                              toPath:_package.installURL.path
                               error:&errorMove])
    {
        [_package setValue:nil forKey:@"installURL"];

        [self setNewError:error
                     code:PACKAGE_ERROR_INSTALL_COULD_NOT_MOVE_PACKAGE
                  message:[NSString stringWithFormat:@"Could not move package to install path \"%@\", underlying error: %@", _installPath, errorMove]
          underlyingError:errorMove];

        CCLOG(@"[PACKAGE/INSTALL][ERROR] Moving unzipped package to installation folder: %@", *error);

        return NO;
    }

    return YES;
}

- (BOOL)packageExists:(NSError **)error
{
    CCPackageInstallData *installData = [_package installData];
    NSAssert(installData.unzipURL, @"installData.unzipURL must not be nil");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:installData.unzipURL.path])
    {
        [self setNewError:error
                     code:PACKAGE_ERROR_INSTALL_PACKAGE_NOT_FOUND
                  message:[NSString stringWithFormat:@"Package to install not found at path \"%@\"", installData.unzipURL]];

        CCLOG(@"[PACKAGE/INSTALL][ERROR] Moving unzipped package to installation folder, package already exists! %@", *error);
        return NO;
    }
    return YES;
}

- (void)setNewError:(NSError **)errorPtr code:(NSInteger)code message:(NSString *)message underlyingError:(NSError *)underlyingError
{
    NSMutableDictionary *userInfo = [@{NSLocalizedDescriptionKey : message, @"package" : _package} mutableCopy];
    if (underlyingError)
    {
        userInfo[NSUnderlyingErrorKey] = underlyingError;
    }

    NSError *error = [NSError errorWithDomain:@"cocos2d"
                                         code:code
                                     userInfo:userInfo];

    if (errorPtr)
    {
        *errorPtr = error;
    }
    else
    {
        CCLOG(@"[PACKAGE/INSTALL][ERROR] Error pointer not set.");
    }
}

- (void)setNewError:(NSError **)errorPtr code:(NSInteger)code message:(NSString *)message
{
    [self setNewError:errorPtr code:code message:message underlyingError:nil];
}

@end
