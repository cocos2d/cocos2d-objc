#import <Foundation/Foundation.h>

@class CCPackage;

@protocol CCPackageDownloadManagerDelegate <NSObject>

@required
- (void)downloadFinishedOfPackage:(CCPackage *)package;

- (void)downloadFailedOfPackage:(CCPackage *)package error:(NSError *)error;


@optional
// Returns the bytes downloaded and the total bytes of a package download.
// Total bytes can be 0 throughout a download if the response does not contain a Content-Length header.
- (void)downloadProgressOfPackage:(CCPackage *)package downloadedBytes:(NSUInteger)downloadedBytes totalBytes:(NSUInteger)totalBytes;

// Provides the request before it is sent to let delegate adjust headers etc.
// If there is a partial download which should be resumed a Range header will be set after this invocation.
- (void)request:(NSMutableURLRequest *)request ofPackage:(CCPackage *)package;

@end