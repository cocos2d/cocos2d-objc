#import <Foundation/Foundation.h>

@class CCPackage;


@interface CCPackageInstallData : NSObject

/**
 *  Back reference to the package
 */
@property (nonatomic, weak) CCPackage *package;

/**
 *  Local URL of the download file when download finishes. While downloading a temp name
 *  is used which won't be accessible.
 */
@property (nonatomic, copy) NSURL *localDownloadURL;

/**
 *  Local URL of the folder the package is unzipped to
 */
@property (nonatomic, copy) NSURL *unzipURL;

/**
 *  Name of the folder inside the unzip folder. A zipped package is supposed to contain a folder named
 *  like this <NAME>-<OS>-<RESOLUTION>. Example: DLC-iOS-phonehd.
 *  This name can vary though and can be determined by delegation if a standard name was not found
 *  during installation.
 */
@property (nonatomic, copy) NSString *folderName;

/**
 *  Whether or not the the package should be enabled in cocos2d after installation.
 */
@property (nonatomic) BOOL enableOnDownload;


/**
 *  Returns a new instance of CCPackageInstallData.
 *  This class is meant to be used while a package is being downloaded, unzipped and installed.
 *  It becomes obsolete after installation.
 *
 *  @param package The package the installData should be attached to. Note: It won't be attached in the initializer.
 *
 *  @return A new instance of CCPackageInstallData
 */
- (instancetype)initWithPackage:(CCPackage *)package;

/**
 *  Reads values of dictionary and sets them on the install data.
 *  Install data has to be attached to package already.
 *
 *  @param dictionary Dictionary containing values to populate the install data with
 */
- (void)populateInstallDataWithDictionary:(NSDictionary *)dictionary;

//
/**
 *  Writes the install data values into the provided dictionary.
 *
 *  @param dictionary Dictionary that shouöd be used to serialize the install data to
 */
- (void)writeInstallDataToDictionary:(NSMutableDictionary *)dictionary;


@end
