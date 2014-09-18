#import <Foundation/Foundation.h>

@class CCPackage;

@protocol CCPackageDownloadManagerDelegate <NSObject>

@required

/**
 *  Called when the http request of a package download finishes successfully
 *
 *  @param package The package downloaded successfully
 */
- (void)downloadFinishedOfPackage:(CCPackage *)package;

/**
 *  Called when the http request of a package download failed
 *
 *  @param package The package which download failed
 *  @param error Error pointer to an error object containing details
 */
- (void)downloadFailedOfPackage:(CCPackage *)package error:(NSError *)error;


@optional

/**
 *  Returns the bytes downloaded and the total bytes of a package download.
 *  Total bytes can be 0 throughout a download if the response does not contain a Content-Length header.
 *
 *  @param package The package which download reported progress
 *  @param downloadedBytes bytes downloaded
 *  @param totalBytes Total bytes downloaded. Total bytes can be 0 throughout a download if the response does not contain a Content-Length header.
 */
- (void)downloadProgressOfPackage:(CCPackage *)package downloadedBytes:(NSUInteger)downloadedBytes totalBytes:(NSUInteger)totalBytes;

/**
 *  Provides the request before it is sent to let delegate adjust headers etc.
 *  If there is a partial download which should be resumed a Range header will be set after this invocation.
 *
 *  @param request The request object that will be used for the download
 *  @param download The download object which will start with the given request
 */
- (void)request:(NSMutableURLRequest *)request ofPackage:(CCPackage *)package;

@end
