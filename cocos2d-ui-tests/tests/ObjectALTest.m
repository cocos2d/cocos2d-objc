//
//  ObjectALTest.m
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 11/11/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "ObjectALTest.h"
#import "OALSimpleAudio.h"

@implementation ObjectALTest

- (NSArray*) testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupSimpleAudioTest",
            nil];
}

- (void) setupSimpleAudioTest
{
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
