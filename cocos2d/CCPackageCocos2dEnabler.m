#import "CCPackageCocos2dEnabler.h"
#import "CCTextureCache.h"
#import "CCPackage.h"
#import "CCFileUtils.h"
#import "CCSpriteFrameCache.h"
#import "CCPackage_private.h"
#import "CCPackageHelper.h"


@implementation CCPackageCocos2dEnabler

- (BOOL)isPackagInSearchPath:(CCPackage *)package
{
    NSString *newPackagePath = package.installRelURL.path;

    return [[CCFileUtils sharedFileUtils].searchPath containsObject:newPackagePath];
}

- (void)enablePackages:(NSArray *)packages
{
    if ([self addPackagestoSearchPath:packages])
    {
        CCLOGINFO(@"[PACKAGE/INSTALL][INFO] Enable packages - Search path: %@", [CCFileUtils sharedFileUtils].searchPath);

        [self reloadCocos2dFiles];
    }
}

- (void)disablePackages:(NSArray *)array
{
    [self removePackagesFromSearchPath:array];

    CCLOGINFO(@"[PACKAGE/INSTALL][INFO] Disable packages - Search path: %@", [CCFileUtils sharedFileUtils].searchPath);

    [self reloadCocos2dFiles];
}

- (BOOL)addPackagestoSearchPath:(NSArray *)packages
{
    BOOL searchPathChanged = NO;

    for (CCPackage *aPackage in packages)
    {
        NSAssert(aPackage.installRelURL != nil, @"aPackage.installRelURL must not be nil for package %@", aPackage);

        NSMutableArray *newSearchPath = [[CCFileUtils sharedFileUtils].searchPath mutableCopy];

        if (![newSearchPath containsObject:aPackage.installFullURL.path])
        {
            aPackage.status = CCPackageStatusInstalledEnabled;

            [newSearchPath insertObject:aPackage.installFullURL.path atIndex:0];
            [CCFileUtils sharedFileUtils].searchPath = newSearchPath;
            searchPathChanged = YES;
        }
    }

    return searchPathChanged;
}

- (void)reloadCocos2dFiles
{
    [[CCFileUtils sharedFileUtils] purgeCachedEntries];
    [CCSpriteFrameCache purgeSharedSpriteFrameCache];
    [CCTextureCache purgeSharedTextureCache];

    [[CCFileUtils sharedFileUtils] loadFileNameLookupsInAllSearchPathsWithName:@"fileLookup.plist"];

    [[CCSpriteFrameCache sharedSpriteFrameCache] loadSpriteFrameLookupsInAllSearchPathsWithName:@"spriteFrameFileList.plist"];
}

- (void)removePackagesFromSearchPath:(NSArray *)packages
{
    for (CCPackage *aPackage in packages)
    {
        NSMutableArray *newSearchPath = [[CCFileUtils sharedFileUtils].searchPath mutableCopy];
        NSString *packagePathToRemove = aPackage.installFullURL.path;

        [aPackage setValue:@(CCPackageStatusInstalledDisabled) forKey:NSStringFromSelector(@selector(status))];

        if ([newSearchPath containsObject:packagePathToRemove])
        {
            [newSearchPath removeObject:packagePathToRemove];
        }

        [CCFileUtils sharedFileUtils].searchPath = newSearchPath;
    }
}

@end
