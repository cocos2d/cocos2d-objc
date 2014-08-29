//
//  HeadlessActivity.m
//  Headless
//
//  Created by Philippe Hausler on 7/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "HeadlessActivity.h"
#import "MainMenu.h"

@implementation HeadlessActivity

- (void)setupPaths
{
    [super setupPaths];
    CCFileUtils* sharedFileUtils = [CCFileUtils sharedFileUtils];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    sharedFileUtils.searchPath = @[
                                   [resourcePath stringByAppendingPathComponent:@"Images"],
                                   [resourcePath stringByAppendingPathComponent:@"Fonts"],
                                   [resourcePath stringByAppendingPathComponent:@"Resources-shared"],
                                   resourcePath
                                   ];
    
    // Register spritesheets.
    CCSpriteFrameCache *spriteFrameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [spriteFrameCache registerSpriteFramesFile:@"Interface.plist"];
    [spriteFrameCache registerSpriteFramesFile:@"Sprites.plist"];
    [spriteFrameCache registerSpriteFramesFile:@"TilesAtlassed.plist"];
}


- (CCScene *)startScene
{
    return [MainMenu scene];
}

- (BOOL)onKeyUp:(int32_t)keyCode keyEvent:(AndroidKeyEvent *)event
{
    if ([[CCDirector sharedDirector] runningScene] == [self startScene])
    {
        [self finish];
        return NO;
    }
    
    [self runOnGameThread:^{
        CCTransition* transition = [CCTransition transitionMoveInWithDirection:CCTransitionDirectionRight duration:0.3];
        [[CCDirector sharedDirector] replaceScene:[MainMenu scene] withTransition:transition];
    }];
    
    return YES;
}

@end
