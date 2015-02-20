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
#import "CCDirector_Private.h"

#define ACCURACY 1e-3

@interface CCEffectTests : XCTestCase
@end

@implementation CCEffectTests


-(void) setUp
{
    CCDirector *director = [CCDirector director];
    //director.
    [CCDirector pushCurrentDirector:director];
}

-(void)tearDown
{
    [CCDirector popCurrentDirector];
}


-(void)testNodeAncestry
{
    CCRenderableNode *s1 = [CCRenderableNode node];
    CCRenderableNode *s2 = [CCRenderableNode node];
    
    BOOL commonAncestor = NO;
    
    CCEffectUtilsTransformFromNodeToNode(s1, s2, &commonAncestor);
    XCTAssertFalse(commonAncestor, @"Common ancestor found where there is none.");
    
    CCEffectUtilsTransformFromNodeToNode(s2, s1, &commonAncestor);
    XCTAssertFalse(commonAncestor, @"Common ancestor found where there is none.");
}

-(void)testSameNode
{
    CCRenderableNode *s1 = [CCRenderableNode node];
    
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
    CCRenderableNode *root =  [CCRenderableNode node];
    root.name = @"root";
    root.positionType = CCPositionTypePoints;
    root.position = ccp(0.0f, 0.0f);
    root.anchorPoint = ccp(0.0f, 0.0f);
    
    CCRenderableNode *s1 =  [CCRenderableNode node];
    s1.name = @"s1";
    s1.positionType = CCPositionTypePoints;
    s1.position = ccp(10.0f, 10.0f);
    s1.anchorPoint = ccp(0.0f, 0.0f);
    
    CCRenderableNode *s2 =  [CCRenderableNode node];
    s2.name = @"s2";
    s2.positionType = CCPositionTypePoints;
    s2.position = ccp(100.0f, 100.0f);
    s2.anchorPoint = ccp(0.0f, 0.0f);
    
    CCRenderableNode *s3 =  [CCRenderableNode node];
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
    XCTAssertEqualWithAccuracy(transform.m30, -100.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, -100.0f, ACCURACY, @"");

    transform = CCEffectUtilsTransformFromNodeToNode(s2, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, 100.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, 100.0f, ACCURACY, @"");

    transform = CCEffectUtilsTransformFromNodeToNode(s2, s3, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, -900.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, -900.0f, ACCURACY, @"");

    transform = CCEffectUtilsTransformFromNodeToNode(s3, s2, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, 900.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, 900.0f, ACCURACY, @"");

    transform = CCEffectUtilsTransformFromNodeToNode(s1, s3, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, -1000.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, -1000.0f, ACCURACY, @"");

    transform = CCEffectUtilsTransformFromNodeToNode(s3, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, 1000.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, 1000.0f, ACCURACY, @"");

    
    // Test this hierarchy:
    //
    //    s1
    //   / \
    //  s2  s3
    //
    [root removeChild:s1];
    transform = CCEffectUtilsTransformFromNodeToNode(s1, s2, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, -100.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, -100.0f, ACCURACY, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s2, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, 100.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, 100.0f, ACCURACY, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s2, s3, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, -900.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, -900.0f, ACCURACY, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s3, s2, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, 900.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, 900.0f, ACCURACY, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s1, s3, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, -1000.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, -1000.0f, ACCURACY, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s3, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, 1000.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, 1000.0f, ACCURACY, @"");

    [s1 removeChild:s2];
    [s1 removeChild:s3];
}

- (void)testAncestorTransforms
{
    CCRenderableNode *root =  [CCRenderableNode node];
    root.name = @"root";
    root.positionType = CCPositionTypePoints;
    root.position = ccp(0.0f, 0.0f);
    root.anchorPoint = ccp(0.0f, 0.0f);
    
    CCRenderableNode *s1 =  [CCRenderableNode node];
    s1.name = @"s1";
    s1.positionType = CCPositionTypePoints;
    s1.position = ccp(10.0f, 10.0f);
    s1.anchorPoint = ccp(0.0f, 0.0f);
    
    CCRenderableNode *s2 =  [CCRenderableNode node];
    s2.name = @"s2";
    s2.positionType = CCPositionTypePoints;
    s2.position = ccp(100.0f, 100.0f);
    s2.anchorPoint = ccp(0.0f, 0.0f);
    
    CCRenderableNode *s3 =  [CCRenderableNode node];
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
    XCTAssertEqualWithAccuracy(transform.m30, -100.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, -100.0f, ACCURACY, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s2, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, 100.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, 100.0f, ACCURACY, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s2, s3, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, -1000.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, -1000.0f, ACCURACY, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s3, s2, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, 1000.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, 1000.0f, ACCURACY, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s1, s3, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, -1100.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, -1100.0f, ACCURACY, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s3, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, 1100.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, 1100.0f, ACCURACY, @"");

    
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
    XCTAssertEqualWithAccuracy(transform.m30, -100.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, -100.0f, ACCURACY, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s2, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, 100.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, 100.0f, ACCURACY, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s2, s3, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, -1000.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, -1000.0f, ACCURACY, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s3, s2, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, 1000.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, 1000.0f, ACCURACY, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s1, s3, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, -1100.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, -1100.0f, ACCURACY, @"");
    
    transform = CCEffectUtilsTransformFromNodeToNode(s3, s1, &commonAncestor);
    XCTAssertTrue(commonAncestor, @"No common ancestor found where there is one.");
    XCTAssertEqualWithAccuracy(transform.m30, 1100.0f, ACCURACY, @"");
    XCTAssertEqualWithAccuracy(transform.m31, 1100.0f, ACCURACY, @"");
    [s1 removeChild:s2];
    [s2 removeChild:s3];
}

@end
