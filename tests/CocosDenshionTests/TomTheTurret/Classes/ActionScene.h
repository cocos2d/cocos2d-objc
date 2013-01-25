//
//  ActionScene.h
//  TomTheTurret
//
//  Created by Ray Wenderlich on 3/24/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "cocos2d.h"

@interface ActionLayer : CCLayer {
    CCSpriteBatchNode *_batchNode;
    CCSprite *_level_bkgrnd;
    CCSprite *_player;
    NSMutableArray *_monsters;
    NSMutableArray *_projectiles;
    CCSprite *_nextProjectile;
    BOOL _monsterHit;
    double _levelBegin;
    double _lastTimeMonsterAdded;
    BOOL _inLevel;
}

@property (nonatomic, assign) CCSpriteBatchNode *batchNode;
@property (nonatomic, assign) CCSprite *level_bkgrnd;
@property (nonatomic, assign) CCSprite *player;
@property (nonatomic, retain) NSMutableArray *monsters;
@property (nonatomic, retain) NSMutableArray *projectiles;
@property (nonatomic, retain) CCSprite *nextProjectile;
@property (nonatomic, assign) BOOL monsterHit;
@property (nonatomic, assign) double levelBegin;
@property (nonatomic, assign) double lastTimeMonsterAdded;
@property (nonatomic, assign) BOOL inLevel;

@end

@interface ActionScene : CCScene {
    ActionLayer *_layer;
}

@property (nonatomic, assign) ActionLayer *layer;

@end
