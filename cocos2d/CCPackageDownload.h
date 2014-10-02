#import <Foundation/Foundation.h>

@protocol CCPackageDownloadDelegate;
@class CCPackage;


@interface CCPackageDownload : NSObject <NSURLConnectionDataDelegate>

/**
 *  The URL of the package download, includes the filename
 */
@property (nonatomic, copy, readonly) NSURL *localURL;

/**
 *  The package being downloaded
 */
@property (nonatomic, strong, readonly) CCPackage *package;

/**
 *  Total bytes of the download. Might be 0 if no Content-Lenght header is sent by the
 *  host.
 */
@property (nonatomic, readonly) NSUInteger totalBytes;

/**
 *  Bytes downloaded.
 */
@property (nonatomic, readonly) NSUInteger downloadedBytes;

/**
 * The delegate of the download.
 */
@property (nonatomic, weak) id <CCPackageDownloadDelegate> delegate;

/**
 *  Returns a new instance of a CCPackageDownload
 *
 *  @param package The package that should be downloaded
 *  @param localURL The URL of the package download, includes the filename
 *
 *  @return A new instance of a CCPackageDownload
 */
- (instancetype)initWithPackage:(CCPackage *)package localURL:(NSURL *)localURL;

/**
 *  Starts the download, if there is a downloaded data the delegate is asked if the download should be resumed
 */
- (void)start;

/**
 *  Stops the download and deletes the download file
 *  Status of package is reset to CCPackageStatusInitial.
 */
- (void)cancel;

/**
 *  Pauses the download.
 */
- (void)pause;

/**
 *  Resumes a download, otherwise starts from the beginning
 */
- (void)resume;

@end
