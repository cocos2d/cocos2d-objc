/*
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
#import "CCFileLocator_Private.h"

#import "CCFile.h"
#import "CCFile_Private.h"
#import "CCFileLocatorDatabaseProtocol.h"
#import "CCFileMetaData.h"
#import "ccUtils.h"
#import "CCSetup.h"

// Options are only used internally for now
NSString * const CCFILELOCATOR_SEARCH_OPTION_SKIPRESOLUTIONSEARCH = @"CCFILELOCATOR_SEARCH_OPTION_SKIPRESOLUTIONSEARCH";
NSString * const CCFILELOCATOR_SEARCH_OPTION_NOTRACE = @"CCFILELOCATOR_SEARCH_OPTION_NOTRACE";

#pragma mark - CCFileResolvedMetaData helper class

@interface CCFileResolvedMetaData : NSObject

@property (nonatomic, copy) NSString *filename;
@property (nonatomic) BOOL useUIScale;

@end

@implementation CCFileResolvedMetaData

@end


#pragma mark - CCFileLocator

@interface CCFileLocator ()

@property (nonatomic, strong) NSMutableDictionary *cache;

@end


@implementation CCFileLocator

- (id)init
{
    self = [super init];

    if (self)
    {
        self.searchPaths = @[[[NSBundle mainBundle] resourcePath]];
        self.untaggedContentScale = 4;
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

+ (CCFileLocator *)sharedFileLocator
{
    static CCFileLocator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[CCFileLocator alloc] init];
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

- (CCFile *)fileNamedWithResolutionSearch:(NSString *)filename error:(NSError **)error
{
    return [self fileNamed:filename options:nil error:error trace:NO];
}

- (CCFile *)fileNamed:(NSString *)filename error:(NSError **)error
{
    NSDictionary *defaultOptions = @{CCFILELOCATOR_SEARCH_OPTION_SKIPRESOLUTIONSEARCH : @YES};

    return [self fileNamed:filename options:defaultOptions error:error trace:NO];
};

- (CCFile *)fileNamed:(NSString *)filename options:(NSDictionary *)options error:(NSError **)error trace:(BOOL)trace
{
    if (!_searchPaths || _searchPaths.count == 0)
    {
        [self setErrorPtr:error code:CCFileLocatorErrorNoSearchPaths description:@"No search paths set."];
        return nil;
    }

    CCFile *cachedFile = _cache[filename];
    if (cachedFile) return cachedFile;

    CCFileResolvedMetaData *metaData = [self resolvedMetaDataForFilename:filename trace:trace];
    
    CCFile *result = nil;
    if (filename.isAbsolutePath)
    {
        NSURL *fileURL = [NSURL fileURLWithPath:filename];
        if(trace) CCLOG(@"Checking absolute path: %@", fileURL);
        
        result = [[CCFile alloc] initWithName:filename url:fileURL contentScale:1.0 tagged:YES];
    }
    else
    {
        result = [self findFileInAllSearchPaths:filename metaData:metaData options:options trace:trace];
    }

    if (result)
    {
        return result;
    }
    else
    {
#if DEBUG
        // Search for the file again with tracing enabled.
        if(!trace && ![options[CCFILELOCATOR_SEARCH_OPTION_NOTRACE] boolValue])
        {
            CCLOG(@"CCFileLocator: File not found! '%@'", filename);
            CCLOG(@"Beginning trace with options:%@", options);
            [self fileNamed:filename options:options error:error trace:YES];
        }
#endif
        
        [self setErrorPtr:error code:CCFileLocatorErrorNoFileFound description:@"No file found."];
        return nil;
    }
}

- (CCFile *)findFileInAllSearchPaths:(NSString *)filename metaData:(CCFileResolvedMetaData *)metaData options:(NSDictionary *)options trace:(BOOL)trace
{
    for (NSString *searchPath in _searchPaths)
    {
        NSString *resolvedFilename = filename;

        if (metaData)
        {
            resolvedFilename = metaData.filename;
        }

        CCFile *aFile = [self findFilename:resolvedFilename inSearchPath:searchPath options:options trace:trace];

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

- (CCFileResolvedMetaData *)resolvedMetaDataForFilename:(NSString *)filename trace:(BOOL)trace
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

        if(trace) CCLOG(@"Metadata found: %@", metaData);
        return [self resolveMetaData:metaData trace:trace];
    }

    return nil;
}

- (CCFileResolvedMetaData *)resolveMetaData:(CCFileMetaData *)metaData trace:(BOOL)trace
{
    CCFileResolvedMetaData *fileLocatorResolvedMetaData = [[CCFileResolvedMetaData alloc] init];

    NSString *localizedFileName = [self localizedFilenameWithMetaData:metaData trace:trace];

    fileLocatorResolvedMetaData.filename = localizedFileName ?: metaData.filename;
    fileLocatorResolvedMetaData.useUIScale = metaData.useUIScale;

    return fileLocatorResolvedMetaData;
}

- (NSString *)localizedFilenameWithMetaData:(CCFileMetaData *)metaData trace:(BOOL)trace
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
            if(trace) CCLOG(@"Filename alias found:'%@' for languageID:'%@'", filenameForLanguageID, languageID);
            return filenameForLanguageID;
        }
    }

    return nil;
}

- (CCFile *)findFilename:(NSString *)filename inSearchPath:(NSString *)searchPath options:(NSDictionary *)options trace:(BOOL)trace
{
    __block CCFile *ret = nil;
    
    if(trace) CCLOG(@"Checking in search path:'%@'", searchPath);
    
    [self tryVariantsForFilename:filename options:options block:^(NSString *variantName, CGFloat contentScale, BOOL tagged) {
        NSURL *fileURL = [NSURL fileURLWithPath:[searchPath stringByAppendingPathComponent:variantName]];
        if(trace) CCLOG(@"%@", fileURL);
        
        BOOL isDirectory = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:fileURL.path isDirectory:&isDirectory] && !isDirectory)
        {
            ret = [[CCFile alloc] initWithName:filename url:fileURL contentScale:contentScale tagged:tagged];
            return YES;
        }
        
        return NO;
    }];
    
    return ret;
}

- (NSString *)contentScaleFilenameWithBasefilename:(NSString *)baseFilename contentScale:(NSUInteger)contentScale
{
    NSString *base = [baseFilename stringByDeletingPathExtension];
    NSString *ext = [baseFilename pathExtension];
    
    // Need to handle multiple extensions. (ex: .pvr.gz)
    while([base pathExtension].length > 0)
    {
        ext = [NSString stringWithFormat:@"%@.%@", [base pathExtension], ext];
        base = [base stringByDeletingPathExtension];
    }
    
    return [NSString stringWithFormat:@"%@-%dx.%@", base, (int)contentScale, ext];
}

- (void)tryVariantsForFilename:(NSString *)filename options:(NSDictionary *)options block:(BOOL (^)(NSString *name, CGFloat contentScale, BOOL tagged))block
{
    if ([options[CCFILELOCATOR_SEARCH_OPTION_SKIPRESOLUTIONSEARCH] boolValue])
    {
        block(filename, 1.0, YES);
    }
    else
    {
        NSUInteger contentScale = CCNextPOT(ceil([CCSetup sharedSetup].assetScale));
        
        // First try the highest-res tagged variant.
        NSString *name = [self contentScaleFilenameWithBasefilename:filename contentScale:contentScale];
        if(block(name, contentScale, YES)) return;
        
        // Then the untagged variant.
        if(block(filename, self.untaggedContentScale, NO)) return;
        
        // Then the lower-res tagged variants.
        while(true)
        {
            contentScale /= 2;
            if(contentScale < 1) break;
            
            name = [self contentScaleFilenameWithBasefilename:filename contentScale:contentScale];
            if(block(name, contentScale, YES)) return;
        }
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
