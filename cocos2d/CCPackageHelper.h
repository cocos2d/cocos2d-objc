#import <Foundation/Foundation.h>


@interface CCPackageHelper : NSObject

/**
 * Returns the current OS, possible values: iOS, Android and Mac
 */
+ (NSString *)currentOS;

/**
 * Returns a spritebuilder resolution(phone, phonehd, tablet, tablethd) for a CCFileUtil's device/resolution suffix like CCFileUtilsSuffixiPadHD
 * If none given or not found it'll return nil.
 *
 * @param suffix
 */
+ (NSString *)ccFileUtilsSuffixToResolution:(NSString *)suffix;

/**
 * Returns the preferred Sprite Builder resolution(phone, phonehd, tablet, tablethd) for the current cocos2d setup by looking at the entries
 * in CCFileUtils searchResolutionsOrder array. If none can be found or mapped phonehd will be returned as default.
 */
+ (NSString *)defaultResolution;

@end
