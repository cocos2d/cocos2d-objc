#import <Foundation/Foundation.h>

/** CCPackageHelper provides methods to determine information about the running app relevant for packages used throughout the packages feature.

 */
@interface CCPackageHelper : NSObject

/**
 * Returns the current OS, possible values: `iOS` or `Android`. 
 * @note On OS X this will also return `iOS`.
 * @since v3.3 and later
 */
+ (NSString *)currentOS;

/**
 * Returns the full path to the caches folder, this may differ depending on OS.
 * @since v3.3 and later
 */
+ (NSString *)cachesFolder;

/**
 * Returns the preferred SpriteBuilder resolution string (`phone`, `phonehd`, `tablet`, `tablethd`) for the current Cocos2D setup by looking at the entries
 * in [CCFileUtils searchResolutionsOrder] array. If none can be found or mapped `phonehd` will be returned as default.
 * @since v3.3 and later
 */
+ (NSString *)defaultResolution;

@end
