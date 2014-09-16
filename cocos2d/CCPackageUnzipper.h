#import <Foundation/Foundation.h>
// #import "SSZipArchive.h"

@protocol CCPackageUnzipperDelegate;
@class CCPackage;

@interface CCPackageUnzipper : NSObject // <SSZipArchiveDelegate>

@property (nonatomic, strong, readonly) CCPackage *package;
@property (nonatomic, weak) id <CCPackageUnzipperDelegate> delegate;

// If set the password is used to unzip the package.
@property (nonatomic, copy) NSString *password;

// The queue on which unzipping of packages is achieved
#if OS_OBJECT_HAVE_OBJC_SUPPORT == 1
@property (nonatomic, strong, readonly) dispatch_queue_t queue;
#else
@property (nonatomic, readonly) dispatch_queue_t queue;
#endif


- (instancetype)initWithPackage:(CCPackage *)package;

- (void)unpackPackage;

// Queue to run unzip task on, default is DISPATCH_QUEUE_PRIORITY_LOW
- (void)unpackPackageOnQueue:(dispatch_queue_t)queue;

@end