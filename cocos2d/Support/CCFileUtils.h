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
#import "../ccTypes.h"

/** Helper class to handle file operations */
@interface CCFileUtils : NSObject
{
	NSFileManager	*fileManager_;
	NSBundle		*bundle_;
	NSMutableDictionary *fullPathCache_;
	NSMutableDictionary *removeSuffixCache_;
	
	BOOL	enableFallbackSuffixes_;
	
#ifdef __CC_PLATFORM_IOS	
	NSString *iPhoneRetinaDisplaySuffix_;
	NSString *iPadSuffix_;
	NSString *iPadRetinaDisplaySuffix_;
#elif defined(__CC_PLATFORM_MAC)
	NSString *macSuffix_;
	NSString *macRetinaDisplaySuffix_;
#endif // __CC_PLATFORM_MAC
}

/** NSBundle used by CCFileUtils. By default it uses [NSBundle mainBundle].
 @since v2.0
 */
@property (nonatomic, readwrite, retain) NSBundle	*bundle;

/** NSFileManager used by CCFileUtils. By default it uses its own instance.
 @since v2.0
 */
@property (nonatomic, readwrite, retain) NSFileManager	*fileManager;

/** Whether of not the fallback suffixes is enabled.
 When enabled it will try to search for the following suffixes in the following order until one is found:
 * On iPad HD  : iPad HD suffix, iPad suffix, iPhone HD suffix, Without suffix
 * On iPad     : iPad suffix, iPhone HD suffix, Without suffix
 * On iPhone HD: iPhone HD suffix, Without suffix
 * On Mac HD   : Mac HD suffix, Mac suffix, Without suffix
 * On Mac      : Mac suffix, Without suffix
 
 By default this functionality is off;
 */
@property (nonatomic, readwrite) BOOL enableFallbackSuffixes;


#ifdef __CC_PLATFORM_IOS
/** The iPhone RetinaDisplay suffixes to load resources.
 By default it is "-hd" and "" in that order.
 Only valid on iOS. Not valid for OS X.
 
 @since v1.1
 */
@property (nonatomic,readwrite, copy, setter = setiPhoneRetinaDisplaySuffix:) NSString *iPhoneRetinaDisplaySuffix;

/** The iPad suffixes to load resources.
 By default it is "-ipad", "-hd", "", in that order.
 Only valid on iOS. Not valid for OS X.
 
 @since v1.1
 */
@property (nonatomic,readwrite, copy, setter = setiPadSuffix:) NSString *iPadSuffix;


/** Sets the iPad Retina Display suffixes to load resources.
 By default it is "-ipadhd", "-ipad", "-hd", "", in that order.
 Only valid on iOS. Not valid for OS X.
 
 @since v2.0
 */
@property (nonatomic,readwrite, copy, setter = setiPadRetinaDisplaySuffix:) NSString *iPadRetinaDisplaySuffix;

#elif defined(__CC_PLATFORM_MAC)
/** The Mac suffixes to load resources.
 By default it is "-mac", "" in that order.
 Only valid on OS X. Not valid for iOS.
 
 @since v2.1
 */
@property (nonatomic,readwrite, copy, setter = setMacSuffix:) NSString *macSuffix;

/** The Mac Retina Display suffixes to load resources.
 By default it is "-machd", "-mac", "" in that order.
 Only valid on OS X. Not valid for iOS.
 
 @since v2.1
 */
@property (nonatomic,readwrite, copy, setter = setMacRetinaDisplaySuffix:) NSString *macRetinaDisplaySuffix;

#endif // __CC_PLATFORM_MAC


/** returns the shared file utils instance */
+(CCFileUtils*) sharedFileUtils;


/** Purge cached entries.
 Will be called automatically by the Director when a memory warning is received
 */
-(void) purgeCachedEntries;

/** Returns the fullpath of an filename.

 If in iPhoneRetinaDisplay mode, and a RetinaDisplay file is found, it will return that path.
 If in iPad mode, and an iPad file is found, it will return that path.

 Examples:

  * In iPad mode: "image.png" -> "/full/path/image-ipad.png" (in case the -ipad file exists)
  * In iPhone RetinaDisplay mode: "image.png" -> "/full/path/image-hd.png" (in case the -hd file exists)
  * In iPad RetinaDisplay mode: "image.png" -> "/full/path/image-ipadhd.png" (in case the -ipadhd file exists)

 */
-(NSString*) fullPathFromRelativePath:(NSString*) relPath;


/** Returns the fullpath of an filename including the resolution of the image.
 
 If in RetinaDisplay mode, and a RetinaDisplay file is found, it will return that path.
 If in iPad mode, and an iPad file is found, it will return that path.
 
 Examples:
 
 * In iPad mode: "image.png" -> "/full/path/image-ipad.png" (in case the -ipad file exists)
 * In iPhone RetinaDisplay mode: "image.png" -> "/full/path/image-hd.png" (in case the -hd file exists)
 * In iPad RetinaDisplay mode: "image.png" -> "/full/path/image-ipadhd.png" (in case the -ipadhd file exists)
 * In Mac RetinaDisplay mode: "image.png" -> "/full/path/image-hd.png" (in case the -hd file exists)
 
 If an iPad file is found, it will set resolution type to kCCResolutioniPad
 If a RetinaDisplay file is found, it will set resolution type to kCCResolutionRetinaDisplay
 
 */
-(NSString*) fullPathFromRelativePath:(NSString*)relPath resolutionType:(ccResolutionType*)resolutionType;

#ifdef __CC_PLATFORM_IOS

/** removes the suffix from a path
 * On iPhone RetinaDisplay it will remove the -hd suffix
 * On iPad it will remove the -ipad suffix
 * On iPad RetinaDisplay it will remove the -ipadhd suffix

 Only valid on iOS. Not valid for OS X.

 @since v0.99.5
 */
-(NSString *)removeSuffixFromFile:(NSString*) path;

/** Returns whether or not a given path exists with the iPhone RetinaDisplay suffix.
 Only available on iOS. Not supported on OS X.
 @since v1.1
 */
-(BOOL) iPhoneRetinaDisplayFileExistsAtPath:(NSString*)filename;

/** Returns whether or not a given filename exists with the iPad suffix.
 Only available on iOS. Not supported on OS X.
 @since v1.1
 */
-(BOOL) iPadFileExistsAtPath:(NSString*)filename;

/** Returns whether or not a given filename exists with the iPad RetinaDisplay suffix.
 Only available on iOS. Not supported on OS X.
 @since v2.0
 */
-(BOOL) iPadRetinaDisplayFileExistsAtPath:(NSString*)filename;

#elif defined(__CC_PLATFORM_MAC)

/** Returns whether or not a given filename exists with the Mac RetinaDisplay suffix.
 Only available on OS  X. Not supported on iOS
 @since v2.1
 */
-(BOOL) macRetinaDisplayFileExistsAtPath:(NSString*)filename;

/** Returns whether or not a given filename exists with the Mac RetinaDisplay suffix.
 Only available on OS  X. Not supported on iOS
 @since v2.1
 */
-(BOOL) macFileExistsAtPath:(NSString*)filename;

#endif // __CC_PLATFORM_MAC


@end

#ifdef __cplusplus
extern "C" {
#endif

/** loads a file into memory.
 the caller should release the allocated buffer.

 @returns the size of the allocated buffer
 @since v0.99.5
 */
NSInteger ccLoadFileIntoMemory(const char *filename, unsigned char **out);
	
#ifdef __cplusplus
}
#endif
