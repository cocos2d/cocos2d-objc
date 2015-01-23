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
#import "CCFile_Private.h"
#import "CCFileUtilsDatabaseProtocol.h"
#import "CCFileMetaData.h"

NSUInteger const ERROR_FILEUTILS_NO_SEARCH_PATHS = 20000;

NSUInteger const ERROR_FILEUTILS_NO_FILE_FOUND = 20001;


// Options are only used internally for now
static NSString *const CCFILEUTILS_SEARCH_OPTION_SKIPRESOLUTIONSEARCH = @"CCFILEUTILS_SEARCH_OPTION_SKIPRESOLUTIONSEARCH";

// Define CCFILEUTILS_TRACE_SEARCH as 1 to get trace logs of a search for debugging purposes
#if CCFILEUTILS_TRACE_SEARCH == 1
	#define TraceLog( s, ... ) NSLog( @"[CCFILEUTILS][TRACE] %@", [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
	#define TraceLog( s, ... )
#endif


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

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, scale %@", _filename, _contentScale];
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
    TraceLog(@"Start searching for image named \"%@\" including content scale variants...", filename);
    return [self fileNamed:filename options:nil error:error];
}

- (CCFile *)fileNamed:(NSString *)filename error:(NSError **)error
{
    TraceLog(@"Start searching for file named \"%@\"...", filename);
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
        TraceLog(@"SUCCESS: Cache hit for \”%@\” -> %@", filename, cachedFile);
        return cachedFile;
    };

    CCFileResolvedMetaData *metaData = [self resolvedMetaDataForFilename:filename];

    CCFile *result = [self findFileInAllSearchPaths:filename metaData:metaData options:options];

    if (result)
    {
        return result;
    }

    [self setErrorPtr:error code:ERROR_FILEUTILS_NO_FILE_FOUND description:@"No file found."];
    return nil;
}

- (CCFile *)findFileInAllSearchPaths:(NSString *)filename metaData:(CCFileResolvedMetaData *)metaData options:(NSDictionary *)options
{
    for (NSString *searchPath in _searchPaths)
    {
        NSString *resolvedFilename = filename;

        if (metaData)
        {
            resolvedFilename = metaData.filename;
        }

        CCFile *aFile = [self findFilename:resolvedFilename inSearchPath:searchPath options:options];

        if (aFile)
        {
            if (metaData)
            {
                aFile.useUIScale = metaData.useUIScale;
            }

            _cache[filename] = aFile;
            return aFile;
        }
    }
    return nil;
}

- (CCFileResolvedMetaData *)resolvedMetaDataForFilename:(NSString *)filename
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

        TraceLog(@"* Database entry for search path \"%@\": %@", searchPath, metaData);
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
            TraceLog(@"* Localization for languageID \"%@\" found: \"%@\"", languageID, filenameForLanguageID);
            return filenameForLanguageID;
        }
    }

    return nil;
}

- (CCFile *)findFilename:(NSString *)filename inSearchPath:(NSString *)searchPath options:(NSDictionary *)options
{
    NSArray *searchVariants = [self contentScaleVariantsWithFilename:filename options:options];

    TraceLog(@"* Searching for content scale variants: %@", searchVariants);

    for (CCFileUtilsV2SearchData *fileLocatorSearchData in searchVariants)
    {
        NSURL *fileURL = [NSURL fileURLWithPath:[searchPath stringByAppendingPathComponent:fileLocatorSearchData.filename]];

        BOOL isDirectory = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:fileURL.path isDirectory:&isDirectory] && !isDirectory)
        {
            TraceLog(@"SUCCESS: File exists! Filename: \"%@\" in search path: \"%@\"", fileLocatorSearchData.filename, searchPath);
            return [[CCFile alloc] initWithName:filename url:fileURL contentScale:[fileLocatorSearchData.contentScale floatValue]];
        }
    }
    return nil;
}

- (CCFileUtilsV2SearchData *)contentScaleFilenameWithBasefilename:(NSString *)baseFilename contentScale:(NSNumber *)contentScale
{
    NSString *filename = [[NSString stringWithFormat:@"%@-%dx",
                           [baseFilename stringByDeletingPathExtension],
                           [contentScale unsignedIntegerValue]] stringByAppendingPathExtension:[baseFilename pathExtension]];

    return [[CCFileUtilsV2SearchData alloc] initWithFilename:filename contentScale:contentScale];
}

- (NSArray *)contentScaleVariantsWithFilename:(NSString *)filename options:(NSDictionary *)options
{
    NSMutableArray *searchVariantFilenames = [NSMutableArray arrayWithCapacity:4];

    if (options[CCFILEUTILS_SEARCH_OPTION_SKIPRESOLUTIONSEARCH])
    {
        return @[[[CCFileUtilsV2SearchData alloc] initWithFilename:filename contentScale:@(_untaggedContentScale)]];
    }

    if (_deviceContentScale >= 3)
    {
        [searchVariantFilenames addObject:[self contentScaleFilenameWithBasefilename:filename contentScale:@4]];
        [searchVariantFilenames addObject:[self contentScaleFilenameWithBasefilename:filename contentScale:@2]];
        [searchVariantFilenames addObject:[self contentScaleFilenameWithBasefilename:filename contentScale:@1]];
    }

    if (_deviceContentScale == 2)
    {
        [searchVariantFilenames addObject:[self contentScaleFilenameWithBasefilename:filename contentScale:@2]];
        [searchVariantFilenames addObject:[self contentScaleFilenameWithBasefilename:filename contentScale:@4]];
        [searchVariantFilenames addObject:[self contentScaleFilenameWithBasefilename:filename contentScale:@1]];
    }

    if (_deviceContentScale == 1)
    {
        [searchVariantFilenames addObject:[self contentScaleFilenameWithBasefilename:filename contentScale:@1]];
        [searchVariantFilenames addObject:[self contentScaleFilenameWithBasefilename:filename contentScale:@2]];
    }

    [self insertUntaggedFilename:filename intoSearchVariantFilenames:searchVariantFilenames];

    return searchVariantFilenames;
}

- (void)insertUntaggedFilename:(NSString *)filename intoSearchVariantFilenames:(NSMutableArray *)filenames
{
    for (NSUInteger i = 0; i < filenames.count - 1; ++i)
    {
        CCFileUtilsV2SearchData *filenameData = filenames[i];
        if ([filenameData.contentScale unsignedIntegerValue] == _untaggedContentScale)
        {
            CCFileUtilsV2SearchData *filenameDataToInsert = [[CCFileUtilsV2SearchData alloc] initWithFilename:filename
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
