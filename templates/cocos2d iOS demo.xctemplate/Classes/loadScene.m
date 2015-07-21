//
//  ___FILENAME___
//
//  Created by : ___FULLUSERNAME___
//  Project    : ___PROJECTNAME___
//  Date       : ___DATE___
//
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___.
//  All rights reserved.
//
// -----------------------------------------------------------------

#import "LoadScene.h"
#import "MainScene.h"

// -----------------------------------------------------------------------

@implementation LoadScene

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    
    // The thing is, that if this fails, your app will 99.99% crash anyways, so why bother
    // Just make an assert, so that you can catch it in debug
    NSAssert(self, @"Whoops");
    
    // background
    CCSprite9Slice *background = [CCSprite9Slice spriteWithImageNamed:@"white_square.png"];
    background.anchorPoint = CGPointZero;
    background.contentSize = [CCDirector sharedDirector].viewSize;
    background.color = [CCColor grayColor];
    [self addChild:background];
    
    // loading text
    CCSprite *loading = [CCSprite spriteWithImageNamed:@"loading.png"];
    loading.positionType = CCPositionTypeNormalized;
    loading.position = (CGPoint){0.5, 0.5};
    [self addChild:loading];
    
    // progress indicator
    CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:@"progress.png"]];
    progress.positionType = CCPositionTypeNormalized;
    progress.position = (CGPoint){0.5, 0.5};
    progress.type = CCProgressNodeTypeRadial;
    progress.rotation = 180;
    progress.percentage = 0;
    [self addChild:progress];
    
    // run percentage
    [progress runAction:[CCActionSequence actions:
                         [CCActionTween actionWithDuration:2 key:@"percentage" from:0 to:100],
                         [CCActionCallBlock actionWithBlock:^(void)
                          {
                              [progress runAction:[CCActionEaseOut actionWithAction:[CCActionFadeOut actionWithDuration:1.0] rate:2.0]];
                              [progress runAction:[CCActionEaseOut actionWithAction:[CCActionScaleTo actionWithDuration:1.0 scale:5.0] rate:2.0]];
                              [loading runAction:[CCActionFadeOut actionWithDuration:1.0]];
                          }],
                         [CCActionDelay actionWithDuration:1.5], // here we wait for scale and fade to complete
                         [CCActionCallBlock actionWithBlock:^(void)
                          {
                              [[CCDirector sharedDirector] replaceScene:[MainScene new]
                                                         withTransition:[CCTransition transitionRevealWithDirection:CCTransitionDirectionLeft duration:0.5]];
                          }],
                         nil]];
    
    // enable touch handing
    self.userInteractionEnabled = YES;
    
    // done
	return self;
}

// -----------------------------------------------------------------------

@end























// why not add a few extra lines, so we dont have to sit and edit at the bottom of the screen ...
