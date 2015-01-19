//
// Created by Nicky Weber on 08.01.15.
//

#import <Foundation/Foundation.h>

@class CCFile;
@protocol CCFileUtilsDatabaseProtocol;


@interface CCFileUtilsV2 : NSObject

@property (nonatomic, copy) NSArray *searchPaths;

// A database that can be queried for metadata and filepaths of an asset
@property (nonatomic, strong) id <CCFileUtilsDatabaseProtocol> database;

// Base content scale for untagged, automatically resized assets.
// Required to be a power of two.
// Default is 4
@property (nonatomic, assign) NSUInteger untaggedContentScale;

// Default is 4
@property (nonatomic, assign) NSUInteger deviceContentScale;


+ (CCFileUtilsV2 *)sharedFileUtils;

- (CCFile *)imageNamed:(NSString *)filename error:(NSError **)error;

- (CCFile *)fileNamed:(NSString *)filename error:(NSError **)error;

- (void)purgeCache;

@end
