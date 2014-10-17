#import <Foundation/Foundation.h>
#import "CCPackageTypes.h"

@class CCPackage;

typedef bool(^WaitConditionBlock)(void);


@interface CCPackagesTestFixturesAndHelpers : NSObject

+ (CCPackage *)testPackageInitial;

+ (CCPackage *)testPackageWithStatus:(CCPackageStatus)status installFolderPath:(NSString *)installFolderPath;

+ (void)waitForCondition:(WaitConditionBlock)waitConditionBlock;

+ (BOOL)isURLInCocos2dSearchPath:(NSURL *)URL;

@end