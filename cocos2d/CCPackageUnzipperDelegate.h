#import <Foundation/Foundation.h>

@class CCPackageUnzipper;
@class CCPackage;

@protocol CCPackageUnzipperDelegate <NSObject>

@optional
- (void)unzipFinished:(CCPackageUnzipper *)package;

- (void)unzipFailed:(CCPackageUnzipper *)package error:(NSError *)error;

- (void)unzipProgress:(CCPackageUnzipper *)unpacker unzippedBytes:(NSUInteger)unzippedBytes totalBytes:(NSUInteger)totalBytes;

@end