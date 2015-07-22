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

#import "Paddle.h"

// -----------------------------------------------------------------

@implementation GameScene
{
    Paddle *_paddleA;
    Paddle *_paddleB;
    CCSprite *_ball;
    CGSize _gameSize;
    CGPoint _ballVector;
}

// -----------------------------------------------------------------

- (instancetype)init
{
    self = [super init];
    
    _gameSize = [CCDirector sharedDirector].viewSize;
    
    // create paddles
    _paddleA = [Paddle paddleWithSide:PaddleSideLeft];
    [self addChild:_paddleA];
    
    _paddleB = [Paddle paddleWithSide:PaddleSideRight];
    [self addChild:_paddleB];
    
    _ball = [CCSprite spriteWithImageNamed:@"ball.png"];
    [self addChild:_ball];
    
    // create a way out of this ...
    CCButton *back = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"back.png"]];
    back.positionType = CCPositionTypeNormalized;
    back.position = (CGPoint){0.5,0.1};
    [back setBlock:^(id sender)
    {
        [[CCDirector sharedDirector] popSceneWithTransition:[CCTransition transitionRevealWithDirection:CCTransitionDirectionUp
                                                                                               duration:0.5]];
    }];
    [self addChild:back];
    
    // draw touch area markers
    CCDrawNode *drawNode = [CCDrawNode node];
    [drawNode drawSegmentFrom:(CGPoint){kGamePaddleTouchArea, 0}
                           to:(CGPoint){kGamePaddleTouchArea, _gameSize.height}
                       radius:1.0
                        color:[CCColor orangeColor]];
    [drawNode drawSegmentFrom:(CGPoint){_gameSize.width - kGamePaddleTouchArea, 0}
                           to:(CGPoint){_gameSize.width - kGamePaddleTouchArea, _gameSize.height}
                       radius:1.0
                        color:[CCColor orangeColor]];
    [self addChild:drawNode];
    
    // enable touch
    self.userInteractionEnabled = YES;
    
    // enable multi touch
    self.multipleTouchEnabled = YES;

    [self serveFromSide:PaddleSideInvalid];
    
    return self;
}

// -----------------------------------------------------------------

- (void)gameTilt
{
    // for now just show a game tilt label
    CCLabelTTF *gameTiltLabel = [CCLabelTTF labelWithString:@"Game Tilt" fontName:@"ArialMT" fontSize:48];
    gameTiltLabel.fontColor = [CCColor orangeColor];
    gameTiltLabel.positionType = CCPositionTypeNormalized;
    gameTiltLabel.position = (CGPoint){0.5, 0.5};
    [self addChild:gameTiltLabel];
    [gameTiltLabel runAction:
     [CCActionSequence actions:
      [CCActionFadeOut actionWithDuration:1.0],
      [CCActionRemove action],
      nil]];
}

// -----------------------------------------------------------------
#pragma mark - Touch Handling

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // find out what paddle is being touched
    Paddle *paddle = nil;
    if ([_paddleA validPosition:touch.locationInWorld]) paddle = _paddleA;
    else if ([_paddleB validPosition:touch.locationInWorld]) paddle = _paddleB;
    
    // if the touch is not for a paddle, just pass the touch on, and exit
    if (paddle == nil)
    {
        [super touchBegan:touch withEvent:event];
        return;
    }
    
    // if paddle area is already being touched, there are too many fingers in play
    if (paddle.touch != nil)
    {
        [self gameTilt];
        [super touchBegan:touch withEvent:event];
        return;
    }
    
    // so, the touch in the paddle area is valid
    paddle.touch = touch.uiTouch;
    paddle.destination = touch.locationInWorld.y;
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    Paddle *paddle;
    
    // find out where the touch belogs
    if (touch.uiTouch == _paddleA.touch)
    {
        paddle = _paddleA;
    }
    else if (touch.uiTouch == _paddleB.touch)
    {
        paddle = _paddleB;
    }
    
    // check for valid position
    if ([paddle validPosition:touch.locationInWorld])
    {
        paddle.destination = touch.locationInWorld.y;
    }
    else
    {
        // cancel paddle touch (user will have to lift inside touch area)
        paddle.touch = nil;
    }

}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    if (touch.uiTouch == _paddleA.touch)
    {
        _paddleA.touch = nil;
    }
    else if (touch.uiTouch == _paddleB.touch)
    {
        _paddleB.touch = nil;
    }
}

// -----------------------------------------------------------------
#pragma mark - Game Update Loop











// -----------------------------------------------------------------
#pragma mark - Game Mechanics

- (void)serveFromSide:(PaddleSide)side
{
    // if invalid side, serve random
    if (side == PaddleSideInvalid) side = (CCRANDOM_0_1() > 0.5) ? PaddleSideLeft : PaddleSideRight;
    
    if (side == PaddleSideLeft)
    {
        _ball.position = (CGPoint){_paddleA.position.x + ((_paddleA.contentSize.width + _ball.contentSize.width) * 0.5), _paddleA.position.y};
        _ballVector = (CGPoint){kGameBallSpeed, 0};
    }
    else
    {
        _ball.position = (CGPoint){_paddleB.position.x - ((_paddleB.contentSize.width + _ball.contentSize.width) * 0.5), _paddleB.position.y};
        _ballVector = (CGPoint){-kGameBallSpeed, 0};
    }
}

// -----------------------------------------------------------------









// -----------------------------------------------------------------

@end





