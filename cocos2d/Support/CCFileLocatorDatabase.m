/*
 * cocos2d for iPhone: http://www.cocos2d-swift.org
 *
 * Copyright (c) 2014 Cocos2D Authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#import <Foundation/Foundation.h>
#import "CCFileLocatorDatabase.h"
#import "CCFileMetaData.h"

@interface CCFileLocatorDatabase ()

@property (nonatomic, strong) NSMutableDictionary *databases;

@end


@implementation CCFileLocatorDatabase

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.databases = [NSMutableDictionary dictionary];
    }

    return self;
}

- (BOOL)addJSONWithFilePath:(NSString *)filePath forSearchPath:(NSString *)searchPath error:(NSError **)error
{
    id database = [self loadDatabaseWithFilePath:[searchPath stringByAppendingPathComponent:filePath] error:error];

    if (database)
    {
        _databases[searchPath] = database;
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)removeEntriesForSearchPath:(NSString *)searchPath
{
    [_databases removeObjectForKey:searchPath];
}

- (CCFileMetaData *)metaDataForFileNamed:(NSString *)filename inSearchPath:(NSString *)searchPath;
{
    return [self metaDataFromDictionary:_databases[searchPath][filename]];
}

- (NSMutableDictionary *)loadDatabaseWithFilePath:(NSString *)filePath error:(NSError **)error
{
    NSError *errorData;
    NSData *data = [NSData dataWithContentsOfFile:filePath
                                          options:0
                                            error:&errorData];

    if (!data)
    {
        NSLog(@"Error reading database file as data at \"%@\" with error %@", filePath, errorData);
        if (error)
        {
            *error = errorData;
        }
        return nil;
    }

    NSError *errorJson = nil;
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&errorJson];

    if (!json)
    {
        NSLog(@"Error parsing JSON with error %@", errorJson);
        if (error)
        {
            *error = errorJson;
        }
        return nil;
    }

    return json[@"data"];
}

- (CCFileMetaData *)metaDataFromDictionary:(NSDictionary *)dictionary
{
    NSString *filename = dictionary[@"filename"];

    if (!filename)
    {
        return nil;
    }

    CCFileMetaData *metaData = [[CCFileMetaData alloc] initWithFilename:filename];
    metaData.useUIScale = [dictionary[@"UIScale"] boolValue];

    if ([dictionary[@"localizations"] isKindOfClass:[NSDictionary class]])
    {
        metaData.localizations =  dictionary[@"localizations"];
    }

    return metaData;
}

@end
