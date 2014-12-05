#import <MacTypes.h>
#import "CCPackageHelper.h"
#import "CCFileUtils.h"
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

+ (NSString *)ccFileUtilsSuffixToResolution:(NSString *)suffix
{
    if ([suffix isEqualToString:CCFileUtilsSuffixiPhone5HD]
        || [suffix isEqualToString:CCFileUtilsSuffixiPhone5]
        || [suffix isEqualToString:CCFileUtilsSuffixiPhoneHD]
        || [suffix isEqualToString:CCFileUtilsSuffixDefault])
    {
        return @"phonehd";
    }

    if ([suffix isEqualToString:CCFileUtilsSuffixiPhone])
    {
        return @"phone";
    }

    if ([suffix isEqualToString:CCFileUtilsSuffixiPadHD]
        || [suffix isEqualToString:CCFileUtilsSuffixMacHD])
    {
        return @"tablethd";
    }

    if ([suffix isEqualToString:CCFileUtilsSuffixMac]
        || [suffix isEqualToString:CCFileUtilsSuffixiPad])
    {
        return @"tablet";
    }

    return nil;
}

+ (NSString *)defaultResolution
{
    for (NSString *resolution in [CCFileUtils sharedFileUtils].searchResolutionsOrder)
    {
        NSString *result = [CCPackageHelper ccFileUtilsSuffixToResolution:resolution];
        if (result)
        {
            return result;
        }
    }

    return @"phonehd";
}

@end
