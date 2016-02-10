/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

// keys used for the suffix or directory dictionaries
extern NSString * const CCFileUtilsSuffixDefault;
extern NSString * const CCFileUtilsSuffixiPad;
extern NSString * const CCFileUtilsSuffixiPadHD;
extern NSString * const CCFileUtilsSuffixiPhone;
extern NSString * const CCFileUtilsSuffixiPhoneHD;
extern NSString * const CCFileUtilsSuffixiPhone5;
extern NSString * const CCFileUtilsSuffixiPhone5HD;
extern NSString * const CCFileUtilsSuffixMac;
extern NSString * const CCFileUtilsSuffixMacHD;

extern NSString * const kCCFileUtilsDefaultSearchPath;

/** Search mode used by CCFileUtils. */
typedef NS_ENUM(NSUInteger, CCFileUtilsSearchMode) {
    /** Search using suffixes */
	CCFileUtilsSearchModeSuffix,
    /** Search using directories */
	CCFileUtilsSearchModeDirectory,
};


/** Helper class to resolve files with resolution-specific suffixes (ie `-hd`) to actual file paths, including fallbacks.
 
 @warning **CCFileUtils should no longer be used by developers! CCFileUtils will be deprecated in an upcoming Cocos2D version!** 
 
 Consider CCFileUtils a private API and this documentation only for instructional purposes and "historical" reference. Unfortunately
 too many such references exist so that it would be a disservice to developers not to document the details of CCFileUtils,
 no matter how much we all §/%&")$/$%! what CCFileUtils has grown into.
 */
@interface CCFileUtils : NSObject
{
	NSFileManager		*_fileManager;
	NSBundle			*_bundle;

	NSMutableDictionary *_fullPathCache;
	NSMutableDictionary *_fullPathNoResolutionsCache;
	NSMutableDictionary *_removeSuffixCache;
	
	NSMutableDictionary	*_directoriesDict;
	NSMutableDictionary	*_suffixesDict;
	
	NSMutableDictionary	*_filenameLookup;
	
	NSMutableArray		*_searchResolutionsOrder;
	NSMutableArray		*_searchPath;
	
	// it could be suffix (default) or directory
	CCFileUtilsSearchMode _searchMode;
	
	BOOL				_enableiPhoneResourcesOniPad;
}

/** @name All the methods you shouldn't be using :) */

/** NSBundle used by CCFileUtils. By default it uses [NSBundle mainBundle].
 @warning Avoid using this method in new code. See class *Overview*.
 */
@property (nonatomic, readwrite, strong) NSBundle	*bundle;

/** NSFileManager used by CCFileUtils. By default it uses its own instance.
 @warning Avoid using this method in new code. See class *Overview*.
 */
@property (nonatomic, readwrite, strong) NSFileManager	*fileManager;

/** Whether of not the fallback suffixes is enabled.
 When enabled it will try to search for the following suffixes in the following order until one is found:
 * On iPad HD  : iPad HD, iPad, iPhone HD, Resources without resolution
 * On iPad     : iPad, iPhone HD, Resources without resolution
 * On iPhone HD: iPhone HD, Resources without resolution
 * On Mac HD   : Mac HD, Mac, Resources without resolution
 * On Mac      : Mac, Resources without resolution
 
 By default this functionality is on;
 @warning Avoid using this method in new code. See class *Overview*.
 */
@property (nonatomic, readwrite, getter = isEnablediPhoneResourcesOniPad) BOOL enableiPhoneResourcesOniPad;

/** Dictionary that contians the search directories for the different devices. Default values:
 - iPhone: "resources-iphone"
 - iPhone HD: "resources-hd"
 - iPhone5 : "resources-wide"
 - iPhone5 HD: "resources-widehd"
 - iPad: "resources-ipad"
 - iPad HD: "resources-ipadhd"
 - Mac: "resources-mac"
 - Mac HD: "resources-machd"
 
 If "search in directories" is enabled (disabled by default), it will try to get the resources from the directories according to the order of "searchResolutionsOrder" array.
 @warning Avoid using this method in new code. See class *Overview*.
 */
@property (nonatomic, copy) NSMutableDictionary *directoriesDict;

/** Dictionary that contians the suffix for the different devices. Default values:
	- iPhone: ""
	- iPhone HD: "-hd"
	- iPhone5 : "-wide"
	- iPhone5 HD: "-widehd"
	- iPad: "-ipad"
	- iPad HD: "-ipadhd"
	- Mac: ""
	- Mac HD: "-machd"

  If "search with suffixes" is enabled (enabled by default), it will try to get the resources by appending the suffixes according to the order of "searchResolutionsOrder" array.
 @warning Avoid using this method in new code. See class *Overview*.
 */
@property (nonatomic, copy) NSMutableDictionary *suffixesDict;

/** Array that contains the search order of the resources based for the device.
 By default it will try to load resources in the following order until one is found:
   - On iPad HD: iPad HD resources, iPad resources, resources not associated with any device
   - On iPad: iPad resources, resources not associated with any device
   - On iPhone 5 HD: iPhone 5 HD resources, iPhone HD resouces, iPhone 5 resources, iPhone resources, resources not associated with any device
   - On iPhone HD: iPhone HD resources, iPhone resouces, resources not associated with any device
   - On iPhone: iPhone resources, resources not associated with any device

   - On Mac HD: Mac HD resources, Mac resources, resources not associated with any device
   - On Mac: Mac resources, resources not associated with any device
 
 If the property "enableiPhoneResourcesOniPad" is enabled, it will also search for iPhone resources if you are in an iPad.
 @warning Avoid using this method in new code. See class *Overview*.
 */
@property (nonatomic, strong) NSMutableArray *searchResolutionsOrder;

/** Array of search paths.
 You can use this array to modify the search path of the resources.
 If you want to use "themes" or search resources in the "cache", you can do it easily by adding new entries in this array.
 
 By default it is an array with only the "" (empty string) element.
 @warning Avoid using this method in new code. See class *Overview*.
 */
@property (nonatomic, copy) NSArray *searchPath;


/**  It determines how the "resolution resources"  are to be searched.
 Possible values:
	- kCCFileUtilsSearchSuffix: It will search for resources by appending suffixes like "-hd", "-ipad", etc...
	- kCCFileUtilsSearchDirectory: It will search the resoureces in subdirectories like "resources-hd", "resources-ipad", etc...
 
 Default: kCCFileUtilsSearchSuffix
 @warning Avoid using this method in new code. See class *Overview*.
 */
@property (nonatomic, readwrite) CCFileUtilsSearchMode searchMode;

/** Dictionary used to lookup filenames based on a key.
 It is used internally by the following methods:

  *	-(NSString*) fullPathForFilename:(NSString*)key contentScale:(CGFloat *)contentScale;
  *	-(NSString*) fullPathForFilenameIgnoringResolutions:(NSString*)key;
 @warning Avoid using this method in new code. See class *Overview*.
 */
@property (nonatomic, readwrite, copy) NSMutableDictionary *filenameLookup;

#if __CC_PLATFORM_IOS
/** 
   The iPhone RetinaDisplay suffixes to load resources.
   By default it is "-hd" and "" in that order.
   Only valid on iOS. Not valid for OS X.
 
   @param iPhoneRetinaDisplaySuffix Suffix to set
 @warning Avoid using this method in new code. See class *Overview*.
 */
-(void) setiPhoneRetinaDisplaySuffix:(NSString*)iPhoneRetinaDisplaySuffix;

/** 
   The iPad suffixes to load resources.
   By default it is "-ipad", "-hd", "", in that order.
   Only valid on iOS. Not valid for OS X.
 
   @param iPadSuffix Suffix to set
 @warning Avoid using this method in new code. See class *Overview*.
 */
-(void) setiPadSuffix:(NSString*) iPadSuffix;


/** 
   Sets the iPad Retina Display suffixes to load resources.
   By default it is "-ipadhd", "-ipad", "-hd", "", in that order.
   Only valid on iOS. Not valid for OS X.
 
   @param iPadRetinaDisplaySuffix Suffix to set
 @warning Avoid using this method in new code. See class *Overview*.
 */
-(void)setiPadRetinaDisplaySuffix:(NSString*)iPadRetinaDisplaySuffix;

/** Sets the base contentScale of textures loaded on the iPhone.
 Useful for when you manipulate CCDirector.contenScaleFactor.
 Defaults to 1.0.
 Only valid on iOS. Not valid for OS X.
 @param scale scale factor
 @warning Avoid using this method in new code. See class *Overview*.
 */
-(void)setiPhoneContentScaleFactor:(CGFloat)scale;

/** Sets the base contentScale of textures loaded on the iPad.
 Useful for when you manipulate CCDirector.contenScaleFactor.
 Defaults to 1.0.
 Only valid on iOS. Not valid for OS X.
 @param scale scale factor
 @warning Avoid using this method in new code. See class *Overview*.
 */
-(void)setiPadContentScaleFactor:(CGFloat)scale;

#elif __CC_PLATFORM_MAC

/** Sets the base contentScale of textures loaded on the Mac.
 Useful for when you manipulate CCDirector.contenScaleFactor.
 Defaults to 1.0.
 Only valid on Mac. Not valid for iOS.
 @param scale scale factor
 @warning Avoid using this method in new code. See class *Overview*.
 */
-(void)setMacContentScaleFactor:(CGFloat)scale;

#endif // __CC_PLATFORM_IOS


/** returns the shared file utils instance
 @warning Avoid using this method in new code. See class *Overview*.
*/
+(CCFileUtils*) sharedFileUtils;


/** Purge cached entries.
 Will be called automatically by the Director when a memory warning is received
 @warning Avoid using this method in new code. See class *Overview*.
 */
-(void) purgeCachedEntries;

/** Calling this method will populate the searchResolutionsOrder property depending on the current device.
 @warning Avoid using this method in new code. See class *Overview*.
 */
- (void) buildSearchResolutionsOrder;

/** 
 *  Returns the fullpath of an filename.
 *
 *  If in iPhoneRetinaDisplay mode, and a RetinaDisplay file is found, it will return that path.
 *  If in iPad mode, and an iPad file is found, it will return that path.
 *
 *  If the filename can't be found, it will return "relPath" instead of nil.
 *  Examples:
 *  - In iPad mode: "image.png" -> "/full/path/image-ipad.png" (in case the -ipad file exists)
 *  - In iPhone RetinaDisplay mode: "image.png" -> "/full/path/image-hd.png" (in case the -hd file exists)
 *  - In iPad RetinaDisplay mode: "image.png" -> "/full/path/image-ipadhd.png" (in case the -ipadhd file exists)
 *
 *  @param relPath relative path
 *
 *  @return Full path
 *  @warning Avoid using this method in new code. See class *Overview*.
 */
-(NSString*) fullPathFromRelativePath:(NSString*) relPath;

/** 
 *  Returns the fullpath of an filename. It will try to get the correct file for the current screen resolution.
 *  Useful for loading images and other assets that are related for the screen resolution.
 *  If in iPad mode, and an iPad file is found, it will return that path.
 *  If in iPhoneRetinaDisplay mode, and a RetinaDisplay file is found, it will return that path. But if it is not found, it will try load an iPhone Non-RetinaDisplay  file.
 *
 *  If the filename can't be found, it will return "relPath" instead of nil.
 *  Examples:
 *  - In iPad mode: "image.png" -> "/full/path/image-ipad.png" (in case the -ipad file exists)
 *  - In iPhone RetinaDisplay mode: "image.png" -> "/full/path/image-hd.png" (in case the -hd file exists)
 *  - In iPad RetinaDisplay mode: "image.png" -> "/full/path/image-ipadhd.png" (in case the -ipadhd file exists)
 *
 * @param relPath        Relative path to expand.
 * @param contentScale The resolution to search for.
 *
 * @return Full path
 *  @warning Avoid using this method in new code. See class *Overview*.
 */
-(NSString*) fullPathFromRelativePath:(NSString*)relPath contentScale:(CGFloat *)contentScale;

/** 
 *  Returns the fullpath of an filename without taking into account the screen resolution suffixes or directories.
 *  It will use the "searchPath" though.
 *  If the file can't be found, it will return nil.
 *
 *  Useful for loading music files, shaders, "data" and other files that are not related to the screen resolution of the device.
 *
 *  @param relPath Relative path.
 *
 *  @return Full path.
 *  @warning Avoid using this method in new code. See class *Overview*.
 */
-(NSString*) fullPathFromRelativePathIgnoringResolutions:(NSString*)relPath;

/**
 *  Returns all fullpaths of a filename in all search paths without taking into account the screen resolution suffixes or directories.
 *  It will use the "searchPath" though.
 *  If the file can't be found, it will return an empty array.
 *
 *  Useful for loading the fileLookup.plist and spriteFrameFileList.plist for packages
 *
 *  @param filename Relative path.
 *
 *  @return Array of full paths.
 *  @warning Avoid using this method in new code. See class *Overview*.
 */
- (NSArray *)fullPathsOfFileNameInAllSearchPaths:(NSString *)filename;

/**
 *  Returns the fullpath for a given filename.
 *  First it will try to get a new filename from the "filenameLookup" dictionary. If a new filename can't be found on the dictionary, it will use the original filename.
 *  Then it will try obtain the full path of the filename using the CCFileUtils search rules: resolutions, and search paths
 *
 *  If in iPad mode, and an iPad file is found, it will return that path.
 *  If in iPhoneRetinaDisplay mode, and a RetinaDisplay file is found, it will return that path. But if it is not found, it will try load an iPhone Non-RetinaDisplay  file.
 *
 *  If the filename can't be found on the file system, it will return nil.
 *
 *  This method was added to simplify multiplatform support. Whether you are using cocos2d-js or any cross-compilation toolchain like StellaSDK or Apportable,
 *  you might need to load differerent resources for a given file in the different platforms.
 *  Examples:
 *  - In iPad mode: "image.png" -> "image.pvr" -> "/full/path/image-ipad.pvr" (in case the -ipad file exists)
 *
 *  @param filename Filename to get full path for.
 *
 *  @return FUll path.
 *  @warning Avoid using this method in new code. See class *Overview*.
 */
-(NSString*) fullPathForFilename:(NSString*)filename;

/** 
 *  Returns the fullpath for a given filename.
 *  First it will try to get a new filename from the "filenameLookup" dictionary. If a new filename can't be found on the dictionary, it will use the original filename.
 *  Then it will try obtain the full path of the filename using the CCFileUtils search rules: resolutions, and search paths
 *
 *  If in iPad mode, and an iPad file is found, it will return that path.
 *  If in iPhoneRetinaDisplay mode, and a RetinaDisplay file is found, it will return that path. But if it is not found, it will try load an iPhone Non-RetinaDisplay  file.
 *
 *  If the filename can't be found on the file system, it will return nil.
 *
 *  This method was added to simplify multiplatform support. Whether you are using cocos2d-js or any cross-compilation toolchain like StellaSDK or Apportable,
 *  you might need to load differerent resources for a given file in the different platforms.
 *  Examples:
 *  - In iPad mode: "image.png" -> "image.pvr" -> "/full/path/image-ipad.pvr" (in case the -ipad file exists)
 *
 *  @param filename       Filename to get full path for.
 *  @param contentScale scale factor
 *
 *  @return Full path.
 *  @warning Avoid using this method in new code. See class *Overview*.
 */
-(NSString*) fullPathForFilename:(NSString*)filename contentScale:(CGFloat *)contentScale;

/** 
 *  Returns the fullpath for a given filename, without taking into account device resolution.
 *  It will try to get a new filename from the "filenameLookup" dictionary. If a new filename can't be found on the dictionary, it will use the original filename.
 *
 *  Once it gets the filename, it will try to get the fullpath for the filename, using the "searchPath", but it won't use any resolution search rules.
 *  If the file can't be found, it will return nil.
 *
 *  Useful for loading music files, shaders, "data" and other files that are not related to the screen resolution of the device.
 *
 *  This method was added to simplify multiplatform support. Whether you are using cocos2d-js or any cross-compilation toolchain like StellaSDK or Apportable,
 *  you might need to load differerent resources for a given file in the different platforms.
 *  Examples:
 *  - On iOS: "sound.wav" -> "sound.caf" -> "/full/path/sound.caf" (in case the key dictionary says that "sound.wav" should be converted to "sound.caf")
 *
 *  @param key Key to get full path for.
 *
 *  @return Full path.
 *  @warning Avoid using this method in new code. See class *Overview*.
 */
-(NSString*) fullPathForFilenameIgnoringResolutions:(NSString*)key;

/**
 *  Loads the filenameLookup dictionary from the contents of a filename.
 *
 *  @param filename Filename to query.
 *  @warning Avoid using this method in new code. See class *Overview*.
 */
-(void) loadFilenameLookupDictionaryFromFile:(NSString*)filename;

/**
 *  Loads the filenameLookup dictionary from the contents of a filename in all search paths.
 *
 *  Used for packages to merge filenameLookups found in different search paths.
 *
 *  @param filename Filename to query.
 *  @warning Avoid using this method in new code. See class *Overview*.
 */
- (void)loadFileNameLookupsInAllSearchPathsWithName:(NSString *)filename;

/** 
 *  Removes the suffix from a path.
 *  On iPhone RetinaDisplay it will remove the -hd suffix
 *  On iPad it will remove the -ipad suffix
 *  On iPad RetinaDisplay it will remove the -ipadhd suffix
 *
 *  @param path Path to clean for suffix.
 *
 *  @return Cleaned path.
 *  @warning Avoid using this method in new code. See class *Overview*.
 */
-(NSString *)removeSuffixFromFile:(NSString*) path;

/**
 *  Stadardize a path.
 *  It calls [string stringByStandardizingPath], and if "suffix mode" is on, it will also call [self removeSuffixFromFile:path];
 *
 *  @param path Path to standardize.
 *
 *  @return Standardized path.
 *  @warning Avoid using this method in new code. See class *Overview*.
 */
-(NSString*) standarizePath:(NSString*)path;

#if __CC_PLATFORM_IOS

/** 
 *  Returns whether or not a given path exists with the iPhone RetinaDisplay suffix.
 *  Only available on iOS. Not supported on OS X.
 *
 *  @param filename Filename to test.
 *
 *  @return YES if the file exists.
 *  @warning Avoid using this method in new code. See class *Overview*.
 */
-(BOOL) iPhoneRetinaDisplayFileExistsAtPath:(NSString*)filename;

/** 
 *  Returns whether or not a given filename exists with the iPad suffix.
 *  Only available on iOS. Not supported on OS X.
 *
 *  @param filename Filename to test.
 *
 *  @return YES if the file exists.
 *  @warning Avoid using this method in new code. See class *Overview*.
 */
-(BOOL) iPadFileExistsAtPath:(NSString*)filename;

/** 
 *  Returns whether or not a given filename exists with the iPad RetinaDisplay suffix.
 *  Only available on iOS. Not supported on OS X.
 *
 *  @param filename Filename to test.
 *
 *  @return YES if the file exists.
 *  @warning Avoid using this method in new code. See class *Overview*.
 */
-(BOOL) iPadRetinaDisplayFileExistsAtPath:(NSString*)filename;

#endif // __CC_PLATFORM_MAC

@end

#ifdef __cplusplus
extern "C" {
#endif

/** 
 *  Loads a file into memory.
 *  It is the callers responsibility to release the allocated buffer.
 *
 *  @return The size of the allocated buffer.
 *  @warning Avoid using this method in new code. See class *Overview*.
 */
NSInteger ccLoadFileIntoMemory(const char *filename, unsigned char **out);
	
#ifdef __cplusplus
}
#endif
