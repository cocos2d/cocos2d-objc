#import "CCFileLocator.h"
#import "CCFile.h"
#import "CCPackageConstants.h"
#import "CCFile_Private.h"
#import "CCEffect_Private.h"


@interface CCFileLocator()

@end


@implementation CCFileLocator

- (id)init
{
    self = [super init];

    if (self)
    {
        self.defaultContentScale = 4;
        self.deviceContentScale = 4;
    }

    return self;
}

+ (CCFileLocator *)sharedFileUtils
{
    static CCFileLocator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[CCFileLocator alloc] init];
    });
    return sharedInstance;
}

- (CCFile *)fileNamed:(NSString *)filename options:(NSDictionary *)options error:(NSError **)error
{
    if (!_searchPaths || _searchPaths.count == 0)
    {
        [self setErrorPtr:error code:ERROR_FILELOCATOR_NO_SEARCH_PATHS description:@"No search paths set."];
        return nil;
    }

    for (NSString *searchPath in _searchPaths)
    {
        CCFile *aFile = [self findFilename:filename inPath:searchPath];
        if (aFile)
        {
            return aFile;
        }
    }

    [self setErrorPtr:error code:ERROR_FILELOCATOR_NO_FILE_FOUND description:@"No file found."];
    return nil;
}

- (CCFile *)findFilename:(NSString *)filename inPath:(NSString *)path
{
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSArray *searchFilenames = [self searchFilenamesWithFilename:filename];


    for (id searchFilename in searchFilenames)
    {
        NSDirectoryEnumerator *dirEnumerator = [localFileManager enumeratorAtURL:[NSURL fileURLWithPath:path isDirectory:YES]
                                                      includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                    errorHandler:nil];

        for (NSURL *theURL in dirEnumerator)
        {
            NSString *currentFilename;
            [theURL getResourceValue:&currentFilename forKey:NSURLNameKey error:NULL];

            NSNumber *isDirectory;
            [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];

            // NSLog(@"-> %@ in %@", currentFilename, theURL);

            if ([currentFilename isEqualToString:searchFilename[@"filename"]] && ![isDirectory boolValue])
            {
                return [[CCFile alloc] initWithName:filename url:theURL contentScale:[searchFilename[@"contentscale"] floatValue]];
            }
        }
    }

    return nil;
}

- (NSDictionary *)filename:(NSString *)filename contentScale:(NSNumber *)contentScale
{
    return @{
        @"filename" : [[NSString stringWithFormat:@"%@-%dx",
                                 [filename stringByDeletingPathExtension],
                                 [contentScale unsignedIntegerValue]] stringByAppendingPathExtension:[filename pathExtension]],
        @"contentscale" : contentScale
    };
}

- (NSArray *)searchFilenamesWithFilename:(NSString *)filename
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:4];

    if (_deviceContentScale == 3 || _deviceContentScale == 4)
    {
        [result addObject:[self filename:filename contentScale:@4]];
        [result addObject:[self filename:filename contentScale:@2]];
        [result addObject:[self filename:filename contentScale:@1]];
    }

    if (_deviceContentScale == 2)
    {
        [result addObject:[self filename:filename contentScale:@2]];
        [result addObject:[self filename:filename contentScale:@4]];
        [result addObject:[self filename:filename contentScale:@1]];
    }

    if (_deviceContentScale == 1)
    {
        [result addObject:[self filename:filename contentScale:@1]];
        [result addObject:[self filename:filename contentScale:@2]];
        [result addObject:[self filename:filename contentScale:@4]];
    }

    [self insertDefaultScaleWithFilename:filename intoSearchFilenames:result];

    return result;
}

- (void)insertDefaultScaleWithFilename:(NSString *)filename intoSearchFilenames:(NSMutableArray *)filenames
{
    for (NSUInteger i = 0; i < filenames.count - 1; ++i)
    {
        NSDictionary *filenameData = filenames[i];
        if ([filenameData[@"contentscale"] unsignedIntegerValue] == _defaultContentScale)
        {
            [filenames insertObject:@{@"filename" : filename, @"contentscale" : @(_defaultContentScale)} atIndex:i];
            return;
        };
    }
}

- (CCFile *)fileNamed:(NSString *)filename error:(NSError **)error
{
    NSDictionary *defaultOptions = @{};

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
