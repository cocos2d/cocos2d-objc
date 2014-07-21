//
//  ObjectALTest.m
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 11/11/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "TestBase.h"
#import "OALSimpleAudio.h"

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
    btn.position = ccp(0.5, 0.5);
    [btn setTarget:self selector:@selector(playSimpleSound:)];
    
    [self.contentNode addChild:btn];
}

- (void) playSimpleSound:(id)sender
{
    [[OALSimpleAudio sharedInstance] playEffect:@"Sounds/sound.wav"];
}

@end
