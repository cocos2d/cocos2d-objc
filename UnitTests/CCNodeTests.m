//
//  CCNodeTests
//
//  Created by Andy Korth on December 12th, 2013.
//
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"
#import "CCDirector_Private.h"
#import "CCNode_Private.h"

@interface CCNodeTests : XCTestCase

@end


@implementation CCNodeTests


-(void)testGetChildByName
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	[scene addChild:first z:0 name:@"first"];

	XCTAssertTrue(first == [scene getChildByName:@"first" recursively:NO], @"");
	XCTAssertTrue(nil == [scene getChildByName:@"nothing" recursively:NO], @"");

	XCTAssertTrue(first == [first getChildByName:@"first" recursively:NO], @"Unable to find itself!");


}
-(void)testGetChildByNameRecursive
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	[scene addChild:first z:0 name:@"first"];
	
	CCNode *second = [CCNode node];
	[first addChild:second z:0 name:@"second"];
	
	XCTAssertTrue(first == [scene getChildByName:@"first" recursively:YES], @"");
	XCTAssertTrue(second == [scene getChildByName:@"second" recursively:YES], @"");
	
	XCTAssertTrue(second == [first getChildByName:@"second" recursively:YES], @"");
	
}


-(void)testGetChildByNameNonRecursive
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	[scene addChild:first z:0 name:@"first"];
	
	CCNode *second = [CCNode node];
	[first addChild:second z:0 name:@"second"];
	

	XCTAssertTrue(nil == [scene getChildByName:@"second" recursively:NO], @"");
	XCTAssertTrue(second == [first getChildByName:@"second" recursively:NO], @"");
	
	
}


-(void)testRemovingNodes
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	[scene addChild:first z:0];
	
	CCNode *second = [CCNode node];
	[first addChild:second z:0];
	
	[scene onEnter];
	
	XCTAssertTrue(first.children.count == 1, @"");
	XCTAssertTrue(second.parent == first, @"");
	
	XCTAssertTrue(first.runningInActiveScene, @"");
	XCTAssertTrue(second.runningInActiveScene, @"");
	
	[first removeChild:second];
	XCTAssertTrue(first.children.count == 0, @"");
	XCTAssertTrue(second.parent == nil, @"");
	
	XCTAssertTrue(first.runningInActiveScene, @"");
	XCTAssertTrue(!second.runningInActiveScene, @"");

}



-(void)testNodeCleanupUnschedulesBlocks{
	CCScene *scene = [CCScene node];
	
	CCNode *cleanMeUp = [CCNode node];
	[scene addChild:cleanMeUp z:0];

	static bool firstActionOccured = FALSE;

	// this one will be cleaned up and won't happen
	[cleanMeUp scheduleBlock:^(CCTimer *timer){
		firstActionOccured = TRUE;
	} delay:0.1];
	
	[cleanMeUp cleanup];
	
	XCTAssertTrue(!firstActionOccured, @"No action should happen yet!");
	
	[[[CCDirector sharedDirector] scheduler] update: 1.0];

	XCTAssertTrue(!firstActionOccured, @"Should not occur since this node had cleanup called on it.");
}

-(void)testRemovingScheduledNodes
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	[scene addChild:first z:0];

	CCNode *second = [CCNode node];
	[scene addChild:second z:0];
	
	static bool firstActionOccured = FALSE;
	static bool secondActionOccured = FALSE;
	
	// This one should occur.
	[first scheduleBlock:^(CCTimer *timer){
		firstActionOccured = TRUE;
	} delay:0.1];
	
	// this one will be cleaned up and won't happen
	[second scheduleBlock:^(CCTimer *timer){
		secondActionOccured = TRUE;
	} delay:0.1];
	

	XCTAssertTrue(!firstActionOccured, @"No action should happen yet!");
	XCTAssertTrue(!secondActionOccured, @"No action should happen yet!");

	[scene removeChild:first cleanup:NO];
	[scene removeChild:second cleanup:YES];
	
	[[[CCDirector sharedDirector] scheduler] update: 1.0];
	
	XCTAssertTrue(firstActionOccured);
	XCTAssertTrue(!secondActionOccured, @"Cleaned up action should have unscheduled itself and should not occur.");
}



-(void)testCCNodePositionTypePoints
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	first.positionType = CCPositionTypePoints;
	first.position = ccp(10.0, 15.0);
	first.contentSize = CGSizeMake(1.0, 2.0);
	[scene addChild:first z:0];

	first.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerBottomLeft);

	
	XCTAssertEqual(first.position.x, (CGFloat) 10.0f, @"");
	XCTAssertEqual(first.position.y, (CGFloat) 15.0, @"");
	XCTAssertEqual(first.contentSize.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSize.height, (CGFloat) 2.0, @"");
	
	XCTAssertEqual(first.positionInPoints.x, (CGFloat) 10.0, @"");
	XCTAssertEqual(first.positionInPoints.y, (CGFloat) 15.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.height, (CGFloat) 2.0, @"");

	
	
}

// TODO Write tests where points != pixels.


-(void)testCCNodePositionTypeChangeCorners
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	first.positionType = CCPositionTypePoints;
	first.position = ccp(10.0, 15.0);
	first.contentSize = CGSizeMake(1.0, 2.0);
	[scene addChild:first z:0];
	
	// Change position type, now we're relative to the other corner of the screen.
	first.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerTopRight);
	
	float screenWidth = 1024.0;
	float screenHeight = 768.0;
	
#warning first.positionInPoints is not consistent with first.position.
	XCTAssertEqual(first.position.x, (CGFloat) (screenWidth - 10.0), @"");
	XCTAssertEqual(first.position.y, (CGFloat) (screenHeight - 15.0), @"");
	XCTAssertEqual(first.contentSize.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSize.height, (CGFloat) 2.0, @"");
	
#warning first.positionInPoints is not consistent with first.position.
	XCTAssertEqual(first.positionInPoints.x, (CGFloat) (screenWidth - 10.0), @"");
	XCTAssertEqual(first.positionInPoints.y, (CGFloat) (screenHeight - 15.0), @"");
	XCTAssertEqual(first.contentSizeInPoints.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.height, (CGFloat) 2.0, @"");
	
}


-(void)testCCNodePositionTypeChangeToUIPoints
{
	CCScene *scene = [CCScene node];

	CCNode *first = [CCNode node];
	first.positionType = CCPositionTypePoints;
	first.position = ccp(10.0, 15.0);
	first.contentSize = CGSizeMake(1.0, 2.0);
	[scene addChild:first z:0];

	first.positionType = CCPositionTypeMake(CCPositionUnitUIPoints, CCPositionUnitUIPoints, CCPositionReferenceCornerBottomLeft);
	
	XCTAssertEqual(first.position.x, (CGFloat) 10.0f, @"");
	XCTAssertEqual(first.position.y, (CGFloat) 15.0, @"");
	XCTAssertEqual(first.contentSize.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSize.height, (CGFloat) 2.0, @"");
	
	XCTAssertEqual(first.positionInPoints.x, (CGFloat) 10.0, @"");
	XCTAssertEqual(first.positionInPoints.y, (CGFloat) 15.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.height, (CGFloat) 2.0, @"");
	
	[CCDirector sharedDirector].UIScaleFactor = 2.0;
	
	XCTAssertEqual(first.positionInPoints.x, (CGFloat) 20.0, @"");
	XCTAssertEqual(first.positionInPoints.y, (CGFloat) 30.0, @"");
#warning Should content size be doubled when the UIScaleFactor changes?
	XCTAssertEqual(first.contentSizeInPoints.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.height, (CGFloat) 2.0, @"");

}


-(void)testCCNodeTransformChanges
{
	[CCDirector sharedDirector].UIScaleFactor = 1.0;
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	first.positionType = CCPositionTypePoints;
	first.position = ccp(10.0, 15.0);
	first.contentSize = CGSizeMake(1.0, 2.0);
	[scene addChild:first z:0];
		
	CGAffineTransform nodeToWorld = [first nodeToWorldTransform];
	XCTAssertEqualWithAccuracy(nodeToWorld.a, 1.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.b, 0.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.c, 0.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.d, 1.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.tx, 10.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.ty, 15.0, 0.001, @"");
	
	//change position type. This should mark the transform as dirty, so we can recalculate and try again:
	first.positionType = CCPositionTypeMake(CCPositionUnitUIPoints, CCPositionUnitUIPoints, CCPositionReferenceCornerBottomLeft);
	
	nodeToWorld = [first nodeToWorldTransform];
	XCTAssertEqualWithAccuracy(nodeToWorld.a, 1.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.b, 0.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.c, 0.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.d, 1.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.tx, 10.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.ty, 15.0, 0.001, @"");
	
	//Now try with a UIScaleFactor:
	[CCDirector sharedDirector].UIScaleFactor = 2.0;
	first.positionType = CCPositionTypeMake(CCPositionUnitUIPoints, CCPositionUnitUIPoints, CCPositionReferenceCornerBottomLeft);
	
#warning It seems odd that "UIScaleFactor" is applied to all nodes. Does the name need changing?
#warning Also seems odd that a global scale factor works by changing every transform in the app. Why not apply it only when it's being drawn?
	nodeToWorld = [first nodeToWorldTransform];
	XCTAssertEqualWithAccuracy(nodeToWorld.a, 1.0, 0.001, @""); // UIScale Factor *doesn't* change the transform scale.
	XCTAssertEqualWithAccuracy(nodeToWorld.b, 0.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.c, 0.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.d, 1.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.tx, 20.0, 0.001, @""); // Should be doubled.
	XCTAssertEqualWithAccuracy(nodeToWorld.ty, 30.0, 0.001, @"");
	
}

-(void)testCCNodeTransformScale
{
	[CCDirector sharedDirector].UIScaleFactor = 1.0;
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	first.positionType = CCPositionTypePoints;
	first.position = ccp(10.0, 15.0);
	first.contentSize = CGSizeMake(1.0, 2.0);
	[first setScale:2.0];
	
	[scene addChild:first z:0];
	
	CGAffineTransform nodeToWorld = [first nodeToWorldTransform];
	XCTAssertEqualWithAccuracy(nodeToWorld.a, 2.0, 0.001, @""); // Node Scale *does* change the transform scale.
	XCTAssertEqualWithAccuracy(nodeToWorld.b, 0.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.c, 0.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.d, 2.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.tx, 10.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(nodeToWorld.ty, 15.0, 0.001, @"");
	
	// Should changing node scale also change the content size? If contentSize is being used for input on the node....
	XCTAssertEqualWithAccuracy(first.contentSize.width, 2.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(first.contentSize.height, 4.0, 0.001, @"");
	
	
}

// TODO: Write tests that scale a parent anchor node, make sure the child's nodeToWorldTransform moves.


@end
