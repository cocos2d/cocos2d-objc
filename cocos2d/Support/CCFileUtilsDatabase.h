//
// Created by Nicky Weber on 13.01.15.
//

#import <Foundation/Foundation.h>
#import "CCFileUtilsDatabaseProtocol.h"

@interface CCFileUtilsDatabase : NSObject <CCFileUtilsDatabaseProtocol>

- (void)addDatabaseWithFilePath:(NSString *)filePath inSearchPath:(NSString *)searchPath;

- (void)removeDatabaseForSearchPath:(NSString *)searchPath;

@end
