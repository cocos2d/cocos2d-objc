//
//  CCImageTests.m
//  cocos2d-tests
//
//  Created by Andy Korth on 12/17/14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"

#import "AppDelegate.h"
#import "CCImage_Private.h"
#import "CCFile_Private.h"

/**
 Automated unit tests for loading many different types of files into CCImages. The goal with these
 tests is to make sure specific infrequently used texture loading methods don't crash. These tests
 don't interact with the OpenGL context. See the visual testbed TextureTest.m for a visual and non-automated
 version of this test.
 */
@interface CCImageTests : XCTestCase

@end

@implementation CCImageTests

- (void)setUp
{
    [super setUp];
    [(AppController *)[UIApplication sharedApplication].delegate configureCocos2d];
}

-(void) testImageNamed:(NSString*) fileName withTitle:(NSString*) title{
    CGFloat contentScale;
    
    NSString *fullPath =[[CCFileUtils sharedFileUtils] fullPathForFilename:fileName contentScale:&contentScale];
    XCTAssertNotNil(fullPath, @"Missing file %@ for test <%@>.", fileName, title);
    if(!fullPath) return; // don't continue this test if we failed above.

    NSURL *url = [NSURL fileURLWithPath:fullPath];
    XCTAssertNotNil(url, @"Missing file %@ for test <%@>.", fileName, title);
    if(!url) return; // don't continue this test if we failed above.
    
    CCFile *file = [[CCFile alloc] initWithName:title url:url contentScale:contentScale];
    XCTAssertNotNil(file, @"File didn't load from URL.");
    
    CCImage *image = [[CCImage alloc]initWithCCFile:file options:nil];
    XCTAssertNotNil(image, @"CCImage didn't load from %@ for test <%@>.", fileName, title);
    
    // First check pixel size.
    XCTAssertGreaterThan(image.sizeInPixels.width, 0, @"Zero pixel width image");
    XCTAssertGreaterThan(image.sizeInPixels.height, 0, @"Zero pixel height image");

    // If the CCImage loaded with a sensical width and height, it probably worked.
    XCTAssertGreaterThan(image.contentSize.width, 0, @"Zero contentSize.width image");
    XCTAssertGreaterThan(image.contentSize.height, 0, @"Zero contentSize.height image");
}

-(void) testPNG
{
    [self testImageNamed: @"test_image.png" withTitle: @"PNG loading example (has alpha)"];
}

-(void) testBMP
{
    [self testImageNamed:	@"test_image.bmp" withTitle: @"BMP loading example (no alpha)"];
}

-(void) testJPEG
{
    [self testImageNamed: @"test_image.jpeg" withTitle: @"JPEG loading example (no alpha, white spots)"];
}

-(void) testTIFF
{
    [self testImageNamed: @"test_image.tiff" withTitle: @"TIFF loading example (has alpha)"];
}

#if __CC_PLATFORM_IOS
// PVR on iOS only.

// This wasn't supported on purpose. We only noticed that ImageIO happened to load PVR files.
// This only works on iOS 8 however, so we should comment the test out for now.
//-(void) testPVR
//{
//    // Important note. This uses ImageIO to load the pvr texture. In normal cocos2d operation, we have our own pvr loading code.
//    [self testImageNamed: @"test_image.pvr" withTitle: @"PVR loading example (no alpha)"];
//}

#endif

-(void) testNonPowerOfTwoTextureTest
{
    [self testImageNamed: @"test_1021x1024.png" withTitle: @"1021x1024 png. Watch for memory leaks with Instruments. See http://www.cocos2d-iphone.org/forum/topic/31092"];
}


@end