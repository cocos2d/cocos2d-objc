#import "CCPackageUnzipper.h"
#import "CCPackageUnzipperDelegate.h"
#import "CCPackage.h"
#import <SSZipArchive/SSZipArchive.h>
#import "ccMacros.h"


@interface CCPackageUnzipper ()

@property (nonatomic, strong, readwrite) CCPackage *package;
#if OS_OBJECT_HAVE_OBJC_SUPPORT == 1
@property (nonatomic, strong, readwrite) dispatch_queue_t queue;
#else
@property (nonatomic, readwrite) dispatch_queue_t queue;
#endif

@end


@implementation CCPackageUnzipper

- (instancetype)initWithPackage:(CCPackage *)package
{
    self = [super init];
    if (self)
    {
        self.package = package;
        self.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    }

    return self;
}


#pragma mark - actions

- (void)unpackPackage;
{
    [self unpackPackageOnQueue:_queue];
}

- (void)unpackPackageOnQueue:(dispatch_queue_t)queue
{
    NSAssert(queue != nil, @"queue must not be nil");
    NSAssert(_package != nil, @"package must not be nil");
    NSAssert(_package.localDownloadURL != nil, @"package.localDownloadURL must not be nil");
    NSAssert(_package.unzipURL != nil, @"package.unzipURL must not be nil");

    self.queue = queue;
    [_package setValue:@(CCPackageStatusUnzipping) forKey:@"status"];

    dispatch_async(queue, ^
    {
        CCLOGINFO(@"[PACKAGE/UNZIP][INFO]: Unzipping package... %@", _package);

        NSError *error;
        BOOL success = [SSZipArchive unzipFileAtPath:_package.localDownloadURL.path
                                       toDestination:_package.unzipURL.path
                                           overwrite:YES
                                            password:_password
                                               error:&error
                                            delegate:self];

        if (success)
        {
            CCLOGINFO(@"[PACKAGE/UNZIP][INFO]: Unzipping finished of package: %@", _package);

            [_package setValue:@(CCPackageStatusUnzipped) forKey:@"status"];

            if ([_delegate respondsToSelector:@selector(unzipFinished:)])
            {
                [_delegate unzipFinished:self];
            }
        }
        else
        {
            CCLOG(@"[PACKAGE/UNZIP][ERROR]: Unzipping failed of package: %@ with error: %@", _package, error);

            [_package setValue:@(CCPackageStatusUnzipFailed) forKey:@"status"];

            if ([_delegate respondsToSelector:@selector(unzipFailed:error:)])
            {
                [_delegate unzipFailed:self error:error];
            }
        }
    });
}

#pragma mark - SSZipArchiveDelegate

- (void)zipArchiveProgressEvent:(NSInteger)loaded total:(NSInteger)total
{
    if ([_delegate respondsToSelector:@selector(unzipProgress:unzippedBytes:totalBytes:)])
    {
        [_delegate unzipProgress:self unzippedBytes:(NSUInteger) loaded totalBytes:(NSUInteger) total];
    }
}



@end
