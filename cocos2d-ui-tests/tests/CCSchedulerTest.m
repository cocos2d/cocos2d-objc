//
//  ObjectALTest.m
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 11/11/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "TestBase.h"


@interface SchedulerTestSprite : CCSprite @end
@implementation SchedulerTestSprite {
	CCTime _updateTime, _fixedUpdateTime;
}

-(id)initWithTexture:(CCTexture *)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
	if((self = [super initWithTexture:texture rect:rect rotated:rotated])){
		self.position = ccp(390, 160);
	}
	
	return self;
}

-(void)foo:(CCTime)delta
{
	NSLog(@"Foooo!");
}

-(void)onEnter
{
	// Scheduling a method before calling [super onEnter] used to trigger a bug.
	[self schedule:@selector(foo:) interval:1.0];
	
	[super onEnter];
}

-(void)update:(CCTime)delta
{
	// update: moves left and right
	_updateTime += delta;
	
	CGPoint pos = self.position;
	pos.x = 360 + 30*cos(_updateTime);
	self.position = pos;
}

-(void)fixedUpdate:(CCTime)delta
{
	// fixedUpdate: moves up and down
	_fixedUpdateTime += delta;
	
	CGPoint pos = self.position;
	pos.y = 160 + 30*sin(_updateTime);
	self.position = pos;
}

@end


#define CLASS_NAME CCSchedulerTest

@interface CLASS_NAME : TestBase @end
@implementation CLASS_NAME

-(void)pauseTestWithParent:(CCNode *)parent objectToPause:(CCNode *)objectToPause
{
	{
		// Set up a simple physics scene.
		CCPhysicsNode *physics = [CCPhysicsNode node];
		physics.debugDraw = YES;
		
		CCNode *bounds = [CCNode node];
		bounds.physicsBody = [CCPhysicsBody bodyWithPolylineFromRect:CGRectMake(0, 80, 240, 120) cornerRadius:1];
		bounds.physicsBody.elasticity = 1.0;
		[physics addChild:bounds];
		
		CCNode *ball = [CCNode node];
		ball.position = ccp(120, 160);
		
		CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:10 andCenter:CGPointZero];
		body.elasticity = 1.0;
		body.friction = 0.0;
		body.velocity = ccpMult(CCRANDOM_ON_UNIT_CIRCLE(), 200.0);
		ball.physicsBody = body;
		
		[physics addChild:ball];
		[parent addChild:physics];
	}
	
	{
		// Tests pausing update: and fixedUpdate:
		CCSprite *sprite = [SchedulerTestSprite spriteWithImageNamed:@"Sprites/bird.png"];
		[parent addChild:sprite];
	}
	
	{
		// Tests pausing actions
		CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
		sprite.position = ccp(360, 160);
		[sprite runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:1 angle:90]]];
		[parent addChild:sprite];
	}
	
	CCButton *pause = [CCButton buttonWithTitle:@"Pause"];
	pause.block = ^(id sender){
		objectToPause.paused = !objectToPause.paused;
		[(CCButton *)sender setTitle:objectToPause.paused ? @"Unpause" : @"Pause"];
	};
	pause.positionType = CCPositionTypeNormalized;
	pause.position = ccp(0.5, 0.2);
	[parent addChild:pause];
	
}

- (void) setupPause1Test
{
	// Test pausing just the content node.
	self.subTitle = @"All motion should stop when paused (1)";
	[self pauseTestWithParent:self.contentNode objectToPause:self.contentNode];
}

- (void) setupPause2Test
{
	// Test pausing the whole scene.
	self.subTitle = @"All motion should stop when paused (2)\nThis test pauses the entire scene.";
	[self pauseTestWithParent:self.contentNode objectToPause:self.scene];
}

- (void) setupPause3Test
{
	// Test pausing the content node with extra parent nodes.
	self.subTitle = @"All motion should stop when paused (3)";
	
	CCNode *node1 = [CCNode node];
	[self.contentNode addChild:node1];
	
	CCNode *node2 = [CCNode node];
	node2.contentSize = self.contentNode.contentSizeInPoints;
	[node1 addChild:node2];
	
	[self pauseTestWithParent:node2 objectToPause:self.contentNode];
}

@end
