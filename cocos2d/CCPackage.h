#import <Foundation/Foundation.h>
#import "CCPackageTypes.h"

@class CCPackageManager;

/** CCPackage represents a Spritebuilder package. It's a data object managed by CCPackageManager describing the details of a package.
 A package is a bundle containing resource files.

 Most of the properties are readonly and are not meant to be set by a developer. They are set by the CCPackageManager.

 The properties can be key value observed. Especially the status property can provide fine grained information about the package's lifecycle.

 You can use the convenience methods of CCPackageManager to create CCPackage instances as well as the provided initializer initWithName:resolution:os:remoteURL:.

 @warning Do not use the standard initializer `-(id) init`.
 */
@interface CCPackage : NSObject

/** @name Initializing a Package */

/**
 *  Creates a new instance of a package.
 *
 *  @param name Name of the package, must not be nil
 *  @param resolution Resolution of the package, must not be nil
 *  @param os OS of the package, usally determined internally, must not be nil
 *  @param remoteURL Remote URL of the package, must not be nil
 *
 *  @return New instance of CCPackage
 *  @since v3.3 and later
 */
- (instancetype)initWithName:(NSString *)name
                  resolution:(NSString *)resolution
                          os:(NSString *)os
                   remoteURL:(NSURL *)remoteURL;

/** @name Accessing Package Information */

/**
 *  Name of the package
 *  @since v3.3 and later
 *  @see standardIdentifier
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 *  Resolution of the package, e.g. tablethd, phonehd, etc.
 *  @since v3.3 and later
 *  @see standardIdentifier
 */
@property (nonatomic, copy, readonly) NSString *resolution;

/**
 *  OS of the package e.g. iOS, Android, Mac
 *  @since v3.3 and later
 *  @see standardIdentifier
 */
@property (nonatomic, copy, readonly) NSString *os;

/**
 *  Returns an identifier of the package: The pattern is `<NAME>-<OS>-<RESOLUTION>`. Example: `DLC_Bundle-iOS-phonehd`.
 *
 *  @return A dictionary containing the values of the package
 *  @since v3.3 and later
 *  @see name <br/> resolution <br/> os
 */
- (NSString *)standardIdentifier;

/** @name Accessing Package URLs */

/**
 *  The remote URL of the package
 *  @since v3.3 and later
 */
@property (nonatomic, copy, readonly) NSURL *remoteURL;

/**
 *  The relative local URL where the package is installed. The URL is relative to the caches folder.
 *  This value will be initially nil and set only if installation was successful.
 *  @since v3.3 and later
 *  @see installFullURL
 */
@property (nonatomic, copy, readonly) NSURL *installRelURL;

/**
 *  Full local URL where the package is installed.
 *  This value will be initially nil and set only if installation was successful.
 *  @since v3.3 and later
 *  @see installRelURL
 */
@property (nonatomic, copy, readonly) NSURL *installFullURL;

/**
 *  Local URL of the download file when download finishes. While downloading a temp name
 *  is used which won't be accessible.
 *  @since v3.3 and later
 */
@property (nonatomic, copy, readonly) NSURL *localDownloadURL;

/**
 *  Local URL of the folder the package is unzipped to
 *  @since v3.3 and later
 */
@property (nonatomic, copy, readonly) NSURL *unzipURL;

/**
 *  Name of the folder inside the unzip folder. A zipped package is supposed to contain a folder named
 *  like this <NAME>-<OS>-<RESOLUTION>. Example: DLC-iOS-phonehd.
 *  This name can vary though and can be determined by delegation if a standard name was not found
 *  during installation.
 *  @since v3.3 and later
 */
@property (nonatomic, copy, readonly) NSString *folderName;

/** @name Accessing Package Status */

/**
 *  Whether or not the the package should be enabled in cocos2d after installation.
 *  @since v3.3 and later
 */
@property (nonatomic, readonly) BOOL enableOnDownload;

/**
 *  The current status of the package
 *  @since v3.3 and later
 *  @see statusToString
 */
@property (nonatomic, readonly) CCPackageStatus status;

/**
 *  Returns the status as a string.
 *  Debugging purposes.
 *
 *  @return A string representation of the status property
 *  @since v3.3 and later
 *  @see status
 */
- (NSString *)statusToString;

/*
 *  Creates a new instance of a package populated with the contents of the dictionary.
 *  Used in context of serialization.
 *
 *  @param dictionary Dictionary containing values to populate the package with.
 *
 *  @return New instance of CCPackage
 *  @since v3.3 and later
 *  @see toDictionary
 */
// purposefully undocumented: The initializer initWithDictionary is for internal use only to persist packages.
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/*
 *  Returns a dictionary containing the values of the package's properties.
 *  Used in context of serialization.
 *
 *  @return A dictionary containing the values of the package
 *  @since v3.3 and later
 *  @see initWithDictionary:
 */
// purposefully undocumented: The initializer initWithDictionary and related toDictionary are for internal use only to persist packages.
- (NSDictionary *)toDictionary;

@end

