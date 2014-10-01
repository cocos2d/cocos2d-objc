#import <Foundation/Foundation.h>
#import <SSZipArchive/SSZipArchive.h>

@protocol CCPackageUnzipperDelegate;
@class CCPackage;

@interface CCPackageUnzipper : NSObject <SSZipArchiveDelegate>

/**
 *  The package to be unzipped
 */
@property (nonatomic, strong, readonly) CCPackage *package;

/**
 *  Unzipper's delegate
 */
@property (nonatomic, weak) id <CCPackageUnzipperDelegate> delegate;

/**
 *  Password used to unzip the package archive.
 */
@property (nonatomic, copy) NSString *password;

/**
 *  The queue on which unzipping of packages is achieved
 *  On iOS 5.0, MacOS 10.7 and below you have to get rid of the queue after use if it's not a global one.
 */
#if OS_OBJECT_HAVE_OBJC_SUPPORT == 1
@property (nonatomic, strong, readonly) dispatch_queue_t queue;
#else
@property (nonatomic, readonly) dispatch_queue_t queue;
#endif

/**
 * Returns a new instance of CCPackageUnzipper
 *
 * @param package The package to be unzipped
 *
 * @return A new instance of CCPackageUnzipper
 */
- (instancetype)initWithPackage:(CCPackage *)package;

/**
 * Unpacks a package archive. The local location of the package archive and the destination
 * is determined by the package's install data. See CCPacakgeInstallData.
 * Those locations are usually set by the CCPackageManager and the various components to
 * install a package.
 *
 * @param package The package to be unzipped
 */
- (void)unpackPackage;

/**
 * Like the method above. You can specify a queue instead of the default one to run the
 * unzip task on.
 * Note: On iOS 5.0 and MacOS 10.7 and below you have to claim ownership of the queue if it's not a global one.
 *
 * @param queue Queue to run unzip task on, default is DISPATCH_QUEUE_PRIORITY_LOW
 */
- (void)unpackPackageOnQueue:(dispatch_queue_t)queue;

@end
