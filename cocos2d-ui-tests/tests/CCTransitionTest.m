//
//  CCTransitionTest.m
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 10/16/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "CCTransitionTest.h"

@implementation CCTransitionTest

- (NSArray*) testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupCrossFadeTest",
            @"setupFadeWithColorTest",
            // TODO: Fix all tests
            nil];
}

- (void) setupCrossFadeTest
{
    self.subTitle = @"Cross fade";
    _nextTransition = [CCTransition transitionCrossFadeWithDuration:1];
    
    CCLayerColor* bgLayer = [CCLayerColor layerWithColor:ccc4(255, 0, 0, 255)];
    bgLayer.contentSize = CGSizeMake(1, 1);
    bgLayer.contentSizeType = CCContentSizeTypeNormalized;
    [self.contentNode addChild:bgLayer];
}

- (void) setupFadeWithColorTest
{
    self.subTitle = @"Fade with Color";
    _nextTransition = [CCTransition transitionFadeWithColor:ccc3(0, 0, 0) duration:1];
    
    CCLayerColor* bgLayer = [CCLayerColor layerWithColor:ccc4(0, 255, 0, 255)];
    bgLayer.contentSize = CGSizeMake(1, 1);
    bgLayer.contentSizeType = CCContentSizeTypeNormalized;
    [self.contentNode addChild:bgLayer];
}

// Overridden methods to support transitions

- (void)  pressedNext:(id)sender
{
    NSInteger newTest = _currentTest + 1;
    if (newTest >= self.testConstructors.count) newTest = 0;
    
    CCScene* testScene = [TestBase sceneWithTestName:self.testName];
    [[[testScene children] objectAtIndex:0] setupTestWithIndex:newTest];
    
    [[CCDirector sharedDirector] replaceScene:testScene withTransition:_nextTransition];
}

@end
