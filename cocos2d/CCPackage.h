#import <Foundation/Foundation.h>
#import "CCPackageTypes.h"

@class CCPackageManager;

@interface CCPackage : NSObject

/**
 *  Name of the package
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 *  Resolution of the package, e.g. tablethd, phonehd, etc.
 */
@property (nonatomic, copy, readonly) NSString *resolution;

/**
 *  OS of the package e.g. iOS, Android, Mac
 */
@property (nonatomic, copy, readonly) NSString *os;

/**
 *  The remote URL of the package
 */
@property (nonatomic, copy, readonly) NSURL *remoteURL;

/**
 *  The relative local URL where the package is installed. The URL is relative to the caches folder.
 *  This value will be initially nil and set only if installation was successful.
 */
@property (nonatomic, copy, readonly) NSURL *installRelURL;

/**
 *  Full local URL where the package is installed.
 *  This value will be initially nil and set only if installation was successful.
 */
@property (nonatomic, copy, readonly) NSURL *installFullURL;

/**
 *  Local URL of the download file when download finishes. While downloading a temp name
 *  is used which won't be accessible.
 */
@property (nonatomic, copy, readonly) NSURL *localDownloadURL;

/**
 *  Local URL of the folder the package is unzipped to
 */
@property (nonatomic, copy, readonly) NSURL *unzipURL;

/**
 *  Name of the folder inside the unzip folder. A zipped package is supposed to contain a folder named
 *  like this <NAME>-<OS>-<RESOLUTION>. Example: DLC-iOS-phonehd.
 *  This name can vary though and can be determined by delegation if a standard name was not found
 *  during installation.
 */
@property (nonatomic, copy, readonly) NSString *folderName;

/**
 *  Whether or not the the package should be enabled in cocos2d after installation.
 */
@property (nonatomic, readonly) BOOL enableOnDownload;

/**
 *  The current status of the package
 */
@property (nonatomic, readonly) CCPackageStatus status;

/**
 *  Creates a new instance of a package.
 *
 *  @param name Name of the package, must not be nil
 *  @param resolution Resolution of the package, must not be nil
 *  @param os OS of the package, usally determined internally, must not be nil
 *  @param remoteURL Remote URL of the package, must not be nil
 *
 *  @return New instance of CCPackage
 */
- (instancetype)initWithName:(NSString *)name
                  resolution:(NSString *)resolution
                          os:(NSString *)os
                   remoteURL:(NSURL *)remoteURL;

/**
 *  Creates a new instance of a package populated with the contents of the dictionary.
 *  Used in context of serialization.
 *
 *  @param dictionary Dictionary containing values to populate the package with.
 *
 *  @return New instance of CCPackage
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 *  Returns a dictionary containing the values of the package's properties.
 *  Used in context of serialization.
 *
 *  @return A dictionary containing the values of the package
 */
- (NSDictionary *)toDictionary;

/**
 *  Returns an identifier of the package: The pattern is <NAME>-<OS>-<RESOLUTION>. Example: DLC-iOS-phonehd.
 *
 *  @return A dictionary containing the values of the package
 */
- (NSString *)standardIdentifier;

/**
 *  Returns the status as a string.
 *  Debugging purposes.
 *
 *  @return A string representation of the status property
 */
- (NSString *)statusToString;

@end

