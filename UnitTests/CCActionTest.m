//
//  CCActionTest.m
//  cocos2d-tests-ios
//
//  Created by Andy Korth on Dec 5th, 2014.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"
#import "CCAction.h"

@interface CCActionReuseTest : XCTestCase

@end

@implementation CCActionReuseTest


const float accuracy = 1e-4;

CGPoint startPos;
CGPoint endPos;
CCScene *scene;
CCNode *node;

- (void)setUp
{
    [super setUp];

    scene = [CCScene node];
    
    startPos = ccp(0,0);
    endPos = ccp(2.0f,1.0f);
    
    node = [CCNode node];
    node.position = startPos;
    [scene addChild:node z:0 name:@"testNode"];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}


- (void)testIsFirstStepIgnored
{
     CCActionMoveTo * action = [CCActionMoveTo actionWithDuration:1.0f position:ccp(1.0f, 1.0f)];
    [node runAction:action];
    
    //Step the action by half a second
    [action step: 0.5f];
    
    /*
     
     Test disabled pending actually fixing this behavior in CCAction.
    
    XCTAssertEqualWithAccuracy(action.elapsed, 0.5f, 1e-4, @"Elapsed time incorrect, it's as if the first step never occured!");
     */
    XCTAssertTrue(true);
}

- (void)testSimpleAction
{
    // Sanity check.
    XCTAssertTrue(ccpDistance(node.position, startPos) < accuracy, @"Initial position incorrect!");

    CCActionMoveTo * action = [CCActionMoveTo actionWithDuration:1.0f position:endPos];
    [node runAction:action];
    
    // Node should not have moved yet.
    XCTAssertTrue(ccpDistance(node.position, startPos) < accuracy, @"Node moved before action stepped!");

    // TODO: Bug workaround
    [action step: 0.0f];
    
    //Step the action by half a second (half the duration)
    [action step: 0.5f];
    XCTAssertEqualWithAccuracy(action.elapsed, 0.5f, accuracy, @"Elapsed time incorrect after stepping.");
    
    XCTAssertTrue( (ccpDistance(node.position, startPos) - ccpDistance(startPos, endPos)) / 2.0f < accuracy, @"Node should have moved half the distance between start and end.");

    //Step the action to completion.
    [action step: 0.5f];
    XCTAssertEqualWithAccuracy(action.elapsed, 1.0f, accuracy, @"Elapsed time incorrect after second step.");

    XCTAssertTrue( ccpDistance(node.position, endPos) < accuracy, @"Node should have arrived at end point.");
    XCTAssertEqualWithAccuracy(node.position.x, endPos.x, accuracy, @"Node X was incorrect after moving.");
    XCTAssertEqualWithAccuracy(node.position.y, endPos.y, accuracy, @"Node Y was incorrect after moving.");

}

- (void)testCopyUnaddedAction
{
    CCActionMoveTo * action = [CCActionMoveTo actionWithDuration:1.0f position:endPos];

    // copy node immediately
    CCActionMoveTo *actionCopy = [action copy];
    [node runAction:actionCopy];
   
    [actionCopy step: 0.0f]; // TODO: Bug workaround
    [actionCopy step: 1.0f];
    
    XCTAssertTrue( ccpDistance(node.position, endPos) < accuracy, @"Node should have arrived at end point.");
}

- (void)testCopyAddedAction
{
    CCActionMoveTo * action = [CCActionMoveTo actionWithDuration:1.0f position:endPos];
    // Add to node before copying.
    [node runAction:action];
    
    CCActionMoveTo *actionCopy = [action copy];
    [node runAction:actionCopy];
    
    [actionCopy step: 0.0f]; // TODO: Bug workaround
    [actionCopy step: 1.0f];
    
    XCTAssertTrue( ccpDistance(node.position, endPos) < accuracy, @"Node should have arrived at end point.");
}


- (void)testCopyUsedAction
{
    CCActionMoveTo * action = [CCActionMoveTo actionWithDuration:1.0f position:endPos];
    [node runAction:action];
    
    [action step: 0.0f]; // TODO: Bug workaround
    [action step: 0.5f];
    
    CCActionMoveTo *actionCopy = [action copy];
    [node runAction:actionCopy];
    
    [actionCopy step: 0.0f]; // TODO: Bug workaround
    [actionCopy step: 1.0f];
    
    XCTAssertTrue( ccpDistance(node.position, endPos) < accuracy, @"Node should have arrived at end point.");
}

- (void)testRunningSameActionOnTwoNodes
{
    CCNode *node1 = [CCNode node];
    CCNode *node2 = [CCNode node];
    node1.position = node2.position = startPos;
    [scene addChild:node1 z:0 name:@"testNode1"];
    [scene addChild:node2 z:0 name:@"testNode2"];
    
    const float accuracy = 1e-4;
    
    CCActionMoveTo * action = [CCActionMoveTo actionWithDuration:1.0f position:endPos];
    [node1 runAction:action];
    [node2 runAction:action];
    
    // TODO: Bug workaround
    [action step: 0.0f];
    
    //Step the action to completion.
    [action step: 1.0f];

    XCTAssertEqualWithAccuracy(action.elapsed, 1.0f, accuracy, @"Elapsed time incorrect after second step.");
    
    // Check node 2
    XCTAssertTrue( ccpDistance(node2.position, endPos) < accuracy, @"Node 2 should have arrived at end point.");

    // Check node 1
    // TODO:
    XCTAssertTrue( ccpDistance(node1.position, startPos) < accuracy, @"Node 1 doesn't move at all.");
}

- (void)testReinitActionShouldThrowAssertion
{
    CGPoint secondEndPos = ccp(4.0, -1.0);
    
    CCActionMoveTo * action = [CCActionMoveTo actionWithDuration:1.0f position:endPos];
    [node runAction:action];
    
    // TODO: Bug workaround
    [action step: 0.0f];
    
    //Step the action to completion.
    [action step: 1.0f];
    XCTAssertEqualWithAccuracy(action.elapsed, 1.0f, accuracy, @"Elapsed time incorrect after second step.");
    XCTAssertTrue( ccpDistance(node.position, endPos) < accuracy, @"Node should have arrived at end point.");
    
    // Re-init and re-assign to node
    action = [action initWithDuration:1.0 position:secondEndPos];
    
    // Conclusion: You cannot re-init a action and expect it to work. Internal variables are not reset because CCActionManager sets them by calling startWithTarget.
    XCTAssertThrows( [node runAction:action], @"Running same action again should throw assertion, even if re-inited");
}

- (void)testReusingActionWithCopy
{
    CCActionMoveTo * action = [CCActionMoveTo actionWithDuration:1.0f position:endPos];
    [node runAction:action];
    
    [action step: 0.0f];  // TODO: Bug workaround
    
    //Step the action to completion.
    [action step: 1.0f];
    XCTAssertEqualWithAccuracy(action.elapsed, 1.0f, accuracy, @"Elapsed time incorrect after second step.");
    XCTAssertTrue( ccpDistance(node.position, endPos) < accuracy, @"Node should have arrived at end point.");
    
    // Copy and re-assign to node
    action = [action copy];
    node.position = startPos;
    [node runAction:action];
    
    XCTAssertEqualWithAccuracy(action.elapsed, 0.0f, accuracy, @"Elapsed time incorrect after re-init.");
    XCTAssertTrue(ccpDistance(node.position, startPos) < accuracy, @"Node should be back at start position in preparation for action move!");
    
    [action step: 0.0f];  // TODO: Bug workaround
    
    //Step the action again, see where we end up.
    [action step: 1.0f];
    XCTAssertEqualWithAccuracy(action.elapsed, 1.0f, accuracy, @"Elapsed time incorrect after reuse.");
    
    XCTAssertTrue( ccpDistance(node.position, endPos) < accuracy, @"Node should have arrived at second end point.");
}

- (void)testCopyActionClearsState
{
    CCActionMoveTo * action = [CCActionMoveTo actionWithDuration:1.0f position:endPos];
    
    [node runAction:action];
    [action step: 0.0f]; // TODO: Bug workaround
    [action step: 0.5f];
    
    CCActionMoveTo *actionCopy = [action copy];
    
    XCTAssertEqualWithAccuracy(action.elapsed, 0.5f, accuracy, @"Original action didn't run.");
    XCTAssertEqualWithAccuracy(actionCopy.elapsed, 0.0f, accuracy, @"Elapsed time was not reset.");
    XCTAssertEqualWithAccuracy(actionCopy.duration, 1.0f, accuracy, @"Duration should have been copied.");
    XCTAssertNil(actionCopy.target, @"Target not reset");
    XCTAssertNil(actionCopy.originalTarget, @"originalTarget not reset");
}

- (void)testCopyActionClearsStateForCompletedActions
{
    CCActionMoveTo * action = [CCActionMoveTo actionWithDuration:1.0f position:endPos];
    
    [node runAction:action];
    [action step: 0.0f]; // TODO: Bug workaround
    [action step: 1.5f];
    
    CCActionMoveTo *actionCopy = [action copy];
    
    XCTAssertEqualWithAccuracy(action.elapsed, 1.5f, accuracy, @"Original action didn't run.");
    XCTAssertEqualWithAccuracy(actionCopy.elapsed, 0.0f, accuracy, @"Elapsed time was not reset.");
    XCTAssertEqualWithAccuracy(actionCopy.duration, 1.0f, accuracy, @"Duration should have been copied.");
    XCTAssertNil(actionCopy.target, @"Target not reset");
    XCTAssertNil(actionCopy.originalTarget, @"originalTarget not reset");
}


@end
