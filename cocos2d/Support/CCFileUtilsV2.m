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
#import "CCFileUtilsV2.h"
#import "CCFile.h"
#import "CCFileUtilsConstants.h"
#import "CCFile_Private.h"
#import "CCFileUtilsDatabaseProtocol.h"
#import "CCFileMetaData.h"

static NSString *const CCFILEUTILS_SEARCH_OPTION_SKIPRESOLUTIONSEARCH = @"CCFILEUTILS_SEARCH_OPTION_SKIPRESOLUTIONSEARCH";


#pragma mark - CCFileResolvedMetaData helper class

@interface CCFileResolvedMetaData : NSObject

@property (nonatomic, copy) NSString *filename;
@property (nonatomic) BOOL useUIScale;

@end

@implementation CCFileResolvedMetaData

@end


#pragma mark - CCFileLocatorSearchData helper class


@interface CCFileUtilsV2SearchData : NSObject

@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSNumber *contentScale;

- (instancetype)initWithFilename:(NSString *)filename contentScale:(NSNumber *)contentScale;

@end


@implementation CCFileUtilsV2SearchData

- (instancetype)initWithFilename:(NSString *)filename contentScale:(NSNumber *)contentScale
{
    self = [super init];

    if (self)
    {
        self.filename = filename;
        self.contentScale = contentScale;
    }

    return self;
}

@end


#pragma mark - CCFileLocator

@interface CCFileUtilsV2()

@property (nonatomic, strong) NSMutableDictionary *cache;

@end


@implementation CCFileUtilsV2

- (id)init
{
    self = [super init];

    if (self)
    {
        self.untaggedContentScale = 4;
        self.deviceContentScale = 4;
        self.cache = [NSMutableDictionary dictionary];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(purgeCache)
                                                     name:NSCurrentLocaleDidChangeNotification
                                                   object:nil];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (CCFileUtilsV2 *)sharedFileUtils
{
    static CCFileUtilsV2 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[CCFileUtilsV2 alloc] init];
    });
    return sharedInstance;
}

- (void)setSearchPaths:(NSArray *)searchPaths
{
    if ([_searchPaths isEqualToArray:searchPaths])
    {
        return;
    }

    _searchPaths = [searchPaths copy];

    [self purgeCache];
}

- (CCFile *)imageNamed:(NSString *)filename error:(NSError **)error
{
    return [self fileNamed:filename options:nil error:error];
}

- (CCFile *)fileNamed:(NSString *)filename error:(NSError **)error
{
    NSDictionary *defaultOptions = @{CCFILEUTILS_SEARCH_OPTION_SKIPRESOLUTIONSEARCH : @YES};

    return [self fileNamed:filename options:defaultOptions error:error];
};

- (CCFile *)fileNamed:(NSString *)filename options:(NSDictionary *)options error:(NSError **)error
{
    if (!_searchPaths || _searchPaths.count == 0)
    {
        [self setErrorPtr:error code:ERROR_FILEUTILS_NO_SEARCH_PATHS description:@"No search paths set."];
        return nil;
    }

    CCFile *cachedFile = _cache[filename];
    if (cachedFile)
    {
        return cachedFile;
    }

    CCFileResolvedMetaData *queryResult = [self queryDatabaseForFilename:filename];

    for (NSString *searchPath in _searchPaths)
    {
        NSString *resolvedFilename = filename;

        if (queryResult)
        {
            resolvedFilename = queryResult.filename;
        }

        CCFile *aFile = [self findFilename:resolvedFilename inPath:searchPath options:options];

        if (aFile)
        {
            if (queryResult)
            {
                aFile.useUIScale = queryResult.useUIScale;
            }

            _cache[filename] = aFile;

            return aFile;
        }
    }

    [self setErrorPtr:error code:ERROR_FILEUTILS_NO_FILE_FOUND description:@"No file found."];
    return nil;
}

- (CCFileResolvedMetaData *)queryDatabaseForFilename:(NSString *)filename
{
    if (!_database)
    {
        return nil;
    }

    for (NSString *searchPath in _searchPaths)
    {
        CCFileMetaData *metaData = [_database metaDataForFileNamed:filename inSearchPath:searchPath];

        if (!metaData)
        {
            continue;
        }

        return [self resolveMetaData:metaData];
    }

    return nil;
}

- (CCFileResolvedMetaData *)resolveMetaData:(CCFileMetaData *)metaData
{
    CCFileResolvedMetaData *fileUtilsV2ResolvedMetaData = [[CCFileResolvedMetaData alloc] init];

    NSString *localizedFileName = [self localizedFilenameWithMetaData:metaData];

    fileUtilsV2ResolvedMetaData.filename = localizedFileName
            ? localizedFileName
            : metaData.filename;

    fileUtilsV2ResolvedMetaData.useUIScale = metaData.useUIScale;

    return fileUtilsV2ResolvedMetaData;
}

- (NSString *)localizedFilenameWithMetaData:(CCFileMetaData *)metaData
{
    if (!metaData.localizations)
    {
        return nil;
    }

    for (NSString *languageID in [NSLocale preferredLanguages])
    {
        NSString *filenameForLanguageID = metaData.localizations[languageID];
        if (filenameForLanguageID)
        {
            return filenameForLanguageID;
        }
    }

    return nil;
}

- (CCFile *)findFilename:(NSString *)filename inPath:(NSString *)path options:(NSDictionary *)options
{
    NSArray *searchFilenames = [self searchFilenamesWithBaseFilename:filename options:options];

    for (CCFileUtilsV2SearchData *fileLocatorSearchData in searchFilenames)
    {
        NSURL *fileURL = [NSURL fileURLWithPath:[path stringByAppendingPathComponent:fileLocatorSearchData.filename]];

        BOOL isDirectory = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:fileURL.path isDirectory:&isDirectory] && !isDirectory)
        {
            return [[CCFile alloc] initWithName:filename url:fileURL contentScale:[fileLocatorSearchData.contentScale floatValue]];
        }
    }

    return nil;
}

- (CCFileUtilsV2SearchData *)filenameWithBasefilename:(NSString *)baseFilename contentScale:(NSNumber *)contentScale
{
    NSString *filename = [[NSString stringWithFormat:@"%@-%dx",
                           [baseFilename stringByDeletingPathExtension],
                           [contentScale unsignedIntegerValue]] stringByAppendingPathExtension:[baseFilename pathExtension]];

    return [[CCFileUtilsV2SearchData alloc] initWithFilename:filename contentScale:contentScale];
}

- (NSArray *)searchFilenamesWithBaseFilename:(NSString *)baseFilename options:(NSDictionary *)options
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:4];

    if (options[CCFILEUTILS_SEARCH_OPTION_SKIPRESOLUTIONSEARCH])
    {
        return @[[[CCFileUtilsV2SearchData alloc] initWithFilename:baseFilename contentScale:@(_untaggedContentScale)]];
    }

    if (_deviceContentScale >= 3)
    {
        [result addObject:[self filenameWithBasefilename:baseFilename contentScale:@4]];
        [result addObject:[self filenameWithBasefilename:baseFilename contentScale:@2]];
        [result addObject:[self filenameWithBasefilename:baseFilename contentScale:@1]];
    }

    if (_deviceContentScale == 2)
    {
        [result addObject:[self filenameWithBasefilename:baseFilename contentScale:@2]];
        [result addObject:[self filenameWithBasefilename:baseFilename contentScale:@4]];
        [result addObject:[self filenameWithBasefilename:baseFilename contentScale:@1]];
    }

    if (_deviceContentScale == 1)
    {
        [result addObject:[self filenameWithBasefilename:baseFilename contentScale:@1]];
        [result addObject:[self filenameWithBasefilename:baseFilename contentScale:@2]];
    }

    [self insertDefaultScaleWithBaseFilename:baseFilename intoSearchFilenames:result];

    return result;
}

- (void)insertDefaultScaleWithBaseFilename:(NSString *)baseFilename intoSearchFilenames:(NSMutableArray *)filenames
{
    for (NSUInteger i = 0; i < filenames.count - 1; ++i)
    {
        CCFileUtilsV2SearchData *filenameData = filenames[i];
        if ([filenameData.contentScale unsignedIntegerValue] == _untaggedContentScale)
        {
            CCFileUtilsV2SearchData *filenameDataToInsert = [[CCFileUtilsV2SearchData alloc] initWithFilename:baseFilename
                                                                                                 contentScale:@(_untaggedContentScale)];

            [filenames insertObject:filenameDataToInsert atIndex:i+1];
            return;
        };
    }
}

- (void)purgeCache
{
    [_cache removeAllObjects];
}

- (void)setErrorPtr:(NSError **)errorPtr code:(NSInteger)code description:(NSString *)description
{
    if (errorPtr)
    {
        *errorPtr = [NSError errorWithDomain:@"cocos2d"
                                        code:code
                                    userInfo:@{NSLocalizedDescriptionKey : description}];
    }
}

@end
