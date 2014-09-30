//
//  CCPackageCocos2dEnablerTests.m
//  cocos2d-tests-ios
//
//  Created by Nicky Weber on 23.09.14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCPackageCocos2dEnabler.h"
#import "CCPackage.h"
#import "CCFileUtils.h"
#import "CCSprite.h"
#import "CCBReader.h"
#import "AppDelegate.h"
#import "CCPackage_private.h"

@interface CCPackageCocos2dEnablerTests : XCTestCase

@property (nonatomic, strong) CCPackage *package;
@property (nonatomic, copy) NSURL *installURL;

@end


@implementation CCPackageCocos2dEnablerTests

- (void)setUp
{
    [super setUp];
    [(AppController *)[UIApplication sharedApplication].delegate configureCocos2d];

    self.package = [[CCPackage alloc] initWithName:@"Foo"
                                        resolution:@"phonehd"
                                                os:@"iOS"
                                         remoteURL:[NSURL URLWithString:@"http://foo.fake/Foo-iOS-phonehd.zip"]];

    NSString *pathToPackage = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources-shared/Packages/testpackage-iOS-phonehd_unzipped"];
    self.installURL = [[NSURL fileURLWithPath:pathToPackage] URLByAppendingPathComponent:@"testpackage-iOS-phonehd"];
    _package.installURL = _installURL;
}


#pragma mark - Tests

- (void)testEnablePackage
{
    CCPackageCocos2dEnabler *packageEnabler = [[CCPackageCocos2dEnabler alloc] init];
    [packageEnabler enablePackages:@[_package]];

    XCTAssertTrue([self isPackageInSearchPath]);
    XCTAssertEqual(_package.status, CCPackageStatusInstalledEnabled);

    CCSprite *sprite = [CCSprite spriteWithImageNamed:@"boredSmiley.png"];
    XCTAssertNotNil(sprite);
}

- (void)testDisablePackage
{
    [self testEnablePackage];

    CCPackageCocos2dEnabler *packageEnabler = [[CCPackageCocos2dEnabler alloc] init];
    [packageEnabler disablePackages:@[_package]];

    XCTAssertEqual(_package.status, CCPackageStatusInstalledDisabled);

    XCTAssertFalse([self isPackageInSearchPath]);

    // Can't use [CCSprite spriteWithImageNamed:@"boredSmiley.png"], assertion exception is screwing up test result
    CGFloat *scale;
    NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:@"boredSmiley.png" contentScale:&scale];
    XCTAssertNil(path);
}


#pragma mark - Helper

- (BOOL)isPackageInSearchPath
{
    for (NSString *aSearchPath in [CCFileUtils sharedFileUtils].searchPath)
    {
        if ([aSearchPath isEqualToString:_package.installURL.path])
        {
            return YES;
        }
    }
    return NO;
}

@end
