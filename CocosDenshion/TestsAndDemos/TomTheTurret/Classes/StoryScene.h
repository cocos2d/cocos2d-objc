//
//  StoryScene.h
//  TomTheTurret
//
//  Created by Ray Wenderlich on 3/24/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "cocos2d.h"

@interface StoryLayer : CCLayer {
    CCSpriteBatchNode *_batchNode;
    CCSprite *_main_bkgrnd;
    CCLabelTTF *_label;
    CCSprite *_tapToCont;
    CCSprite *_spriteNewGame;
    int _curStoryIndex;
}

@property (nonatomic, assign) CCSpriteBatchNode *batchNode;
@property (nonatomic, assign) CCSprite *main_bkgrnd;
@property (nonatomic, assign) CCLabelTTF *label;
@property (nonatomic, assign) CCSprite *tapToCont;
@property (nonatomic, assign) CCSprite *spriteNewGame;
@property (nonatomic, assign) int curStoryIndex;

@end

@interface StoryScene : CCScene {
    StoryLayer *_layer;
}

@property (nonatomic, assign) StoryLayer *layer;

@end