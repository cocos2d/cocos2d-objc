//
//  Level.h
//  TomTheTurret
//
//  Created by Ray Wenderlich on 3/24/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Level : NSObject {

}

@end

@interface StoryLevel : Level {

    NSMutableArray *_storyStrings;
    BOOL _isGameOver;

}

@property (nonatomic, retain) NSMutableArray *storyStrings;
@property (nonatomic, assign) BOOL isGameOver;

@end

@interface ActionLevel : Level {

    float _spawnSeconds;
    float _spawnRate;
    NSMutableArray *_spawnIds;
    BOOL _isFinalLevel;

}

@property (nonatomic, assign) float spawnSeconds;
@property (nonatomic, assign) float spawnRate;
@property (nonatomic, retain) NSMutableArray *spawnIds;
@property (nonatomic, assign) BOOL isFinalLevel;

@end
