//
//  Level.m
//  TomTheTurret
//
//  Created by Ray Wenderlich on 3/24/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "Level.h"

@implementation Level

@end

@implementation StoryLevel
@synthesize storyStrings = _storyStrings;
@synthesize isGameOver = _isGameOver;

- (id)init {
    if ((self = [super init])) {
        self.storyStrings = [[[NSMutableArray alloc] init] autorelease];
    }
    return self;
}

- (void) dealloc
{
    self.storyStrings = nil;
    [super dealloc];
}

@end

@implementation ActionLevel
@synthesize spawnSeconds = _spawnSeconds;
@synthesize spawnRate = _spawnRate;
@synthesize spawnIds = _spawnIds;
@synthesize isFinalLevel = _isFinalLevel;

- (id)init {
    if ((self = [super init])) {
        self.spawnIds = [[[NSMutableArray alloc] init] autorelease];
    }
    return self;
}

- (void) dealloc
{
    self.spawnIds = nil;
    [super dealloc];
}

@end
