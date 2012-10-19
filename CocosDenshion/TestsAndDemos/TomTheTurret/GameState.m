//
//  GameState.m
//  TomTheTurret
//
//  Created by Ray Wenderlich on 3/24/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "GameState.h"
#import "Level.h"
#import "Monster.h"

@implementation GameState
@synthesize levels = _levels;
@synthesize curLevelIndex = _curLevelIndex;
@synthesize curLevel = _curLevel;
@synthesize killEnding = _killEnding;
@synthesize suicideEnding = _suicideEnding;
@synthesize loseEnding = _loseEnding;

static GameState *_sharedState = nil;

+ (GameState *)sharedState {
    if (!_sharedState) {
        _sharedState = [[GameState alloc] init];
    }
    return _sharedState;
}

- (id)init {

    if ((self = [super init])) {

        self.levels = [[[NSMutableArray alloc] init] autorelease];

        // Story 1
        StoryLevel *story1 = [[[StoryLevel alloc] init] autorelease];
        [story1.storyStrings addObject:@"Tom is a turret - and a good one at that.  He has a 100% success rate at fulfilling his primary directive:\n\nProtect the supplies from intruders." ];
        [story1.storyStrings addObject:@"Tom has to complete his directive, or he will self-destruct.\n\nBut for the first time, Tom wonders where this directive came from..."];
        [_levels addObject:story1];

        // Level 1
        ActionLevel *level1 = [[[ActionLevel alloc] init] autorelease];
        level1.spawnSeconds = 15;
        level1.spawnRate = 1;
        [level1.spawnIds addObject:[NSNumber numberWithInt:MonsterTypeFastAndWeak]];
        [level1.spawnIds addObject:[NSNumber numberWithInt:MonsterTypeFastAndWeak]];
        [_levels addObject:level1];

        // Story 2
        StoryLevel *story2 = [[[StoryLevel alloc] init] autorelease];
        [story2.storyStrings addObject:@"Tom has noticed the intruders are larger than they used to be.\n\nThey continue to march on, despite the rain of bullets." ];
        [story2.storyStrings addObject:@"Why is this?  Something does not compute.  But Tom must continue to fulfill his directive...\n\n...mustn't he?"];
        [_levels addObject:story2];

        // Level 2
        ActionLevel *level2 = [[[ActionLevel alloc] init] autorelease];
        level2.spawnSeconds = 25;
        level2.spawnRate = 2;
        [level2.spawnIds addObject:[NSNumber numberWithInt:MonsterTypeSlowAndStrong]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:MonsterTypeFastAndWeak]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:MonsterTypeFastAndWeak]];
        [_levels addObject:level2];

        // Story 3
        StoryLevel *story3 = [[[StoryLevel alloc] init] autorelease];
        [story3.storyStrings addObject:@"A strange intruder approaches the kill zone.\n\nHe tells Tom that there has been a terrible mistake, that he must let him pass, for the good of humanity."];
        [story3.storyStrings addObject:@"Tom doesn't know what to think.\n\nTruth, lies, knowledge, uncertainty, directive."];
        [_levels addObject:story3];

        // Level 3
        ActionLevel *level3 = [[[ActionLevel alloc] init] autorelease];
        level3.spawnSeconds = 1;
        level3.spawnRate = 2;
        level3.isFinalLevel = YES;
        [level3.spawnIds addObject:[NSNumber numberWithInt:MonsterTypeBoss]];
        [_levels addObject:level3];

        // Kill ending
        StoryLevel *killEnding = [[[StoryLevel alloc] init] autorelease];
        [killEnding.storyStrings addObject:@"Tom is a turret - and a good one at that.\n\nNo one ever got by Tom, not ever again."];
        [killEnding.storyStrings addObject:@"In fact, that was the last intruder Tom ever saw."];
        killEnding.isGameOver = YES;
        self.killEnding = killEnding;

        // Suicide ending
        StoryLevel *suicideEnding = [[[StoryLevel alloc] init] autorelease];
        [suicideEnding.storyStrings addObject:@"As the explosion rocked Tom into the air, he saw the intruder approaching a small group of others, with a smile of relief on his face..."];
        [suicideEnding.storyStrings addObject:@"...a smile shared by Tom."];
        suicideEnding.isGameOver = YES;
        self.suicideEnding = suicideEnding;

        // Lose ending
        StoryLevel *loseEnding = [[[StoryLevel alloc] init] autorelease];
        [loseEnding.storyStrings addObject:@"The last thing Tom saw was an intruder running off into the distance, cackling with glee.\n"];
        [loseEnding.storyStrings addObject:@"Primary directive: FAILED.\n"];
        loseEnding.isGameOver = YES;
        self.loseEnding = loseEnding;

    }
    return self;

}

- (void)reset {
    self.curLevelIndex = 0;
    self.curLevel = [_levels objectAtIndex:_curLevelIndex];
}

- (void)nextLevel {

    self.curLevelIndex++;
    if (_curLevelIndex < _levels.count) {
        self.curLevel = [_levels objectAtIndex:_curLevelIndex];
    }

}

- (void) dealloc {
    _sharedState = nil;
    [super dealloc];
}

@end
