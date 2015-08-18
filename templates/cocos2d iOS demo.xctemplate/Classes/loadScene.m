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
#import "GameTypes.h"

// -----------------------------------------------------------------------

@implementation LoadScene
{
    CCProgressNode *_progress;
    CCSprite *_loading;
    int _loadStep;
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    
    // The thing is, that if this fails, your app will 99.99% crash anyways, so why bother
    // Just make an assert, so that you can catch it in debug
    NSAssert(self, @"Whoops");

    // preload artwork needed for load scene
    // NOTE!
    // In this case, this is also the artwork for the entire app, but in real life this would probably not be the case
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"demo.plist"];
    
    // get screen dimensions
    CGSize size = [CCDirector sharedDirector].viewSize;

    // background
    CCSprite9Slice *background = [CCSprite9Slice spriteWithImageNamed:@"white_square.png"];
    background.anchorPoint = CGPointZero;
    background.position = CGPointZero;
    background.contentSize = size;
    background.color = kGameLoadSceneColor;
    [self addChild:background];
    
    // loading text
    _loading = [CCSprite spriteWithImageNamed:@"loading.png"];
    _loading.positionType = CCPositionTypeNormalized;
    _loading.position = (CGPoint){0.5, 0.5};
    [self addChild:_loading];
    
    // progress indicator
    _progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:@"progress.png"]];
    _progress.positionType = CCPositionTypeNormalized;
    _progress.position = (CGPoint){0.5, 0.5};
    _progress.type = CCProgressNodeTypeRadial;
    _progress.rotation = 180;
    _progress.percentage = 0;
    [self addChild:_progress];
    
    // load progress
    _loadStep = 0;
    [self schedule:@selector(loadNext:) interval:0.033];
    
    // done
	return self;
}

// -----------------------------------------------------------------------

- (void)loadNext:(CCTime)delta
{
    switch (_loadStep)
    {
        case 0:
        {
            // load ex textures here
            // our loading doesnt take time, so we add a small delay to simulate "real" loading
            usleep(500000);

            // We already loaded this, because the load scene needs it, but just to demonstrate ...
            // There is no memory penalty from loading it twice
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"demo.plist"];

            _progress.percentage = 40;
            break;
        }
        case 1:
        {
            // load ex audio here
            usleep(500000);
            
            [[OALSimpleAudio sharedInstance] preloadEffect:@"beep.wav"];
            [[OALSimpleAudio sharedInstance] preloadEffect:@"game.wav"];
            
            _progress.percentage = 50;
            break;
        }
        case 2:
        {
            // load animations, shaders etc
            usleep(500000);
            _progress.percentage = 60;
            break;
        }
        case 3:
        {
            // pre render stuff
            usleep(500000);
            _progress.percentage = 90;
            break;
        }
        default:
        {
            // done
            _progress.percentage = 100;
            [self unschedule:@selector(loadNext:)];
            
            // Show some fancy animation.
            // Why, do you ask? Well, because we can.
            [_progress runAction:[CCActionSequence actions:
                                  [CCActionCallBlock actionWithBlock:^(void)
                                   {
                                       [_progress runAction:[CCActionEaseOut actionWithAction:[CCActionFadeOut actionWithDuration:1.0] rate:2.0]];
                                       [_progress runAction:[CCActionEaseOut actionWithAction:[CCActionScaleTo actionWithDuration:1.0 scale:5.0] rate:2.0]];
                                       [_loading runAction:[CCActionFadeOut actionWithDuration:1.0]];
                                   }],
                                  [CCActionDelay actionWithDuration:1.5], // here we wait for scale and fade to complete
                                  [CCActionCallBlock actionWithBlock:^(void)
                                   {
                                       [[CCDirector sharedDirector] replaceScene:[MainScene new]
                                                                  withTransition:[CCTransition transitionRevealWithDirection:CCTransitionDirectionLeft duration:0.5]];
                                   }],
                                  nil]];
            break;
        }
    }
    
    // next step
    _loadStep ++;
}

// -----------------------------------------------------------------------

@end























// why not add a few extra lines, so we dont have to sit and edit at the bottom of the screen ...
