//
//  CCFileUtilTests
//
//  Created by Andy Korth on December 6th, 2013.
//
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"


@interface CCFileUtilTests : XCTestCase

@end


@implementation CCFileUtilTests


-(void)testGetChildByName
{
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];

	[sharedFileUtils fullPathForFilename:@"non existant file"];
	
	XCTAssertTrue(first == [scene getChildByName:@"first" recursively:NO], @"");
	XCTAssertTrue(nil == [scene getChildByName:@"nothing" recursively:NO], @"");

	XCTAssertTrue(first == [first getChildByName:@"first" recursively:NO], @"Unable to find itself!");


}

@end
