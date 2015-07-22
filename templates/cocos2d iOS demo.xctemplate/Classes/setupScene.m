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

#import "SetupScene.h"
#import "cocos2d-ui.h"
#import "GameTypes.h"

// -----------------------------------------------------------------

@implementation SetupScene
{
    CCSlider *_soundVolume;
    CCSlider *_musicVolume;
}

// -----------------------------------------------------------------

- (instancetype)init
{
    self = [super init];
    
    _soundVolume = [[CCSlider alloc] initWithBackground:[CCSpriteFrame frameWithImageNamed:@"slider.png"]
                                         andHandleImage:[CCSpriteFrame frameWithImageNamed:@"handle.png"]];
    _soundVolume.positionType = CCPositionTypeNormalized;
    _soundVolume.position = (CGPoint){0.5, 0.6};
    _soundVolume.anchorPoint = (CGPoint){0.5, 0.5};
    _soundVolume.endStop = kGameSliderEndStop;
    [self addChild:_soundVolume];
    
    CCLabelTTF *soundLabel = [CCLabelTTF labelWithString:@"Sound Volume" fontName:@"ArialMT" fontSize:32];
    soundLabel.positionType = CCPositionTypeNormalized;
    soundLabel.position = (CGPoint){0.5, 0.55};
    soundLabel.fontColor = [CCColor colorWithRed:1.00 green:0.65 blue:0.00];
    [self addChild:soundLabel];

    _musicVolume = [[CCSlider alloc] initWithBackground:[CCSpriteFrame frameWithImageNamed:@"slider.png"]
                                         andHandleImage:[CCSpriteFrame frameWithImageNamed:@"handle.png"]];
    _musicVolume.positionType = CCPositionTypeNormalized;
    _musicVolume.position = (CGPoint){0.5, 0.4};
    _musicVolume.anchorPoint = (CGPoint){0.5, 0.5};
    _musicVolume.endStop = kGameSliderEndStop;
    [self addChild:_musicVolume];
    
    CCLabelTTF *musicLabel = [CCLabelTTF labelWithString:@"Music Volume" fontName:@"ArialMT" fontSize:32];
    musicLabel.positionType = CCPositionTypeNormalized;
    musicLabel.position = (CGPoint){0.5, 0.35};
    musicLabel.fontColor = [CCColor colorWithRed:1.00 green:0.65 blue:0.00];
    [self addChild:musicLabel];

    [self validateSetup];
    
    // load setup
    NSUserDefaults *setup = [NSUserDefaults standardUserDefaults];
    _soundVolume.sliderValue = [setup floatForKey:kGameKeySoundVolume];
    _musicVolume.sliderValue = [setup floatForKey:kGameKeyMusicVolume];

    // Ze back button ...
    CCButton *back = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"back.png"]];
    back.positionType = CCPositionTypeNormalized;
    back.position = (CGPoint){0.5,0.1};
    [back setBlock:^(id sender)
     {
         [[CCDirector sharedDirector] popSceneWithTransition:[CCTransition transitionRevealWithDirection:CCTransitionDirectionDown
                                                                                                duration:0.5]];
     }];
    [self addChild:back];

    return self;
}

// -----------------------------------------------------------------

- (void)validateSetup
{
    // makes sure there is a valid setup
    NSUserDefaults *setup = [NSUserDefaults standardUserDefaults];
    // make sure keys exist
    if ([setup objectForKey:kGameKeySoundVolume] == nil) [setup setFloat:1.0 forKey:kGameKeySoundVolume];
    if ([setup objectForKey:kGameKeyMusicVolume] == nil) [setup setFloat:1.0 forKey:kGameKeyMusicVolume];
    [setup synchronize];
}

// -----------------------------------------------------------------

- (void)dealloc
{
    // save setup on exit
    NSUserDefaults *setup = [NSUserDefaults standardUserDefaults];
    [setup setFloat:_soundVolume.sliderValue forKey:kGameKeySoundVolume];
    [setup setFloat:_musicVolume.sliderValue forKey:kGameKeyMusicVolume];
}

// -----------------------------------------------------------------

@end





