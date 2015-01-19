//
// Created by Nicky Weber on 08.01.15.
//

#import <Foundation/Foundation.h>

@class CCFile;
@protocol CCFileUtilsDatabaseProtocol;


@interface CCFileUtilsV2 : NSObject

// All paths the should be searched for assets. Provide full directory paths.
// Changing the searchPaths will purge the cache.
@property (nonatomic, copy) NSArray *searchPaths;

// A database that can be queried for metadata and filepaths of an asset
@property (nonatomic, strong) id <CCFileUtilsDatabaseProtocol> database;

// Base content scale for untagged, automatically resized assets.
// Required to be a power of two. Fully supported values: 4, 2 and 1
@property (nonatomic, assign) NSUInteger untaggedContentScale;

// The device's content scale.
@property (nonatomic, assign) NSUInteger deviceContentScale;

// Returns a singleton instance of the file utils.
+ (CCFileUtilsV2 *)sharedFileUtils;

- (CCFile *)imageNamed:(NSString *)filename error:(NSError **)error;

- (CCFile *)fileNamed:(NSString *)filename error:(NSError **)error;

// Purges the cache used internally. If assets get invalid(move, delete) invoking this method can help get rid of false positives.
- (void)purgeCache;

@end
