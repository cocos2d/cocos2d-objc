//
//  CCFileLocatorTests.m
//  cocos2d-tests
//
//  Created by Nicky Weber on 08.01.15.
//  Copyright (c) 2015 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CCFile.h"
#import "CCFile_Private.h"
#import "CCFileLocator_Private.h"
#import "FileSystemTestCase.h"
#import "CCUnitTestHelperMacros.h"
#import "CCSetup.h"

@interface CCFileLocatorTests : FileSystemTestCase

@property (nonatomic, strong) CCFileLocator *fileLocator;

@end


@implementation CCFileLocatorTests

- (void)setUp
{
    [super setUp];

    self.fileLocator = [[CCFileLocator alloc] init];
    _fileLocator.searchPaths = @[[self fullPathForFile:@"Resources"]];
    _fileLocator.untaggedContentScale = 4;
    
    [CCSetup sharedSetup].contentScale = 1;
    [CCSetup sharedSetup].UIScale = 1;
    [CCSetup sharedSetup].assetScale = 4;
}

#pragma mark - Tests for non image files

- (void)testFileNamedWithTextFile
{
    [self createEmptyFilesRelativeToDirectory:@"Resources/dialogs" files:@[
        @"characters.txt",
    ]];

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"dialogs/characters.txt" error:&error];

    XCTAssertNil(error);
    XCTAssertNotNil(file);
    XCTAssertEqualObjects(file.absoluteFilePath, [self fullPathForFile:@"Resources/dialogs/characters.txt"]);
}

- (void)testFileNamedWithLocalizedTextFileInDatabase
{
    id metadata = @{
        @"data": @{
            @"dialogs/merchants.txt": @{
                @"localizations": @{
                    @"es": @"dialogs/merchants-es.txt"
                },
                @"filename": @"dialogs/merchants.txt"
            }
        }
    };

    [self createEmptyFilesRelativeToDirectory:@"Resources/dialogs" files:@[
            @"merchants.txt",
            @"merchants-es.txt"
    ]];

    [self addDatabaseWithPlist:metadata forSearchPath:[self fullPathForFile:@"Resources"]];

    [self mockPreferredLanguages:@[@"es"]];

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"dialogs/merchants-es.txt" error:&error];

    XCTAssertNil(error);
    XCTAssertNotNil(file);
    XCTAssertEqualObjects(file.absoluteFilePath, [self fullPathForFile:@"Resources/dialogs/merchants-es.txt"]);
}


#pragma mark - Tests for search order with database

- (void)testImageNamedLocalizationAddedInDLCPackage
{
    id metadataResources = @{
        @"data": @{
            @"images/horse.png": @{
                @"filename": @"images/mule.png"
            }
        }
    };

    id metadataPackage = @{
        @"data": @{
            @"images/horse.png": @{
                @"localizations": @{
                    @"es": @"images/mule-es.png"
                },
                @"filename": @"images/mule.png"
            }
        }
    };

    [self createEmptyFiles:@[
            @"Resources/images/mule.png",
            @"Packages/localizations.sbpack/images/mule-es.png",
    ]];

    [self addDatabaseWithPlist:metadataResources forSearchPath:[self fullPathForFile:@"Resources"]];
    [self addDatabaseWithPlist:metadataPackage forSearchPath:[self fullPathForFile:@"Packages/localizations.sbpack"]];

    // This order is significant, otherwise filename of the json db is returned as a fallback since no localization
    // exists in the Resources json
    _fileLocator.searchPaths = @[[self fullPathForFile:@"Packages/localizations.sbpack"], [self fullPathForFile:@"Resources"]];

    [self mockPreferredLanguages:@[@"es"]];

    [CCSetup sharedSetup].assetScale = 4;
    _fileLocator.untaggedContentScale = 4;

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"images/horse.png" error:&error];

    [self assertSuccessForFile:file filePath:@"Packages/localizations.sbpack/images/mule-es.png" contentScale:4.0 error:error];
}

- (void)testImageNamedMultipleDatabasesAndSearchPaths
{
    id metadataResources = @{
        @"data": @{
            @"images/horse.png": @{
                @"filename": @"images/mule.png"
            }
        }
    };

    id metadataPackage = @{
        @"data": @{
            @"images/bicycle.png": @{
                @"filename": @"images/unicycle.png"
            }
        }
    };

    [self createEmptyFiles:@[
            @"Resources/images/mule.png",
            @"Packages/Superpackage.sbpack/images/unicycle.png",
    ]];

    // Reset the search paths.
    _fileLocator.searchPaths = @[];
    
    [self addDatabaseWithPlist:metadataResources forSearchPath:[self fullPathForFile:@"Resources"]];
    [self addDatabaseWithPlist:metadataPackage forSearchPath:[self fullPathForFile:@"Packages/Superpackage.sbpack"]];
    _fileLocator.searchPaths = @[[self fullPathForFile:@"Resources"], [self fullPathForFile:@"Packages/Superpackage.sbpack"]];

    [CCSetup sharedSetup].assetScale = 4;
    _fileLocator.untaggedContentScale = 4;

    NSError *error1;
    CCFile *file1 = [_fileLocator fileNamedWithResolutionSearch:@"images/horse.png" error:&error1];

    NSError *error2;
    CCFile *file2 = [_fileLocator fileNamedWithResolutionSearch:@"images/bicycle.png" error:&error2];

    [self assertSuccessForFile:file1 filePath:@"Resources/images/mule.png" contentScale:4.0 error:error1];
    [self assertSuccessForFile:file2 filePath:@"Packages/Superpackage.sbpack/images/unicycle.png" contentScale:4.0 error:error2];
};

- (void)testImageNamedMetaDataWithDatabase
{
    id metadata = @{
        @"data": @{
            @"images/foo.png": @{
                @"UIScale": @(YES),
                @"filename": @"images/foo.png",
            }
        }
    };
    
    // Reset the search paths.
    _fileLocator.searchPaths = @[];
    
    [self addDatabaseWithPlist:metadata forSearchPath:[self fullPathForFile:@"Resources"]];
    _fileLocator.searchPaths = @[[self fullPathForFile:@"Resources"]];

    [self createPNGsInDir:@"Resources/images" name:@"foo" scales:@[@"default"]];


    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"images/foo.png" error:nil];

    XCTAssertEqual(file.useUIScale, YES);
}

- (void)testImageNamedLocalizationSearchOrderForResolutionsWithDatabase
{
    id metadata = @{
        @"data": @{
            @"images/foo.png": @{
                @"localizations" : @{
                    @"en": @"images/foo-en.png",
                    @"de": @"images/foo-de.png"
                },
                @"filename": @"images/foo-en.png"
            }
        }
    };
    
    // Reset the search paths.
    _fileLocator.searchPaths = @[];
    
    [self addDatabaseWithPlist:metadata forSearchPath:[self fullPathForFile:@"Resources"]];
    _fileLocator.searchPaths = @[[self fullPathForFile:@"Resources"]];
    
    [self createEmptyFilesRelativeToDirectory:@"Resources/images" files:@[
            @"foo-en.png",
            @"foo-en-1x.png",
            @"foo-en-2x.png",
            @"foo-en-4x.png",
            @"foo-de.png",
            @"foo-de-1x.png",
            @"foo-de-2x.png",
            @"foo-de-4x.png",
    ]];

    [CCSetup sharedSetup].assetScale = 2;

    [self mockPreferredLanguages:@[@"de"]];

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"images/foo.png" error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/images/foo-de-2x.png" contentScale:2.0 error:error];
}

- (void)testImageNamedNoLocalizedImageAvailableWithDatabase
{
    id metadata = @{
        @"data": @{
            @"images/foo.png": @{
                @"localizations": @{
                    @"en": @"images/shouldnotbereturned.png"
                },
                @"filename": @"images/fallback.png"
            }
        }
    };
    
    // Reset the search paths.
    _fileLocator.searchPaths = @[];
    
    [self addDatabaseWithPlist:metadata forSearchPath:[self fullPathForFile:@"Resources"]];
    _fileLocator.searchPaths = @[[self fullPathForFile:@"Resources"]];
    
    [self createEmptyFilesRelativeToDirectory:@"Resources/images" files:@[
        @"shouldnotbereturned.png",
        @"fallback.png",
    ]];

    [self mockPreferredLanguages:@[@"de"]];

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"images/foo.png" error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/images/fallback.png" contentScale:4.0 error:error];
}

- (void)testImageNamedLocalizationWithDatabase
{
    id metadata = @{
        @"data": @{
            @"images/foo.png": @{
                @"localizations": @{
                    @"en": @"images/foo-en.png",
                    @"de": @"images/foo-de.png"
                },
                @"filename": @"images/foo-en.png"
            }
        }
    };
    
    // Reset the search paths.
    _fileLocator.searchPaths = @[];
    
    [self addDatabaseWithPlist:metadata forSearchPath:[self fullPathForFile:@"Resources"]];
    _fileLocator.searchPaths = @[[self fullPathForFile:@"Resources"]];
    
    [self createEmptyFilesRelativeToDirectory:@"Resources/images" files:@[
            @"foo-en.png",
            @"foo-de.png",
    ]];

    [CCSetup sharedSetup].assetScale = 4;
    _fileLocator.untaggedContentScale = 4;

    [self mockPreferredLanguages:@[@"de"]];

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"images/foo.png" error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/images/foo-de.png" contentScale:4.0 error:error];
}

- (void)testImageNamedLocalizationAvailableButImageIsMissing
{
    id metadata = @{
        @"data": @{
            @"images/foo.png": @{
                @"localizations": @{
                    @"en": @"images/missing.png",
                },
                @"filename": @"images/shouldnotbereturned.png"
            }
        }
    };

    [self addDatabaseWithPlist:metadata forSearchPath:[self fullPathForFile:@"Resources"]];

    [self mockPreferredLanguages:@[@"en"]];

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"images/foo.png" error:&error];

    [self assertFailureForFile:file errorCode:CCFileLocatorErrorNoFileFound error:error];
}

- (void)testImageNamedAliasingWithDatabase
{
    id metadata = @{
        @"data": @{
            @"images/foo.png": @{
                @"filename": @"images/baa.jpg"
            }
        }
    };
    
    // Reset the search paths.
    _fileLocator.searchPaths = @[];
    
    [self addDatabaseWithPlist:metadata forSearchPath:[self fullPathForFile:@"Resources"]];
    _fileLocator.searchPaths = @[[self fullPathForFile:@"Resources"]];
    
    [self createEmptyFilesRelativeToDirectory:@"Resources/images" files:@[
            @"baa-4x.jpg",
            @"baa.jpg",
    ]];

    [CCSetup sharedSetup].assetScale = 4;
    _fileLocator.untaggedContentScale = 4;

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"images/foo.png" error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/images/baa-4x.jpg" contentScale:4.0 error:error];
}


#pragma mark - fileNamed

- (void)testFileNamed
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"4", @"default"]];

    [CCSetup sharedSetup].assetScale = 4;
    _fileLocator.untaggedContentScale = 4;

    NSError *error;
    CCFile *file = [_fileLocator fileNamed:@"Hero.png" error:&error];
    
    // Files have no content scale (1.0), when skipping the resolution search.
    [self assertSuccessForFile:file filePath:@"Resources/Hero.png" contentScale:1.0 error:error];
};


#pragma mark - Tests for search order no database

- (void)testImageNamedSearchOrderPrecedenceExplicitContentScaleOverDefault
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"4", @"2", @"1", @"default"]];

    [CCSetup sharedSetup].assetScale = 4;
    _fileLocator.untaggedContentScale = 4;

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"Hero.png" error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero-4x.png" contentScale:4.0 error:error];
}

- (void)testImageNamedSearchOrder3XDeviceScaleNoDefaultImage
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"4", @"2", @"1"]];

    [CCSetup sharedSetup].assetScale = 3;

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"Hero.png" error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero-4x.png" contentScale:4.0 error:error];
}

- (void)testImageNamedSearchOrder2XDeviceScaleNoDefaultImage
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"4", @"2", @"1"]];

    [CCSetup sharedSetup].assetScale = 2;

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"Hero.png" error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero-2x.png" contentScale:2.0 error:error];
}

- (void)testImageNamedSearchOrderFor2xDeviceScaleWithoutPixelPerfectAvailable
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"4", @"1"]];

    [CCSetup sharedSetup].assetScale = 2;

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"Hero.png" error:&error];
    
    // It should fall back to the 1x file since it won't search for files that are >= 2x the asset scale.
    [self assertSuccessForFile:file filePath:@"Resources/Hero-1x.png" contentScale:1.0 error:error];
}

- (void)testImageNamedSearchOrderFor2xDeviceScaleButOnly1xAvailable
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"1"]];

    [CCSetup sharedSetup].assetScale = 2;

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"Hero.png" error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero-1x.png" contentScale:1.0 error:error];
}

- (void)testImageNamedSearchOrderFor1xDeviceScaleWith4xOnlyAvailable
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"4"]];

    [CCSetup sharedSetup].assetScale = 1;

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"Hero.png" error:&error];

    [self assertFailureForFile:file errorCode:CCFileLocatorErrorNoFileFound error:error];
}

- (void)testImageNamedSearchOrderFor1xDeviceScaleWith2xOnlyAvailable
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"2"]];

    [CCSetup sharedSetup].assetScale = 1;

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"Hero.png" error:&error];
    
    // It should fail to find files that are >= 2x the content scale of the device.
    XCTAssertNil(file);
}

- (void)testImageNamedSearchOrder4XDeviceScaleWith1xOnlyAvailable
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"1"]];

    [CCSetup sharedSetup].assetScale = 4;

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"Hero.png" error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero-1x.png" contentScale:1.0 error:error];
}

- (void)testImageNamedSearchOrder4XDeviceScaleDefaultAndLowResImageAvailable
{
    [self createPNGsInDir:@"Resources" name:@"Hero" scales:@[@"2", @"default"]];

    [CCSetup sharedSetup].assetScale = 4;
    _fileLocator.untaggedContentScale = 4;

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"Hero.png" error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/Hero.png" contentScale:4.0 error:error];
}


#pragma mark - Tests for search paths

- (void)testSearchPathsOrderImageAvailableInBothPaths
{
    [self createPNGsInDir:@"Packages/baa" name:@"Hero" scales:@[@"4", @"2", @"1"]];
    [self createPNGsInDir:@"Packages/foo" name:@"Hero" scales:@[@"4", @"2", @"1"]];

    _fileLocator.searchPaths = @[[self fullPathForFile:@"Packages/foo"], [self fullPathForFile:@"Packages/baa"]];
    [CCSetup sharedSetup].assetScale = 2;

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"Hero.png" error:&error];

    [self assertSuccessForFile:file filePath:@"Packages/foo/Hero-2x.png" contentScale:2.0 error:error];
}

- (void)testSearchPathsOrderImageAvailableOnlyInLastPath
{
    [self createPNGsInDir:@"Packages/baa" name:@"Hero" scales:@[@"4", @"2", @"1"]];
    [self createPNGsInDir:@"Packages/foo" name:@"Spaceship" scales:@[@"4", @"2", @"1"]];

    _fileLocator.searchPaths = @[[self fullPathForFile:@"Packages/foo"], [self fullPathForFile:@"Packages/baa"]];
    [CCSetup sharedSetup].assetScale = 2;

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"Hero.png" error:&error];

    [self assertSuccessForFile:file filePath:@"Packages/baa/Hero-2x.png" contentScale:2.0 error:error];
}


#pragma mark - Tests with errors

- (void)testImageNamedWithDefaultContentScale
{
    [self createEmptyFiles:@[@"Resources/images/vehicles/spaceship.png"]];

    _fileLocator.untaggedContentScale = 4;

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"images/vehicles/spaceship.png" error:&error];

    [self assertSuccessForFile:file filePath:@"Resources/images/vehicles/spaceship.png" contentScale:4.0 error:error];
}

- (void)testEmptySearchPaths
{
    _fileLocator.searchPaths = @[];

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"someasset.png" error:&error];

    [self assertFailureForFile:file errorCode:CCFileLocatorErrorNoSearchPaths error:error];
}

- (void)testShouldNotReturnDirectoryURLWithAssetFilename
{
    [self createFolders:@[@"Resources/image.png"]];

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:@"image.png" error:&error];

    [self assertFailureForFile:file errorCode:CCFileLocatorErrorNoFileFound error:error];
}


#pragma mark - Tests cache

- (void)prepareCacheTestRequestImageNamedAndDeleteAssetAfterwards:(NSString *)imageName
{
    [CCSetup sharedSetup].assetScale = 4;
    _fileLocator.untaggedContentScale = 4;

    NSString *relPath = [_fileLocator.searchPaths[0] stringByAppendingPathComponent:imageName];
    [self createEmptyFiles:@[relPath]];

    NSError *error;
    CCFile *file = [_fileLocator fileNamedWithResolutionSearch:imageName error:&error];

    [self assertSuccessForFile:file filePath:relPath contentScale:4.0 error:error];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    XCTAssertTrue([fileManager removeItemAtPath:[self fullPathForFile:relPath] error:nil]);
}

- (void)testFileNamedCache
{
    [self prepareCacheTestRequestImageNamedAndDeleteAssetAfterwards:@"images/foo.png"];

    NSError *error2;
    CCFile *file2 = [_fileLocator fileNamedWithResolutionSearch:@"images/foo.png" error:&error2];

    [self assertSuccessForFile:file2 filePath:@"Resources/images/foo.png" contentScale:4.0 error:error2];
}

- (void)testPurgeCache
{
    [self prepareCacheTestRequestImageNamedAndDeleteAssetAfterwards:@"images/foo.png"];

    [_fileLocator purgeCache];

    NSError *error2;
    CCFile *file2 = [_fileLocator fileNamedWithResolutionSearch:@"images/foo.png" error:&error2];

    [self assertFailureForFile:file2 errorCode:CCFileLocatorErrorNoFileFound error:error2];
}

- (void)testCachePurgedAfterLocaleChangedNotification
{
    [self prepareCacheTestRequestImageNamedAndDeleteAssetAfterwards:@"images/foo.png"];

    [[NSNotificationCenter defaultCenter] postNotificationName:NSCurrentLocaleDidChangeNotification object:nil];

    NSError *error2;
    CCFile *file2 = [_fileLocator fileNamedWithResolutionSearch:@"images/foo.png" error:&error2];

    [self assertFailureForFile:file2 errorCode:CCFileLocatorErrorNoFileFound error:error2];
}

- (void)testCachePurgedAfterSearchPathsChanged
{
    [self prepareCacheTestRequestImageNamedAndDeleteAssetAfterwards:@"images/foo.png"];

    _fileLocator.searchPaths = @[[self fullPathForFile:@"Packages/foo.sbpack"]];

    NSError *error2;
    CCFile *file2 = [_fileLocator fileNamedWithResolutionSearch:@"images/foo.png" error:&error2];

    [self assertFailureForFile:file2 errorCode:CCFileLocatorErrorNoFileFound error:error2];
}


#pragma mark - helper

- (void)createPNGsInDir:(NSString *)dir name:(NSString *)name scales:(NSArray *)scales
{
    for (NSString *scale in scales)
    {
        NSString *imageName = [scale isEqualToString:@"default"]
            ? [NSString stringWithFormat:@"%@.png", name]
            : [NSString stringWithFormat:@"%@-%@x.png", name, scale];

        [self createEmptyFilesRelativeToDirectory:dir files:@[imageName]];
    }
}

- (void)assertSuccessForFile:(CCFile *)file filePath:(NSString *)filePath contentScale:(CGFloat)contentScale error:(NSError *)error
{
    XCTAssertNil(error);
    XCTAssertNotNil(file);
    XCTAssertEqualObjects(file.absoluteFilePath, [self fullPathForFile:filePath]);
    XCTAssertEqual(file.contentScale, contentScale );
}

- (void)assertFailureForFile:(CCFile *)file errorCode:(NSInteger)errorCode error:(NSError *)error
{
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, errorCode);
    XCTAssertNil(file);
}

- (void)addDatabaseWithPlist:(id)plist forSearchPath:(NSString *)searchPath
{
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:plist format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
    NSString *filename = [searchPath stringByAppendingPathComponent:@"metadata.plist"];
    
    [self createFilesWithContents:@{filename: data}];
}

- (void)mockPreferredLanguages:(NSArray *)preferredLanguages
{
    id classMock = OCMClassMock([NSLocale class]);
    OCMStub([classMock preferredLanguages]).andReturn(preferredLanguages);
}

@end
