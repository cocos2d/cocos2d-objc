#import <Foundation/Foundation.h>
#import "CCFileUtilsV2.h"
#import "CCFile.h"
#import "CCPackageConstants.h"
#import "CCFile_Private.h"
#import "CCFileUtilsDatabaseProtocol.h"


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

@implementation CCFileUtilsV2

- (id)init
{
    self = [super init];

    if (self)
    {
        self.untaggedContentScale = 4;
        self.deviceContentScale = 4;
    }

    return self;
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

- (CCFile *)imageNamed:(NSString *)filename error:(NSError **)error
{
    return [self fileNamed:filename options:nil error:error];
}

- (CCFile *)fileNamed:(NSString *)filename options:(NSDictionary *)options error:(NSError **)error
{
    if (!_searchPaths || _searchPaths.count == 0)
    {
        [self setErrorPtr:error code:ERROR_FILELOCATOR_NO_SEARCH_PATHS description:@"No search paths set."];
        return nil;
    }

    NSDictionary *queryResult = [self queryDatabaseForFilename:filename];

    for (NSString *searchPath in _searchPaths)
    {
        NSString *resolvedFilename = filename;

        if (queryResult)
        {
            resolvedFilename = queryResult[@"filename"];
        }

        CCFile *aFile = [self findFilename:resolvedFilename inPath:searchPath options:options];

        if (aFile)
        {
            if (queryResult)
            {
                aFile.useUIScale = [queryResult[@"useUIScale"] boolValue];
            }
            return aFile;
        }
    }

    [self setErrorPtr:error code:ERROR_FILELOCATOR_NO_FILE_FOUND description:@"No file found."];
    return nil;
}

- (NSDictionary *)queryDatabaseForFilename:(NSString *)filename
{
    if (!_database)
    {
        return nil;
    }

    for (NSString *searchPath in _searchPaths)
    {
        NSDictionary *metaData = [_database metaDataForFileNamed:filename inSearchPath:searchPath];

        if (!metaData || !metaData[@"filename"])
        {
            continue;
        }

        NSString *localizedFileName = [self localizedFilenameWithMetaData:metaData];
        NSString *resolvedFilename = metaData[@"filename"];

        if (localizedFileName)
        {
            resolvedFilename = localizedFileName;
        }

        return @{
            @"filename" : resolvedFilename,
            @"useUIScale" : metaData[@"UIScale"]
                ? metaData[@"UIScale"]
                : @NO
        };
    }

    return nil;
}

- (NSString *)localizedFilenameWithMetaData:(NSDictionary *)dictionary
{
    if (!dictionary[@"localizations"])
    {
        return nil;
    }

    for (NSString *languageID in [NSLocale preferredLanguages])
    {
        NSString *filenameForLanguageID = dictionary[@"localizations"][languageID];
        if (filenameForLanguageID)
        {
            return filenameForLanguageID;
        }
    }

    return nil;
}

- (CCFile *)findFilename:(NSString *)filename inPath:(NSString *)path options:(NSDictionary *)options
{
    NSFileManager *localFileManager = [[NSFileManager alloc] init];

    NSArray *searchFilenames = [self searchFilenamesWithBaseFilename:filename options:options];

    for (CCFileUtilsV2SearchData *fileLocatorSearchData in searchFilenames)
    {
        NSURL *fileURL = [NSURL fileURLWithPath:[path stringByAppendingPathComponent:fileLocatorSearchData.filename]];

        BOOL isDirectory = NO;
        if ([localFileManager fileExistsAtPath:fileURL.path isDirectory:&isDirectory] && !isDirectory)
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
        [result addObject:[self filenameWithBasefilename:baseFilename contentScale:@4]];
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

- (CCFile *)fileNamed:(NSString *)filename error:(NSError **)error
{
    NSDictionary *defaultOptions = @{CCFILEUTILS_SEARCH_OPTION_SKIPRESOLUTIONSEARCH : @YES};

    return [self fileNamed:filename options:defaultOptions error:error];
};

- (void)purgeCache
{

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
