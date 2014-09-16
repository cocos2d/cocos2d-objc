#import <Foundation/Foundation.h>

@class CCPackage;

@interface CCPackageInstaller : NSObject

@property (nonatomic, strong, readonly) CCPackage *package;
@property (nonatomic, copy, readonly) NSString *installPath;

- (instancetype)initWithPackage:(CCPackage *)package installPath:(NSString *)installPath;

// Installs the package. The contents of the unzipped packages folder are moved to the
// Packages folder.
// Returns YES if installation was successful. Check error pointer for details if installation failed.
- (BOOL)installWithError:(NSError **)error;

@end