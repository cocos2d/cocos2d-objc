//
//  CCNodeTests
//
//  Created by Andy Korth on December 12th, 2013.
//
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"
#import "CCDirector_Private.h"

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
	[scene addChild:first z:0 name:@"first"];
	
	CCNode *second = [CCNode node];
	[first addChild:second z:0 name:@"second"];
	
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

-(void)testRemovingScheduledNodes
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	[scene addChild:first z:0 name:@"first"];

	CCNode *second = [CCNode node];
	[first addChild:second z:0 name:@"second"];
	
	// This one should occur.
	[first scheduleBlock:^(CCTimer *timer){
		XCTAssertTrue(TRUE);
	} delay:0.0];
	
	// this one will be cleaned up and won't happen
	[second scheduleBlock:^(CCTimer *timer){
		XCTFail(@"Cleaned up action should not occur");
	} delay:0.0];
	
	[scene removeChild:first cleanup:NO];
	[scene removeChild:second cleanup:YES];
	
	[[[CCDirector sharedDirector] scheduler] update: 1.0];
}



-(void)testCCNodePositionTypePoints
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	first.positionType = CCPositionTypePoints;
	first.position = ccp(10.0, 15.0);
	first.contentSize = CGSizeMake(1.0, 2.0);
	[scene addChild:first z:0 name:@"first"];

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


-(void)testCCNodePositionTypeChangeCorners
{
	CCScene *scene = [CCScene node];
	
	CCNode *first = [CCNode node];
	first.positionType = CCPositionTypePoints;
	first.position = ccp(10.0, 15.0);
	first.contentSize = CGSizeMake(1.0, 2.0);
	[scene addChild:first z:0 name:@"first"];
	
	// Change position type, now we're relative to the other corner of the screen.
	first.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerTopRight);
	
	float screenWidth = 1024.0;
	float screenHeight = 768.0;
	
	XCTAssertEqual(first.position.x, (CGFloat) (screenWidth - 10.0), @""); // TODO: What's up with these crazy numbers?
	XCTAssertEqual(first.position.y, (CGFloat) (screenHeight - 15.0), @"");
	XCTAssertEqual(first.contentSize.width, (CGFloat) 1.0, @"");
	XCTAssertEqual(first.contentSize.height, (CGFloat) 2.0, @"");
	
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
	[scene addChild:first z:0 name:@"first"];

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
	XCTAssertEqual(first.contentSizeInPoints.width, (CGFloat) 1.0, @""); // TODO: Should content size be doubled?
	XCTAssertEqual(first.contentSizeInPoints.height, (CGFloat) 2.0, @"");

}



@end
