#import <Foundation/Foundation.h>

@class CCPackageDownload;


/** CCPackageDownloadDelegate is the common interface for a CCPackageDownload's delegate.
 
 It describes providing feedback of the download as well as asking how to act in certain situations.
 
 */
@protocol CCPackageDownloadDelegate <NSObject>

@required

/**
 *  Called when the http request finishes successfully
 *
 *  @param download The download object that finished
 */
- (void)downloadFinished:(CCPackageDownload *)download;

/**
 *  Called when the http request fails, for example a timeout, not a 404 returned.
 *
 *  @param download The download object that failed
 *  @param error Error pointer to an error object containing details
 */
- (void)downloadFailed:(CCPackageDownload *)download error:(NSError *)error;


@optional

/**
 *  Called whenever new bytes are received from the host.
 *
 *  @param download The download object that reported progress
 *  @param downloadedBytes bytes downloaded
 *  @param totalBytes Total bytes downloaded. Total bytes can be 0 throughout a download if the response does not contain a Content-Length header.
 */
- (void)downlowdProgress:(CCPackageDownload *)download downloadedBytes:(NSUInteger)downloadedBytes totalBytes:(NSUInteger)totalBytes;


/**
 *  Return YES if a download should be resumed. If not implemented YES is default.
 *  Return NO if the download should start over.
 *  This method will only be invoked if there is a downloaded file
 *
 *  @param download The download object that should be resumed
 *
 *  @return whether a download should be resumed(YES) or started over(NO)
 */
- (BOOL)shouldResumeDownload:(CCPackageDownload *)download;

/**
 *  Return whether a completed download with the same filename should be overwritten.
 *  If not implemented default is NO.
 *
 *  @param download The download object which downloaded file should be overwritten.
 *
 *  @return whether an already downloaded file should be overwritten(YES) or started over(NO)
 */
- (BOOL)shouldOverwriteDownloadedFile:(CCPackageDownload *)download;

/**
 *  Provides the request before it is sent to let delegate adjust headers etc.
 *  If there is a partial download which should be resumed a Range header will be set after this invocation.
 *
 *  @param request The request object that will be used for the download
 *  @param download The download object which will start with the given request
 */
- (void)request:(NSMutableURLRequest *)request ofDownload:(CCPackageDownload *)download;

@end
