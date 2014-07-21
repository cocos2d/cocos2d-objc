//
//  CCSprite9SliceTest.m
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 10/23/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "TestBase.h"

@interface CCSprite9SliceTest : TestBase @end

@implementation CCSprite9SliceTest

- (NSArray*) testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupSprite9SliceBasicTest",
            nil];
}

- (void) setupSprite9SliceBasicTest
{
    self.subTitle = @"The two rounded rects should have the same size.";
    
    CCSprite9Slice* sprite0 = [CCSprite9Slice spriteWithImageNamed:@"Interface/textfield-bg.png"];
    sprite0.positionType = CCPositionTypeNormalized;
    sprite0.position = ccp(0.5, 0.4);
    sprite0.contentSize = CGSizeMake(240, 40);
    [self.contentNode addChild:sprite0];
    
    CCSprite9Slice* sprite1 = [CCSprite9Slice spriteWithImageNamed:@"Tests/textfield-bg.png"];
    sprite1.positionType = CCPositionTypeNormalized;
    sprite1.position = ccp(0.5, 0.6);
    sprite1.contentSize = CGSizeMake(240, 40);
    [self.contentNode addChild:sprite1];
    
    
}

@end
