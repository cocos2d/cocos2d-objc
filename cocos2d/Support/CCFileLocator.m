#import "CCFileLocator.h"
#import "CCFile.h"
#import "CCPackageConstants.h"
#import "ioapi.h"
#import "CCFile_Private.h"


@implementation CCFileLocator

#pragma mark - Initialization

- (id)init
{
    self = [super init];

    if (self)
    {

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

    [self setErrorPtr:error code:ERROR_FILELOCATOR_NO_FILE_FOUND description:@"No search paths set."];
    return nil;
}

- (CCFile *)findFilename:(NSString *)filename inPath:(NSString *)path
{
    NSFileManager *localFileManager = [[NSFileManager alloc] init];

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

        if ([currentFilename isEqualToString:filename])
        {
            return [[CCFile alloc] initWithName:filename url:theURL contentScale:_defaultContentScale];
        }

        // NSLog(@"-> %@", theURL, fileName);
/*
        // Ignore files under the _extras directory
        if (([fileName caseInsensitiveCompare:@"_extras"] == NSOrderedSame) && [isDirectory boolValue])
        {
            [dirEnumerator skipDescendants];
        }
        else
        {
            // Add full path for non directories
            if (![isDirectory boolValue])
            {
                [theArray addObject:theURL];
            }
        }
*/
    }

    return nil;
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
