#import "CCPackageInstaller.h"
#import "CCPackageConstants.h"
#import "CCPackage.h"
#import "ccMacros.h"
#import "CCPackage_private.h"


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
    if (![self unzippedPackageFolderExists:error])
    {
        [_package setValue:@(CCPackageStatusInstallationFailed) forKey:@"status"];
        return NO;
    }

    if (![self movePackageToInstallPathWithError:error])
    {
        [_package setValue:@(CCPackageStatusInstallationFailed) forKey:@"status"];
        return NO;
    }

    [_package setValue:@(CCPackageStatusInstalledDisabled) forKey:@"status"];

    return YES;
}

- (BOOL)movePackageToInstallPathWithError:(NSError **)error
{
    NSAssert(_package.unzipURL != nil, @"package.unzipURL must not be nil.");
    NSAssert(_package.folderName != nil, @"package.folderName must not be nil.");

    _package.installURL = [NSURL fileURLWithPath:[_installPath stringByAppendingPathComponent:_package.folderName]];

    NSError *errorMove;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager moveItemAtPath:[_package.unzipURL.path stringByAppendingPathComponent:_package.folderName]
                              toPath:_package.installURL.path
                               error:&errorMove])
    {
        [_package setValue:nil forKey:@"installURL"];

        [self setNewError:error
                     code:PACKAGE_ERROR_INSTALL_COULD_NOT_MOVE_PACKAGE_TO_INSTALL_FOLDER
                  message:[NSString stringWithFormat:@"Could not move package to install path \"%@\", underlying error: %@", _installPath, errorMove]
          underlyingError:errorMove];

        CCLOG(@"[PACKAGE/INSTALL][ERROR] Moving unzipped package to installation folder: %@", *error);

        return NO;
    }

    return YES;
}

- (BOOL)unzippedPackageFolderExists:(NSError **)error
{
    NSAssert(_package.unzipURL != nil, @"package.unzipURL must not be nil.");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_package.unzipURL.path])
    {
        [self setNewError:error
                     code:PACKAGE_ERROR_INSTALL_UNZIPPED_PACKAGE_NOT_FOUND
                  message:[NSString stringWithFormat:@"Package to install not found at path \"%@\"", _package.unzipURL]];

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
