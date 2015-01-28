/*
 * cocos2d for iPhone: http://www.cocos2d-swift.org
 *
 * Copyright (c) 2014 Cocos2D Authors
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
 */


#import <Foundation/Foundation.h>

@class CCFile;
@protocol CCFileLocatorDatabaseProtocol;

// CCFileLocator NSError code values.
typedef NS_ENUM(NSInteger, CCFileLocatorError){
    /**
     Error indicating that there are no search paths available in CCFileUtils.

     @since 4.0
     */
    CCFileLocatorErrorNoSearchPaths = 20000,
    
    /**
     Error: No file could be found for a given filename.

     @since 4.0
     */
    CCFileLocatorErrorNoFileFound = 20001,
};

/**
 Class to find assets in search paths taking localization and image content scales into account.
 
 General idea is to provide the filename only and depending on the device's settings and capabilities(resolution) an appropriate CCFile instance is returned.

 There are two methods available to access files: fileNamedWithResolutionSearch and fileNamed. fileNamedWithResolutionSearch is supposed to be used for image lookups as well as other files containing a resolution specific tag if you like to optimize visual quality depending on the device's resolution. See below.
 FileNamed works for any file.

 To provide localizations and file aliasing(usually only used by Spritebuilder managed projects) a database has to be provided containing the required metadata to look up files.
 If you like to provide your own custom database it has to adopt the CCFileLocatorDatabaseProtocol. The CCFileLocatorDatabase is a simple example to add the contents of json files to the database per search path.
 CCFileMetaData instances are returned by a database to provide information on localizations and if UI scaling should happen.
 Any file can use the localization mechanics, all that's needed is an entry in the database with the corresponding localized file referenced by languageID.
 For details see CCFileMetaData.h.

 Images are searched for depending on the device's content scale and the availability of an image's resolution variants.
 You can provide three different content scale variants in a bundle: 1x, 2x and 4x. The naming convention is <FILENAME>-<CONTENTSCALE>x.<EXETENSION> for explicitly tagged files.
 Example Hero.png:
  * Hero-1x.png
  * Hero-2x.png
  * Hero-4x.png

 If the explicit content scale tag is omitted then it's content scale is determined by the property untaggedContentScale.

 The search will try to match the device's content scale first. If there is no matching variant then file utils will look for an image which content scale is at max 2x greater than the device's content scale.
 If there is none it will look for the next lower POT scale and so on.

 Explicitly tagged files take precedence over untagged images.

 @since 4.0
 */
@interface CCFileLocator : NSObject


/**
 All paths that will be searched for assets. Provide full directory paths.
 
 Changing the searchPaths will purge the cache.
 
 @since 4.0
 */
@property (nonatomic, copy) NSArray *searchPaths;

/**
 A database that can be queried for metadata and filepaths of an asset.
 Refer to the CCFileLocatorDatabaseProtocol for more details about the interface required.
 
 @since 4.0
 */
@property (nonatomic, strong) id <CCFileLocatorDatabaseProtocol> database;

/**
 Base content scale for untagged, automatically resized assets.
 Required to be a power of two. Fully supported values: 4, 2 and 1
 
 @since 4.0
 */
@property (nonatomic, assign) NSUInteger untaggedContentScale;

/**
 The device's content scale.
 
 @since 4.0
 */
@property (nonatomic, assign) NSUInteger deviceContentScale;

/**
 Returns a singleton instance of the file utils.
 
 @return An shared instance of this class
 
 @since 4.0
 */
+ (CCFileLocator *)sharedFileLocator;

/**
 Returns an instance of CCFile if a file was found.
 This method is meant to be used for images and other files that have a resolution tag included in their names as it will search for resolutions matching the device's content scale.
 
 See header for details on search order.
 
 @param filename the file's filename to search for. Note: filenames are the relative path to a search path including the filename, e.g. images/vehicles/car.png
 @param error    On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 
 @return An instance of CCFile pointing to a file found. If an error occured nil is returned and assigns an appropriate error object to the error parameter.
 
 @since 4.0
 */
- (CCFile *)fileNamedWithResolutionSearch:(NSString *)filename error:(NSError **)error;

/**
 Returns an instance of CCFile if a file was found.
 This method is meant to be used for non-images as it will NOT search for resolutions matching the device's content scale like fileNamedWithResolutionSearch does.
 
 @param filename the filename to search for. Note: filenames are the relative path to a search path including the filename, e.g. sounds/vehicles/honk.wav
 @param error    On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 
 @return An instance of CCFile pointing to a file found. If an error occured nil is returned and assigns an appropriate error object to the error parameter.
 
 @since 4.0
 */
- (CCFile *)fileNamed:(NSString *)filename error:(NSError **)error;

/**
 Purges the cache used internally. If assets get invalid(move, delete) invoking this method can help get rid of false positives.
 
 @since 4.0
 */
- (void)purgeCache;

@end
