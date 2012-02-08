//
//  MainMenuScene.m
//  TomTheTurret
//
//  Created by Ray Wenderlich on 3/24/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "MainMenuScene.h"
#import "GameState.h"
#import "TomTheTurretAppDelegate.h"

@implementation MainMenuScene
@synthesize layer = _layer;

- (id)init {

    if ((self = [super init])) {
        self.layer = [[[MainMenuLayer alloc] init] autorelease];
        [self addChild:_layer];
    }
    return self;

}

@end

@implementation MainMenuLayer
@synthesize batchNode = _batchNode;
@synthesize main_bkgrnd = _main_bkgrnd;

- (id) init {

    if ((self = [super init])) {

        // Add a sprite sheet based on the loaded texture and add it to the scene
        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png"];
        [self addChild:_batchNode];

        // Add main background to scene
        CGSize winSize = [CCDirector sharedDirector].winSize;
        self.main_bkgrnd = [CCSprite spriteWithSpriteFrameName:@"Turret_main_bkgrnd.png"];
        _main_bkgrnd.position = ccp(winSize.width/2, winSize.height/2);
        [_batchNode addChild:_main_bkgrnd];

        // Add a main menu
        CCSprite *newGameSprite = [CCSprite spriteWithSpriteFrameName:@"Turret_newgame.png"];
        CCMenuItem *newGameItem = [CCMenuItemSprite itemWithNormalSprite:newGameSprite selectedSprite:nil target:self selector:@selector(newGameSpriteTapped:)];
        CCMenu *menu = [CCMenu menuWithItems:newGameItem, nil];
        [self addChild:menu];

    }

    return self;

}

- (void)newGameSpriteTapped:(id)sender {

    TomTheTurretAppDelegate *delegate = (TomTheTurretAppDelegate *) [UIApplication sharedApplication].delegate;
    [delegate launchNewGame];

}

@end
