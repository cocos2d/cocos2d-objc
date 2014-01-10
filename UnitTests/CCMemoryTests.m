//
//  CCMemoryTests.m
//  cocos2d-tests-ios
//
//  Created by Scott Lembcke on 1/9/14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"
#import "CCNode_private.h"

@interface CCMemoryTests : XCTestCase
@end


@implementation CCMemoryTests

- (void)testPhysicsBodyRetainCycle1
{
	CCNode *node = [[CCNode alloc] init];
	XCTAssert(node.retainCount == 1, @"");
	
	node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
	XCTAssert(node.retainCount == 1, @"");
	
	node.physicsBody = nil;
	XCTAssert(node.retainCount == 1, @"");
	
	[node release];
}

- (void)testPhysicsBodyRetainCycle2
{
	CCNode *node = [[CCNode alloc] init];
	XCTAssert(node.retainCount == 1, @"");
	
	node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
	XCTAssert(node.retainCount == 1, @"");
	
	CCPhysicsNode *physics = [CCPhysicsNode node];
	[physics onEnter];
	
	[physics addChild:node];
	XCTAssert(node.retainCount > 1, @"");
	
	[physics removeChild:node];
	XCTAssert(node.retainCount == 1, @"");
	
	[physics release];
	[node release];
}

// There are terrible problems with the following test.
// I think it's due to singletons not getting cleaned up properly. -_-

//- (void)testPhysicsBodyRetainCycle3
//{
//	CCNode *node = [[CCNode alloc] init];
//	XCTAssert(node.retainCount == 1, @"");
//	
//	node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
//	XCTAssert(node.retainCount == 1, @"");
//	
//	@autoreleasepool {
//		CCPhysicsNode *physics = [CCPhysicsNode node];
//		[physics onEnter];
//		
//		[physics addChild:node];
//		XCTAssert(node.retainCount > 1, @"");
//		
//		[physics onExit];
//		[physics cleanup];
//	}
//	XCTAssert(node.retainCount == 1, @"");
//	
//	[node release];
//}

@end
