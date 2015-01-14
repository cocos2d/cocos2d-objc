#import <Foundation/Foundation.h>
#import "CCFileUtilsDatabase.h"

@interface CCFileUtilsDatabase ()

@property (nonatomic, strong) NSMutableDictionary *databases;

@end


@implementation CCFileUtilsDatabase

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.databases = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)addDatabaseWithFilePath:(NSString *)filePath inSearchPath:(NSString *)searchPath
{
    id database = [self loadDatabaseWithFilePath:[searchPath stringByAppendingPathComponent:filePath]];

    if (database)
    {
        _databases[searchPath] = database;
    }
}

- (void)removeDatabaseForSearchPath:(NSString *)searchPath
{
    [_databases removeObjectForKey:searchPath];
}

- (NSDictionary *)metaDataForFileNamed:(NSString *)filename inSearchPath:(NSString *)searchPath;
{
    return _databases[searchPath][filename];
}

- (NSMutableDictionary *)loadDatabaseWithFilePath:(NSString *)filePath
{
    NSError *errorData;
    NSData *data = [NSData dataWithContentsOfFile:filePath
                                          options:nil
                                            error:&errorData];

    if (!data)
    {
        NSLog(@"Error reading database file as data at \"%@\" with error %@", filePath, errorData);
        return nil;
    }

    NSError *errorJson = nil;
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&errorJson];

    if (!json)
    {
        NSLog(@"Error parsing JSON with error %@", errorJson);
        return nil;
    }

    return json;
}

@end
