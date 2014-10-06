//
//  CCSpriteFrameCacheTests.m
//  cocos2d-tests-ios
//
//  Created by Nicky Weber on 02.10.14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCFileUtils.h"
#import "CCSpriteFrameCache.h"


@interface  CCSpriteFrameCache()

@end



@interface  CCFileUtils()
+(void) resetSingleton;
@end

@interface CCSpriteFrameCacheTests : XCTestCase

@end

@implementation CCSpriteFrameCacheTests

- (void)setUp
{
    [super setUp];

    [CCFileUtils resetSingleton];

    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];

    sharedFileUtils.directoriesDict =
            [@{CCFileUtilsSuffixiPad : @"resources-tablet",
                    CCFileUtilsSuffixiPadHD : @"resources-tablethd",
                    CCFileUtilsSuffixiPhone : @"resources-phone",
                    CCFileUtilsSuffixiPhoneHD : @"resources-phonehd",
                    CCFileUtilsSuffixiPhone5 : @"resources-phone",
                    CCFileUtilsSuffixiPhone5HD : @"resources-phonehd",
                    CCFileUtilsSuffixDefault : @""} mutableCopy];

    sharedFileUtils.searchMode = CCFileUtilsSearchModeDirectory;
    [sharedFileUtils buildSearchResolutionsOrder];
}

- (void)tearDown
{
    [CCFileUtils resetSingleton];

    [super tearDown];
}

- (void)testLoadSpriteFrameLookupsInAllSearchPathsWithName
{
    NSString *pathToUnzippedPackage = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources-shared/Packages/testpackage-iOS-phonehd_unzipped/testpackage-iOS-phonehd"];
    NSString *pathToUnzippedPackage2 = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources-shared/Packages/testpackage-iOS-phonehd_unzipped/testpackage-iOS-phonehd"];

    NSString *newSearchPathForPackage = [NSTemporaryDirectory() stringByAppendingPathComponent:@"testpackage-iOS-phonehd"];
    NSString *newSearchPathForPackage2 = [NSTemporaryDirectory() stringByAppendingPathComponent:@"testpackage2-iOS-phonehd"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:newSearchPathForPackage error:nil];
    [fileManager copyItemAtPath:pathToUnzippedPackage toPath:newSearchPathForPackage error:nil];

    [fileManager removeItemAtPath:newSearchPathForPackage2 error:nil];
    [fileManager copyItemAtPath:pathToUnzippedPackage2 toPath:newSearchPathForPackage2 error:nil];

    [CCFileUtils sharedFileUtils].searchPath = @[newSearchPathForPackage,newSearchPathForPackage2];

    [[CCSpriteFrameCache sharedSpriteFrameCache] loadSpriteFrameLookupsInAllSearchPathsWithName:@"spriteFrameFileList.plist"];

    CCSpriteFrame *frame1 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"smileys/angrySmiley.png"];
    CCSpriteFrame *frame2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"moresmileys/confusedSmiley.png"];

    XCTAssertNotNil(frame1, @"Error loading: smileys/angrySmiley.png");
    XCTAssertNotNil(frame2, @"Error loading: smileys/moresmileys/confusedSmiley.png");
}

@end
