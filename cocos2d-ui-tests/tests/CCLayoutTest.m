//
//  CCLayoutTest.m
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 10/24/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "CCLayoutTest.h"
#import "CCLayoutBox.h"

@implementation CCLayoutTest

- (NSArray*) testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupLayoutBoxTestHorizontal",
            @"setupLayoutBoxTestVertical",
            nil];
}

- (void) setupLayoutBoxTestHorizontal
{
    self.subTitle = @"Horizontal Box Layout.";
    
    CCLayoutBox* layout = [[CCLayoutBox alloc] init];
    layout.positionType = CCPositionTypeNormalized;
    layout.position = ccp(0.5f, 0.5f);
    
    CCSprite* sprite0 = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
    CCSprite* sprite1 = [CCSprite spriteWithImageNamed:@"Sprites/grossini.png"];
    CCSprite* sprite2 = [CCSprite spriteWithImageNamed:@"Sprites/grossinis_sister.png"];
    
    [layout addChild:sprite0];
    [layout addChild:sprite1];
    [layout addChild:sprite2];
    
    layout.anchorPoint = ccp(0.5f, 0.5f);
    layout.spacing = 20;
    
    [self.contentNode addChild:layout];
}

- (void) setupLayoutBoxTestVertical
{
    self.subTitle = @"Vertical Box Layout.";
    
    CCLayoutBox* layout = [[CCLayoutBox alloc] init];
    layout.positionType = CCPositionTypeNormalized;
    layout.position = ccp(0.5f, 0.5f);
    layout.direction = CCLayoutBoxDirectionVertical;
    
    CCSprite* sprite0 = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
    CCSprite* sprite1 = [CCSprite spriteWithImageNamed:@"Sprites/grossini.png"];
    CCSprite* sprite2 = [CCSprite spriteWithImageNamed:@"Sprites/grossinis_sister.png"];
    
    [layout addChild:sprite0];
    [layout addChild:sprite1];
    [layout addChild:sprite2];
    
    layout.anchorPoint = ccp(0.5f, 0.5f);
    layout.spacing = 20;
    
    [self.contentNode addChild:layout];
}

@end
