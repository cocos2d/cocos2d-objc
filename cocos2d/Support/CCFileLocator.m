#import "CCFileLocator.h"
#import "CCFile.h"
#import "CCPackageConstants.h"


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
