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

@implementation CCActionMoveToMovingTargetTest {
    CCSprite *_spriteToFollow;
    CCSprite *_followingSprite;
}

#pragma mark - Move To Node

- (void)basicSetup
{
    // setup sprite to follow
    _spriteToFollow = [CCSprite spriteWithImageNamed:@"Sprites/shape-1.png"];
    _spriteToFollow.position = ccp(400,200);
    
    CCActionMoveBy *moveBottomLeft = [CCActionMoveBy actionWithDuration:1.f position:ccp(-50, -200)];
    CCActionMoveBy *moveTopRight = [CCActionMoveBy actionWithDuration:1.f position:ccp(50, 200)];
    
    CCActionSequence *moveSequence = [CCActionSequence actionOne:moveBottomLeft two:moveTopRight];
    CCActionRepeatForever *repeatMovement = [CCActionRepeatForever actionWithAction:moveSequence];
    
    [_spriteToFollow runAction:repeatMovement];
    
    [self.contentNode addChild:_spriteToFollow];
    
    // setup following sprite
    _followingSprite = [CCSprite spriteWithImageNamed:@"Sprites/shape-0.png"];
    _followingSprite.position = ccp(100,100);
    [self.contentNode addChild:_followingSprite];
}

- (void)setupNodeFollowingTest
{
    self.subTitle = @"Move to node. Once reached position stop following";

    [self basicSetup];
    
    CCActionMoveToMovingTarget *moveTo = [CCActionMoveToMovingTarget actionWithSpeed:100.f targetNode:_spriteToFollow];
    [_followingSprite runAction:moveTo];
}

- (void)setupNodeFollowingInfiniteTest
{
    self.subTitle = @"Move to node. Follow infinitely";

    [self basicSetup];

    CCActionMoveToMovingTarget *moveTo = [CCActionMoveToMovingTarget actionWithSpeed:100.f targetNode:_spriteToFollow followInfinite:TRUE];
    [_followingSprite runAction:moveTo];
}

#pragma mark - Move To block provided position

- (void)setupBlockFollowingTest
{
    self.subTitle = @"Move to position provided by block. Once reached position stop following";

    [self basicSetup];
    
    CCActionMoveToMovingTarget *moveTo = [CCActionMoveToMovingTarget actionWithSpeed:100.f positionUpdateBlock:^CGPoint{
        return _spriteToFollow.position;
    }];
    [_followingSprite runAction:moveTo];
}

- (void)setupBlockFollowingInfiniteTest
{
    self.subTitle = @"Move to position provided by block. Follow infinitely";
    
    [self basicSetup];
    
    CCActionMoveToMovingTarget *moveTo = [CCActionMoveToMovingTarget actionWithSpeed:100.f positionUpdateBlock:^CGPoint{
        return _spriteToFollow.position;
    } followInfinite:TRUE];
    [_followingSprite runAction:moveTo];
}

#pragma mark - Completion Handler Test

- (void)setupBlockFollowingCompletionHandlerTest
{
    self.subTitle = @"Move to position provided by block. Once reached position add label";
    
    [self basicSetup];
    
    CCActionMoveToMovingTarget *moveTo = [CCActionMoveToMovingTarget actionWithSpeed:100.f positionUpdateBlock:^CGPoint{
        return _spriteToFollow.position;
    }];
    
    CCLabelTTF *completedLabel = [CCLabelTTF labelWithString:@"Completed!" fontName:@"Arial" fontSize:20];
    completedLabel.positionType = CCPositionTypeNormalized;
    completedLabel.position = ccp(0.5, 0.5);
    
    moveTo.actionCompletedBlock = ^(void) {
        [self.contentNode addChild:completedLabel];
    };
    
    [_followingSprite runAction:moveTo];
}

- (void)setupNodeFollowingCompletionHandlerTest
{
    self.subTitle = @"Move to Node. Once reached position add label";
    
    [self basicSetup];
    
    CCActionMoveToMovingTarget *moveTo = [CCActionMoveToMovingTarget actionWithSpeed:100.f targetNode:_spriteToFollow];
    
    CCLabelTTF *completedLabel = [CCLabelTTF labelWithString:@"Completed!" fontName:@"Arial" fontSize:20];
    completedLabel.positionType = CCPositionTypeNormalized;
    completedLabel.position = ccp(0.5, 0.5);
    
    moveTo.actionCompletedBlock = ^(void) {
        [self.contentNode addChild:completedLabel];
    };
    
    [_followingSprite runAction:moveTo];
}


@end
