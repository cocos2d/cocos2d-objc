#import <Foundation/Foundation.h>

@class CCPackage;

/** CCPackageManagerDelegate protocol provides feedback on the lifecycle of packages in general and may ask a delegate for some information in special cases.
 
 Used by CCPackageManager.
 
 */
@protocol CCPackageManagerDelegate <NSObject>

@required

/** @name Download and Installation Callbacks */

/**
 *  Only called when the full process of downloading, unzipping and installation completed successfully
 *
 *  @param package The package for which the installation finished
 *  @see CCPackage
 */
- (void)packageInstallationFinished:(CCPackage *)package;

/**
 *  Only called when something went wrong during installation
 *
 *  @param package The package for which the installation failed
 *  @param error Pointer to an error object*
 *  @see CCPackage
 */
- (void)packageInstallationFailed:(CCPackage *)package error:(NSError *)error;


/**
 *  Called when a download of a package finished successfully
 *
 *  @param package The package for which the download finished
 *  @see CCPackage
 */
- (void)packageDownloadFinished:(CCPackage *)package;

/**
 *  Only called when a download of a package failed, see error pointer.
 *
 *  @param package The package for which the download failed
 *  @param error Pointer to an error object
 *  @see CCPackage
 */
- (void)packageDownloadFailed:(CCPackage *)package error:(NSError *)error;

@optional
/**
 *  Called whenever the download of a package received bytes.
 *  Note: Total bytes can be 0 throughout a download if the response does not contain a Content-Length header.
 *
 *  @param package The package for which the download progress occured
 *  @param downloadedBytes Download progress in bytes
 *  @param totalBytes Total size of the download in bytes
 *  @see CCPackage
 */
- (void)packageDownloadProgress:(CCPackage *)package downloadedBytes:(NSUInteger)downloadedBytes totalBytes:(NSUInteger)totalBytes;


@required

/** @name Unzip Callbacks */

/**
 *  Only called when the process of unzipping finished successfully
 *
 *  @param package The package for which the unzip process finished
 *  @see CCPackage
 */
- (void)packageUnzippingFinished:(CCPackage *)package;

/**
 *  Only called when the process of unzipping failed
 *
 *  @param package The package for which the unzip process failed
 *  @param error Pointer to an error object
 *  @see CCPackage
 */
- (void)packageUnzippingFailed:(CCPackage *)package error:(NSError *)error;

@optional
/**
 *  Called whenever the process of unzipping reports a progress in bytes
 *
 *  @param package The package for which the unzip progress occured
 *  @param unzippedBytes Unzip progress in bytes
 *  @param totalBytes Total size of the unzipping operation
 *  @see CCPackage
 */
- (void)packageUnzippingProgress:(CCPackage *)package unzippedBytes:(NSUInteger)unzippedBytes totalBytes:(NSUInteger)totalBytes;

/** @name Misc Callbacks */

/**
 *  When a package is installed the root object of an unzipped package should be a folder named with the
 *  standard identifier(<NAME>-<OS>-<RESOLUTION>).
 *
 *  The package installer will first try to find a folder with the standard identifier. If that fails you can
 *  omplement this method if a package contains a folder named other than the standard identifier.
 *  The content of the unzipped package is provided to select a folder name.
 *  If finding the standard identifier fails and this method is not implemented the installation will fail-
 *
 *  @param package The package for which the unzipped folder name should be determined
 *  @param packageContents A list of URLs of unzipped package's first level directory
 *
 *  @return The folder name of the package
 *  @see CCPackage
 */
- (NSString *)customFolderName:(CCPackage *)package packageContents:(NSArray *)packageContents;

/**
 *  Provide this method if you want to set a password to unzip a protected zip archive.
 *
 *  @param package The package for which the password should be set
 *
 *  @return The password to be used to unzip a package archive
 *  @see CCPackage
 */
- (NSString *)passwordForPackageZipFile:(CCPackage *)package;

/**
 *  Provides the request before it is sent to let delegate adjust headers etc.
 *  If there is a partial download which should be resumed a Range header will be set after this invocation.
 *
 *  @param request The request object that will be used for the download
 *  @param package The requested package
 *  @see CCPackage
 */
- (void)request:(NSMutableURLRequest *)request ofPackage:(CCPackage *)package;

@end
