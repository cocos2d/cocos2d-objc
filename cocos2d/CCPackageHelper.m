#import "CCPackageHelper.h"


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
    return nil;
}

@end
