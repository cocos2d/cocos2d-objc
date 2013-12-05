//
//  CCNodeTests
//
//  Created by Andy Korth on December 12th, 2013.
//
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"


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

@end
