#import <Foundation/Foundation.h>

@class CCPackageUnzipper;

@protocol CCPackageUnzipperDelegate <NSObject>

@optional

/**
 *  Only called when the process of unzipping finished successfully
 *
 *  @param packageUnzipper The package unzipper
 */
- (void)unzipFinished:(CCPackageUnzipper *)packageUnzipper;

/**
 *  Only called when the process of unzipping failed
 *
 *  @param packageUnzipper The package unzipper
 *  @param error Pointer to an error object
 */
- (void)unzipFailed:(CCPackageUnzipper *)packageUnzipper error:(NSError *)error;

/**
 *  Called whenever the process of unzipping reports a progress in bytes
 *
 *  @param packageUnzipper The package unzipper
 *  @param unzippedBytes Unzip progress in bytes
 *  @param totalBytes Total size of the unzipping operation
 */
- (void)unzipProgress:(CCPackageUnzipper *)packageUnzipper unzippedBytes:(NSUInteger)unzippedBytes totalBytes:(NSUInteger)totalBytes;

@end
