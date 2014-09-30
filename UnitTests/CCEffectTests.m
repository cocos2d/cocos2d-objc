//
//  CCEffectTests.m
//  cocos2d-tests-ios
//
//  Created by Thayer J Andrews on 9/26/14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"
#import "CCEffectUtils.h"

@interface CCEffectTests : XCTestCase
@end

@implementation CCEffectTests

-(void)testNodeAncestry
{
    CCSprite *s1 = [CCSprite spriteWithImageNamed:@"f1.png"];
    CCSprite *s2 = [CCSprite spriteWithImageNamed:@"f1.png"];
    
    BOOL commonAncestor = NO;
    
    CCEffectUtilsTransformFromNodeToNode(s1, s2, &commonAncestor);
    XCTAssertFalse(commonAncestor, @"Common ancestor found where there is none.");
    
    CCEffectUtilsTransformFromNodeToNode(s2, s1, &commonAncestor);
    XCTAssertFalse(commonAncestor, @"Common ancestor found where there is none.");
}

-(void)testSameNode
{
    CCSprite *s1 = [CCSprite spriteWithImageNamed:@"f1.png"];
    
    BOOL commonAncestor = NO;
    GLKMatrix4 transform;
    
    transform = CCEffectUtilsTransformFromNodeToNode(s1, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");

    XCTAssertEqual(transform.m00, 1.0f, @"Unexpected transform value.");
    XCTAssertEqual(transform.m01, 0.0f, @"Unexpected transform value.");
    XCTAssertEqual(transform.m02, 0.0f, @"Unexpected transform value.");
    XCTAssertEqual(transform.m03, 0.0f, @"Unexpected transform value.");
    
    XCTAssertEqual(transform.m10, 0.0f, @"Unexpected transform value.");
    XCTAssertEqual(transform.m11, 1.0f, @"Unexpected transform value.");
    XCTAssertEqual(transform.m12, 0.0f, @"Unexpected transform value.");
    XCTAssertEqual(transform.m13, 0.0f, @"Unexpected transform value.");
    
    XCTAssertEqual(transform.m20, 0.0f, @"Unexpected transform value.");
    XCTAssertEqual(transform.m21, 0.0f, @"Unexpected transform value.");
    XCTAssertEqual(transform.m22, 1.0f, @"Unexpected transform value.");
    XCTAssertEqual(transform.m23, 0.0f, @"Unexpected transform value.");
    
    XCTAssertEqual(transform.m30, 0.0f, @"Unexpected transform value.");
    XCTAssertEqual(transform.m31, 0.0f, @"Unexpected transform value.");
    XCTAssertEqual(transform.m32, 0.0f, @"Unexpected transform value.");
    XCTAssertEqual(transform.m33, 1.0f, @"Unexpected transform value.");
}

-(void)testSiblingTransforms
{
    CCSprite *root = [CCSprite spriteWithImageNamed:@"f1.png"];
    root.name = @"root";
    root.positionType = CCPositionTypePoints;
    root.position = ccp(0.0f, 0.0f);
    root.anchorPoint = ccp(0.0f, 0.0f);
    
    CCSprite *s1 = [CCSprite spriteWithImageNamed:@"f1.png"];
    s1.name = @"s1";
    s1.positionType = CCPositionTypePoints;
    s1.position = ccp(10.0f, 10.0f);
    s1.anchorPoint = ccp(0.0f, 0.0f);
    
    CCSprite *s2 = [CCSprite spriteWithImageNamed:@"f1.png"];
    s2.name = @"s2";
    s2.positionType = CCPositionTypePoints;
    s2.position = ccp(100.0f, 100.0f);
    s2.anchorPoint = ccp(0.0f, 0.0f);
    
    CCSprite *s3 = [CCSprite spriteWithImageNamed:@"f1.png"];
    s3.name = @"s3";
    s3.positionType = CCPositionTypePoints;
    s3.position = ccp(1000.0f, 1000.0f);
    s3.anchorPoint = ccp(0.0f, 0.0f);
    
    BOOL commonAncestor = NO;
    GLKMatrix4 transform;
    
    

    // Test this hierarchy:
    //
    //  root
    //    \
    //     s1
    //    / \
    //   s2  s3
    //
    [root addChild:s1];
    [s1 addChild:s2];
    [s1 addChild:s3];
    transform = CCEffectUtilsTransformFromNodeToNode(s1, s2, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, -100.0f, @"");
    XCTAssertEqual(transform.m31, -100.0f, @"");

    transform = CCEffectUtilsTransformFromNodeToNode(s2, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, 100.0f, @"");
    XCTAssertEqual(transform.m31, 100.0f, @"");

    transform = CCEffectUtilsTransformFromNodeToNode(s2, s3, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, -900.0f, @"");
    XCTAssertEqual(transform.m31, -900.0f, @"");

    transform = CCEffectUtilsTransformFromNodeToNode(s3, s2, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, 900.0f, @"");
    XCTAssertEqual(transform.m31, 900.0f, @"");

    transform = CCEffectUtilsTransformFromNodeToNode(s1, s3, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, -1000.0f, @"");
    XCTAssertEqual(transform.m31, -1000.0f, @"");

    transform = CCEffectUtilsTransformFromNodeToNode(s3, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, 1000.0f, @"");
    XCTAssertEqual(transform.m31, 1000.0f, @"");

    
    // Test this hierarchy:
    //
    //    s1
    //   / \
    //  s2  s3
    //
    [root removeChild:s1];
    transform = CCEffectUtilsTransformFromNodeToNode(s1, s2, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, -100.0f, @"");
    XCTAssertEqual(transform.m31, -100.0f, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s2, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, 100.0f, @"");
    XCTAssertEqual(transform.m31, 100.0f, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s2, s3, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, -900.0f, @"");
    XCTAssertEqual(transform.m31, -900.0f, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s3, s2, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, 900.0f, @"");
    XCTAssertEqual(transform.m31, 900.0f, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s1, s3, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, -1000.0f, @"");
    XCTAssertEqual(transform.m31, -1000.0f, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s3, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, 1000.0f, @"");
    XCTAssertEqual(transform.m31, 1000.0f, @"");

    [s1 removeChild:s2];
    [s1 removeChild:s3];
}

- (void)testAncestorTransforms
{
    CCSprite *root = [CCSprite spriteWithImageNamed:@"f1.png"];
    root.name = @"root";
    root.positionType = CCPositionTypePoints;
    root.position = ccp(0.0f, 0.0f);
    root.anchorPoint = ccp(0.0f, 0.0f);
    
    CCSprite *s1 = [CCSprite spriteWithImageNamed:@"f1.png"];
    s1.name = @"s1";
    s1.positionType = CCPositionTypePoints;
    s1.position = ccp(10.0f, 10.0f);
    s1.anchorPoint = ccp(0.0f, 0.0f);
    
    CCSprite *s2 = [CCSprite spriteWithImageNamed:@"f1.png"];
    s2.name = @"s2";
    s2.positionType = CCPositionTypePoints;
    s2.position = ccp(100.0f, 100.0f);
    s2.anchorPoint = ccp(0.0f, 0.0f);
    
    CCSprite *s3 = [CCSprite spriteWithImageNamed:@"f1.png"];
    s3.name = @"s3";
    s3.positionType = CCPositionTypePoints;
    s3.position = ccp(1000.0f, 1000.0f);
    s3.anchorPoint = ccp(0.0f, 0.0f);
    
    BOOL commonAncestor = NO;
    GLKMatrix4 transform;
    
    
    // Test this hierarchy:
    //
    //  root
    //    \
    //     s1
    //      \
    //       s2
    //        \
    //         s3
    //
    [root addChild:s1];
    [s1 addChild:s2];
    [s2 addChild:s3];
    transform = CCEffectUtilsTransformFromNodeToNode(s1, s2, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, -100.0f, @"");
    XCTAssertEqual(transform.m31, -100.0f, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s2, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, 100.0f, @"");
    XCTAssertEqual(transform.m31, 100.0f, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s2, s3, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, -1000.0f, @"");
    XCTAssertEqual(transform.m31, -1000.0f, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s3, s2, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, 1000.0f, @"");
    XCTAssertEqual(transform.m31, 1000.0f, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s1, s3, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, -1100.0f, @"");
    XCTAssertEqual(transform.m31, -1100.0f, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s3, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, 1100.0f, @"");
    XCTAssertEqual(transform.m31, 1100.0f, @"");

    
    // Test this hierarchy:
    //
    //  s1
    //   \
    //    s2
    //     \
    //      s3
    //
    [root removeChild:s1];
    transform = CCEffectUtilsTransformFromNodeToNode(s1, s2, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, -100.0f, @"");
    XCTAssertEqual(transform.m31, -100.0f, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s2, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, 100.0f, @"");
    XCTAssertEqual(transform.m31, 100.0f, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s2, s3, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, -1000.0f, @"");
    XCTAssertEqual(transform.m31, -1000.0f, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s3, s2, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, 1000.0f, @"");
    XCTAssertEqual(transform.m31, 1000.0f, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s1, s3, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, -1100.0f, @"");
    XCTAssertEqual(transform.m31, -1100.0f, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s3, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqual(transform.m30, 1100.0f, @"");
    XCTAssertEqual(transform.m31, 1100.0f, @"");
    [s1 removeChild:s2];
    [s2 removeChild:s3];
}

@end
