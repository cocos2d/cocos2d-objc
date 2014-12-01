#import <Foundation/Foundation.h>

@class CCPackage;

/** CCPackageInstaller class takes care of copying the contents of a package to the installation folder.
 
 */
@interface CCPackageInstaller : NSObject

/**
 *  The package that should be installed
 */
@property (nonatomic, strong, readonly) CCPackage *package;

/**
 *  The local installation path for the package
 */
@property (nonatomic, copy, readonly) NSString *installRelPath;

/**
 *  Returns a new instance of a CCPackageInstaller
 *
 *  @param package The package that should be installed
 *  @param installRelPath The path relative to the caches folder where the package should be installed to
 *
 *  @return A new instance of a CCPackageInstaller
 */
- (instancetype)initWithPackage:(CCPackage *)package installRelPath:(NSString *)installRelPath;

/**
 *  Installs the package. The contents of the unzipped packages folder are moved to the
 *  installRelPath folder.
 *
 *  @param error Error pointer to an error object containing details if installation failed
 *
 *  @return Whether the installation was successful(YES) or not(NO)
 */
- (BOOL)installWithError:(NSError **)error;

@end
