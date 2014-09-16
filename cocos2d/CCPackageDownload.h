#import <Foundation/Foundation.h>

@protocol CCPackageDownloadDelegate;
@class CCPackage;


@interface CCPackageDownload : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, copy) NSURL *packageURL;
@property (nonatomic, copy) NSURL *localURL;
@property (nonatomic, strong, readonly) CCPackage *package;

@property (nonatomic, readonly) NSUInteger totalBytes;
@property (nonatomic, readonly) NSUInteger downloadedBytes;

@property (nonatomic, weak) id <CCPackageDownloadDelegate> delegate;

- (instancetype)initWithPackage:(CCPackage *)package localURL:(NSURL *)localURL;

// Starts the download, if there is a downloaded data the delegate is asked if the download should be resumed
- (void)start;

// Stops the download and deletes the download file
- (void)cancel;

// Stops the download
- (void)pause;

// Resumes a download, otherwise starts from the beginning
- (void)resume;

@end