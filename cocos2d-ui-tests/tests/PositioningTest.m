//
//  PositioningTest.m
//  cocos2d-tests-ios
//
//  Created by Lars Birkemose on 06/02/14.
//  Copyright 2014 Cocos2d. All rights reserved.
//

#import "TestBase.h"

// -----------------------------------------------------------------

#define NUMBER_OF_CARDS 10

extern const NSString *CARD_NAME[];
/*
=
{
    @"hearts", @"diamonds", @"spades", @"clubs"
};
*/

// -----------------------------------------------------------------
// PositioningSprite implementation
// -----------------------------------------------------------------

@interface PositioningSprite : CCSprite

@end

// -----------------------------------------------------------------

@implementation PositioningSprite

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{

}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pos = [self.parent convertToNodeSpace:touch.locationInWorld];
    self.position = pos;
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{

}

@end

// -----------------------------------------------------------------
// PositioningTest implementation
// -----------------------------------------------------------------

@interface PositioningTest : TestBase

@end

// -----------------------------------------------------------------

@implementation PositioningTest

- (NSArray *)testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupPositioningTest",
            nil];
}

- (NSString *)randomCard
{
    return([NSString stringWithFormat:@"%@.%d.png", CARD_NAME[arc4random() % 4], 1 + (arc4random() % 13)]);
}

- (void)setupPositioningTest
{
    PositioningSprite *card;

    self.subTitle = @"Move cards around";
    
    // Load card images
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Cards/cards.classic.plist"];

    // add cards with normalized positioning
    for (int count = 0; count < NUMBER_OF_CARDS; count ++)
    {
        card = [PositioningSprite spriteWithImageNamed:[self randomCard]];
        card.positionType = CCPositionTypeNormalized;
        card.position = ccp(0.1 + CCRANDOM_0_1() * 0.8, 0.1 + CCRANDOM_0_1() * 0.8);
        card.userInteractionEnabled = YES;
        [self.contentNode addChild:card];
    }

    // add cards with absolute positioning
    for (int count = 0; count < NUMBER_OF_CARDS; count ++)
    {
        card = [PositioningSprite spriteWithImageNamed:[self randomCard]];
        card.position = ccp(
                            (0.1 + CCRANDOM_0_1() * 0.8) * [CCDirector sharedDirector].viewSize.width,
                            (0.1 + CCRANDOM_0_1() * 0.8) * [CCDirector sharedDirector].viewSize.height);
        card.userInteractionEnabled = YES;
        [self.contentNode addChild:card];
    }
    



}

@end

// -----------------------------------------------------------------
