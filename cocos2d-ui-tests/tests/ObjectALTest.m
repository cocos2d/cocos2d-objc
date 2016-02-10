//
//  ObjectALTest.m
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 11/11/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "TestBase.h"
#import "CCOAL.h"

@interface ObjectALTest : TestBase @end

@implementation ObjectALTest

- (NSArray*) testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupSimpleAudioTest",
            nil];
}

- (void) setupSimpleAudioTest
{
    self.subTitle = @"Test playback of sound effect.";
    
    CCButton* btn = [CCButton buttonWithTitle:@"Play Sound"];
    btn.positionType = CCPositionTypeNormalized;
    btn.position = ccp(0.4, 0.5);
    [btn setTarget:self selector:@selector(playSimpleSound:)];
    
    [self.contentNode addChild:btn];
    
    CCButton* btn2 = [CCButton buttonWithTitle:@"Play Music"];
    btn2.positionType = CCPositionTypeNormalized;
    btn2.position = ccp(0.6, 0.6);
    [btn2 setTarget:self selector:@selector(playLoopingMusic:)];
    
    [self.contentNode addChild:btn2];
    
    CCButton* btn3 = [CCButton buttonWithTitle:@"Stop Music"];
    btn3.positionType = CCPositionTypeNormalized;
    btn3.position = ccp(0.6, 0.4);
    [btn3 setTarget:self selector:@selector(stopLoopingMusic:)];
    
    [self.contentNode addChild:btn3];
    
}

- (void) playSimpleSound:(id)sender
{
#if ANDROID
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/sound.ogg"];
#else
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/sound.wav"];
#endif
}


- (void) playLoopingMusic:(id)sender
{
    [[OALSimpleAudio sharedInstance] playBg:@"Music/CIRCUS.mp3" loop:YES];
}

- (void) stopLoopingMusic:(id)sender
{
    [[OALSimpleAudio sharedInstance] stopBg];
}

@end
