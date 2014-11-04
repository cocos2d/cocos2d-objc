//
//  CCPhysicsTests.m
//  CCPhysicsTests
//
//  Created by Scott Lembcke on 10/11/13.
//
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"

#import "CCPhysics+ObjectiveChipmunk.h"
#import "CCDirector_Private.h"
#import "AppDelegate.h"

@interface CCScheduler(Test)

-(CCTimer*)fixedUpdateTimer;

@end

@interface CCPhysicsTests : XCTestCase <CCPhysicsCollisionDelegate>

@end


@implementation CCPhysicsTests

- (void)setUp
{
    [super setUp];

    [(AppController *)[UIApplication sharedApplication].delegate configureCocos2d];
    [[CCDirector sharedDirector] startAnimation];
}

static void
TestBasicSequenceHelper(id self, CCPhysicsNode *physicsNode, CCNode *parent, CCNode *node, CCPhysicsBody *body)
{
	// Probably not necessary, but doesn't hurt.
	CCScene *scene = [CCScene node];
	[scene addChild:physicsNode];
	
	// Allow the parent to be the physics node.
	if(parent != physicsNode) [physicsNode addChild:parent];
	
	CGPoint position = node.position;
	float rotation = node.rotation;
	
	const float accuracy = 1e-4;
	
	// Sanity check.
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	[parent addChild:node];
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Set the physics body.
	// Node's internal transform is still used since the onEnter hasn't happened.
	node.physicsBody = body;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
		
	// Force on onEnter to be called.
	// Body's transform is now used instead of the node's.
	[scene onEnter];
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Remove the node and check the position is still correct
	[node removeFromParent];
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Add back to the physics
	[parent addChild:node];
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Force onExit
	[scene onExit];
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Force re-entry to the scene.
	[scene onEnter];
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Try switching the physics body.
	node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:ccp(1,1)];
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Test setting the body to nil.
	node.physicsBody = nil;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Set back to the original body
	node.physicsBody = body;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Try setting the body when not added to a scene anymore.
	[node removeFromParent];
	node.physicsBody = nil;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Terrible things happen when you don't call this due to Cocos2D global variables.
	[scene onExit];
}

-(void)testBasicSequences1
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	CCNode *node = [CCNode node];
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, physicsNode, node, body);
}

-(void)testBasicSequences2
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *node = [CCNode node];
	node.position = ccp(100, 100);
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, physicsNode, node, body);
}

-(void)testBasicSequences3
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0.5, 0.5);
	node.position = ccp(100, 100);
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, physicsNode, node, body);
}

-(void)testBasicSequences4
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0.5, 0.5);
	node.position = ccp(100, 100);
	node.rotation = 30;
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, physicsNode, node, body);
}

-(void)testBasicSequences5
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0.5, 0.5);
	node.position = ccp(100, 100);
	node.rotation = 30;
	node.scaleX = 2.0;
	node.scaleY = 3.0;
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, physicsNode, node, body);
}

-(void)testBasicSequences6
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *parent = [CCNode node];
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0.5, 0.5);
	node.position = ccp(100, 100);
	node.rotation = 30;
	node.scaleX = 2.0;
	node.scaleY = 3.0;
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, parent, node, body);
}

-(void)testBasicSequences7
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *parent = [CCNode node];
	parent.position = ccp(20, 60);
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0.5, 0.5);
	node.position = ccp(100, 100);
	node.rotation = 30;
	node.scaleX = 2.0;
	node.scaleY = 3.0;
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, parent, node, body);
}

-(void)testBasicSequences8
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *parent = [CCNode node];
	parent.contentSize = CGSizeMake(25, 35);
	parent.anchorPoint = ccp(0.3, 0.7);
	parent.position = ccp(20, 60);
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0.5, 0.5);
	node.position = ccp(100, 100);
	node.rotation = 30;
	node.scaleX = 2.0;
	node.scaleY = 3.0;
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, parent, node, body);
}

-(void)testBasicSequences9
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *parent = [CCNode node];
	parent.contentSize = CGSizeMake(25, 35);
	parent.anchorPoint = ccp(0.3, 0.7);
	parent.position = ccp(20, 60);
	parent.rotation = -10;
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0.5, 0.5);
	node.position = ccp(100, 100);
	node.rotation = 35;
	node.scaleX = 2.0;
	node.scaleY = 3.0;
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, parent, node, body);
}

-(void)testBasicSequences10
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *parent = [CCNode node];
	parent.contentSize = CGSizeMake(25, 35);
	parent.anchorPoint = ccp(0.3, 0.7);
	parent.position = ccp(20, 60);
	parent.rotation = -15;
	parent.scaleX = 1.5;
	parent.scaleY = 8.0;
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0,0);
	node.position = ccp(100, 100);
	node.rotation = 30;
	node.scaleX = 2.0;
	node.scaleY = 3.0;
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, parent, node, body);
}

-(void)testBasicSequences11
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *parent = [CCNode node];
	parent.contentSize = CGSizeMake(25, 35);
	parent.anchorPoint = ccp(0.3, 0.7);
	parent.position = ccp(20, 60);
	parent.rotation = -15;
	parent.scaleX = 1.5;
	parent.scaleY = 8.0;
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0,0);
	node.position = ccp(100, 100);
	node.rotation = 30;
	node.scaleX = 2.0;
	node.scaleY = 3.0;
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	body.type = CCPhysicsBodyTypeStatic;
	
	TestBasicSequenceHelper(self, physicsNode, parent, node, body);
}

-(void)testDynamicAnchorPoint
{
	cpFloat accuracy = 1e-4;
	
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(2, 2);
	node.anchorPoint = ccp(0.5, 0.5);
	XCTAssert(ccpDistance(node.position, CGPointZero) < accuracy, @"");
	
	node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	node.physicsBody.type = CCPhysicsBodyTypeDynamic;
	XCTAssert(ccpDistance(node.position, CGPointZero) < accuracy, @"");
	
	[physicsNode addChild:node];
	[physicsNode onEnter];
	XCTAssert(ccpDistance(node.position, CGPointZero) < accuracy, @"");
	
	node.rotation = 90;
	XCTAssert(ccpDistance(node.position, CGPointZero) < accuracy, @"");
	
	[physicsNode onExit];
}

-(void)testStaticAnchorPoint
{
	cpFloat accuracy = 1e-4;
	
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(2, 2);
	node.anchorPoint = ccp(0.5, 0.5);
	XCTAssert(ccpDistance(node.position, CGPointZero) < accuracy, @"");
	
	node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	node.physicsBody.type = CCPhysicsBodyTypeStatic;
	XCTAssert(ccpDistance(node.position, CGPointZero) < accuracy, @"");
	
	[physicsNode addChild:node];
	[physicsNode onEnter];
	XCTAssert(ccpDistance(node.position, CGPointZero) < accuracy, @"");
	
	node.rotation = 90;
	XCTAssert(ccpDistance(node.position, CGPointZero) < accuracy, @"");
	
	[physicsNode onExit];
}

-(void)testCollisionGroups
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	NSString *noCollide = @"nocollide";
	
	CCNode *node1 = [CCNode node];
	node1.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	node1.physicsBody.collisionGroup = noCollide;
	[physicsNode addChild:node1];
	
	CCNode *node2 = [CCNode node];
	node2.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	node2.physicsBody.collisionGroup = noCollide;
	[physicsNode addChild:node2];
	
	// Force entering the scene to set up the physics objects.
	[physicsNode onEnter];
	
	// Step the physics for a while.
	for(int i=0; i<100; i++){
		[physicsNode fixedUpdate:1.0/60.0];
	}
	
	// Both nodes should be at (0, 0)
	XCTAssertTrue(CGPointEqualToPoint(node1.position, CGPointZero) , @"");
	XCTAssertTrue(CGPointEqualToPoint(node2.position, CGPointZero) , @"");
	
	[physicsNode onExit];
}

-(void)testAffectedByGravity
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	physicsNode.gravity = ccp(0, -100);
	
	NSString *noCollide = @"nocollide";
	
	CCNode *node1 = [CCNode node];
	node1.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	node1.physicsBody.collisionGroup = noCollide;
	[physicsNode addChild:node1];
	
	CCNode *node2 = [CCNode node];
	node2.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	node2.physicsBody.collisionGroup = noCollide;
	node2.physicsBody.affectedByGravity = NO;
	[physicsNode addChild:node2];
	
	// Force entering the scene to set up the physics objects.
	[physicsNode onEnter];
	
	// Step the physics for a while.
	for(int i=0; i<100; i++){
		[physicsNode fixedUpdate:1.0/60.0];
	}
	
	// Node1 should move down due to gravity
	XCTAssertTrue(node1.position.y < 0.0, @"");
	
	// Node2 should stay at (0, 0)
	XCTAssertTrue(node2.position.y == 0.0, @"");
	
	[physicsNode onExit];
}

-(void)testAllowsRotation
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	[physicsNode onEnter];
	
	{
		// Regular body.
		CCNode *node = [CCNode node];
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
		XCTAssert(node.physicsBody.allowsRotation == YES, @"");
		
		[physicsNode addChild:node];
		XCTAssert(node.physicsBody.allowsRotation == YES, @"");
		
		XCTAssert(node.physicsBody.body.moment < INFINITY, @"");
	}{
		// Set before adding.
		CCNode *node = [CCNode node];
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
		node.physicsBody.allowsRotation = NO;
		XCTAssert(node.physicsBody.allowsRotation == NO, @"");
		
		[physicsNode addChild:node];
		XCTAssert(node.physicsBody.allowsRotation == NO, @"");
		
		XCTAssert(node.physicsBody.body.moment == INFINITY, @"");
	}{
		// Set after adding.
		CCNode *node = [CCNode node];
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
		XCTAssert(node.physicsBody.allowsRotation == YES, @"");
		
		[physicsNode addChild:node];
		XCTAssert(node.physicsBody.allowsRotation == YES, @"");
		node.physicsBody.allowsRotation = NO;
		XCTAssert(node.physicsBody.allowsRotation == NO, @"");
		
		XCTAssert(node.physicsBody.body.moment == INFINITY, @"");
	}{
		// Set and reverted before adding.
		CCNode *node = [CCNode node];
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
		node.physicsBody.allowsRotation = NO;
		XCTAssert(node.physicsBody.allowsRotation == NO, @"");
		node.physicsBody.allowsRotation = YES;
		XCTAssert(node.physicsBody.allowsRotation == YES, @"");
		
		[physicsNode addChild:node];
		XCTAssert(node.physicsBody.allowsRotation == YES, @"");
		
		XCTAssert(node.physicsBody.body.moment < INFINITY, @"");
	}{
		// Set before and reverted after adding.
		CCNode *node = [CCNode node];
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
		node.physicsBody.allowsRotation = NO;
		XCTAssert(node.physicsBody.allowsRotation == NO, @"");
		
		[physicsNode addChild:node];
		XCTAssert(node.physicsBody.allowsRotation == NO, @"");
		node.physicsBody.allowsRotation = YES;
		XCTAssert(node.physicsBody.allowsRotation == YES, @"");
		
		XCTAssert(node.physicsBody.body.moment < INFINITY, @"");
	}{
		// Set reverted after adding.
		CCNode *node = [CCNode node];
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
		XCTAssert(node.physicsBody.allowsRotation == YES, @"");
		
		[physicsNode addChild:node];
		XCTAssert(node.physicsBody.allowsRotation == YES, @"");
		node.physicsBody.allowsRotation = NO;
		XCTAssert(node.physicsBody.allowsRotation == NO, @"");
		node.physicsBody.allowsRotation = YES;
		XCTAssert(node.physicsBody.allowsRotation == YES, @"");
		
		XCTAssert(node.physicsBody.body.moment < INFINITY, @"");
	}
	
	[physicsNode onExit];
}

-(void)testBodyType
{
	CGPoint points[3] = {};
	
	// Regular bodies should default to being dynamic.
	XCTAssertEqual([CCPhysicsBody bodyWithCircleOfRadius:0 andCenter:CGPointZero].type, CCPhysicsBodyTypeDynamic, @"");
	XCTAssertEqual([CCPhysicsBody bodyWithPillFrom:ccp(0, 1) to:ccp(1, 0) cornerRadius:0].type, CCPhysicsBodyTypeDynamic, @"");
	XCTAssertEqual([CCPhysicsBody bodyWithPolygonFromPoints:points count:3 cornerRadius:0].type, CCPhysicsBodyTypeDynamic, @"");
	XCTAssertEqual([CCPhysicsBody bodyWithRect:CGRectZero cornerRadius:0].type, CCPhysicsBodyTypeDynamic, @"");
	
	// Polyline bodies should default to being static bodies.
	XCTAssertEqual([CCPhysicsBody bodyWithPolylineFromRect:CGRectZero cornerRadius:0].type, CCPhysicsBodyTypeStatic, @"");
	
	XCTAssertEqual([CCPhysicsBody bodyWithPolylineFromPoints:points count:3 cornerRadius:0 looped:YES].type, CCPhysicsBodyTypeStatic, @"");
	
	// Test body type setters
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:0 andCenter:CGPointZero];
	
	body.type = CCPhysicsBodyTypeStatic;
	XCTAssertEqual(body.type, CCPhysicsBodyTypeStatic, @"");
	XCTAssertEqual(body.body.type, CP_BODY_TYPE_STATIC, @"");
	
//	body.type = CCPhysicsBodyTypeKinematic;
//	XCTAssertEqual(body.type, CCPhysicsBodyTypeKinematic, @"");
//	XCTAssertEqual(body.body.type, CP_BODY_TYPE_KINEMATIC, @"");
	
	body.type = CCPhysicsBodyTypeDynamic;
	XCTAssertEqual(body.type, CCPhysicsBodyTypeDynamic, @"");
	XCTAssertEqual(body.body.type, CP_BODY_TYPE_DYNAMIC, @"");
}

-(void)testBreakingJoints
{
	CCPhysicsNode *physics = [CCPhysicsNode node];
	physics.gravity = ccp(0, -100);
	
	CGRect rect = CGRectMake(0, 0, 50, 50);
	CCPhysicsJoint *joint1, *joint2, *joint3, *joint4;
	
	// These should break.
	{
		CCNode *node1 = [CCNode node];
		node1.position = ccp(100, 200);
		
		CCPhysicsBody *body1 = node1.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
		body1.type = CCPhysicsBodyTypeStatic;
		
		[physics addChild:node1];
		
		CCNode *node2 = [CCNode node];
		node2.position = ccp(100, 100);
		
		CCPhysicsBody *body2 = node2.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
		
		[physics addChild:node2];
		
		joint1 = [CCPhysicsJoint connectedPivotJointWithBodyA:body1 bodyB:body2 anchorA:ccp(rect.size.width/2.0, -rect.size.height/4.0)];
		joint1.breakingForce = -physics.gravity.y*body2.mass*0.9;
	}{
		CCNode *node1 = [CCNode node];
		node1.position = ccp(200, 200);
		
		CCPhysicsBody *body1 = node1.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
		body1.type = CCPhysicsBodyTypeStatic;
		
		[physics addChild:node1];
		
		CCNode *node2 = [CCNode node];
		node2.position = ccp(200, 100);
		
		CCPhysicsBody *body2 = node2.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
		
		[physics addChild:node2];
		
		joint2 = [CCPhysicsJoint connectedDistanceJointWithBodyA:body1 bodyB:body2 anchorA:ccp(rect.size.width/2.0, 0.0) anchorB:ccp(rect.size.width/2.0, rect.size.height)];
		joint2.breakingForce = -physics.gravity.y*body2.mass*0.9;
	}
	
	// These shouldn't
	{
		CCNode *node1 = [CCNode node];
		node1.position = ccp(300, 200);
		
		CCPhysicsBody *body1 = node1.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
		body1.type = CCPhysicsBodyTypeStatic;
		
		[physics addChild:node1];
		
		CCNode *node2 = [CCNode node];
		node2.position = ccp(300, 100);
		
		CCPhysicsBody *body2 = node2.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
		
		[physics addChild:node2];
		
		joint3 = [CCPhysicsJoint connectedPivotJointWithBodyA:body1 bodyB:body2 anchorA:ccp(rect.size.width/2.0, -rect.size.height/4.0)];
		joint3.breakingForce = -physics.gravity.y*body2.mass*1.1;
	}{
		CCNode *node1 = [CCNode node];
		node1.position = ccp(400, 200);
		
		CCPhysicsBody *body1 = node1.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
		body1.type = CCPhysicsBodyTypeStatic;
		
		[physics addChild:node1];
		
		CCNode *node2 = [CCNode node];
		node2.position = ccp(400, 100);
		
		CCPhysicsBody *body2 = node2.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
		
		[physics addChild:node2];
		
		joint4 = [CCPhysicsJoint connectedDistanceJointWithBodyA:body1 bodyB:body2 anchorA:ccp(rect.size.width/2.0, 0.0) anchorB:ccp(rect.size.width/2.0, rect.size.height)];
		joint4.breakingForce = -physics.gravity.y*body2.mass*1.1;
	}
	
	[physics onEnter];
	
	for(int i=0; i<100; i++){
		[physics fixedUpdate:1.0/60.0];
	}
	
	XCTAssert(!joint1.valid, @"");
	XCTAssert(!joint2.valid, @"");
	XCTAssert(joint3.valid, @"");
	XCTAssert(joint4.valid, @"");
	
	[physics onExit];
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair theStaticOne:(CCNode *)nodeA theDynamicOne:(CCNode *)nodeB
{
	nodeB.physicsBody.type = CCPhysicsBodyTypeStatic;
	
	// TODO not sure if we should hide the deferred nature or not... Hrm.
	XCTAssertEqual(nodeB.physicsBody.type, CCPhysicsBodyTypeDynamic, @"");
	
	return FALSE;
}

-(void)testBodyTypeCollisions
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	physicsNode.collisionDelegate = self;
	physicsNode.gravity = ccp(0, -100);
	
	CCNode *node1 = [CCNode node];
	node1.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	node1.physicsBody.type = CCPhysicsBodyTypeStatic;
	node1.physicsBody.collisionType = @"theStaticOne";
	[physicsNode addChild:node1];
	
	CCNode *node2 = [CCNode node];
	node2.position = ccp(0, 10);
	node2.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	node2.physicsBody.type = CCPhysicsBodyTypeDynamic;
	node2.physicsBody.collisionType = @"theDynamicOne";
	[physicsNode addChild:node2];
	
	// Force entering the scene to set up the physics objects.
	[physicsNode onEnter];
	
	// Step the physics for a while.
	for(int i=0; i<100; i++){
		[physicsNode fixedUpdate:1.0/100.0];
	}
	
	XCTAssertEqual(node2.physicsBody.type, CCPhysicsBodyTypeStatic, @"");
	
	[physicsNode onExit];
}

-(void)testBodyEachCollisionPair
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	physicsNode.gravity = ccp(0, -100);
	
	CCNode *node1 = [CCNode node];
	node1.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	node1.physicsBody.type = CCPhysicsBodyTypeStatic;
	[physicsNode addChild:node1];
	
	CCNode *node2 = [CCNode node];
	node2.position = ccp(0, 10);
	node2.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	node2.physicsBody.type = CCPhysicsBodyTypeDynamic;
	[physicsNode addChild:node2];
	
	// Force entering the scene to set up the physics objects.
	[physicsNode onEnter];
	
	// Step the physics for a while.
	for(int i=0; i<100; i++){
		[physicsNode fixedUpdate:1.0/100.0];
	}
	
	__block BOOL check = NO;
	
	[node1.physicsBody eachCollisionPair:^(CCPhysicsCollisionPair *pair) {
		CCPhysicsShape *a, *b; [pair shapeA:&a shapeB:&b];
		check = (
			(a.node == node1 && b.node == node2) ||
			(b.node == node1 && a.node == node2)
		);
	}];
	
	XCTAssert(check, @"The objects should have had a collision pair listed between them.");
	
	[physicsNode onExit];
}

//Focusing on Position.
-(void)testKineticBodyBasic1
{
    CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	physicsNode.collisionDelegate = self;
	physicsNode.gravity = ccp(0, 0);
    
    CGPoint node0Pos = ccp(100.0f,0.0f);
    
    CCNode *node0 = [CCNode node];
    node0.position = node0Pos;
    node0.name = @"node0";
    [physicsNode addChild:node0];
	
    CCPhysicsBody * body1 = [CCPhysicsBody bodyWithRect:CGRectMake(0, 0, 60, 20) cornerRadius:0];

    
    CGPoint node1Pos = ccp(-25, 0);
	CCNode *node1 = [CCNode node];
	node1.physicsBody = body1;
	node1.physicsBody.type = CCPhysicsBodyTypeStatic;
	node1.physicsBody.collisionType = @"theStaticOne";
    node1.name = @"node1";
    node1.position = node1Pos;
    node1.contentSize = CGSizeMake(60, 20);
    node1.anchorPoint = ccp(0.5f,0.5f);
	[node0 addChild:node1];
    
	// Force entering the scene to set up the physics objects.
	[physicsNode onEnter];
    
    // Step the physics for a while.
    const int KineticCount = 50;
    
    //Test translation.
	for(int i=0; i<100; i++)
    {
        if(i < KineticCount)
        {
            node0.position = ccp(node0Pos.x + (i + 1), node0Pos.y);
        }
      
		[physicsNode fixedUpdate:1.0/100.0];
        
        if(i >= KineticCount)
        {
            XCTAssertTrue(body1.type != CCPhysicsBodyTypeKinematic,@"Should not be kinetic now.");
            XCTAssertTrue(ccpLength(body1.velocity) == 0.0f ,@"Should not have velocity.");
        }
        else
        {
            XCTAssertTrue(body1.type == CCPhysicsBodyTypeKinematic, @"Should be kinetic now");
            XCTAssertTrue(ccpLength(body1.velocity) > 0.0f ,@"Should have velocity.");
            XCTAssertTrue(body1.absolutePosition.x == (45.0f + (i + 1)), @"should be this value");
        }
	}
    
    
}

//Focusing on rotation.
-(void)testKineticBodyBasic2
{
    CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	physicsNode.collisionDelegate = self;
	physicsNode.gravity = ccp(0, 0);
    
    CGPoint node0Pos = ccp(100.0f,0.0f);
    
    CCNode *node0 = [CCNode node];
    node0.position = node0Pos;
    node0.name = @"node0";
    [physicsNode addChild:node0];
	
    CCPhysicsBody * body1 = [CCPhysicsBody bodyWithRect:CGRectMake(0, 0, 60, 20) cornerRadius:0];
    
    CGPoint node1Pos = ccp(-25, 0);
	CCNode *node1 = [CCNode node];
	node1.physicsBody = body1;
	node1.physicsBody.type = CCPhysicsBodyTypeStatic;
	node1.physicsBody.collisionType = @"theStaticOne";
    node1.name = @"node1";
    node1.position = node1Pos;
    node1.contentSize = CGSizeMake(60, 20);
    node1.anchorPoint = ccp(0.5f,0.5f);
	[node0 addChild:node1];
    
	// Force entering the scene to set up the physics objects.
	[physicsNode onEnter];
    
    // Step the physics for a while.
    const int KineticCount = 50;
 
    
    //Test translation.
	for(int i=0; i<100; i++)
    {
        if(i < KineticCount)
        {
            node0.rotation = (i + 1) * 1.0f;
            node1.rotation = (i + 1) * 1.0f;
        }
        
        [physicsNode fixedUpdate:1.0/100.0];
        
        if(i >= KineticCount)
        {
            XCTAssertTrue(body1.type != CCPhysicsBodyTypeKinematic, @"Should not be kinetic now.");
        }
        else
        {
            XCTAssertTrue(body1.type == CCPhysicsBodyTypeKinematic, @"Should be kinetic now");
            XCTAssertEqualWithAccuracy(-CC_RADIANS_TO_DEGREES(body1.absoluteRadians),(i + 1) * 2.0f,0.01f, @"Should be 2x rotation because of parent.");
        }
	}
    
    //TODO on exit
    //TODO if node0->node1->node2->node3 and you detatch node1,that node0 can get unobservered.
    
}


//When a node graph that is the child of a physics node is added (onEnter) ensure all the actions
//it subsuquently posesses are changed to fixed scheduled.
-(void)testKineticNodeActionsBasic1
{
    CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	physicsNode.collisionDelegate = self;
	physicsNode.gravity = ccp(0, 0);
    
    CGPoint node0Pos = ccp(0.0f,0.0f);
    
    CCNode *node0 = [CCNode node];
    node0.position = node0Pos;
    node0.name = @"node0";
	node0.scale = 2.0f;
	[node0 runAction:[CCActionMoveBy actionWithDuration:10 position:ccp(100, 0)]];
    [physicsNode addChild:node0];
	
    CCPhysicsBody * body1 = [CCPhysicsBody bodyWithRect:CGRectMake(0, 0, 60, 20) cornerRadius:0];
    
    CGPoint node1Pos = ccp(0, 0);
	CCNode *node1 = [CCNode node];
	node1.physicsBody = body1;
	node1.physicsBody.type = CCPhysicsBodyTypeStatic;
	node1.physicsBody.collisionType = @"theStaticOne";
    node1.name = @"node1";
    node1.position = node1Pos;
    node1.contentSize = CGSizeMake(60, 20);
    node1.anchorPoint = ccp(0.0f,0.0f);
	[node0 addChild:node1];
    
	[node1 runAction:[CCActionMoveBy actionWithDuration:10 position:ccp(100, 0)]];
	
	// Force entering the scene to set up the physics objects.
	[physicsNode onEnter];
	
	CCScheduler * scheduler =  [CCDirector sharedDirector].scheduler;
    scheduler.fixedUpdateInterval = 0.1f;
	[scheduler update:0.10f];// first tick
	const float accuracy = 1e-4;
    //test actions are fixed.
    for(int i = 0; i < 100; i++)
	{
		float desired  = (float)i * 0.1f * 100.0f/10.0f + (float)i * 0.1f * 200.0f/10.0f;
		//NSLog(@"node1.position.x=  %0.2f   desired = %0.2f",body1.absolutePosition.x, desired);
		XCTAssertEqualWithAccuracy(body1.absolutePosition.x, desired , accuracy, @"Not in the write position");
		[scheduler update:0.10f];
	}
}


//TODO
//Test : When a node is added to a scene graph, its actions are Fixed if its part of a PhysicsNode.



-(void)testApplyImpulse
{
	CCPhysicsNode *physics = [CCPhysicsNode node];
	[physics onEnter];
	
	{
		CCNode *node = [CCNode node];
		[physics addChild:node];
		
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
		node.physicsBody.mass = 5;
		
		node.physicsBody.velocity = ccp(10, 10);
		[node.physicsBody applyImpulse:ccp(5, 5)];
		XCTAssert(ccpDistance(ccp(11, 11), node.physicsBody.velocity) < 1e-5, @"");
	}{
		CCNode *node = [CCNode node];
		node.rotation = 90;
		[physics addChild:node];
		
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
		node.physicsBody.mass = 5;
		
		node.physicsBody.velocity = ccp(10, 10);
		[node.physicsBody applyImpulse:ccp(5, 5)];
		XCTAssert(ccpDistance(ccp(11, 11), node.physicsBody.velocity) < 1e-5, @"");
	}{
		CCNode *node = [CCNode node];
		node.position = ccp(20, 20);
		[physics addChild:node];
		
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
		node.physicsBody.mass = 5;
		
		node.physicsBody.velocity = ccp(10, 10);
		[node.physicsBody applyImpulse:ccp(5, 5) atWorldPoint:node.position];
		XCTAssert(ccpDistance(ccp(11, 11), node.physicsBody.velocity) < 1e-5, @"");
	}{
		CCNode *node = [CCNode node];
		node.position = ccp(20, 20);
		[physics addChild:node];
		
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
		node.physicsBody.mass = 5;
		
		node.physicsBody.velocity = ccp(10, 10);
		[node.physicsBody applyImpulse:ccp(5, 5) atLocalPoint:ccp(0, 0)];
		XCTAssert(ccpDistance(ccp(11, 11), node.physicsBody.velocity) < 1e-5, @"");
	}{
		CCNode *node = [CCNode node];
		node.position = ccp(20, 20);
		node.rotation = 90;
		[physics addChild:node];
		
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
		node.physicsBody.mass = 5;
		
		node.physicsBody.velocity = ccp(10, 10);
		[node.physicsBody applyImpulse:ccp(5, 0) atLocalPoint:ccp(0, 0)];
		XCTAssert(ccpDistance(ccp(10, 9), node.physicsBody.velocity) < 1e-5, @"");
	}{
		CCNode *node = [CCNode node];
		node.position = ccp(20, 20);
		node.rotation = 180;
		[physics addChild:node];
		
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
		node.physicsBody.mass = 5;
		
		node.physicsBody.velocity = ccp(10, 10);
		[node.physicsBody applyImpulse:ccp(5, 0) atLocalPoint:ccp(0, 1)];
		XCTAssert(ccpDistance(ccp(9, 10), node.physicsBody.velocity) < 1e-5, @"");
		XCTAssertEqualWithAccuracy(node.physicsBody.angularVelocity, -2, 1e-5, @"");
	}
	
	[physics onExit];
}

-(void)testApplyForce
{
	CCPhysicsNode *physics = [CCPhysicsNode node];
	[physics onEnter];
	
	{
		CCNode *node = [CCNode node];
		[physics addChild:node];
		
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
		node.physicsBody.mass = 5;
		
		[node.physicsBody applyForce:ccp(5, 5)];
		XCTAssert(ccpDistance(ccp(5, 5), node.physicsBody.force) < 1e-5, @"");
	}{
		CCNode *node = [CCNode node];
		node.rotation = 90;
		[physics addChild:node];
		
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
		node.physicsBody.mass = 5;
		
		[node.physicsBody applyForce:ccp(5, 5)];
		XCTAssert(ccpDistance(ccp(5, 5), node.physicsBody.force) < 1e-5, @"");
	}{
		CCNode *node = [CCNode node];
		node.position = ccp(20, 20);
		[physics addChild:node];
		
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
		node.physicsBody.mass = 5;
		
		[node.physicsBody applyForce:ccp(5, 5) atWorldPoint:node.position];
		XCTAssert(ccpDistance(ccp(5, 5), node.physicsBody.force) < 1e-5, @"");
	}{
		CCNode *node = [CCNode node];
		node.position = ccp(20, 20);
		[physics addChild:node];
		
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
		node.physicsBody.mass = 5;
		
		[node.physicsBody applyForce:ccp(5, 5) atLocalPoint:ccp(0, 0)];
		XCTAssert(ccpDistance(ccp(5, 5), node.physicsBody.force) < 1e-5, @"");
	}{
		CCNode *node = [CCNode node];
		node.position = ccp(20, 20);
		node.rotation = 90;
		[physics addChild:node];
		
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
		node.physicsBody.mass = 5;
		
		[node.physicsBody applyForce:ccp(5, 0) atLocalPoint:ccp(0, 0)];
		XCTAssert(ccpDistance(ccp(0, -5), node.physicsBody.force) < 1e-5, @"");
	}{
		CCNode *node = [CCNode node];
		node.position = ccp(20, 20);
		node.rotation = 180;
		[physics addChild:node];
		
		node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
		node.physicsBody.mass = 5;
		
		[node.physicsBody applyForce:ccp(5, 0) atLocalPoint:ccp(0, 1)];
		XCTAssert(ccpDistance(ccp(-5, 0), node.physicsBody.force) < 1e-5, @"");
		XCTAssertEqualWithAccuracy(node.physicsBody.torque, -5, 1e-5, @"");
	}
	
	[physics onExit];
}

-(void)testBodySleep
{
	CCPhysicsNode *physics = [CCPhysicsNode node];
	[physics onEnter];
	
	CCNode *staticNode = [CCNode node];
	staticNode.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
	staticNode.physicsBody.type = CCPhysicsBodyTypeStatic;
	[physics addChild:staticNode];
	
	CCNode *node = [CCNode node];
	node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
	node.physicsBody.mass = 5;
	
	// Bodies default to being active.
	XCTAssertFalse(node.physicsBody.sleeping, @"");
	
	// Setting the sleeping property before adding to a scene should be ignored.
	node.physicsBody.sleeping = YES;
	XCTAssertFalse(node.physicsBody.sleeping, @"");
	
	[physics addChild:node];
	
	node.physicsBody.sleeping = YES;
	XCTAssertTrue(node.physicsBody.sleeping, @"");
	
	node.physicsBody.sleeping = NO;
	XCTAssertFalse(node.physicsBody.sleeping, @"");
	
	// Changing various flags should wake a body up.
	node.physicsBody.sleeping = YES;
	XCTAssertTrue(node.physicsBody.sleeping, @"");
	node.physicsBody.affectedByGravity = YES;
	XCTAssertFalse(node.physicsBody.sleeping, @"");
	
	node.physicsBody.sleeping = YES;
	XCTAssertTrue(node.physicsBody.sleeping, @"");
	node.physicsBody.mass = 1.0;
	XCTAssertFalse(node.physicsBody.sleeping, @"");
	
	// Removing the node from the scene and re-adding it should wake up its body.
	node.physicsBody.sleeping = YES;
	XCTAssertTrue(node.physicsBody.sleeping, @"");
	[node removeFromParent];
	[physics addChild:node];
	XCTAssertFalse(node.physicsBody.sleeping, @"");
	
	// Adding joints should wake up a body.
	node.physicsBody.sleeping = YES;
	XCTAssertTrue(node.physicsBody.sleeping, @"");
	[CCPhysicsJoint connectedMotorJointWithBodyA:node.physicsBody bodyB:staticNode.physicsBody rate:1.0];
	XCTAssertFalse(node.physicsBody.sleeping, @"");
	
	[physics onExit];
}

// TODO
// * Check that body and shape settings are preserved through multiple add/remove cycles and are actually applied to the cpBody.
// * Check that changing properties before and after adding to an active physics node updates the properties correctly.

@end
