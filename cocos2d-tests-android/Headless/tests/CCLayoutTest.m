//
//  CCLayoutTest.m
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 10/24/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "TestBase.h"
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "CCLayoutBox.h"

@interface CCLayoutTest : TestBase @end

@implementation CCLayoutTest
{
    CCLayoutBox *_layout;
}

- (NSArray*) testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupLayoutBoxTestHorizontal",
            @"setupLayoutBoxTestVertical",
            @"setupLayoutBoxTestDynamical",
            nil];
}

- (void) setupLayoutBoxTestHorizontal
{
    self.subTitle = @"Horizontal Box Layout.";
    
    _layout = [[CCLayoutBox alloc] init];
    _layout.positionType = CCPositionTypeNormalized;
    _layout.position = ccp(0.5f, 0.5f);
    
    CCSprite* sprite0 = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
    CCSprite* sprite1 = [CCSprite spriteWithImageNamed:@"Sprites/grossini.png"];
    CCSprite* sprite2 = [CCSprite spriteWithImageNamed:@"Sprites/grossinis_sister.png"];
    
    [_layout addChild:sprite0];
    [_layout addChild:sprite1];
    [_layout addChild:sprite2];
    
    _layout.anchorPoint = ccp(0.5f, 0.5f);
    _layout.spacing = 20;
    
    [self.contentNode addChild:_layout];
}

- (void) setupLayoutBoxTestVertical
{
    self.subTitle = @"Vertical Box Layout.";
    
    _layout = [[CCLayoutBox alloc] init];
    _layout.positionType = CCPositionTypeNormalized;
    _layout.position = ccp(0.5f, 0.5f);
    _layout.direction = CCLayoutBoxDirectionVertical;
    
    CCSprite* sprite0 = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
    CCSprite* sprite1 = [CCSprite spriteWithImageNamed:@"Sprites/grossini.png"];
    CCSprite* sprite2 = [CCSprite spriteWithImageNamed:@"Sprites/grossinis_sister.png"];
    
    [_layout addChild:sprite0];
    [_layout addChild:sprite1];
    [_layout addChild:sprite2];
    
    _layout.anchorPoint = ccp(0.5f, 0.5f);
    _layout.spacing = 20;
    
    [self.contentNode addChild:_layout];
}

- (void) setupLayoutBoxTestDynamical
{
    self.subTitle = @"Dynamic Box Layout.";
    
    _layout = [[CCLayoutBox alloc] init];
    _layout.positionType = CCPositionTypeNormalized;
    _layout.position = ccp(0.5f, 0.5f);
    _layout.direction = CCLayoutBoxDirectionVertical;
    
    CCSprite* sprite0 = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
    CCSprite* sprite1 = [CCSprite spriteWithImageNamed:@"Sprites/grossini.png"];
    CCButton* sprite2 = [CCButton buttonWithTitle:@"Button" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Sprites/grossinis_sister.png"]];
    
    [_layout addChild:sprite0];
    [_layout addChild:sprite1];
    [_layout addChild:sprite2];
    
    _layout.anchorPoint = ccp(0.5f, 0.5f);
    _layout.spacing = 20;
    
    CCButton *changeButton = [CCButton buttonWithTitle:@"[Change]"];
    changeButton.positionType = CCPositionTypeNormalized;
    changeButton.position = ccp(0.9, 0.9);
    [changeButton setTarget:self selector:@selector(changedPressed:)];
    [self.contentNode addChild:changeButton];
    
    CCButton *fadeButton = [CCButton buttonWithTitle:@"[Fade]"];
    fadeButton.positionType = CCPositionTypeNormalized;
    fadeButton.position = ccp(0.9, 0.7);
    [fadeButton setTarget:self selector:@selector(fadePressed)];
    [self.contentNode addChild:fadeButton];
    
    [self.contentNode addChild:_layout];
}

- (void)changedPressed:(id)sender
{
    _layout.direction = (_layout.direction == CCLayoutBoxDirectionHorizontal) ? CCLayoutBoxDirectionVertical : CCLayoutBoxDirectionHorizontal;
    _layout.spacing = (_layout.spacing == 20) ? 60 : 20;
    
    CCLOG(@"Layout contentSize %.0fx%.0f", _layout.contentSize.width, _layout.contentSize.height);
}

- (void)fadePressed
{
    _layout.cascadeOpacityEnabled = YES;
    [_layout runAction:[CCActionSequence actions:[CCActionFadeOut actionWithDuration:1], [CCActionFadeIn actionWithDuration:1], nil]];
}

@end
