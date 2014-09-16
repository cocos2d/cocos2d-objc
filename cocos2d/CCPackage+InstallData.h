#import <Foundation/Foundation.h>
#import "CCPackage.h"

@class CCPackageInstallData;


@interface CCPackage (InstallData)

- (CCPackageInstallData *)installData;

// Attaches install data to the package as an associated object
- (void)setInstallData:(CCPackageInstallData *)installData;

// Removes any install data attached to the package if there is any
- (void)removeInstallData;

// Reads values of dictionary and sets them on the install data
// InstallData has to be attached to the package already
- (void)populateInstallDataWithDictionary:(NSDictionary *)dictionary;

// Returns a dictionary with the install data's values
- (void)writeInstallDataToDictionary:(NSMutableDictionary *)dictionary;

@end