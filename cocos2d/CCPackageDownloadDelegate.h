#import <Foundation/Foundation.h>

@class CCPackageDownload;

@protocol CCPackageDownloadDelegate <NSObject>

@required
// Called when the http request finishes
- (void)downloadFinished:(CCPackageDownload *)download;

// Called when the http request fails, for example a timeout, not a 404 returned.
- (void)downloadFailed:(CCPackageDownload *)download error:(NSError *)error;

@optional
// Called whenever new bytes are received from the host.
// Returns the bytes downloaded and the total bytes.
// Total bytes can be 0 throughout a download if the response does not contain a Content-Length header.
- (void)downlowdProgress:(CCPackageDownload *)download downloadedBytes:(NSUInteger)downloadedBytes totalBytes:(NSUInteger)totalBytes;

// Return YES if a partial download should be resume if the host accepts range requests otherwise it will start over
// Return NO if the download should start over
// This method will only be invoked if there is a downloaded file
// If not implemented the default is as if returned YES
- (BOOL)shouldResumeDownload:(CCPackageDownload *)download;

// Return whether a completed download with the same filename should be overwritten.
- (BOOL)shouldOverwriteDownloadedFile:(CCPackageDownload *)download;

// Provides the request before it is sent to let delegate adjust headers etc.
// If there is a partial download which should be resumed a Range header will be set after this invocation.
- (void)request:(NSMutableURLRequest *)request ofDownload:(CCPackageDownload *)download;

@end