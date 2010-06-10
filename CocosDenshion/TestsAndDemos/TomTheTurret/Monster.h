//
//  Monster.h
//  TomTheTurret
//
//  Created by Ray Wenderlich on 3/24/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "cocos2d.h"

typedef enum {
    MonsterTypeSlowAndStrong,
    MonsterTypeFastAndWeak,
    MonsterTypeBoss
} MonsterType;

@interface Monster : CCSprite {
    MonsterType _monsterType;
    int _hp;
    int _maxHp;
    int _minMoveDuration;
    int _maxMoveDuration;
    int _hitEffectSoundId;
    float _hitEffectGain;
}

@property (nonatomic, assign) MonsterType monsterType;
@property (nonatomic, assign) int hp;
@property (nonatomic, assign) int maxHp;
@property (nonatomic, assign) int minMoveDuration;
@property (nonatomic, assign) int maxMoveDuration;
@property (nonatomic, assign) int hitEffectSoundId;
@property (nonatomic, assign) float hitEffectGain;

+ (Monster *)monsterWithType:(MonsterType)monsterType;

@end
