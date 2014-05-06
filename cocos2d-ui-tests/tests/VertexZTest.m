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
#import "CCSprite_Private.h"

@interface GlobalSortSprite : CCSprite @end

@implementation GlobalSortSprite {
	NSInteger _globalSortOrder;
}

-(void)setVertexZ:(float)vertexZ
{
	// Intercept the vertexZ value and use it for global sort order instead.
	_globalSortOrder = vertexZ;
}

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
	const CCSpriteVertexes *verts = self.vertexes;
	
	CCRenderBuffer buffer = [renderer enqueueTriangles:2 andVertexes:4 withState:self.renderState globalSortOrder:_globalSortOrder];
	CCRenderBufferSetVertex(buffer, 0, CCVertexApplyTransform(verts->bl, transform));
	CCRenderBufferSetVertex(buffer, 1, CCVertexApplyTransform(verts->br, transform));
	CCRenderBufferSetVertex(buffer, 2, CCVertexApplyTransform(verts->tr, transform));
	CCRenderBufferSetVertex(buffer, 3, CCVertexApplyTransform(verts->tl, transform));
	
	CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
	CCRenderBufferSetTriangle(buffer, 1, 0, 2, 3);
}

@end

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

- (NSString *)randomCard
{
    return([NSString stringWithFormat:@"%@.%d.png", CARD_NAME[arc4random() % 4], 1 + (arc4random() % 13)]);
}

- (void)setupVertexZTest
{
    self.subTitle = @"Tests vertexZ (hardware Z) for batch nodes";
		
		[self addButtons];

    // Load card images
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Cards/cards.classic.plist"];

    // add a card node to hold the cards
    _cardNode = [CCNode node];
    _cardNode.contentSize = [CCDirector sharedDirector].viewSize;
		
    [self.contentNode addChild:_cardNode];
    
    // add an array of cards
    for (int count = 0; count < NUMBER_OF_CARDS; count ++)
    {
        CCSprite *card = [CCSprite spriteWithImageNamed:[self randomCard]];
				
        card.positionType = CCPositionTypeNormalized;
        card.position = ccp(0.5 + (count - NUMBER_OF_CARDS / 2) * 0.02, 0.5 + (count - NUMBER_OF_CARDS / 2) * 0.01);
        [_cardNode addChild:card];
				
		    card.shader = [CCShader positionTextureColorAlphaTestShader];
		    card.blendMode = [CCBlendMode disabledMode];
    }
}

- (void)setupGlobalSortTest
{
    self.subTitle = @"Tests global sorting order.";
		
		[self addButtons];

    // Load card images
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Cards/cards.classic.plist"];

    // add a card node to hold the cards
    _cardNode = [CCNode node];
    _cardNode.contentSize = [CCDirector sharedDirector].viewSize;
		
    [self.contentNode addChild:_cardNode];
    
    // add an array of cards
    for (int count = 0; count < NUMBER_OF_CARDS; count ++)
    {
        CCSprite *card = [GlobalSortSprite spriteWithImageNamed:[self randomCard]];
				
        card.positionType = CCPositionTypeNormalized;
        card.position = ccp(0.5 + (count - NUMBER_OF_CARDS / 2) * 0.02, 0.5 + (count - NUMBER_OF_CARDS / 2) * 0.01);
        [_cardNode addChild:card];
    }
}

// -----------------------------------------------------------------

- (void)addButtons
{
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
}

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

