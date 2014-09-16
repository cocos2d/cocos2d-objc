#import <Foundation/Foundation.h>

@class CCPackage;


@interface CCPackageInstallData : NSObject

@property (nonatomic, weak) CCPackage *package;

// Temp URL of the download file
@property (nonatomic, copy) NSURL *localDownloadURL;

// URL of the folder the package is unzipped to
@property (nonatomic, copy) NSURL *unzipURL;

// Name of the folder inside the unzip folder. A zipped package is supposed to contain a folder named
// like this <NAME>-<OS>-<RESOLUTION>. Example: DLC-iOS-phonehd.
// This name can vary though and can be determined by delegation.
@property (nonatomic, copy) NSString *folderName;

// Whether or not the the package should be enabled in cocos2d
@property (nonatomic) BOOL enableOnDownload;

- (instancetype)initWithPackage:(CCPackage *)package;

@end