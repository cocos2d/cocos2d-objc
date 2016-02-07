#import "CCPackageManager.h"

@class CCPackageDownloadManager;

@interface CCPackageManager()

@property (nonatomic, strong, readwrite) NSMutableArray *packages;
@property (nonatomic, strong) CCPackageDownloadManager *downloadManager;

@end