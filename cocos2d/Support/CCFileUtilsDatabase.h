//
// Created by Nicky Weber on 13.01.15.
//

#import <Foundation/Foundation.h>


@interface CCFileUtilsDatabase : NSObject

- (void)addDatabaseWithFilePath:(NSString *)filePath inSearchPath:(NSString *)searchPath;

- (void)removeDatabaseForSearchPath:(NSString *)searchPath;

- (NSDictionary *)metaDataForFileNamed:(NSString *)filename inSearchPath:(NSString *)searchPath;

@end