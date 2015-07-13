#import "CCPackageInstaller.h"
#import "CCPackageConstants.h"
#import "CCPackage.h"
#import "ccMacros.h"
#import "CCPackage_private.h"
#import "CCPackageHelper.h"


@interface CCPackageInstaller ()

@property (nonatomic, strong, readwrite) CCPackage *package;
@property (nonatomic, copy, readwrite) NSString *installRelPath;

@end


@implementation CCPackageInstaller

- (instancetype)initWithPackage:(CCPackage *)package installRelPath:(NSString *)installRelPath
{
    NSAssert(package != nil, @"package must not be nil");
    NSAssert(installRelPath != nil, @"installRelPath must not be nil");

    self = [super init];
    if (self)
    {
        self.package = package;
        self.installRelPath = installRelPath;
    }

    return self;
}

- (BOOL)installWithError:(NSError **)error
{
    if (![self unzippedPackageFolderExists:error])
    {
        _package.status = CCPackageStatusInstallationFailed;
        return NO;
    }

    if (![self movePackageToInstallRelPathWithError:error])
    {
        [_package setValue:@(CCPackageStatusInstallationFailed) forKey:@"status"];
        return NO;
    }

    [_package setValue:@(CCPackageStatusInstalledDisabled) forKey:@"status"];

    return YES;
}

- (BOOL)movePackageToInstallRelPathWithError:(NSError **)error
{
    NSAssert(_package.unzipURL != nil, @"package.unzipURL must not be nil.");
    NSAssert(_package.folderName != nil, @"package.folderName must not be nil.");


    _package.installRelURL = [NSURL URLWithString:[_installRelPath stringByAppendingPathComponent:_package.folderName]];

    NSString *fullInstallPath = _package.installFullURL.path;

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *errorDelete;
    if ([fileManager fileExistsAtPath:fullInstallPath])
    {
        if (![fileManager removeItemAtPath:fullInstallPath error:&errorDelete])
        {
            _package.installRelURL = nil;

            [self setNewError:error
                         code:PACKAGE_ERROR_INSTALL_COULD_NOT_DELETE_EXISTING_FOLDER_BEFORE_MOVING_TO_INSTALL_FOLDER
                      message:[NSString stringWithFormat:@"Could not remove existing folder at path \"%@\" before moving package to be installed. Underlying error: %@", fullInstallPath, errorDelete]
              underlyingError:errorDelete];

            CCLOG(@"[PACKAGE/INSTALL][ERROR] Could remove existing folder before moving package: %@  with error: %@", _package, *error);

            return NO;
        }
    }

    NSError *errorMove;
    if (![fileManager moveItemAtPath:[_package.unzipURL.path stringByAppendingPathComponent:_package.folderName]
                              toPath:fullInstallPath
                               error:&errorMove])
    {
        _package.installRelURL = nil;

        [self setNewError:error
                     code:PACKAGE_ERROR_INSTALL_COULD_NOT_MOVE_PACKAGE_TO_INSTALL_FOLDER
                  message:[NSString stringWithFormat:@"Could not move package to install path \"%@\", underlying error: %@", fullInstallPath, errorMove]
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

- (BOOL)setNewError:(NSError **)errorPtr code:(NSInteger)code message:(NSString *)message underlyingError:(NSError *)underlyingError
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
    return (error == nil);
}

- (BOOL)setNewError:(NSError **)errorPtr code:(NSInteger)code message:(NSString *)message
{
    return [self setNewError:errorPtr code:code message:message underlyingError:nil];
}

@end
