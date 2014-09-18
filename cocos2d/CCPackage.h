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
 *  The local URL where the package is installed. This value will be initially nil and set only if installation was successful.
 */
@property (nonatomic, copy, readonly) NSURL *installURL;

/**
 *  The current status of the package
 */
@property (nonatomic, readonly) CCPackageStatus status;


/**
 *  Creates a new instance of a package.
 *
 *  @param name Name of the package
 *  @param resolution Resolution of the package
 *  @param remoteURL Remote URL of the package
 *
 *  @return New instance of CCPackage
 */
- (instancetype)initWithName:(NSString *)name
                  resolution:(NSString *)resolution
                   remoteURL:(NSURL *)remoteURL;

/**
 *  Creates a new instance of a package.
 *
 *  @param name Name of the package
 *  @param resolution Resolution of the package
 *  @param os OS of the package, usally determined internally
 *  @param remoteURL Remote URL of the package
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

