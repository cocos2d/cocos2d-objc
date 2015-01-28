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

@interface CCMemoryNode : CCNode

@end

@implementation CCMemoryNode

-(id)retain
{
	//Help with debug.
	//NSLog(@"CCMemoryNode : Retain %@",[NSThread callStackSymbols]);
	return [super retain];
}

-(oneway void)release
{
	//Help with debug.
	//NSLog(@"CCMemoryNode : release %@",[NSThread callStackSymbols]);
	[super release];
}

-(id)autorelease
{
	//Help with debug.
	//NSLog(@"CCMemoryNode : retain | autorelease %@",[NSThread callStackSymbols]);
	return [super autorelease];
}

@end

@interface CCMemoryTests : XCTestCase
@end


@implementation CCMemoryTests

- (void)testPhysicsBodyRetainCycle1
{
	CCNode *node = [[CCNode alloc] init];
	XCTAssertEqual(1, node.retainCount, @"");
	
	node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
	XCTAssertEqual(1, node.retainCount, @"");
	
	node.physicsBody = nil;
	XCTAssertEqual(1, node.retainCount, @"");
	
	[node release];
}

- (void)testPhysicsBodyRetainCycle2
{
	CCNode *node;
	CCPhysicsNode *physics;
	@autoreleasepool {
		node = [[CCMemoryNode alloc] init];
		XCTAssertEqual(1, node.retainCount, @"");
		
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
		XCTAssertEqual(1, node.retainCount, @"");
		
		physics = [CCPhysicsNode node];
		[physics onEnter];
		
		[physics addChild:node];
		XCTAssert(node.retainCount > 1, @"");
		
		[physics removeChild:node];

#warning Explicitly calling cleanup wasn't necessary in develop. Currently required to unschedule the physics node, which is causing an extra retain.
        [physics cleanup];
	}
	XCTAssertEqual(1, node.retainCount, @"");
	XCTAssertEqual(1, physics.retainCount, @"");
	
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
