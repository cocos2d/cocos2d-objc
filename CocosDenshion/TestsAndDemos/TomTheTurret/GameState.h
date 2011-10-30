//
//  GameState.h
//  TomTheTurret
//
//  Created by Ray Wenderlich on 3/24/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "cocos2d.h"

@class Level;

@interface GameState : NSObject {
    // Level pointer
    Level *_curLevel;

    // Normal levels
    NSMutableArray *_levels;
    int _curLevelIndex;

    // Special levels
    Level *_killEnding;
    Level *_suicideEnding;
    Level *_loseEnding;
}

@property (nonatomic, retain) NSMutableArray *levels;
@property (nonatomic, assign) int curLevelIndex;
@property (nonatomic, retain) Level *curLevel;
@property (nonatomic, retain) Level *killEnding;
@property (nonatomic, retain) Level *suicideEnding;
@property (nonatomic, retain) Level *loseEnding;

- (void)reset;
- (void)nextLevel;
+ (GameState *)sharedState;

@end
