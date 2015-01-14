//
// Created by Nicky Weber on 08.01.15.
//

#import <Foundation/Foundation.h>


@class CCFile;
@class CCFileUtilsDatabase;
@protocol CCFileUtilsDatabaseProtocol;


@interface CCFileUtilsV2 : NSObject

@property (nonatomic, copy) NSArray *searchPaths;

// A database that can be queried for metadata and filepaths of an asset
@property (nonatomic, strong) id <CCFileUtilsDatabaseProtocol> database;

// Base content scale for untagged, automatically resized assets.
// Required to be a power of two.
// Default is 4
@property (nonatomic, assign) NSUInteger untaggedContentScale;

// The user's preferred languages as an array of NSString objects, where each string is a language ID.
@property (nonatomic, copy) NSArray *preferredLanguages;

// Default is 4
@property (nonatomic, assign) NSUInteger deviceContentScale;

// User definable, but default to a reasonable standard value (tablet, phone, desktop, etc)
@property (nonatomic, copy) NSString *deviceFamily;


+ (CCFileUtilsV2 *)sharedFileUtils;

- (CCFile *)fileNamed:(NSString *)filename options:(NSDictionary *)options error:(NSError **)error;

// Calls fileNamed:options: on the shared delegate with reasonable default options.
- (CCFile *)fileNamed:(NSString *)filename error:(NSError **)error;

- (void)purgeCache;

@end
