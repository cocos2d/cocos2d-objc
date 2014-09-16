#import <Foundation/Foundation.h>
#import "CCPackageDownloadManagerDelegate.h"
#import "CCPackageUnzipperDelegate.h"

@class CCPackage;
@protocol CCPackageManagerDelegate;


@interface CCPackageManager : NSObject <CCPackageDownloadManagerDelegate, CCPackageUnzipperDelegate>

// The path where all installed packages are stored. Default is /Library/Caches/Packages
@property (nonatomic, copy) NSString *installedPackagesPath;
@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, readonly) NSArray *allPackages;

@property (nonatomic, weak) id <CCPackageManagerDelegate> delegate;

// The queue on which unzipping of packages is achieved, default is DISPATCH_QUEUE_PRIORITY_LOW
#if OS_OBJECT_HAVE_OBJC_SUPPORT == 1
@property (nonatomic, strong) dispatch_queue_t unzippingQueue;
#else
@property (nonatomic) dispatch_queue_t unzippingQueue;
#endif


+ (CCPackageManager *)sharedManager;

// Loads all packages from user defaults.
- (void)loadPackages;

// Persists all packages to user defaults.
- (void)storePackages;


// Returns a package immediately which will be downloaded, unzipped and installed to the Packages folder in /Library/Caches (default)
// If a package with the same name and resolution already exists it won't be rescheduled for downloading.
// If you need to update a package by redownloading it you will have to delete it first.
// The various delegate callbacks provice feedback about the current steps of the whole process.
// You can KVO the package's status property as well, which will change during the cause of the installation.
// The URL is determined by the baseURL property and the standard identifier created by the name, os and resolution.
// Example: base is http://foo, name: DLC, os: iOS (determined by manager), resolution: phonehd => http://foo/DLC-iOS-phonehd.zip
- (CCPackage *)downloadPackageWithName:(NSString *)name resolution:(NSString *)resolution enableAfterDownload:(BOOL)enableAfterDownload;

// Like the method above. Instead of using the baseURL, name and resolution you can provide the URL directly.
- (CCPackage *)downloadPackageWithName:(NSString *)name resolution:(NSString *)resolution remoteURL:(NSURL *)remoteURL enableAfterDownload:(BOOL)enableAfterDownload;

// The package is removed from cocos2d's search, sprite sheets and filename lookups are reset
- (BOOL)disablePackage:(CCPackage *)aPackage error:(NSError **)error;

// The package is added to cocos2d's search, sprite sheets getting loaded as well as filename lookups
- (BOOL)enablePackage:(CCPackage *)aPackage error:(NSError **)error;

// Will disable the package first and delete it from disk. Temp download and unzip files will be removed as well.
- (BOOL)deletePackage:(CCPackage *)aPackage error:(NSError **)error;


// This will remove the package from the download manager as well from the package manager if the status is in one of the download states:
// CCPackageStatusDownloadPaused, CCPackageStatusDownloading, CCPackageStatusDownloaded, CCPackageStatusDownloadFailed
- (void)cancelDownloadOfPackage:(CCPackage *)package;

- (void)pauseDownloadOfPackage:(CCPackage *)package;

- (void)resumeDownloadOfPackage:(CCPackage *)package;

- (void)pauseAllDownloads;

- (void)resumeAllDownloads;

@end