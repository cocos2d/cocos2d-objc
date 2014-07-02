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

#define PADDLE_SCALE 0.5f
#define PADDLE_X_OFFSET 10.0f

#define BALL_HEIGHT 10.0f
#define BALL_WIDTH 10.0f

#define CEILING_HEIGHT 2.0f
#define FLOOR_HEIGHT 2.0f

#define BALL_VELOCITY 200.0f

//#define ENABLE_GLOW

typedef enum { TEST_PONG_PLAYING, TESTS_PONG_GAMEOVER } TEST_PONG_STATE;

@interface CCEffectPongTest : TestBase <CCPhysicsCollisionDelegate> @end

@implementation CCEffectPongTest {
    CCSprite* _playerPaddle;
    CCSprite* _aiPaddle;
    CCSprite* _ball;
    CGSize _designSize;
    
    CCEffectNode* _ballEffectNode;
    CCEffectGaussianBlur* _ballEffect;
    
    CCNodeColor* _ceiling;
    CCNodeColor* _floor;
    
    CCEffectNode* _pixellateEffectNode;
    CCEffectPixellate* _pixellateEffect;
    
    CCLabelTTF* _scoredLabel;
    
    TEST_PONG_STATE _gameState;
    
    int _playerScore;
    int _aiScore;
}

- (BOOL)canPaddleMoveTo:(float)y
{
    const float paddleHeight = _playerPaddle.contentSize.height * PADDLE_SCALE;
    return !((y + (paddleHeight * 0.5f) > _designSize.height - CEILING_HEIGHT) ||
            (y - (paddleHeight * 0.5f) < FLOOR_HEIGHT));
}

- (void)setupEffectPongTest
{
    self.userInteractionEnabled = YES;
    
    _gameState = TEST_PONG_PLAYING;
    
    CCPhysicsNode *physics = [CCPhysicsNode node];
    //physics.debugDraw = YES;
    [physics setCollisionDelegate:self];
	//[self.contentNode addChild:physics];
    
    _designSize = [[CCDirector sharedDirector] designSize];
    _designSize.height -= _headerBg.contentSize.height;
    
    _pixellateEffectNode = [[CCEffectNode alloc] initWithWidth:_designSize.width height:_designSize.height];
    _pixellateEffect = [[CCEffectPixellate alloc] initWithBlockSize:4.0f];

    [self setupBackgroundScene];
    
    [self setupBall];
    [physics addChild:_ballEffectNode];

    [self setupPlayerPaddle];
    [physics addChild:_playerPaddle];
    
    [self setupAIPaddle];
    [physics addChild:_aiPaddle];
    
    [self setupFloorAndCeiling];
    [physics addChild:_ceiling];
    [physics addChild:_floor];
    
    [self setupScoredLabel];
    
    [_pixellateEffectNode addChild:physics];

    [self.contentNode addChild:_pixellateEffectNode];
    
    [self schedule:@selector(sceneUpdate:) interval:1.0f/60.0f];
}

- (void)setupPlayerPaddle
{
    // Left paddle (player)
    if(_playerPaddle == nil)
    {
        _playerPaddle = [CCSprite spriteWithImageNamed:@"sample_vertical_rect.png"];
        _playerPaddle.anchorPoint = ccp(0.0, 0.5);
        _playerPaddle.scale = PADDLE_SCALE;
        
        CGRect rect = {CGPointZero, _playerPaddle.contentSize};
        _playerPaddle.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
        _playerPaddle.physicsBody.type = CCPhysicsBodyTypeStatic;
        _playerPaddle.physicsBody.collisionType = @"playerPaddle";
    }
    
    _playerPaddle.position = ccp(PADDLE_X_OFFSET, _designSize.height * 0.5f);
}

- (void)setupAIPaddle
{
    if(_aiPaddle == nil)
    {
        _aiPaddle = [CCSprite spriteWithImageNamed:@"sample_vertical_rect.png"];
        _aiPaddle.anchorPoint = ccp(0.0, 0.5);
        _aiPaddle.scale = PADDLE_SCALE;
        
        CGRect rect = {CGPointZero, _aiPaddle.contentSize};
        _aiPaddle.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
        _aiPaddle.physicsBody.type = CCPhysicsBodyTypeStatic;
        _aiPaddle.physicsBody.collisionType = @"aiPaddle";
    }
    
    _aiPaddle.position = ccp(_designSize.width - _aiPaddle.contentSize.width - PADDLE_X_OFFSET, _designSize.height * 0.5f);
}

- (void)setupBall
{
    if(_ball == nil)
    {
        _ball = [CCSprite spriteWithImageNamed:@"sphere-23.png"];
        _ball.anchorPoint = ccp(0.0, 0.0); // We shouldn't have to set this here. FIXME - Oleg
        
        CGSize size = {_ball.contentSize.width + 20, _ball.contentSize.height + 20};
        _ballEffectNode = [[CCEffectNode alloc] init];
        _ballEffectNode.contentSize = size;
        _ballEffectNode.anchorPoint = ccp(0.5, 0.5);
        
        CGRect rect = {CGPointZero, size};
        _ballEffectNode.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
        _ballEffectNode.physicsBody.collisionType = @"ball";
        
        _ballEffectNode.scale = 0.1f;
        [_ballEffectNode addChild:_ball];
        
        _ballEffect = [CCEffectGaussianBlur effectWithPixelBlurRadius:2.0];
        _ballEffectNode.effect = _ballEffect;
    }
    
    _ballEffectNode.physicsBody.velocity = ccp(-BALL_VELOCITY, 0);
    _ballEffectNode.physicsBody.angularVelocity = 0.1;
    _ballEffectNode.position = ccp(_designSize.width * 0.5f, _designSize.height * 0.5f);
}

- (void)setupFloorAndCeiling
{
    _ceiling = [CCNodeColor nodeWithColor:[CCColor lightGrayColor]];
    _ceiling.anchorPoint = ccp(0.5, 1.0);
    _ceiling.contentSize = CGSizeMake(_designSize.width, CEILING_HEIGHT);
    
    CGRect rect = {CGPointZero, _ceiling.contentSize};
    _ceiling.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
    _ceiling.physicsBody.type = CCPhysicsBodyTypeStatic;
    _ceiling.physicsBody.collisionType = @"ceiling";
    
    _ceiling.position = ccp(_designSize.width * 0.5f, _designSize.height);
    
    _floor = [CCNodeColor nodeWithColor:[CCColor lightGrayColor]];
    _floor.anchorPoint = ccp(0.5f, 0.0f);
    _floor.contentSize = CGSizeMake(_designSize.width, FLOOR_HEIGHT);
    
    rect.size = _floor.contentSize;
    _floor.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
    _floor.physicsBody.type = CCPhysicsBodyTypeStatic;
    _floor.physicsBody.collisionType = @"floor";
    
    _floor.position = ccp(_designSize.width * 0.5f, 0.0f);
}

- (void)setupBackgroundScene
{
    CCSprite* bg = [CCSprite spriteWithImageNamed:@"starynight.png"];
    bg.scale = 1.0f;
    bg.position = ccp(_designSize.width * 0.5f, _designSize.height * 0.5f);
    [_pixellateEffectNode addChild:bg];

    CCSprite* dirtPlatform = [CCSprite spriteWithImageNamed:@"planet1.png"]; // horrible asset choice, just a place holder.
    dirtPlatform.positionType = CCPositionTypeNormalized;
    dirtPlatform.position = ccp(0.3, 0.3);
    dirtPlatform.scale = 0.2f;

#ifdef ENABLE_GLOW
    CCEffectNode* glowNode = [[CCEffectNode alloc] initWithWidth:_designSize.width height:_designSize.height];
    CCEffectGlow* glow = [CCEffectGlow effectWithBlurStrength:0.002f];
    [glowNode addEffect:glow];

    [glowNode addChild:dirtPlatform];
    [_pixellateEffectNode addChild:glowNode];
#else
//    [_pixellateEffectNode addChild:dirtPlatform];
#endif
    

    

}

- (void)setupScoredLabel
{
    _scoredLabel = [CCLabelTTF labelWithString:@"Score %i/%i" fontName:@"HelveticaNeue-Medium" fontSize:17 * [CCDirector sharedDirector].UIScaleFactor];
    _scoredLabel.positionType = CCPositionTypeNormalized;
    _scoredLabel.position = ccp(0.5f,0.5f);
}

- (void)sceneUpdate:(CCTime)interval
{
    if(_gameState == TEST_PONG_PLAYING)
    {
        [self updateAI];
        [self handleOutOfBounds];
    }
}

#pragma mark game logic

- (void)updateAI
{
    if(_ballEffectNode.position.x + _ballEffectNode.contentSize.width * 0.5f > _designSize.width * 0.5f)
    {
        if([self canPaddleMoveTo:_ballEffectNode.position.y])
            _aiPaddle.position = ccp(_aiPaddle.position.x, _ballEffectNode.position.y);
    }
}

- (void)handleOutOfBounds
{
    if([self ballOutOfBounds])
    {
        _gameState = TESTS_PONG_GAMEOVER;
        
        [self updateScore];
        
        _pixellateEffectNode.effect = _pixellateEffect;
                
        [_pixellateEffectNode addChild:_scoredLabel];
        
        [self schedule:@selector(increasePixellate:) interval:1.0f/60.0f repeat:10 delay:1.0f];
        [self schedule:@selector(decreasePixellate:) interval:1.0f/60.0f repeat:10 delay:2.0f];
        [self scheduleOnce:@selector(resetGame:) delay:3.0f];
    }
}

- (void)updateScore
{
    if(_ballEffectNode.position.x > _designSize.width * 0.5f)
        _playerScore++;
    else
        _aiScore++;
    
    _scoredLabel.string = [NSString stringWithFormat:@"Score %i/%i", _playerScore, _aiScore];
}

- (void)resetGame:(CCTimer*)interval
{
    [self setupPlayerPaddle];
    [self setupAIPaddle];

    _pixellateEffectNode.effect = nil;
  
    [self setupBall];
    
    [_pixellateEffectNode removeChild:_scoredLabel];
    
    _gameState = TEST_PONG_PLAYING;
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
        if([self canPaddleMoveTo:location.y])
            _playerPaddle.position = ccp(_playerPaddle.position.x, location.y);
    }
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInNode:self];
    if(location.x < _designSize.width * 0.5f)
    {
        if([self canPaddleMoveTo:location.y])
            _playerPaddle.position = ccp(_playerPaddle.position.x, location.y);
    }
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

#pragma mark collision - Player

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair playerPaddle:(CCNode *)playerPaddle ball:(CCNode *)ball
{
    [ball.physicsBody applyImpulse:ccp(BALL_VELOCITY * 0.5f, 0.0)];
}

- (void)ccPhysicsCollisionSeparate:(CCPhysicsCollisionPair *)pair playerPaddle:(CCNode *)playerPaddle ball:(CCNode *)ball
{
    [ball.physicsBody applyImpulse:ccp(BALL_VELOCITY, 0.0)];
    
    [self schedule:@selector(increaseBallBlur:) interval:1.0f/60.0f repeat:10 delay:0.0f];
    [self schedule:@selector(decreaseBallBlur:) interval:1.0f/60.0f repeat:10 delay:0.1f];
}

#pragma mark collision - AI

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair aiPaddle:(CCNode *)aiPaddle ball:(CCNode *)ball
{
    [ball.physicsBody applyImpulse:ccp(-BALL_VELOCITY * 0.5f, 0.0)];
}

- (void)ccPhysicsCollisionSeparate:(CCPhysicsCollisionPair *)pair aiPaddle:(CCNode *)aiPaddle ball:(CCNode *)ball
{
    [ball.physicsBody applyImpulse:ccp(-BALL_VELOCITY, 0.0)];
    
    [self schedule:@selector(increaseBallBlur:) interval:1.0f/60.0f repeat:10 delay:0.0f];
    [self schedule:@selector(decreaseBallBlur:) interval:1.0f/60.0f repeat:10 delay:0.1f];
}

#pragma mark effect updates

- (void)increaseBallBlur:(CCTime)interval
{
    // TODO
//    _ballEffect.blurStrength += 0.01;
}

- (void)decreaseBallBlur:(CCTime)interval
{
    //TODO
//    _ballEffect.blurStrength -= 0.01f;
}

- (void)increasePixellate:(CCTime)interval
{
    _pixellateEffect.blockSize += 1.0f;
}

- (void)decreasePixellate:(CCTime)interval
{
    _pixellateEffect.blockSize -= 1.0f;
}

@end

#endif



