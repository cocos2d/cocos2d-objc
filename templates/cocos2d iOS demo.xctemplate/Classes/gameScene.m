//
//  ___FILENAME___
//
//  Created by : ___FULLUSERNAME___
//  Project    : ___PROJECTNAME___
//  Date       : ___DATE___
//
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___.
//  All rights reserved.
//
// -----------------------------------------------------------------

#import "GameScene.h"
#import "cocos2d-ui.h"

// -----------------------------------------------------------------
// some game constants

const float kGamePaddleInset = 90;





// -----------------------------------------------------------------

@implementation GameScene
{
    CCSprite *_paddleA;
    CCSprite *_paddleB;
    CCSprite *_ball;
    CGSize _gameSize;
}

// -----------------------------------------------------------------

- (instancetype)init
{
    self = [super init];
    
    _gameSize = [CCDirector sharedDirector].viewSize;
    
    // create paddles
    _paddleA = [CCSprite spriteWithImageNamed:@"paddle.png"];
    _paddleA.position = (CGPoint){kGamePaddleInset, _gameSize.height * 0.5};
    [self addChild:_paddleA];
    
    _paddleB = [CCSprite spriteWithImageNamed:@"paddle.png"];
    _paddleB.position = (CGPoint){_gameSize.width - kGamePaddleInset, _gameSize.height * 0.5};
    [self addChild:_paddleB];
    
    CCButton *back = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"back.png"]];
    back.positionType = CCPositionTypeNormalized;
    back.position = (CGPoint){0.5,0.1};
    [back setBlock:^(id sender)
    {
        [[CCDirector sharedDirector] popSceneWithTransition:[CCTransition transitionRevealWithDirection:CCTransitionDirectionUp
                                                                                               duration:0.5]];
    }];
    [self addChild:back];
    
    
    
    
    return self;
}

// -----------------------------------------------------------------

@end





