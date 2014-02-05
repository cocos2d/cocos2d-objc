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

@interface  CCDirector()
+(void) resetSingleton;
@end

@implementation CCNodeTests

-(void) setUp
{
	// force creation of a new sharedDirector or state will leak between each test.
	[CCDirector resetSingleton];
}

-(void)testGetChildByName
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	[scene addChild:first z:0 name:@"first"];

	XCTAssertTrue(first == [scene getChildByName:@"first" recursively:NO], @"");
	XCTAssertTrue(nil == [scene getChildByName:@"nothing" recursively:NO], @"");
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
	first.name = @"first";
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
	XCTAssertFalse(second.runningInActiveScene, @"");
	
	[scene removeChildByName:@"first"];
	XCTAssertFalse(first.runningInActiveScene, @"");
}


-(void)testRemovingChildrenThatDoNotExist
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	[scene addChild:first z:0];
	
	CCNode *second = [CCNode node];
	[scene addChild:second z:0];
	
	[scene onEnter];
	XCTAssertThrows([second removeChild:first], @"There should be an assertion to ensure we can't call removeChild with something that isn't a child.");
	
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



-(void)testCCNodePositionTypePointsUnscaled
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	first.positionType = CCPositionTypePoints;
	first.position = ccp(10.0, 15.0);
	first.contentSize = CGSizeMake(1.0, 2.0);
	[scene addChild:first z:0];

	// Position and PositionInPoints should be the same wihtout any scaling.
	XCTAssertEqual(first.position.x, (CGFloat) 10.0f, @"");
	XCTAssertEqual(first.position.y, (CGFloat) 15.0, @"");
	XCTAssertEqual(first.contentSize.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSize.height, (CGFloat) 2.0, @"");
	
	XCTAssertEqual(first.positionInPoints.x, (CGFloat) 10.0, @"");
	XCTAssertEqual(first.positionInPoints.y, (CGFloat) 15.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.height, (CGFloat) 2.0, @"");
	
}

-(void)testCCNodePositionTypeUIPointsUnscaled
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];

	// set position type before setting position:
	first.positionType = CCPositionTypeMake(CCPositionUnitUIPoints, CCPositionUnitUIPoints, CCPositionReferenceCornerBottomLeft);
	// now my position values are being set in UIPoints.
	first.position = ccp(10.0, 15.0);
	first.contentSize = CGSizeMake(1.0, 2.0);
	[scene addChild:first z:0];
	
	// Points and position should be the same.
	XCTAssertEqual(first.position.x, (CGFloat) 10.0f, @"");
	XCTAssertEqual(first.position.y, (CGFloat) 15.0, @"");
	XCTAssertEqual(first.contentSize.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSize.height, (CGFloat) 2.0, @"");
	
	XCTAssertEqual(first.positionInPoints.x, (CGFloat) 10.0, @"");
	XCTAssertEqual(first.positionInPoints.y, (CGFloat) 15.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.height, (CGFloat) 2.0, @"");
	
}


-(void)testCCNodePositionTypePointsScaled
{
	// let's say our scale was set the same way since we launched the app.
	[CCDirector sharedDirector].UIScaleFactor = 2.0;
	
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	first.positionType = CCPositionTypePoints;
	first.position = ccp(10.0, 15.0);
	first.contentSize = CGSizeMake(1.0, 2.0);
	[scene addChild:first z:0];
	
	// position should be the same number we set above...
	XCTAssertEqual(first.position.x, (CGFloat) 10.0f, @"");
	XCTAssertEqual(first.position.y, (CGFloat) 15.0, @"");
	
	// Since we didn't set a scaled position type, UIScaleFactor is not applied:
	XCTAssertEqual(first.positionInPoints.x, (CGFloat) 10.0, @"");
	XCTAssertEqual(first.positionInPoints.y, (CGFloat) 15.0, @"");
	
	CGPoint pos = [first convertPositionToPoints:first.position type:CCPositionTypeUIPoints];
	// position in points should should be different, because we applied the position when we were in CCPositionUnitPoints, not CCPositionUnitUIPoints
	XCTAssertEqual(pos.x, (CGFloat) 20.0, @"");
	XCTAssertEqual(pos.y, (CGFloat) 30.0, @"");
}

-(void)testCCNodePositionTypeUIPointsScaled
{
	// let's say our scale was set the same way since we launched the app.
	[CCDirector sharedDirector].UIScaleFactor = 2.0;
	
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	first.positionType = CCPositionTypeUIPoints;
	first.position = ccp(10.0, 15.0); // set position while the position type is in UIPoints.
	first.contentSize = CGSizeMake(1.0, 2.0);
	[scene addChild:first z:0];
	
	// position should be the same number we set above...
	XCTAssertEqual(first.position.x, (CGFloat) 10.0f, @"");
	XCTAssertEqual(first.position.y, (CGFloat) 15.0, @"");
	
	// Now, we ask for the positionInPoints, since the positionType is CCPositionTypeUIPoints, the UIScaleFactor is applied.
	XCTAssertEqual(first.positionInPoints.x, (CGFloat) 20.0, @"");
	XCTAssertEqual(first.positionInPoints.y, (CGFloat) 30.0, @"");
	
	// Now let's specifically ask for the PositionType in points:
	CGPoint pos = [first convertPositionToPoints:first.position type:CCPositionTypePoints];
	XCTAssertEqual(pos.x, (CGFloat) 10.0, @"");
	XCTAssertEqual(pos.y, (CGFloat) 15.0, @"");
}

-(void)testCCNodePositionTypeChangeCorners
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	first.positionType = CCPositionTypePoints; // Bottom Left
	first.position = ccp(10.0, 15.0);
	first.contentSize = CGSizeMake(1.0, 2.0);
	[scene addChild:first z:0];
	
	// Change position type, now we're relative to the other corner of the screen.
	first.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerTopRight);
	
	// float screenWidth = 1024.0;
	// float screenHeight = 768.0;
	
	// Changing position type does not change the position.
	XCTAssertEqual(first.position.x, (CGFloat) 10.0, @"");
	XCTAssertEqual(first.position.y, (CGFloat) 15.0, @"");
	
	// But now this should be relative to a different spot.
	XCTAssertEqual(first.positionInPoints.x, (CGFloat) -10.0, @""); // honestly not sure why this isn't:  (screenWidth - 10.0)
	XCTAssertEqual(first.positionInPoints.y, (CGFloat) -15.0, @"");// honestly not sure why this isn't:  (screenHeight - 15.0)
	
}

-(void)testCCNodeUIScaleFactorShouldDoNothingToMeasurementsInPoints
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	first.positionType = CCPositionTypePoints;
	first.position = ccp(10.0, 15.0);
	first.contentSize = CGSizeMake(1.0, 2.0);
	[scene addChild:first z:0];
	
	XCTAssertEqual(first.position.x, (CGFloat) 10.0f, @"");
	XCTAssertEqual(first.position.y, (CGFloat) 15.0, @"");
	XCTAssertEqual(first.contentSize.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSize.height, (CGFloat) 2.0, @"");
	
	XCTAssertEqual(first.positionInPoints.x, (CGFloat) 10.0, @"");
	XCTAssertEqual(first.positionInPoints.y, (CGFloat) 15.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.height, (CGFloat) 2.0, @"");
	
	[CCDirector sharedDirector].UIScaleFactor = 2.0;
	// Since our positionInPoints are not UIPoints (we didn't change the position type), changing the UIScaleFactor has no effect.
	
	XCTAssertEqual(first.position.x, (CGFloat) 10.0f, @"");
	XCTAssertEqual(first.position.y, (CGFloat) 15.0, @"");
	XCTAssertEqual(first.contentSize.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSize.height, (CGFloat) 2.0, @"");
	
	XCTAssertEqual(first.positionInPoints.x, (CGFloat) 10.0, @"");
	XCTAssertEqual(first.positionInPoints.y, (CGFloat) 15.0, @"");
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
	
	// Content size is in node-local coordinates and should not change when the scale changes.
	XCTAssertEqual(first.contentSizeInPoints.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.height, (CGFloat) 2.0, @"");

}



-(void)testCCNodeChangingPositionType
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
	
	// Content size is in node-local coordinates and should not change when the scale changes.
	XCTAssertEqual(first.contentSizeInPoints.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.height, (CGFloat) 2.0, @"");
	
	// change position type back to (non-UI) points:
	first.positionType = CCPositionTypePoints;
	XCTAssertEqual(first.positionInPoints.x, (CGFloat) 10.0, @"");
	XCTAssertEqual(first.positionInPoints.y, (CGFloat) 15.0, @"");
	
}

-(void)testCCNodeChangingScaleType
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	first.positionType = CCPositionTypePoints;
	first.position = ccp(10.0, 15.0);
	first.contentSize = CGSizeMake(1.0, 2.0);
	[scene addChild:first z:0];
	
	first.scaleType = CCScaleTypeScaled;
	
	XCTAssertEqual(first.position.x, (CGFloat) 10.0f, @"");
	XCTAssertEqual(first.position.y, (CGFloat) 15.0, @"");
	XCTAssertEqual(first.contentSize.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSize.height, (CGFloat) 2.0, @"");
	
	XCTAssertEqual(first.positionInPoints.x, (CGFloat) 10.0, @"");
	XCTAssertEqual(first.positionInPoints.y, (CGFloat) 15.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.height, (CGFloat) 2.0, @"");
	
	XCTAssertEqual(first.scaleInPoints, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.scaleXInPoints, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.scaleYInPoints, (CGFloat) 1.0, @"");
	
	[CCDirector sharedDirector].UIScaleFactor = 2.0;
	
	XCTAssertEqual(first.positionInPoints.x, (CGFloat) 10.0, @"");
	XCTAssertEqual(first.positionInPoints.y, (CGFloat) 15.0, @"");
	
	// Content size is in node-local coordinates and should not change when the scale changes.
	XCTAssertEqual(first.contentSizeInPoints.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.height, (CGFloat) 2.0, @"");
	
	XCTAssertEqual(first.scaleInPoints, (CGFloat) 2.0, @"");
	XCTAssertEqual(first.scaleXInPoints, (CGFloat) 2.0, @"");
	XCTAssertEqual(first.scaleYInPoints, (CGFloat) 2.0, @"");

	// change scale type back, scale should not take UIScaleFactor into account:
	first.scaleType = CCScaleTypePoints;

	XCTAssertEqual(first.contentSizeInPoints.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSizeInPoints.height, (CGFloat) 2.0, @"");
	
	XCTAssertEqual(first.scaleInPoints, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.scaleXInPoints, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.scaleYInPoints, (CGFloat) 1.0, @"");
	
}


// TODO check the transform after CCPositionReferenceCornerBottomLeft to CCPositionReferenceCornerTopRight

-(void)testCCNodeTransformScale
{
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
	
	// Changing node transform scale does not change the content size, which is local to the node.
	XCTAssertEqualWithAccuracy(first.contentSize.width, 1.0, 0.001, @"");
	XCTAssertEqualWithAccuracy(first.contentSize.height, 2.0, 0.001, @"");
	
	
}

// TODO: Write tests that scale a parent anchor node, make sure the child's nodeToWorldTransform moves.


@end
