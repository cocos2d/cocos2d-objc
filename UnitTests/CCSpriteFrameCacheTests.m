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
    NSString *pathToUnzippedPackage2 = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources-shared/Packages/anotherpackage-iOS-phonehd_unzipped/anotherpackage-iOS-phonehd"];

    NSString *newSearchPathForPackage = [NSTemporaryDirectory() stringByAppendingPathComponent:@"testpackage-iOS-phonehd"];
    NSString *newSearchPathForPackage2 = [NSTemporaryDirectory() stringByAppendingPathComponent:@"anotherpackage-iOS-phonehd"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:newSearchPathForPackage error:nil];
    NSError *error1;
    if (![fileManager copyItemAtPath:pathToUnzippedPackage toPath:newSearchPathForPackage error:&error1])
    {
        NSLog(@"1: %@", error1);
    }

    [fileManager removeItemAtPath:newSearchPathForPackage2 error:nil];
    NSError *error2;
    if (![fileManager copyItemAtPath:pathToUnzippedPackage2 toPath:newSearchPathForPackage2 error:&error2])
    {
        NSLog(@"2: %@", error2);
    }

    [CCFileUtils sharedFileUtils].searchPath = @[newSearchPathForPackage,newSearchPathForPackage2];

    [[CCSpriteFrameCache sharedSpriteFrameCache] loadSpriteFrameLookupsInAllSearchPathsWithName:@"spriteFrameFileList.plist"];

    CCSpriteFrame *frame1 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"smileys/angrySmiley.png"];
    CCSpriteFrame *frame2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"moresmileys/knockOutSmiley.png"];

    XCTAssertNotNil(frame1, @"Error loading: smileys/angrySmiley.png");
    XCTAssertNotNil(frame2, @"Error loading: moresmileys/confusedSmiley.png");
}

@end
