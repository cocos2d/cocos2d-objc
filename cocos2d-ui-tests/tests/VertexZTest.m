//
//  VertexZTest.m
//  cocos2d-tests-ios
//
//  Created by Lars Birkemose on 30/01/14.
//  Copyright 2014 Cocos2d. All rights reserved.
//

#import "TestBase.h"
#import "CCTextureCache.h"
#import "CCNode_Private.h"

// -----------------------------------------------------------------

@interface VertexZTest : TestBase

@end

// -----------------------------------------------------------------

#define NUMBER_OF_CARDS 10

const NSString *CARD_NAME[] =
{
    @"hearts", @"diamonds", @"spades", @"clubs"
};

// -----------------------------------------------------------------

@implementation VertexZTest
{
    CCNode *_cardNode;
}

// -----------------------------------------------------------------

- (NSArray *)testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupVertexZTest",
            nil];
}

// -----------------------------------------------------------------

- (NSString *)randomCard
{
    return([NSString stringWithFormat:@"%@.%d.png", CARD_NAME[arc4random() % 4], 1 + (arc4random() % 13)]);
}

- (void)setupVertexZTest
{
    self.subTitle = @"Tests vertexZ (hardware Z) for batch nodes";

    // Load card images
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Cards/cards.classic.plist"];

    // add a shuffle button
    CCButton *shuffleButton = [CCButton buttonWithTitle:@"[shuffle]"];
    shuffleButton.positionType = CCPositionTypeNormalized;
    shuffleButton.position = ccp(0.5, 0.3);
    [shuffleButton setTarget:self selector:@selector(shufflePressed:)];
    [self.contentNode addChild:shuffleButton];

    // add a reset button
    CCButton *resetButton = [CCButton buttonWithTitle:@"[reset]"];
    resetButton.positionType = CCPositionTypeNormalized;
    resetButton.position = ccp(0.5, 0.25);
    [resetButton setTarget:self selector:@selector(resetPressed:)];
    [self.contentNode addChild:resetButton];
    
    
    // add a card node to hold the cards
    _cardNode = [CCSpriteBatchNode batchNodeWithFile:@"Cards/cards.classic.png"];
    _cardNode.contentSize = [CCDirector sharedDirector].viewSize;
		
		_cardNode.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColorAlphaTest];
		GLint location = [_cardNode.shaderProgram uniformLocationForName:@(kCCUniformAlphaTestValue_s)];
		[_cardNode.shaderProgram setUniformLocation:location withF1:0.5];
		
    [self.contentNode addChild:_cardNode];
    
    // add an array of cards
    for (int count = 0; count < NUMBER_OF_CARDS; count ++)
    {
        CCSprite *card = [CCSprite spriteWithImageNamed:[self randomCard]];
				
        card.positionType = CCPositionTypeNormalized;
        card.position = ccp(0.5 + (count - NUMBER_OF_CARDS / 2) * 0.02, 0.5 + (count - NUMBER_OF_CARDS / 2) * 0.01);
        [_cardNode addChild:card];
    }
}

// -----------------------------------------------------------------

- (void)shufflePressed:(id)sender
{
    for (CCNode *node in _cardNode.children) node.vertexZ = arc4random() % 100;
}

- (void)resetPressed:(id)sender
{
    for (CCNode *node in _cardNode.children) node.vertexZ = 0;
}

// -----------------------------------------------------------------


@end

