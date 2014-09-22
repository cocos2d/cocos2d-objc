#import <Foundation/Foundation.h>
#import "CCPackageDownloadManagerDelegate.h"
#import "CCPackageUnzipperDelegate.h"

@class CCPackage;
@protocol CCPackageManagerDelegate;


@interface CCPackageManager : NSObject <CCPackageDownloadManagerDelegate, CCPackageUnzipperDelegate>

/**
 *  The path where all installed packages are stored. Default is /Library/Caches/Packages
 */
@property (nonatomic, copy) NSString *installedPackagesPath;

/**
 *  URL used as base to locate packages. A package standard identifier is added to create a full URL.
 *  BaseURL is only used in conjunction with downloadPackageWithName:resolution:enableAfterDownload. More details below.
 */
@property (nonatomic, copy) NSURL *baseURL;

/**
 *  Returns all packages managed by the CCPackageManager
 */
@property (nonatomic, readonly) NSArray *allPackages;

/**
 *  Package manager's delegate
 */
@property (nonatomic, weak) id <CCPackageManagerDelegate> delegate;

/**
 *  The queue on which unzipping of packages is achieved, default is DISPATCH_QUEUE_PRIORITY_LOW.
 *  On iOS 5.0, MacOS 10.7 and below you have to get rid of the queue after use if it's not a global one.
 */
#if OS_OBJECT_HAVE_OBJC_SUPPORT == 1
@property (nonatomic, strong) dispatch_queue_t unzippingQueue;
#else
@property (nonatomic) dispatch_queue_t unzippingQueue;
#endif

/**
 *  Returns a shared instance of the CCPackageManager, this is the suggested way to use the manager.
 */
+ (CCPackageManager *)sharedManager;

/**
 *  Loads all packages from user defaults. Supposed to be invoked after app finished launching and Cocos2d has been set up.
 */
- (void)loadPackages;

/**
 *  Persists all packages to user defaults. Save often! Suggestion is to save on Application will terminate and will enter background.
 */
- (void)savePackages;


/**
 * The all inclsuive method to add a package to your app.
 * Returns a new package immediately which will be downloaded, unzipped and installed asynchronously to the Packages folder in /Library/Caches (default)
 *
 * If a package with the same name and resolution already exists it won't be rescheduled for downloading.
 * If you need to update a package by re-downloading it you will have to delete it first.
 * The various delegate callbacks provide feedback about the current steps of the whole process.
 * You can KVO the package's status property as well, which will change during the cause of the whole process.
 * The URL is determined by the baseURL property and the standard identifier created by the name, os and resolution.
 * Example: base is http://foo, name: DLC, os: iOS (determined by manager), resolution: phonehd => http://foo/DLC-iOS-phonehd.zip
 *
 * @param name Name of the package
 * @param resolution Resolution of the package, e.g. phonehd, tablethd etc.
 * @param enableAfterDownload If the package should be enabled in cocos2d after download. You can enable it with the enablePackage: method later on.
 */
- (CCPackage *)downloadPackageWithName:(NSString *)name resolution:(NSString *)resolution enableAfterDownload:(BOOL)enableAfterDownload;

/**
 * Like the method above. Instead of using the baseURL, name and resolution you can provide the URL directly.
 *
 * @param name Name of the package
 * @param resolution Resolution of the package, e.g. phonehd, tablethd etc.
 * @param remoteURL URL of the package to be downloaded
 * @param enableAfterDownload If the package should be enabled in cocos2d after download. You can enable it with the enablePackage: method later on.
 */
- (CCPackage *)downloadPackageWithName:(NSString *)name resolution:(NSString *)resolution remoteURL:(NSURL *)remoteURL enableAfterDownload:(BOOL)enableAfterDownload;

/**
 * Downloads a package. This is supposed to work in conjunction with addPackage where a package is created without the package manager
 * and should become managed.
 * A download will only start if the status is CCPackageStatusInitial, CCPackageStatusDownloadFailed.
 * A package with status CCPackageStatusDownloadPaused will be resumed if possible.
 *
 * @param name The package to be manager by the package manager
 * @param enableAfterDownload If the package should be enabled in cocos2d after download. You can enable it with the enablePackage: method later on.
 */
- (BOOL)downloadPackage:(CCPackage *)package enableAfterDownload:(BOOL)enableAfterDownload;

/**
 * Disables a package. Only packages with state CCPackageStatusInstalledEnabled can be disabled.
 * The package is removed from cocos2d's search, sprite sheets and filename lookups are reloaded.
 *
 * @param package The package to be disabled
 * @param error Error pointer with details about a failed operation
 *
 * @return Success(YES) or failure(NO) of the operation
 */
- (BOOL)disablePackage:(CCPackage *)package error:(NSError **)error;

/**
 * Enables a package. Only packages with state CCPackageStatusInstalledDisabled can be enabled.
 *
 * The package is added to cocos2d's search, sprite sheets getting loaded as well as filename lookups
 *
 * @param package The package to be enabled
 * @param error Error pointer with details about a failed operation
 *
 * @return Success(YES) or failure(NO) of the operation
 */
- (BOOL)enablePackage:(CCPackage *)package error:(NSError **)error;

/**
 * Adds a package to the package manager. Only packages with status initial can be added.
 *
 * @param package The package to be added to the package manager
 */
- (void)addPackage:(CCPackage *)package;

/**
 * Deletes a package.
 * Will disable the package first and delete it from disk. Temp download and unzip files will be removed as well.
 *
 * @param package The package to be deleted
 * @param error Error pointer with details about a failed operation
 *
 * @return Success(YES) or failure(NO) of the operation
 */
- (BOOL)deletePackage:(CCPackage *)package error:(NSError **)error;

/**
 * Cancels the download of a package.
 * This will remove the package from the download manager as well from the package manager if the status is in one of the download states:
 *    CCPackageStatusDownloadPaused, CCPackageStatusDownloading, CCPackageStatusDownloaded, CCPackageStatusDownloadFailed
 *
 * @param package The package which download should be cancelled
 */
- (void)cancelDownloadOfPackage:(CCPackage *)package;

/**
 * Pauses the download of a package.
 *
 * @param package The package which download should be paused
 */
- (void)pauseDownloadOfPackage:(CCPackage *)package;

/**
 * Resumes the download of a package.
 *
 * @param package The package which download should be resumed
 */
- (void)resumeDownloadOfPackage:(CCPackage *)package;

/**
 * Pauses all downloads of packages
 */
- (void)pauseAllDownloads;

/**
 * Resumes all downloads of packages
 */
- (void)resumeAllDownloads;

@end