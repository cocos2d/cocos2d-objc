//
//  CCPackageInstallDataTests.m
//  cocos2d-tests-ios
//
//  Created by Nicky Weber on 24.09.14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "CCPackageInstallData.h"
#import "CCPackage.h"

@interface CCPackageInstallDataTests : XCTestCase

@property (nonatomic, strong) CCPackageInstallData *installData;

@end


@implementation CCPackageInstallDataTests

- (void)setUp
{
    [super setUp];

    CCPackage *package = [[CCPackage alloc] initWithName:@"Foo"
                                              resolution:@"phonehd"
                                                      os:@"iOS"
                                               remoteURL:[NSURL URLWithString:@"http://foo.fake/Foo-iOS-phonehd.zip"]];

    self.installData = [[CCPackageInstallData alloc] initWithPackage:package];
    _installData.unzipURL = [NSURL fileURLWithPath:@"/unzupfolder/foo"];
    _installData.folderName = @"somename";
    _installData.localDownloadURL = [NSURL fileURLWithPath:@"/downloadfolder/baa.zip"];
    _installData.enableOnDownload = NO;

}

- (void)testPopulateInstallDataWithDictionary
{
    // Constants for dict keys are only used internally, not making them public
    NSDictionary *installDataDict = @{
        @"localDownloadURL" : @"file:///downloadfolder/baa.zip",
        @"localUnzipURL" : @"file:///unzupfolder/foo",
        @"folderName" : @"somename",
        @"enableOnDownload" : @(YES)
    };

    [_installData populateInstallDataWithDictionary:installDataDict];

    NSURL *localDownloadURL = [NSURL fileURLWithPath:@"/downloadfolder/baa.zip"];
    XCTAssertTrue([_installData.localDownloadURL isEqual:localDownloadURL], @"%@ is not equal to %@", _installData.localDownloadURL, localDownloadURL);

    NSURL *unzipURL = [NSURL fileURLWithPath:@"/unzupfolder/foo"];
    XCTAssertTrue([_installData.unzipURL isEqual:unzipURL], @"%@ is not equal to %@", _installData.unzipURL, unzipURL);

    NSString *folderName = @"somename";
    XCTAssertTrue([_installData.folderName isEqual:folderName], @"%@ is not equal to %@", _installData.folderName, folderName);

    XCTAssertTrue(_installData.enableOnDownload);
}

- (void)testWriteInstallDataToDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    [_installData writeInstallDataToDictionary:dictionary];

    NSURL *localDownloadURL = [NSURL fileURLWithPath:@"/downloadfolder/baa.zip"];
    NSURL *dictDownloadURL = [NSURL URLWithString:dictionary[@"localDownloadURL"]];
    XCTAssertTrue([dictDownloadURL isEqual:localDownloadURL], @"%@ is not equal to %@", dictDownloadURL, localDownloadURL);

    NSURL *localUnzipURL = [NSURL fileURLWithPath:@"/unzupfolder/foo"];
    NSURL *dictUnzipURL = [NSURL URLWithString:dictionary[@"localUnzipURL"]];
    XCTAssertTrue([dictUnzipURL isEqual:localUnzipURL], @"%@ is not equal to %@", dictUnzipURL, localUnzipURL);

    NSString *localFolderName = @"somename";
    NSString *dictFolderName = dictionary[@"folderName"];
    XCTAssertTrue([dictFolderName isEqualToString:localFolderName], @"%@ is not equal to %@", dictFolderName, localFolderName);

    XCTAssertFalse([dictionary[@"enableOnDownload"] boolValue]);
}

@end
