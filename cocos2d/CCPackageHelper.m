#import <MacTypes.h>
#import "CCPackageHelper.h"
#import "CCFileLocator.h"
#import "ccMacros.h"


@implementation CCPackageHelper

+ (NSString *)currentOS
{
#if __CC_PLATFORM_ANDROID
    return @"Android";
#elif __CC_PLATFORM_MAC || __CC_PLATFORM_IOS
    return @"iOS";
#endif
    return nil;
}

+ (NSString *)cachesFolder
{
    #if __CC_PLATFORM_MAC
    NSString *cachesFolderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    return [cachesFolderPath stringByAppendingPathComponent:bundleIdentifier];
    #else
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    #endif
}

+ (NSString *)defaultResolution
{
    // TODO Not sure if this is relevent in v4.
    return @"default";
}

@end
