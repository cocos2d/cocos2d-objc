//
//  Monster.m
//  TomTheTurret
//
//  Created by Ray Wenderlich on 3/24/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "Monster.h"
#import "TomTheTurretAppDelegate.h"

@implementation Monster

@synthesize monsterType = _monsterType;
@synthesize hp = _hp;
@synthesize maxHp = _maxHp;
@synthesize minMoveDuration = _minMoveDuration;
@synthesize maxMoveDuration = _maxMoveDuration;
@synthesize hitEffectSoundId = _hitEffectSoundId;
@synthesize hitEffectGain = _hitEffectGain;

+ (Monster *)monsterWithType:(MonsterType)monsterType {
    Monster *monster = nil;
    if (monsterType == MonsterTypeSlowAndStrong) {
        monster = [[[Monster alloc] initWithSpriteFrameName:@"Level_person2.png"] autorelease];
        monster.hp = 5;
        monster.maxHp = monster.hp;
        monster.minMoveDuration = 4;
        monster.maxMoveDuration = 7;
        monster.hitEffectSoundId = SND_ID_MALE_HIT_EFFECT;
        monster.hitEffectGain = 1.0f;
    } else if (monsterType == MonsterTypeFastAndWeak) {
        monster = [[[Monster alloc] initWithSpriteFrameName:@"Level_person1.png"] autorelease];
        monster.hp = 2;
        monster.maxHp = monster.hp;
        monster.minMoveDuration = 3;
        monster.maxMoveDuration = 6;
        monster.hitEffectSoundId = SND_ID_FEMALE_HIT_EFFECT;
        monster.hitEffectGain = 0.25f;
    } else if (monsterType == MonsterTypeBoss) {
        monster = [[[Monster alloc] initWithSpriteFrameName:@"Level_scientist.png"] autorelease];
        monster.hp = 50;
        monster.maxHp = monster.hp;
        monster.minMoveDuration = 6;
        monster.maxMoveDuration = 9;
        monster.hitEffectSoundId = SND_ID_MALE_HIT_EFFECT;
        monster.hitEffectGain = 1.0f;
    }
    return monster;
}

@end
