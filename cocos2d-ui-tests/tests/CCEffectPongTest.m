//
//  CCEffectPongTest.m
//  cocos2d-tests-ios
//
//  Created by Oleg Osin on 5/16/14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import "TestBase.h"
#import "CCTextureCache.h"
#import "CCNodeColor.h"
#import "CCEffectNode.h"
#import "CCEffectGaussianBlur.h"

#if CC_ENABLE_EXPERIMENTAL_EFFECTS

#define PADDLE_HEIGHT 100.0f
#define PADDLE_WIDTH 20.0f
#define PADDLE_X_OFFSET 10.0f

#define BALL_HEIGHT 10.0f
#define BALL_WIDTH 10.0f

#define CEILING_HEIGHT 5.0f
#define FLOOR_HEIGHT 5.0f


@interface CCEffectPongTest : TestBase @end

@implementation CCEffectPongTest {
    CCNodeColor* _playerPaddle;
    CCNodeColor* _aiPaddle;
    CCSprite* _ball;
    CGSize _designSize;
    
    CCEffectNode* _ballEffectNode;
    CCEffectGaussianBlur* _ballEffect;
    
    CCNodeColor* _ceiling;
    CCNodeColor* _floor;
}

- (float)centerPaddleY:(float)y
{
    float centerY = y - PADDLE_HEIGHT * 0.5f;
    return centerY;
}

- (void)setupEffectPongTest
{
    self.userInteractionEnabled = YES;
    
    CCPhysicsNode *physics = [CCPhysicsNode node];
    //	physics.debugDraw = YES;
    //[physics setCollisionDelegate:self];
	[self.contentNode addChild:physics];
    
    _designSize = [[CCDirector sharedDirector] designSize];
    
    [self setupPlayerPaddle];
    [physics addChild:_playerPaddle];
    
    [self setupAIPaddle];
    [physics addChild:_aiPaddle];
    
    [self setupBall];
    [physics addChild:_ballEffectNode];
    
    [self setupFloorAndCeiling];
    [physics addChild:_ceiling];
    [physics addChild:_floor];
    
    [self schedule:@selector(sceneUpdate:) interval:1.0f/60.0f];
}

- (void)setupPlayerPaddle
{
    // Left paddle (player)
    if(_playerPaddle == nil)
    {
        _playerPaddle = [CCNodeColor nodeWithColor:[CCColor redColor]];
        _playerPaddle.anchorPoint = ccp(0.0, 0.0);
        _playerPaddle.contentSize = CGSizeMake(PADDLE_WIDTH, PADDLE_HEIGHT);
        
        CGRect rect = {CGPointZero, _playerPaddle.contentSize};
        _playerPaddle.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
        _playerPaddle.physicsBody.type = CCPhysicsBodyTypeStatic;
        _playerPaddle.physicsBody.collisionType = @"playerPaddle";
    }
    
    _playerPaddle.position = ccp(PADDLE_X_OFFSET, [self centerPaddleY:_designSize.height * 0.5f]);
}

- (void)setupAIPaddle
{
    if(_aiPaddle == nil)
    {
        _aiPaddle = [CCNodeColor nodeWithColor:[CCColor redColor]];
        _aiPaddle.anchorPoint = ccp(0.0, 0.0);
        _aiPaddle.contentSize = CGSizeMake(PADDLE_WIDTH, PADDLE_HEIGHT);
        
        CGRect rect = {CGPointZero, _aiPaddle.contentSize};
        _aiPaddle.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
        _aiPaddle.physicsBody.type = CCPhysicsBodyTypeStatic;
        _aiPaddle.physicsBody.collisionType = @"aiPaddle";
    }
    
    _aiPaddle.position = ccp(_designSize.width - PADDLE_WIDTH - PADDLE_X_OFFSET, [self centerPaddleY:_designSize.height * 0.5f]);
}

- (void)setupBall
{
    if(_ball == nil)
    {
        _ball = [CCSprite spriteWithImageNamed:@"sphere-23.png"];
        _ball.anchorPoint = ccp(0.0, 0.0); // WTF!?
        
        CGSize size = {_ball.contentSize.width + 10, _ball.contentSize.height + 10};
        _ballEffectNode = [[CCEffectNode alloc] init];
        _ballEffectNode.contentSize = size;
        _ballEffectNode.anchorPoint = ccp(0.5, 0.5);
        
        CGRect rect = {CGPointZero, size};
        _ballEffectNode.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
        _ballEffectNode.physicsBody.collisionType = @"ball";
        _ballEffectNode.scale = 0.3f;
        [_ballEffectNode addChild:_ball];
        
        _ballEffect = [CCEffectGaussianBlur effectWithBlurStrength:0.02f direction:GLKVector2Make(0.0, 0.0)];
        [_ballEffectNode addEffect:_ballEffect];
    }
    
    _ballEffectNode.physicsBody.velocity = ccp(-160, 0);
    _ballEffectNode.physicsBody.angularVelocity = 0.1;
    _ballEffectNode.position = ccp(_designSize.width * 0.5f, _designSize.height * 0.5f);
}

- (void)setupFloorAndCeiling
{
    _ceiling = [CCNodeColor nodeWithColor:[CCColor greenColor]];
    _ceiling.anchorPoint = ccp(0.0, 1.0);
    _ceiling.contentSize = CGSizeMake(_designSize.width, CEILING_HEIGHT);
    
    CGRect rect = {CGPointZero, _ceiling.contentSize};
    _ceiling.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
    _ceiling.physicsBody.type = CCPhysicsBodyTypeStatic;
    _ceiling.physicsBody.collisionType = @"ceiling";
    
    _ceiling.position = ccp(0.0, _designSize.height);
    
    _floor = [CCNodeColor nodeWithColor:[CCColor greenColor]];
    _floor.anchorPoint = ccp(0.0, 0.0);
    _floor.contentSize = CGSizeMake(_designSize.width, FLOOR_HEIGHT);
    
    rect.size = _floor.contentSize;
    _floor.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
    _floor.physicsBody.type = CCPhysicsBodyTypeStatic;
    _floor.physicsBody.collisionType = @"floor";
    
    _floor.position = ccp(0.0, 0.0);
}

- (void)sceneUpdate:(CCTime)interval
{
    [self updateAI];
    [self handleOutOfBounds];
}

#pragma mark game logic

- (void)updateAI
{
    if(_ballEffectNode.position.x + _ballEffectNode.contentSize.width * 0.5f > _designSize.width * 0.5f)
    {
        _aiPaddle.position = ccp(_aiPaddle.position.x, [self centerPaddleY:_ballEffectNode.position.y]);
    }
}

- (void)handleOutOfBounds
{
    if([self ballOutOfBounds])
    {
        [self setupPlayerPaddle];
        [self setupAIPaddle];
        [self setupBall];
    }
}

- (BOOL)ballOutOfBounds
{
    CGRect box = {CGPointZero, _designSize};
    CGPoint loc = _ballEffectNode.position;
    return !CGRectContainsPoint(box, loc);
}

#pragma mark touch

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInNode:self];
    if(location.x < _designSize.width * 0.5f)
    {
        _playerPaddle.position = ccp(_playerPaddle.position.x, [self centerPaddleY:location.y]);
    }
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInNode:self];
    if(location.x < _designSize.width * 0.5f)
    {
        _playerPaddle.position = ccp(_playerPaddle.position.x, [self centerPaddleY:location.y]);
    }
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

#pragma mark collision - Player

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair playerPaddle:(CCNode *)playerPaddle ball:(CCNode *)ball
{
    [ball.physicsBody applyImpulse:ccp(10, 0.0)];
}

- (void)ccPhysicsCollisionSeparate:(CCPhysicsCollisionPair *)pair playerPaddle:(CCNode *)playerPaddle ball:(CCNode *)ball
{
    [ball.physicsBody applyImpulse:ccp(100, 0.0)];
    _ballEffect.blurStrength = 0.05f;
}

#pragma mark collision - AI

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair aiPaddle:(CCNode *)aiPaddle ball:(CCNode *)ball
{
    [ball.physicsBody applyImpulse:ccp(-10, 0.0)];
}

- (void)ccPhysicsCollisionSeparate:(CCPhysicsCollisionPair *)pair aiPaddle:(CCNode *)aiPaddle ball:(CCNode *)ball
{
    [ball.physicsBody applyImpulse:ccp(-100, 0.0)];
}

@end

#endif



