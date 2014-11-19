#import <Foundation/Foundation.h>

/** CCPackageHelper provides methods to determine information about the running app relevant for packages used throughout the packages feature.

 */
@interface CCPackageHelper : NSObject

/**
 * Returns the current OS, possible values: iOS, Android and Mac
 */
+ (NSString *)currentOS;

/**
 * Returns the full path to the caches folder, this may differ depending on OS
 */
+ (NSString *)cachesFolder;

/**
 * Maps a CCFileUtil's device/resolution suffix string, for instance `CCFileUtilsSuffixiPadHD`, to a SpriteBuilder resolution string, for instance `tablethd`.
 *
 * @param suffix A CCFileUtils resolution suffix, as defined by the CCFileUtilsSuffix* constants.
 * @returns A SpriteBuilder resolution string, one of: `phone`, `phonehd`, `tablet`, `tablethd`. Returns nil if there is no matching SpriteBuilder suffix for the given input suffix.
 */
+ (NSString *)ccFileUtilsSuffixToResolution:(NSString *)suffix;

/**
 * Returns the preferred Sprite Builder resolution(phone, phonehd, tablet, tablethd) for the current cocos2d setup by looking at the entries
 * in CCFileUtils searchResolutionsOrder array. If none can be found or mapped phonehd will be returned as default.
 */
+ (NSString *)defaultResolution;

@end
