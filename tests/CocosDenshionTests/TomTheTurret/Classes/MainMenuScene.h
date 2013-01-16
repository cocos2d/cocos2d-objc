//
//  MainMenuScene.h
//  TomTheTurret
//
//  Created by Ray Wenderlich on 3/24/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "cocos2d.h"

@interface MainMenuLayer : CCLayer {
    CCSpriteBatchNode *_batchNode;
    CCSprite *_main_bkgrnd;
}

@property (nonatomic, assign) CCSpriteBatchNode *batchNode;
@property (nonatomic, assign) CCSprite *main_bkgrnd;

@end


@interface MainMenuScene : CCScene {
    MainMenuLayer *_layer;
}

@property (nonatomic, assign) MainMenuLayer *layer;

@end
