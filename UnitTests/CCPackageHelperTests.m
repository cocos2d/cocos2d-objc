//
//  CCPackageHelperTests.m
//  cocos2d-tests-ios
//
//  Created by Nicky Weber on 29.09.14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCFileLocator.h"
#import "CCPackageHelper.h"
#import "CCUnitTestHelperMacros.h"

@interface CCPackageHelperTests : XCTestCase

@property (nonatomic, strong) NSMutableArray *searchResolutionsOrderBackup;

@end


@implementation CCPackageHelperTests

- (void)testDefaultResolution
{
    // Standard test
    [CCFileUtils sharedFileUtils].searchResolutionsOrder = [@[CCFileUtilsSuffixiPhoneHD, CCFileUtilsSuffixiPadHD] mutableCopy];
    NSString *mappedResolution = [CCPackageHelper ccFileUtilsSuffixToResolution:CCFileUtilsSuffixiPhoneHD];
    NSString *defaultResolution = [CCPackageHelper defaultResolution];
    XCTAssertEqualObjects(defaultResolution, mappedResolution);

    // Ignore non mappable entriy and pick next
    [CCFileUtils sharedFileUtils].searchResolutionsOrder = [@[@"weird_nonsense", CCFileUtilsSuffixiPadHD] mutableCopy];
    NSString *mappedResolution2 = [CCPackageHelper ccFileUtilsSuffixToResolution:CCFileUtilsSuffixiPadHD];
    NSString *defaultResolution2 = [CCPackageHelper defaultResolution];
    XCTAssertEqualObjects(defaultResolution2, mappedResolution2);

    // Return default since nothing can be mapped
    [CCFileUtils sharedFileUtils].searchResolutionsOrder = [@[@"nothing_to_be_mapped"] mutableCopy];
    NSString *defaultResolution3 = [CCPackageHelper defaultResolution];
    XCTAssertEqualObjects(defaultResolution3, @"phonehd");

    // Empty array
    [CCFileUtils sharedFileUtils].searchResolutionsOrder = [@[] mutableCopy];
    NSString *defaultResolution4 = [CCPackageHelper defaultResolution];
    XCTAssertEqualObjects(defaultResolution4, @"phonehd");
}

@end
