#import <Foundation/Foundation.h>
#import "CCPackageDownloadDelegate.h"

@class CCPackage;
@protocol CCPackageDownloadManagerDelegate;


@interface CCPackageDownloadManager : NSObject <CCPackageDownloadDelegate>

@property (nonatomic, copy) NSString *downloadPath;
@property (nonatomic, weak) id <CCPackageDownloadManagerDelegate> delegate;
@property (nonatomic) BOOL resumeDownloads;
@property (nonatomic) BOOL overwriteFinishedDownloads;

// Creates a new download for a given package. A package cannot be enqueued twice as long as it is being downloaded already.
- (void)enqueuePackageForDownload:(CCPackage *)package;

- (void)cancelDownloadOfPackage:(CCPackage *)package;

- (void)pauseDownloadOfPackage:(CCPackage *)package;

// Resumes the download of a package if possible: Host accepts range requests.
- (void)resumeDownloadOfPackage:(CCPackage *)package;

- (void)pauseAllDownloads;

- (void)resumeAllDownloads;

@end