#import <Foundation/Foundation.h>
#import "CCPackageTypes.h"

@class CCPackage;

typedef bool(^WaitConditionBlock)(void);


@interface CCPackagesTestFixtures : NSObject

+ (CCPackage *)testPackageWithInstallFolderPath:(NSString *)installFolderPath;

+ (CCPackage *)testPackageWithStatus:(CCPackageStatus)status installFolderPath:(NSString *)installFolderPath;

+ (void)waitForCondition:(WaitConditionBlock)waitConditionBlock;

@end