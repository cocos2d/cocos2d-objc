#import <Foundation/Foundation.h>
#import "CCPackageTypes.h"

@class CCPackage;

typedef bool(^WaitConditionBlock)(void);


@interface CCPackagesTestFixturesAndHelpers : NSObject

+ (void)cleanCachesFolder;

+ (void)cleanTempFolder;

+ (CCPackage *)testPackageInitial;

+ (CCPackage *)testPackageWithStatus:(CCPackageStatus)status installRelPath:(NSString *)installFolderPath;

+ (void)waitForCondition:(WaitConditionBlock)waitConditionBlock;

+ (BOOL)isURLInCocos2dSearchPath:(NSURL *)URL;

+ (BOOL)isPackageInSearchPath:(CCPackage *)package;

@end