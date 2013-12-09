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

@interface  CCFileUtils()
+(void) resetSingleton;
@end

@implementation CCFileUtilTests


-(void)testFullPathForFilenameMissingFile
{
	[CCFileUtils resetSingleton];
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];

	NSString *path = [sharedFileUtils fullPathForFilename:@"file that does not exist"];
	
	XCTAssertTrue(path == nil, @"");
	
	// File does not exist in this directory
	path = [sharedFileUtils fullPathForFilename:@"powered.png"];
	XCTAssertTrue(path == nil, @"");

	
}

// XCode Unit tests look inside the target's test application bundle - not the unit test app bundle, but the "cocos2d-tests-ios.app" bundle.
-(void)testFullPathForFilename
{
	[CCFileUtils resetSingleton];
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];

	NSString *path = [sharedFileUtils fullPathForFilename:@"Images/powered.png"];
	NSLog(@"Path: %@", path);
	XCTAssertTrue(path != nil, @"");
}

-(void)testCCFileUtilsSearchModeSuffix
{
	[CCFileUtils resetSingleton];
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	sharedFileUtils.searchMode = CCFileUtilsSearchModeSuffix;
	
	XCTAssertTrue([sharedFileUtils fullPathForFilename:@"Images/powered.png"] != nil, @"");

	
}

-(void)testCCFileUtilsSearchModeDirectory
{
	[CCFileUtils resetSingleton];
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	sharedFileUtils.searchMode = CCFileUtilsSearchModeDirectory;
	
	NSString *path = [sharedFileUtils fullPathForFilename:@"Images/powered.png" contentScale:nil];
	XCTAssertTrue(path != nil, @"");
	
	CGFloat scale = 1.0;
	CGFloat biggerScale = 2.0;
	
	path = [sharedFileUtils fullPathForFilename:@"Images/powered.png" contentScale:&scale];
	XCTAssertTrue(path != nil, @"");
	
	path = [sharedFileUtils fullPathForFilename:@"Images/powered.png" contentScale:&biggerScale];
	XCTAssertTrue(path != nil, @"");
}

-(void)testCustomSearchPathsForExtensions
{
	[CCFileUtils resetSingleton];
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils purgeCachedEntries];
	[sharedFileUtils setSearchPath: @[ @"Images", kCCFileUtilsDefaultSearchPath] ];
	
	XCTAssertTrue( [sharedFileUtils fullPathForFilename:@"Images/powered.png" contentScale:nil] != nil, @"");
	XCTAssertTrue( [sharedFileUtils fullPathForFilename:@"powered.png" contentScale:nil] != nil, @"Search path 'Images' didn't work.");

}


-(void)testContentScaleLoading
{
	[CCFileUtils resetSingleton];
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	sharedFileUtils.searchMode = CCFileUtilsSearchModeSuffix;
	
	// assume we're on iPhone5 HD.
	// CCFileUtilsSuffixiPhoneHD is hardcoded to look for the "-hd" suffix.
	// So overwrite to look only for these for the purpose of the test.
	[ (NSMutableArray*) [sharedFileUtils searchResolutionsOrder] removeAllObjects];
	[ (NSMutableArray*) [sharedFileUtils searchResolutionsOrder] addObject:CCFileUtilsSuffixiPhoneHD];

	
	CGFloat scale = 0.0;
	
	NSString *path1 = [sharedFileUtils fullPathForFilename:@"Images/blocks.png" contentScale:&scale];
	XCTAssertTrue(scale == 2.0, @"");
	XCTAssertTrue(path1 != nil, @"");

}



@end
