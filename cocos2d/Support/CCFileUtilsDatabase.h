//
// Created by Nicky Weber on 13.01.15.
//

#import <Foundation/Foundation.h>
#import "CCFileUtilsDatabaseProtocol.h"

@interface CCFileUtilsDatabase : NSObject <CCFileUtilsDatabaseProtocol>

- (BOOL)addDatabaseWithFilePath:(NSString *)filePath forSearchPath:(NSString *)searchPath error:(NSError **)error;

- (void)removeDatabaseForSearchPath:(NSString *)searchPath;

@end
