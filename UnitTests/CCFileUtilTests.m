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


-(void)testFullPathForFilename
{
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];

	NSString *path = [sharedFileUtils fullPathForFilename:@"file that does not exist"];
	
	XCTAssertTrue(path == nil, @"");
	
	path = [sharedFileUtils fullPathForFilename:@"powered.png"];
	NSLog(@"Path: %@", path);
}

@end
