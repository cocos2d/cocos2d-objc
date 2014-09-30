#import <MacTypes.h>
#import "CCPackageHelper.h"
#import "CCFileUtils.h"


@implementation CCPackageHelper

+ (NSString *)currentOS
{
#ifdef __CC_PLATFORM_IOS
    return @"iOS";

#elif defined(__CC_PLATFORM_MAC)
    return @"Mac";

#elif defined(__CC_PLATFORM_ANDROID)
    return @"Android";

#endif
    return @"iOS";
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
