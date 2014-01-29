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
    
    CCActionMoveToNode *moveTo = [CCActionMoveToNode actionWithSpeed:100.f targetNode:_spriteToFollow];
    [_followingSprite runAction:moveTo];
}

- (void)setupNodeFollowingInfiniteTest
{
    self.subTitle = @"Move to node. Follow infinitely";

    [self basicSetup];

    CCActionMoveToNode *moveTo = [CCActionMoveToNode actionWithSpeed:100.f targetNode:_spriteToFollow followInfinite:YES];
    [_followingSprite runAction:moveTo];
}

#pragma mark - Move To block provided position

- (void)setupBlockFollowingTest
{
    self.subTitle = @"Move to position provided by block. Once reached position stop following";

    [self basicSetup];
    
    CCActionMoveToNode *moveTo = [CCActionMoveToNode actionWithSpeed:100.f positionUpdateBlock:^CGPoint{
        return _spriteToFollow.position;
    }];
    [_followingSprite runAction:moveTo];
}

- (void)setupBlockFollowingInfiniteTest
{
    self.subTitle = @"Move to position provided by block. Follow infinitely";
    
    [self basicSetup];
    
    CCActionMoveToNode *moveTo = [CCActionMoveToNode actionWithSpeed:100.f positionUpdateBlock:^CGPoint{
        return _spriteToFollow.position;
    } followInfinite:TRUE];
    [_followingSprite runAction:moveTo];
}

#pragma mark - Completion Handler Test

- (void)setupBlockFollowingCompletionHandlerTest
{
    self.subTitle = @"Move to position provided by block. Once reached position add label";
    
    [self basicSetup];
    
    CCActionMoveToNode *moveTo = [CCActionMoveToNode actionWithSpeed:100.f positionUpdateBlock:^CGPoint{
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
    
    CCActionMoveToNode *moveTo = [CCActionMoveToNode actionWithSpeed:100.f targetNode:_spriteToFollow];
    
    CCLabelTTF *completedLabel = [CCLabelTTF labelWithString:@"Completed!" fontName:@"Arial" fontSize:20];
    completedLabel.positionType = CCPositionTypeNormalized;
    completedLabel.position = ccp(0.5, 0.5);
    
    moveTo.actionCompletedBlock = ^(void) {
        [self.contentNode addChild:completedLabel];
    };
    
    [_followingSprite runAction:moveTo];
}

- (void)setupInfiniteNodeFollowingCompletionHandlerTest {
    self.subTitle = @"Move to Node. Once reached position add label. Label should always show '1";
    
    [self basicSetup];
    
    CCActionMoveToNode *moveTo = [CCActionMoveToNode actionWithSpeed:100.f targetNode:_spriteToFollow followInfinite:YES];
    
    CCLabelTTF *completedLabel = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:20];
    completedLabel.positionType = CCPositionTypeNormalized;
    completedLabel.position = ccp(0.5, 0.5);
    
    __block int completions = 0;
    
    moveTo.actionCompletedBlock = ^(void) {
        completions++;
        completedLabel.string = [NSString stringWithFormat:@"%d",completions];
        [self.contentNode addChild:completedLabel];
    };
    
    [_followingSprite runAction:moveTo];
}

- (void)setupInfiniteNodeFollowingCompletionHandlerWithDifferentParentsTest {
    CCNodeColor *parent1 = [CCNodeColor nodeWithColor:[CCColor redColor] width:200.f height:200.f];
    parent1.position = ccp(0, 0);
    parent1.anchorPoint = ccp(0, 0);
    parent1.opacity = 0.5f;
    [self.contentNode addChild:parent1 z:INT_MAX];
    
    CCNodeColor *parent2 = [CCNodeColor nodeWithColor:[CCColor yellowColor] width:200.f height:200.f];
    parent2.anchorPoint = ccp(0,0);
    parent2.position = ccp(300,50);
    parent2.opacity = 0.5f;
    [self.contentNode addChild:parent2 z:INT_MAX];
    
    // setup sprite to follow
    _spriteToFollow = [CCSprite spriteWithImageNamed:@"Sprites/shape-1.png"];
    _spriteToFollow.position = ccp(100,200);
    
    CCActionMoveBy *moveBottomLeft = [CCActionMoveBy actionWithDuration:1.f position:ccp(-50, -200)];
    CCActionMoveBy *moveTopRight = [CCActionMoveBy actionWithDuration:1.f position:ccp(50, 200)];
    
    CCActionSequence *moveSequence = [CCActionSequence actionOne:moveBottomLeft two:moveTopRight];
    CCActionRepeatForever *repeatMovement = [CCActionRepeatForever actionWithAction:moveSequence];
    
    [_spriteToFollow runAction:repeatMovement];
    
    [parent2 addChild:_spriteToFollow];
    
    // setup following sprite
    _followingSprite = [CCSprite spriteWithImageNamed:@"Sprites/shape-0.png"];
    _followingSprite.position = ccp(100,100);
    [parent1 addChild:_followingSprite];
    parent1.scaleX = 0.5f;
    

    CCActionMoveToNode *moveTo = [CCActionMoveToNode actionWithSpeed:100.f targetNode:_spriteToFollow followInfinite:YES];
    [_followingSprite runAction:moveTo];
    
    CCLabelTTF *completedLabel = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:20];
    completedLabel.positionType = CCPositionTypeNormalized;
    completedLabel.position = ccp(0.5, 0.5);
    
    __block int completions = 0;
    
    moveTo.actionCompletedBlock = ^(void) {
        completions++;
        completedLabel.string = [NSString stringWithFormat:@"%d",completions];
        [self.contentNode addChild:completedLabel];
    };
    
    
    // additionally move parent 1
    CCActionMoveBy *moveDown = [CCActionMoveBy actionWithDuration:1.f position:ccp(-10, -50)];
    CCActionMoveBy *moveUp = [CCActionMoveBy actionWithDuration:1.f position:ccp(10, 50)];
    
    CCActionSequence *moveSequenceParent = [CCActionSequence actionOne:moveDown two:moveUp];
    CCActionRepeatForever *repeatMovementParent = [CCActionRepeatForever actionWithAction:moveSequenceParent];
    
    [parent1 runAction:repeatMovementParent];
}


@end
