#import <Foundation/Foundation.h>
#import "CCPackage.h"

@class CCPackageInstallData;


@interface CCPackage (InstallData)

- (CCPackageInstallData *)installData;

/**
 *  Attaches install data to the package as an associated object
 *
 *  @param installData The install data to be attached to the package
 */
- (void)setInstallData:(CCPackageInstallData *)installData;

/**
 *  Removes any install data attached to the package if there is any
 */
- (void)removeInstallData;

@end
