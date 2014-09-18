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

/**
 *  Reads values of dictionary and sets them on the install data.
 *  Install data has to be attached to package already.
 *
 *  @param dictionary Dictionary containing values to populate the install data with
 */
- (void)populateInstallDataWithDictionary:(NSDictionary *)dictionary;

//
/**
 *  Writes the install data values into the provided dictionary.
 *
 *  @param dictionary Dictionary that shouöd be used to serialize the install data to
 */
- (void)writeInstallDataToDictionary:(NSMutableDictionary *)dictionary;

@end
