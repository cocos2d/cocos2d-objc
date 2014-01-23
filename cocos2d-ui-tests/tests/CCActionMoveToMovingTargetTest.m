//
//  CCActionMoveToMovingTargetTest.m
//  cocos2d-tests-ios
//
//  Created by Benjamin Encz on 23/01/14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import "cocos2d.h"
#import "TestBase.h"

@interface CCActionMoveToMovingTargetTest : TestBase @end

@implementation CCActionMoveToMovingTargetTest

#pragma mark - Move To Node

- (void)setupBasicFollowingTest
{
    self.subTitle = @"Move to node. Once reached position stop following";

    // setup sprite to follow
    
    CCSprite *spriteToFollow = [CCSprite spriteWithImageNamed:@"Sprites/shape-1.png"];
    spriteToFollow.position = ccp(400,200);
    
    CCActionMoveBy *moveBottomLeft = [CCActionMoveBy actionWithDuration:1.f position:ccp(-50, -200)];
    CCActionMoveBy *moveTopRight = [CCActionMoveBy actionWithDuration:1.f position:ccp(50, 200)];

    CCActionSequence *moveSequence = [CCActionSequence actionOne:moveBottomLeft two:moveTopRight];
    CCActionRepeatForever *repeatMovement = [CCActionRepeatForever actionWithAction:moveSequence];
    
    [spriteToFollow runAction:repeatMovement];
    
    [self.contentNode addChild:spriteToFollow];
    
    // setup following sprite
    
    CCSprite *followingSprite = [CCSprite spriteWithImageNamed:@"Sprites/shape-0.png"];
    followingSprite.position = ccp(100,100);
    [self.contentNode addChild:followingSprite];
    
    CCActionMoveToMovingTarget *moveTo = [CCActionMoveToMovingTarget actionWithSpeed:100.f targetNode:spriteToFollow];
    [followingSprite runAction:moveTo];
}

- (void)setupBasicFollowingInfiniteTest {
    self.subTitle = @"Move to node. Follow infinitely";
    
    // setup sprite to follow
    
    CCSprite *spriteToFollow = [CCSprite spriteWithImageNamed:@"Sprites/shape-1.png"];
    spriteToFollow.position = ccp(400,200);
    
    CCActionMoveBy *moveBottomLeft = [CCActionMoveBy actionWithDuration:1.f position:ccp(-50, -200)];
    CCActionMoveBy *moveTopRight = [CCActionMoveBy actionWithDuration:1.f position:ccp(50, 200)];
    
    CCActionSequence *moveSequence = [CCActionSequence actionOne:moveBottomLeft two:moveTopRight];
    CCActionRepeatForever *repeatMovement = [CCActionRepeatForever actionWithAction:moveSequence];
    
    [spriteToFollow runAction:repeatMovement];
    
    [self.contentNode addChild:spriteToFollow];
    
    // setup following sprite
    
    CCSprite *followingSprite = [CCSprite spriteWithImageNamed:@"Sprites/shape-0.png"];
    followingSprite.position = ccp(100,100);
    [self.contentNode addChild:followingSprite];
    
    CCActionMoveToMovingTarget *moveTo = [CCActionMoveToMovingTarget actionWithSpeed:100.f targetNode:spriteToFollow followInfinite:TRUE];
    [followingSprite runAction:moveTo];
}

#pragma mark - Move To Node


@end
