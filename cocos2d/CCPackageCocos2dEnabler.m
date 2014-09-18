#import "CCPackageCocos2dEnabler.h"
#import "CCTextureCache.h"
#import "CCPackage.h"
#import "CCFileUtils.h"
#import "CCSpriteFrameCache.h"


@implementation CCPackageCocos2dEnabler

- (void)enablePackages:(NSArray *)packages
{
    [self addPackagestoSearchPath:packages];

    CCLOGINFO(@"[PACKAGE/INSTALL][INFO] Enable packages - Search path: %@", [CCFileUtils sharedFileUtils].searchPath);

    [self reloadCocos2dFiles];
}

- (void)disablePackages:(NSArray *)array
{
    [self removePackagesFromSearchPath:array];

    CCLOGINFO(@"[PACKAGE/INSTALL][INFO] Disable packages - Search path: %@", [CCFileUtils sharedFileUtils].searchPath);

    [self reloadCocos2dFiles];
}

- (void)addPackagestoSearchPath:(NSArray *)packages
{
    for (CCPackage *aPackage in packages)
    {
        NSMutableArray *newSearchPath = [[CCFileUtils sharedFileUtils].searchPath mutableCopy];
        NSString *newPackagePath = aPackage.installURL.path;

        if (![newSearchPath containsObject:newPackagePath])
        {
            [newSearchPath insertObject:newPackagePath atIndex:0];
        }

        [CCFileUtils sharedFileUtils].searchPath = newSearchPath;
    }
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
        NSString *packagePathToRemove = aPackage.installURL.path;

        if ([newSearchPath containsObject:packagePathToRemove])
        {
            [newSearchPath removeObject:packagePathToRemove];
        }

        [CCFileUtils sharedFileUtils].searchPath = newSearchPath;
    }
}

@end
