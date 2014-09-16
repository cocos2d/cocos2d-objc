#import <Foundation/Foundation.h>
#import "CCPackageTypes.h"

@class CCPackageManager;

@interface CCPackage : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *resolution;
@property (nonatomic, copy, readonly) NSString *os;
@property (nonatomic, copy, readonly) NSURL *remoteURL;
@property (nonatomic, copy, readonly) NSURL *installURL;
@property (nonatomic, readonly) CCPackageStatus status;

- (instancetype)initWithName:(NSString *)name
                  resolution:(NSString *)resolution
                          os:(NSString *)os
                   remoteURL:(NSURL *)remoteURL;

// Returns a new instance of a package populated with the contents of the dictionary
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

// Returns a dictionary containing the values of the package's properties.
- (NSDictionary *)toDictionary;

// Returns an identifier of the package: The pattern is <NAME>-<OS>-<RESOLUTION>. Example: DLC-iOS-phonehd.
// This name can vary though and can be determined by delegation.
- (NSString *)standardIdentifier;

// Debug
- (NSString *)statusToString;

@end