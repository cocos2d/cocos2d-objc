#import <Foundation/Foundation.h>
#import "CCPackageTypes.h"
#import "CCPackage.h"

@interface CCPackage()

@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSString *resolution;
@property (nonatomic, copy, readwrite) NSString *os;
@property (nonatomic, copy, readwrite) NSURL *remoteURL;
@property (nonatomic, copy, readwrite) NSString *folderName;
@property (nonatomic, copy, readwrite) NSURL *installRelURL;
@property (nonatomic, copy, readwrite) NSURL *localDownloadURL;
@property (nonatomic, copy, readwrite) NSURL *unzipURL;
@property (nonatomic, readwrite) BOOL enableOnDownload;
@property (nonatomic, readwrite) CCPackageStatus status;

@end
