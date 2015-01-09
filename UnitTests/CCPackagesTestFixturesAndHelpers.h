#import <Foundation/Foundation.h>
#import "CCPackageTypes.h"

@class CCPackage;

#define IGNORED_TESTS 1

#if IGNORED_TESTS

#define IGNORE_TEST_CASE NSObject
@interface NSObject (IgnoredCases)
- (void)setUp;
- (void)tearDown;
@end

#else
#define IGNORE_TEST_CASE XCTestCase
#endif

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